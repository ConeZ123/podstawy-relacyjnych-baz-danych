CREATE DATABASE Biblioteka;
GO
USE Biblioteka;
GO

-- Tabela przechowująca autorów
IF NOT EXISTS (SELECT 1 FROM [INFORMATION_SCHEMA].[TABLES] WHERE TABLE_NAME = 'Autorzy')
CREATE TABLE Autorzy (
    AutorID INT IDENTITY(1,1) PRIMARY KEY,
    Imie NVARCHAR(100) NOT NULL,
    Nazwisko NVARCHAR(100) NOT NULL,
    DataUrodzenia DATE,
    Opis NVARCHAR(500),
    AuditUser INT NOT NULL,
    FOREIGN KEY (AuditUser) REFERENCES Uzytkownicy(UzytkownikID)
);

-- Tabela przechowująca książki
IF NOT EXISTS (SELECT 1 FROM [INFORMATION_SCHEMA].[TABLES] WHERE TABLE_NAME = 'Ksiazki')
CREATE TABLE Ksiazki (
    KsiazkaID INT IDENTITY(1,1) PRIMARY KEY,
    Tytul NVARCHAR(255) NOT NULL,
    Wydawca NVARCHAR(100),
    RokWydania INT NOT NULL,
    Gatunek NVARCHAR(100) NOT NULL,
    Okladka NVARCHAR(100) NOT NULL,
    Dostepna BIT NOT NULL,
    ISBN NVARCHAR(20) UNIQUE NOT NULL,
    Status BIT NOT NULL,
    AuditUser INT NOT NULL,
    FOREIGN KEY (AuditUser) REFERENCES Uzytkownicy(UzytkownikID)
);

-- Relacja wiele-do-wielu między książkami a autorami
IF NOT EXISTS (SELECT 1 FROM [INFORMATION_SCHEMA].[TABLES] WHERE TABLE_NAME = 'AutorKsiazki')
CREATE TABLE AutorKsiazki (
    AutorID INT NOT NULL,
    KsiazkaID INT NOT NULL,
    AuditUser INT NOT NULL,
    PRIMARY KEY (AutorID, KsiazkaID),
    FOREIGN KEY (AutorID) REFERENCES Autorzy(AutorID) ON DELETE CASCADE,
    FOREIGN KEY (KsiazkaID) REFERENCES Ksiazki(KsiazkaID) ON DELETE CASCADE,
    FOREIGN KEY (AuditUser) REFERENCES Uzytkownicy(UzytkownikID)
);

-- Tabela przechowująca użytkowników systemu (pracowników)
IF NOT EXISTS (SELECT 1 FROM [INFORMATION_SCHEMA].[TABLES] WHERE TABLE_NAME = 'Uzytkownicy')
CREATE TABLE Uzytkownicy (
    UzytkownikID INT IDENTITY(1,1) PRIMARY KEY,
    NazwaUzytkownika NVARCHAR(100) UNIQUE NOT NULL,
    HasloHash NVARCHAR(255) NOT NULL,
    Rola NVARCHAR(50) CHECK (Rola IN ('Admin', 'Bibliotekarz')) NOT NULL,
    AuditUser INT NOT NULL
);

-- Tabela przechowująca czytelników
IF NOT EXISTS (SELECT 1 FROM [INFORMATION_SCHEMA].[TABLES] WHERE TABLE_NAME = 'Czytelnicy')
CREATE TABLE Czytelnicy (
    CzytelnikID INT IDENTITY(1,1) PRIMARY KEY,
    Imie NVARCHAR(100) NOT NULL,
    Nazwisko NVARCHAR(100) NOT NULL,
    DataUrodzenia DATE,
    Email NVARCHAR(255) UNIQUE NOT NULL,
    PESEL NVARCHAR(11) NOT NULL CHECK (LEN(PESEL) = 11 AND PESEL NOT LIKE '%[^0-9]%'),
    NumerTelefonu NVARCHAR(20),
    DokumentID NVARCHAR(100) NOT NULL,
    AuditUser INT NOT NULL,
    FOREIGN KEY (AuditUser) REFERENCES Uzytkownicy(UzytkownikID)
);

-- Tabela przechowująca wypożyczenia książek przez czytelników
IF NOT EXISTS (SELECT 1 FROM [INFORMATION_SCHEMA].[TABLES] WHERE TABLE_NAME = 'Wypozyczenia')
CREATE TABLE Wypozyczenia (
    WypozyczenieID INT IDENTITY(1,1) PRIMARY KEY,
    KsiazkaID INT NOT NULL,
    CzytelnikID INT NOT NULL,
    DataWypozyczenia DATETIME NOT NULL,
    DataZwrotu DATETIME NULL,
    TerminZwrotu DATE NOT NULL,
    Status NVARCHAR(20) CHECK (Status IN ('Wypozyczona','Zwrocona','Zalegla')) NOT NULL,
    FOREIGN KEY (KsiazkaID) REFERENCES Ksiazki(KsiazkaID),
    FOREIGN KEY (CzytelnikID) REFERENCES Czytelnicy(CzytelnikID)
);

-- Tabela przechowująca rezerwacje książek
IF NOT EXISTS (SELECT 1 FROM [INFORMATION_SCHEMA].[TABLES] WHERE TABLE_NAME = 'Rezerwacje')
CREATE TABLE Rezerwacje (
    RezerwacjaID INT IDENTITY(1,1) PRIMARY KEY,
    KsiazkaID INT NOT NULL,
    CzytelnikID INT NOT NULL,
    DataRezerwacji DATETIME NOT NULL,
    Status NVARCHAR(50) CHECK (Status IN ('Aktywna', 'Zakonczona', 'Anulowana')) NOT NULL,
    FOREIGN KEY (KsiazkaID) REFERENCES Ksiazki(KsiazkaID),
    FOREIGN KEY (CzytelnikID) REFERENCES Czytelnicy(CzytelnikID)
);

-- Tabela przechowująca kary nałożone na czytelników
IF NOT EXISTS (SELECT 1 FROM [INFORMATION_SCHEMA].[TABLES] WHERE TABLE_NAME = 'Kary')
CREATE TABLE Kary (
    KaraID INT IDENTITY(1,1) PRIMARY KEY,
    CzytelnikID INT NOT NULL,
    WypozyczenieID INT NOT NULL,
    Kwota DECIMAL(10,2) NOT NULL,
    DataKary DATETIME NOT NULL DEFAULT GETDATE(),
    StatusPlatnosci NVARCHAR(20) CHECK (StatusPlatnosci IN ('Oplacona', 'Nieoplacona')) NOT NULL,
    FOREIGN KEY (CzytelnikID) REFERENCES Czytelnicy(CzytelnikID),
    FOREIGN KEY (WypozyczenieID) REFERENCES Wypozyczenia(WypozyczenieID)
);

-- Tabela statusów
IF NOT EXISTS (SELECT 1 FROM [INFORMATION_SCHEMA].[TABLES] WHERE TABLE_NAME = 'Statusy')
CREATE TABLE Statusy (
    StatusID INT IDENTITY(1,1) PRIMARY KEY,
    Nazwa NVARCHAR(20) NOT NULL,
    Typ NVARCHAR(20) NOT NULL,
    Status NVARCHAR(20) NOT NULL
);
