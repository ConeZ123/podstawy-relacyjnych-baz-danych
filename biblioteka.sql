-- Tworzenie bazy danych
USE master
CREATE DATABASE [Biblioteka_g2];
GO
USE [Biblioteka_g2];

CREATE TABLE country (
	country_id INT IDENTITY (1,1),
	country VARCHAR(20) NOT NULL,
	country_short VARCHAR(3) NOT NULL
	CONSTRAINT PK_country_country_id PRIMARY KEY CLUSTERED (country_id)
)

CREATE TABLE [status] (
	status_id INT IDENTITY(1,1) PRIMARY KEY,
	status_name varchar(50) NOT NULL,
	status_desc varchar(200),
	status_type varchar(50), -- typ statusu
	[status] BIT -- akrtywny, nieakrywny
)


-- Tabela Authors (Autorzy)
CREATE TABLE authors (
    author_id INT IDENTITY(1,1) PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_date DATE,
	country_id INT NOT NULL DEFAULT 1,
    biography VARCHAR(MAX),
	FOREIGN KEY (country_id) REFERENCES country(country_id) 
);


-- Tabela Books (Książki)
IF NOT EXISTS (SELECT 1 FROM [INFORMATION_SCHEMA].[TABLES] WHERE TABLE_NAME ='books' )
CREATE TABLE books (
    book_id INT IDENTITY(1,1) PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    isbn VARCHAR(20) UNIQUE,
    publication_year INT,
    publisher VARCHAR(100),
    genre VARCHAR(50),
    available_copies INT DEFAULT 1,
    total_copies INT DEFAULT 1,
	status_id INT NOT NULL,
	FOREIGN KEY ([status_id]) REFERENCES [status]([status_id])
);

-- Tabela łącząca Authors i Books (AutorzyKsiążek)
CREATE TABLE authorsBooks (
    --author_book_id INT IDENTITY(1,1) PRIMARY KEY,
    author_id INT NOT NULL,
    book_id INT NOT NULL,
    FOREIGN KEY (author_id) REFERENCES authors(author_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    --UNIQUE (author_id, book_id)
	CONSTRAINT PK_authorsBooks_author_id_book_id PRIMARY KEY CLUSTERED (author_id,book_id)
);

-- Tabela User (Użytkownicy systemu)
CREATE TABLE [user] (
    [user_id] INT IDENTITY(1,1) PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    [role] VARCHAR(20) CHECK ([role] in ('admin', 'librarian', 'user')),
    created_at DATETIME DEFAULT GETDATE(),
    last_login DATETIME,
	status_id INT NOT NULL,
	FOREIGN KEY ([status_id]) REFERENCES [status]([status_id])
);

--ALTER TABLE dbo.[User]
--ADD CONSTRAINT DF_wlasna_nazwa_constrain_role CHECK ([role] in ('admin', 'librarian', 'user'))
--GO



-- Tabela Czytelnicy (Czytelnicy biblioteki)
CREATE TABLE readers (
    readers_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    [address] VARCHAR(100),
    phone VARCHAR(20),
    registration_date DATE DEFAULT GETDATE(),
	status_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES [User](user_id),
	FOREIGN KEY ([status_id]) REFERENCES [status]([status_id])
);

-- Tabela Wypożyczenia (Wypożyczenia książek)
CREATE TABLE borrowing (
    borrowing_id INT IDENTITY(1,1) PRIMARY KEY,
    book_id INT NOT NULL,
    readers_id INT NOT NULL,
    borrowing_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    return_date DATETIME,
    due INT NOT NULL,
    [status] varchar(20) CHECK ([status] in ('wypożyczona', 'zwrócona', 'przetrzymana')) DEFAULT 'wypożyczona',
	[status_id] INT NOT NULL,
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    FOREIGN KEY (readers_id) REFERENCES readers(readers_id),
	FOREIGN KEY ([status_id]) REFERENCES [status]([status_id])
);

-- Tabela Rezerwacja (Rezerwacje książek)
CREATE TABLE dbo.reservation (
    reservation_id INT IDENTITY(1,1) PRIMARY KEY,
    book_id INT NOT NULL,
    readers_id INT NOT NULL,
    reservation_date DATETIME DEFAULT CURRENT_TIMESTAMP,
	--[status] varchar(20) CHECK ([status] in ('aktywna', 'zrealizowana', 'anulowana')) DEFAULT 'aktywna',
	[status_id] INT NOT NULL,
    FOREIGN KEY (book_id) REFERENCES Books(book_id),
    FOREIGN KEY (readers_id) REFERENCES readers(readers_id),
	FOREIGN KEY ([status_id]) REFERENCES [status]([status_id])
);
-- CREATE INDEX index1 ON schema1.table1 (column1);
CREATE INDEX IX_reservation_book_is ON dbo.reservation(book_id)
	



-- Tabela kary (Kary za przetrzymanie)
CREATE TABLE fine (
    fine_id INT IDENTITY(1,1) PRIMARY KEY,
    borrowing_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    date_issue DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_pay DATETIME,
	--[status] varchar(20) CHECK ([status] in ('naliczona', 'opłacona', 'umorzona')) DEFAULT 'naliczona',
	[status_id] INT NOT NULL
    FOREIGN KEY (borrowing_id) REFERENCES borrowing(borrowing_id),
	FOREIGN KEY ([status_id]) REFERENCES [status]([status_id])
);




--INSERT INTO nazwa (kolumna) VALUES (wartosc)
INSERT INTO dbo.[status] ([status_name],[status_desc],[status_type],[status])
VALUES ('Dostępna','Książka jest dostępna w bibliotece','books',1)

INSERT INTO dbo.[status] ([status_name],[status_type],[status])
VALUES ('Niedostepna','books',1),
('Aktywny','users',1),
('Nieaktywny','users',1)


SELECT * FROM dbo.status

INSERT INTO country (country, country_short)
VALUES 
('Polska', 'PL'),
('Niemcy', 'DE'),
('Francja', 'FR'),
('Włochy', 'IT'),
('Hiszpania', 'ES'),
('USA', 'US'),
('Kanada', 'CA'),
('Japonia', 'JP'),
('Chiny', 'CN'),
('Brazylia', 'BR');

INSERT INTO authors (first_name, last_name, birth_date, country_id, biography)
VALUES 
('Adam', 'Mickiewicz', '1798-12-24', 1, 'Poeta romantyczny'),
('Henryk', 'Sienkiewicz', '1846-05-05', 1, 'Laureat Nobla'),
('Stephen', 'King', '1947-09-21', 6, 'Autor horrorów'),
('J.K.', 'Rowling', '1965-07-31', 6, 'Autorka Harryego Pottera'),
('Ernest', 'Hemingway', '1899-07-21', 6, 'Amerykański pisarz'),
('Gabriel', 'Garcia Marquez', '1927-03-06', 10, 'Kolumbijski pisarz'),
('Haruki', 'Murakami', '1949-01-12', 8, 'Japoński pisarz'),
('Albert', 'Camus', '1913-11-07', 3, 'Francuski filozof i pisarz'),
('Umberto', 'Eco', '1932-01-05', 4, 'Włoski pisarz i filozof'),
('Carlos', 'Ruiz Zafón', '1964-09-25', 5, 'Hiszpański autor bestsellerów');

INSERT INTO books (title, isbn, publication_year, publisher, genre, available_copies, total_copies, status_id)
VALUES 
('Pan Tadeusz', '9788373271234', 1834, 'Czytelnik', 'Epos', 5, 10, 1),
('Quo Vadis', '9788328703286', 1896, 'PWN', 'Historyczna', 4, 10, 1),
('Lśnienie', '9780307743657', 1977, 'Doubleday', 'Horror', 3, 5, 1),
('Harry Potter 1', '9780747532699', 1997, 'Bloomsbury', 'Fantasy', 2, 5, 1),
('Stary człowiek i morze', '9780684801223', 1952, 'Scribner', 'Nowela', 2, 3, 1),
('Sto lat samotności', '9788497592208', 1967, 'Sudamericana', 'Magiczny realizm', 1, 4, 2),
('Kafka nad morzem', '9780099458326', 2002, 'Vintage', 'Surrealizm', 3, 3, 1),
('Dżuma', '9780141185132', 1947, 'Gallimard', 'Egzystencjalizm', 2, 2, 1),
('Imię róży', '9780156001311', 1980, 'Bompiani', 'Kryminał', 1, 2, 1),
('Cień wiatru', '9788408172171', 2001, 'Planeta', 'Dramat', 1, 3, 1);

INSERT INTO authorsBooks (author_id, book_id)
VALUES 
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10);

INSERT INTO [user] (username, password_hash, email, role, status_id)
VALUES 
('admin1', 'hash1', 'admin1@example.com', 'admin', 3),
('lib1', 'hash2', 'lib1@example.com', 'librarian', 3),
('user1', 'hash3', 'user1@example.com', 'user', 3),
('user2', 'hash4', 'user2@example.com', 'user', 3),
('user3', 'hash5', 'user3@example.com', 'user', 3),
('user4', 'hash6', 'user4@example.com', 'user', 3),
('user5', 'hash7', 'user5@example.com', 'user', 3),
('lib2', 'hash8', 'lib2@example.com', 'librarian', 3),
('user6', 'hash9', 'user6@example.com', 'user', 3),
('user7', 'hash10', 'user7@example.com', 'user', 4);

INSERT INTO readers (user_id, first_name, last_name, address, phone, status_id)
VALUES 
(3, 'Jan', 'Kowalski', 'ul. Kwiatowa 10', '500100100', 3),
(4, 'Anna', 'Nowak', 'ul. Leśna 3', '500100101', 3),
(5, 'Piotr', 'Zieliński', 'ul. Polna 8', '500100102', 3),
(6, 'Karolina', 'Wiśniewska', 'ul. Słoneczna 15', '500100103', 3),
(7, 'Tomasz', 'Kamiński', 'ul. Długa 1', '500100104', 3),
(9, 'Ewa', 'Kaczmarek', 'ul. Krótka 22', '500100105', 3),
(10, 'Marcin', 'Wójcik', 'ul. Cicha 4', '500100106', 4),
(8, 'Magda', 'Pawlak', 'ul. Łąkowa 6', '500100107', 3),
(2, 'Beata', 'Michalska', 'ul. Parkowa 2', '500100108', 3),
(1, 'Łukasz', 'Szymczak', 'ul. Sosnowa 12', '500100109', 3);

INSERT INTO borrowing (book_id, readers_id, return_date, due, status_id)
VALUES 
(1, 1, NULL, 14, 3),
(2, 2, NULL, 14, 3),
(3, 3, '2025-04-10', 14, 3),
(4, 4, NULL, 7, 3),
(5, 5, '2025-04-01', 14, 3),
(6, 6, NULL, 10, 3),
(7, 7, '2025-03-30', 14, 3),
(8, 8, NULL, 21, 3),
(9, 9, NULL, 7, 3),
(10, 10, NULL, 14, 3);

INSERT INTO reservation (book_id, readers_id, status_id)
VALUES 
(1, 1, 3),
(2, 2, 3),
(3, 3, 3),
(4, 4, 3),
(5, 5, 3),
(6, 6, 3),
(7, 7, 3),
(8, 8, 3),
(9, 9, 3),
(10, 10, 3);

INSERT INTO fine (borrowing_id, amount, date_pay, status_id)
VALUES 
(3, 10.00, '2025-04-11', 3),
(5, 5.00, NULL, 3),
(6, 20.00, NULL, 3),
(7, 15.50, '2025-04-01', 3),
(8, 30.00, NULL, 3),
(9, 8.75, '2025-04-10', 3),
(10, 12.00, NULL, 3),
(1, 6.50, '2025-03-28', 3),
(2, 14.30, NULL, 3),
(4, 9.90, NULL, 3);
