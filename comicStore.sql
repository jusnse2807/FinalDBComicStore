CREATE TABLE Comics (
    id SERIAL PRIMARY KEY,
    title VARCHAR(500),
    description VARCHAR(500),
    price FLOAT,
    category VARCHAR(500)
);

CREATE TABLE Characters (
    id SERIAL PRIMARY KEY,
    name VARCHAR(500) ,
    powers VARCHAR(500) [],
    weaknesses VARCHAR(500) [],
    affiliations VARCHAR(500) []
);

CREATE TABLE Villagers_And_Arms (
    id SERIAL PRIMARY KEY,
    name VARCHAR(500),
    description VARCHAR(500),
    availability BOOLEAN
);



CREATE TABLE Customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(500),
    birthday DATE,
    email VARCHAR(500)
);

CREATE TABLE Transactions (
    id SERIAL PRIMARY KEY,
    comic_id INT,
    customer_id INT,
    FOREIGN KEY (comic_id) REFERENCES  Comics(id),
    FOREIGN KEY (customer_id) REFERENCES  Customers(id),
    purchase_date DATE,
    total_amount FLOAT
);

CREATE TABLE Battles (
    id SERIAL PRIMARY KEY,
    comic_id INT,
    hero_id INT,
    villiain_id INT,
    mortal_arm_id INT,
    FOREIGN KEY (comic_id) REFERENCES  comics(id),
    FOREIGN KEY (hero_id) REFERENCES  Characters(id),
    FOREIGN KEY (villiain_id) REFERENCES characters(id),
    FOREIGN KEY (mortal_arm_id) REFERENCES Villagers_And_Arms(id),
    winner_id INT
);

--Trigger implementation
CREATE OR REPLACE FUNCTION insert_special_offer()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.comic_id = (SELECT id FROM Comics WHERE title = 'Superman en Calzoncillos con Batman Asustado') THEN
        -- Obtener los datos del cliente desde la tabla Customers
        INSERT INTO SpecialOffers (customer_name, customer_birthday)
        SELECT name, birthday
        FROM Customers
        WHERE id = NEW.customer_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER track_special_offers
AFTER INSERT ON Transactions
FOR EACH ROW
EXECUTE FUNCTION insert_special_offer();

SELECT * FROM SpecialOffers;


-- DATA

INSERT INTO Comics (title, description, price, category)
VALUES
('Superman en Calzoncillos con Batman Asustado', 'Un clásico controversial de los héroes de DC.', 500, 'superhero'),
('El Dandy Mascarado', 'La historia del héroe que redefine la elegancia.', 20, 'superhero'),
('El Villano Sin Nombre', 'Un villano que aterroriza en el anonimato.', 15, 'villain'),
('Guerra en el Multiverso', 'Héroes y villanos luchan en múltiples dimensiones.', 25, 'superhero'),
('Batman: El Misterio del Reloj', 'Batman enfrenta a un nuevo enemigo.', 18, 'superhero'),
('La Venganza de los Oscuros', 'Un grupo de villanos se unen para destruir a los héroes.', 30, 'villain');


INSERT INTO Characters (name, powers, weaknesses, affiliations)
VALUES
('Superman', ARRAY['flight', 'super strength', 'x-ray vision'], ARRAY['kryptonite'], ARRAY['Justice League']),
('Batman', ARRAY['intelligence', 'combat skills'], ARRAY['human limitations'], ARRAY['Justice League']),
('El Dandy Mascarado', ARRAY['charm', 'elegance'], ARRAY['vanity'], ARRAY['Independent']),
('El Villano Sin Nombre', ARRAY['stealth', 'hacking'], ARRAY['ego'], ARRAY['None']),
('Iron Man', ARRAY['flight', 'intelligence', 'tech mastery'], ARRAY['ego'], ARRAY['Avengers']),
('Thanos', ARRAY['super strength', 'immortality'], ARRAY['overconfidence'], ARRAY['None']);


INSERT INTO Characters(name, powers, weaknesses, affiliations)
VALUES
('Spiderman', ARRAY ['intelligence', 'combat skills','climb walls'], ARRAY['Age', 'family'], ARRAY['Avengers']),
('El segundo Villano Sin Nombre',ARRAY['Mind Control', 'Hacking'], ARRAY ['Overcconfidence'], ARRAY ['None']);

INSERT INTO Characters(name, powers, weaknesses, affiliations)
VALUES
('MrVoltiarepa', ARRAY ['intelligence', 'combat skills','climb walls'], ARRAY['Age', 'family'], ARRAY['Avengers', 'Justice League']);

INSERT INTO Villagers_And_Arms (name, description, availability)
VALUES
('Alfred', 'Fiel mayordomo de Batman.', TRUE),
('Batmóvil', 'El icónico vehículo de Batman.', TRUE),
('Infinity Gauntlet', 'El poderoso guantelete de Thanos.', FALSE),
('La Rosa Encantada', 'El arma secreta de El Dandy Mascarado.', TRUE),
('Daily Planet Reporter', 'Un ciudadano que trabaja en el Daily Planet.', TRUE);


INSERT INTO Customers (name, birthday, email)
VALUES
('Juan Pérez', '1990-06-15', 'juan.perez@gmail.com'),
('María López', '1985-11-23', 'maria.lopez@gmail.com'),
('Carlos García', '2000-01-10', 'carlos.garcia@gmail.com'),
('Ana Torres', '1995-07-05', 'ana.torres@gmail.com');

INSERT INTO Transactions (comic_id, customer_id, purchase_date, total_amount)
VALUES
(1, 1, '2024-11-15', 500),
(2, 1, '2024-11-16', 20),
(3, 2, '2024-11-16', 15),
(4, 2, '2024-11-16', 25),
(5, 3, '2024-11-17', 18),
(6, 4, '2024-11-17', 30);

INSERT INTO Transactions (comic_id, customer_id, purchase_date, total_amount)
VALUES
(3, 1, '2024-11-15', 500),
(4, 1, '2024-11-16', 20),
(5, 2, '2024-11-16', 15);

INSERT INTO Transactions (comic_id, customer_id, purchase_date, total_amount)
VALUES
(5, 1, '2024-11-15', 500),
(6, 1, '2024-11-16', 20),
(5, 2, '2024-11-16', 15);

INSERT INTO Transactions (comic_id, customer_id, purchase_date, total_amount)
VALUES (
    (SELECT id FROM Comics WHERE title = 'Superman en Calzoncillos con Batman Asustado'),
    1, -- customer_id
    '2024-11-18',
    99.99
);

-- Insert sample data into Battles
INSERT INTO Battles (comic_id, hero_id, villiain_id, mortal_arm_id, winner_id)
VALUES
    (1, 1, 4, 2, 1),
    (2, 2, 4, 1, 2),
    (3, 3, 8, 3, 3),
    (2, 4, 8, 5, 2),
    (5, 5, 4, 5,4 ),
    (6, 6, 4, 4, 4);

INSERT INTO Transactions (comic_id, customer_id, purchase_date, total_amount)
VALUES (
    (SELECT id FROM Comics WHERE title = 'Superman en Calzoncillos con Batman Asustado'),
    1, -- customer_id
    '2024-11-18',
    99.99
);

--Queries ---------------------------------------------------------------

-- 1. List all comics priced below $20, sorted alphabetically by title

SELECT title, price FROM Comics WHERE price < 20 ORDER BY title;

-- 2. Display all superheroes with powers that include "flight," ordered by name.

SELECT name, powers FROM Characters WHERE 'flight' = ANY(powers) ORDER BY name;

-- 0. Find all villains who have been defeated by a superhero more than three times. A villain is the one who his id%4==0

SELECT name
FROM Characters
WHERE id IN (
    SELECT villiain_id
    FROM Battles
    GROUP BY villiain_id
    HAVING COUNT(winner_id %4!=0) >= 3
    AND villiain_id % 4 = 0
);

-- 1. Retrieve a list of customers who have purchased more than five comics, along with the total amount spent.

SELECT Customers.name, SUM(Transactions.total_amount) AS total_spent
FROM Customers
JOIN Transactions ON Customers.id = Transactions.customer_id
GROUP BY Customers.name HAVING COUNT(Transactions.id) > 5;

--Advanced queries

-- Find the most popular comic category based on the number of purchases.
SELECT category, COUNT(*) AS total_purchases
FROM Comics
JOIN Transactions ON comic_id = Transactions.comic_id
GROUP BY category ORDER BY total_purchases DESC LIMIT 1;

-- Retrieve all characters affiliated with both the "Justice League" and the "Avengers."

SELECT name FROM Characters WHERE 'Justice League' = ANY(affiliations) AND 'Avengers' = ANY(affiliations);

-- 2. Identify comics that feature epic hero-villain battles and include at least one "mortal arm."

SELECT comics.title FROM Comics
JOIN Battles ON Comics.id = Battles.comic_id
JOIN Villagers_And_Arms V ON V.id = Battles.mortal_arm_id;

--Views and materialized views -------------------------------------------------------------------------------

--View
CREATE VIEW Popular_Comics AS
SELECT
    Comics.id AS comic_id,
    Comics.title AS comic_title,
    COUNT(*) AS purchase_count
FROM
    Transactions
JOIN
    Comics ON Transactions.comic_id = Comics.id
GROUP BY Comics.id, Comics.title
HAVING COUNT(*) > 50;


--Materialized View

CREATE MATERIALIZED VIEW Top_Customers AS
SELECT Customers.id, Customers.name, COUNT(Transactions.id) AS purchases, SUM(Transactions.total_amount) AS total_spent
FROM Customers
JOIN Transactions ON Customers.id = Transactions.customer_id
GROUP BY Customers.name, Customers.id HAVING COUNT(Transactions.id) > 10;

CREATE EXTENSION IF NOT EXISTS pg_cron;

REFRESH MATERIALIZED VIEW Top_Customers;

