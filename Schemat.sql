--create database Wypozyczalnia

use Wypozyczalnia
go

/*
drop table Klient
drop table Wypozyczenie
drop table Sprzet
drop table Magazyn
drop table Miasta
drop table Pracownik
drop table Stanowisko
*/

create table Klient(
ID_Klient varchar(5) constraint ID_Klient_KL_NN not null,
Imie varchar(20),
Nazwisko varchar(20),
Adres varchar(50),
constraint ID_Klient_Kl_Check check (ID_Klient like 'KL[0-9][0-9][0-9]'),
constraint Imie_Kl_Check check (Imie not like '%[^A-Z]%'),
constraint Nazwisko_Kl_Check check (Nazwisko not like '%[^A-Z]%')
)

alter table Klient
add constraint pk_id_klient primary key(ID_Klient) 

create table Wypozyczenie(
ID_Wypozyczenie varchar(5) constraint ID_Wypozyczenie_WYP_NN not null,
ID_Sprzet varchar(5),
ID_Klient varchar(5),
Od_kiedy smalldatetime,
Do_kiedy smalldatetime,
constraint ID_Wypozyczenie_Wyp_Check check (ID_Wypozyczenie like 'WY[0-9][0-9][0-9]'),
constraint ID_Sprzet_Wyp_Check check (ID_Sprzet like 'SP[0-9][0-9][0-9]'),
constraint ID_Klient_Wyp_Check check (ID_Klient like 'KL[0-9][0-9][0-9]'),
constraint Od_kiedy_Check check (Od_kiedy > '2017/01/01'),
)

alter table Wypozyczenie
add constraint pk_id_wypozyczenie primary key(ID_Wypozyczenie)

create table Sprzet(
ID_Sprzet varchar(5) constraint ID_Sprzet_SP_NN not null,
ID_Magazyn varchar(5) constraint ID_Magazyn_SP_NN not null,
Nazwa varchar(20),
CenaZaDobe decimal(10,2),
Stan varchar(20),
constraint ID_Sprzet_Sp_Check check (ID_Sprzet like 'SP[0-9][0-9][0-9]'),
constraint ID_Magazyn_Sp_Check check (ID_Magazyn like 'MA[0-9][0-9][0-9]'),
constraint CenaZaDobe_Sp_Check check (CenaZaDobe > 0.0 and CenaZaDobe < 50.0),
constraint Stan_Sp_Check check (Stan like 'Na magazynie' or Stan like 'Wypozyczony' or Stan like 'Zepsuty')
)

alter table Sprzet
add constraint pk_id_sprzet primary key(ID_Sprzet)

create table Magazyn(
ID_Magazyn varchar(5) constraint ID_Magazyn_MA_NN not null,
ID_Miasto char(3),
Nazwa_Magazynu varchar(50),
constraint ID_Magazyn_Mg_Check check (ID_Magazyn like 'MA[0-9][0-9][0-9]'),
constraint ID_Miasto_Mg_Check check (ID_Miasto like '[A-Z][A-Z][A-Z]')
)

alter table Magazyn
add constraint pk_id_magazyn primary key(ID_Magazyn)

create table Miasta(
ID_Miasto char(3) constraint ID_Miasto_MI_NN not null,
Miasto varchar(20),
constraint ID_Miasto_Mi_Check check (ID_Miasto like '[A-Z][A-Z][A-Z]')
)

alter table Miasta
add constraint pk_id_miasto primary key(ID_Miasto)

create table Pracownik(
ID_Pracownik varchar(5) constraint ID_Pracownik_PR_NN not null,
ID_Stanowisko varchar(5),
ID_Magazyn varchar(5),
Imie varchar(20),
Nazwisko varchar(20),
Adres varchar(50),
constraint ID_Pracownik_Pr_Check check (ID_Pracownik like 'PR[0-9][0-9][0-9]'),
constraint ID_Stanowisko_Pr_Check check (ID_Stanowisko like 'ST[0-9][0-9][0-9]'),
constraint ID_Magazyn_Pr_Check check (ID_Magazyn like 'MA[0-9][0-9][0-9]'),
constraint Imie_Pr_Check check (Imie not like '%[^A-Z]%'),
constraint Nazwisko_Pr_Check check (Nazwisko not like '%[^A-Z]%')
)

alter table Pracownik
add constraint pk_id_pracownik primary key(ID_Pracownik)

create table Stanowisko(
ID_Stanowisko varchar(5) constraint ID_Stanowisko_ST_NN not null,
Nazwa_Stanowiska varchar(20),
Wynagrodzenie decimal(10,2),
constraint ID_Stanowisko_St_Check check (ID_Stanowisko like 'ST[0-9][0-9][0-9]'),
constraint Nazwa_Stanowiska_St_Check check (Nazwa_Stanowiska not like '%[^A-Z]%'),
)

alter table Stanowisko
add constraint pk_id_stanowisko primary key(ID_Stanowisko)

alter table Wypozyczenie
add foreign key (ID_Sprzet) references Sprzet(ID_Sprzet)

alter table Wypozyczenie
add foreign key (ID_Klient) references Klient(ID_Klient)

alter table Sprzet
add foreign key (ID_Magazyn) references Magazyn(ID_Magazyn)

alter table Magazyn
add foreign key (ID_Miasto) references Miasta(ID_Miasto)

alter table Pracownik
add foreign key (ID_Magazyn) references Magazyn(ID_Magazyn)

alter table Pracownik
add foreign key (ID_Stanowisko) references Stanowisko(ID_Stanowisko)
