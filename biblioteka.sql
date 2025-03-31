CREATE TABLE books (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    published_year INT
);

CREATE TABLE author (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE authorBooks (
    author_id INT,
    book_id INT,
    PRIMARY KEY (author_id, book_id),
    FOREIGN KEY (author_id) REFERENCES author(id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE
);

CREATE TABLE user (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    role VARCHAR(20) NOT NULL
);

CREATE TABLE wypozyczenia (
    id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT,
    user_id INT,
    borrow_date DATE NOT NULL,
    return_date DATE,
    FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE
);

CREATE TABLE rezerwacja (
    id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT,
    user_id INT,
    reservation_date DATE NOT NULL,
    FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE
);

CREATE TABLE kary (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    wypozyczenie_id INT,
    financial penalty INT,
    payment_status VARCHAR(30),
    FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE,
    FOREIGN KEY (wypozyczenie_id) REFERENCES wypozyczenia(id) ON DELETE CASCADE
);
