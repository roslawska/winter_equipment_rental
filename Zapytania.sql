use Wypozyczalnia

--1. Adresy magazynow, w ktorych znajduje sie snowboard
select distinct Nazwa_Magazynu from Magazyn, Sprzet
where Magazyn.ID_Magazyn=Sprzet.ID_Magazyn and Nazwa = 'Snowboard'

--2. Ile wypozyczen sprzetu dokonali klienci
select distinct Imie, Nazwisko, count(*) as Ilosc_Wypozyczen from Klient, Wypozyczenie
where Klient.ID_Klient=Wypozyczenie.ID_Klient
group by Imie, Nazwisko

--3. Ile sprzetu znajduje siê w kazdym magazynie
select distinct Nazwa_Magazynu, count(*) as Ilosc_sprzetu from Magazyn, Sprzet
where Magazyn.ID_Magazyn=Sprzet.ID_Magazyn
group by Nazwa_Magazynu

--4. Ile poszczegolnych sprzetow znajduje sie w calej wypozyczalni
select distinct Nazwa, count(*) as Ilosc_sprzetu from Sprzet
group by Nazwa

--5. Ktorzy klienci nie dokonali wypozyczen
select ID_Klient, Imie, Nazwisko from Klient
where not exists (select ID_Klient from Wypozyczenie where Klient.ID_Klient = Wypozyczenie.ID_Klient)

--6. Ile magazynow znajduje sie w poszczegolnych miastach
select Miasto, count(*) as Ilosc_Magazynow from Miasta, Magazyn
where Magazyn.ID_Miasto=Miasta.ID_Miasto
group by Miasto

--7. Ilu pracownikow na poszczegolnych stanowiskach zastrudnia firma
select Nazwa_Stanowiska, count(*) as Ilosc_Zatrudnionych from Pracownik, Stanowisko
where Pracownik.ID_Stanowisko=Stanowisko.ID_Stanowisko
group by Nazwa_Stanowiska

--8. Ile kosztuje miesieczne  oraz roczne utrzymanie pracownikow
select Nazwa_Stanowiska, count(*)*Wynagrodzenie as Miesieczne_Wynagrodzenie, count(*)*Wynagrodzenie*12 as Roczne_Wynagrodzenie
from Pracownik, Stanowisko
where Pracownik.ID_Stanowisko=Stanowisko.ID_Stanowisko
group by Nazwa_Stanowiska, Wynagrodzenie

--9. Jakie sprzety sa aktualnie zepsute
select ID_sprzet, Nazwa from Sprzet where Stan = 'Zepsuty'

--10. Ile wynosi srednia cena pojedynczego sprzetu w kazdym magazynie, ktory jest na magazynie
select Nazwa_Magazynu, avg(CenaZaDobe) as Srednia_Cena from Magazyn, Sprzet
where Stan = 'Na magazynie' and Magazyn.ID_Magazyn=Sprzet.ID_Magazyn
group by Nazwa_Magazynu

--11. Ktorzy klienci posiadaja nieoddany sprzet
select Imie, Nazwisko, Nazwa from Klient, Wypozyczenie, Sprzet
where Klient.ID_Klient=Wypozyczenie.ID_Klient and Wypozyczenie.ID_Sprzet=Sprzet.ID_Sprzet and Do_kiedy is null
group by Imie, Nazwisko, Nazwa

--12. Ktory sprzet jest najdrozszy i ile kosztuje
select Nazwa, CenaZaDobe from Sprzet
where (select max(CenaZaDobe) from Sprzet)=CenaZaDobe
group by Nazwa, CenaZaDobe

--13. Ktory sprzet jest najtanszy i w ktorym znajduje sie magazynie
select Nazwa, Nazwa_Magazynu from Sprzet, Magazyn
where Sprzet.ID_magazyn=Magazyn.ID_Magazyn and (select min(CenaZaDobe) from Sprzet)=CenaZaDobe
group by Nazwa, Nazwa_Magazynu

--14. Ile wynosilby dzienny zarobek wypozyczalni, gdyby kazdy sprzet zostal wypozyczony
select sum(CenaZaDobe) as Laczny_Mozliwy_Dzienny_Zarobek from Sprzet
where Stan='Na magazynie' 

--15. Ile trwalo i ile kosztowa³o kazde zakonczone wypozyczenie sprzetu
select ID_Wypozyczenie, datediff(day, Od_kiedy,Do_kiedy) as Liczba_Dni, datediff(day, Od_kiedy,Do_kiedy)*CenaZaDobe as Oplata_Za_Wypozyczenie
from Wypozyczenie, Sprzet
where Do_kiedy is not null and Wypozyczenie.ID_Sprzet=Sprzet.ID_Sprzet

--Funkcja obliczajaca koszty wypozyczen klienta za dany miesiac
--drop function PodliczKlienta
create function PodliczKlienta(
@IDKlient varchar(5),
@miesiac int,
@rok int
)
returns decimal(10,2)
as begin
	declare @suma decimal(10,2)=1.0
	set @suma = (select sum(datediff(day, Od_kiedy,Do_kiedy)*CenaZaDobe) 
		from Wypozyczenie, Sprzet 
		where Do_kiedy is not null 
		and Wypozyczenie.ID_Sprzet=Sprzet.ID_Sprzet 
		and Wypozyczenie.ID_Klient = @IDKlient
		and year(Do_kiedy) = @rok
		and month(Do_kiedy) = @miesiac) 
	return @suma
end

--Wywolanie funkcji
begin
declare @ile decimal(10,2)
set @ile = dbo.PodliczKlienta('KL009',01,2019)
print cast(@ile as varchar(10))
end

--Procedura tworzaca nowego klienta w bazie
--drop procedure Nowy_Klient
create procedure Nowy_Klient(
	@imie varchar(20),
	@nazwisko varchar(20),
	@adres varchar(50)
)
as
begin
	declare @numer varchar(5) = 'KL001'
	declare @increment int = convert(varchar,convert(int,substring(@numer,3,3)))
	while(@numer in (select ID_Klient from Klient))
		begin
			set @increment = @increment +1
			set @numer = 'KL'+ substring('000',1,3-len(convert(varchar,@increment))) + convert(varchar,@increment)
		end
	insert into Klient values (@numer,@imie,@nazwisko,@adres)
end

--Bledne wywolanie procedury, za malo argumentow
--exec Nowy_Klient 'Jan', 'Kowalski'

--Przyklad poprawnego wywolania procedury Nowy_klient
exec Nowy_Klient 'Jan', 'Kowalski', 'Trudna 76/3'

--Poprawne wywolanie, ale imie moze zawierac jedynie litery, wiec rekord nie zostanie dodany do bazy
exec Nowy_Klient '32', 'Kowalski', 'Trudna 76/3'

--Procedura dzieki ktorej mozemy usunac pracownika z bazy
--drop procedure Usun_Pracownika
create procedure Usun_Pracownika(
	@imie varchar(20),
	@nazwisko varchar(20)
)
as
delete from Pracownik where Imie=@imie and Nazwisko=@nazwisko

--Bledne wywolanie procedury, za malo argumentow
--exec Usun_Pracownika 'Lena'

--Wywolanie procedury usuwajacej pracownika
exec Usun_Pracownika 'Lena', 'Nowak'

--Procedura, ktora uaktualnia stan sprzetu w magazynie
--drop procedure Uaktualnij_Stan_Sprzetu
create procedure Uaktualnij_Stan_Sprzetu(
	@id_sprzetu varchar(5),
	@stan varchar(20)
)
as
begin
	if (@id_sprzetu in (select ID_Sprzet from Sprzet))
	begin
		if (@stan = 'Wypozyczony' or @stan = 'Na magazynie' or @stan = 'Zepsuty')
		begin
		update Sprzet 
		set Stan = @stan where ID_Sprzet=@id_sprzetu
		print 'Zmieniono status sprzetu ' + @id_sprzetu + ' na ' + @stan
		end
		else print 'Podano bledny status sprzetu'
	end
	else print 'Nie znaleziono podanego sprzetu'
end

--Bledne wywolanie procedury, za malo argumentow
--exec Uaktualnij_Stan_Sprzetu 'SP091'

--Przyklad wywolania procedury, wynikiem bedzie informacja ze podany sprzet nie znadjuje sie na magazynie
exec Uaktualnij_Stan_Sprzetu 'SP091', 'Wypozyczony'

--Przyklad wywolania procedury, gdy stan sprzetu nie jest poprawny
exec Uaktualnij_Stan_Sprzetu 'SP001', 'Zagubiony'

--Przyklad prawidlowego wywolania procedury
exec Uaktualnij_Stan_Sprzetu 'SP001', 'Wypozyczony'

--Procedura umozliwiajaca wypozyczenie sprzetu przez klienta
--drop procedure Wypozycz
create procedure Wypozycz(
	@id_sprzetu varchar(5),
	@id_klient varchar(5),
	@od_kiedy smalldatetime
)
as
begin
	if(@id_klient in (select ID_Klient from Klient))
	begin 
		if(@id_sprzetu in (select ID_Sprzet from Sprzet where Stan='Na magazynie'))
			begin
			declare @numer varchar(5) = 'WY001'
			declare @increment int = convert(varchar,convert(int,substring(@numer,3,3)))
			while(@numer in (select ID_Wypozyczenie from Wypozyczenie))
				begin
					set @increment = @increment +1
					set @numer = 'WY'+ substring('000',1,3-len(convert(varchar,@increment))) + convert(varchar,@increment)
				end
			insert into Wypozyczenie values (@numer,@id_sprzetu,@id_klient,@od_kiedy, NULL)
			update Sprzet
			set Stan = 'Wypozyczony' where ID_Sprzet=@id_sprzetu
		end
		else print 'Sprzet nie znajduje sie na magazynie'
	end
	else print 'Klient nie istnieje'
end

--Bledne wywolanie procedury, za malo argumentow
--exec Wypozycz 'SP023', 'KL002'

--Prawidlowe wywolanie procedury, lecz sprzet nie jest na magazynie, wypozyczenie nie zostanie zrealizowane
exec Wypozycz 'SP023', 'KL002', '2019-12-01'

--Prawidlowe wywolanie procedury, lecz klient nie istnieje, wypozyczenie nie zostanie zrealizowane
exec Wypozycz 'SP024', 'KL032', '2019-12-01'

--Prawidlowe wywolanie procedury
exec Wypozycz 'SP004', 'KL002', '2019-12-01'

select * from Klient
select * from Wypozyczenie
select * from Sprzet
select * from Magazyn
select * from Miasta
select * from Pracownik
select * from Stanowisko
