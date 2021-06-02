DROP VIEW IF EXISTS car_overview;
ALTER TABLE IF EXISTS EMPLOYEE
    DROP CONSTRAINT IF EXISTS branch_emp;
DROP INDEX IF EXISTS IX_Rent;
DROP TABLE IF EXISTS PAYMENT;
DROP TABLE IF EXISTS RENT;
DROP TABLE IF EXISTS MAINTAINS;
DROP TABLE IF EXISTS CAR;
DROP TABLE IF EXISTS BRANCH;
DROP TABLE IF EXISTS CUSTOMER;
DROP TABLE IF EXISTS PRICE;
DROP TABLE IF EXISTS EMPLOYEE;
DROP TABLE IF EXISTS ADDRESSES;
DROP FUNCTION IF EXISTS car_returned ();

CREATE TABLE ADDRESSES (
    n_address_id serial UNIQUE NOT NULL,
    s_street varchar(128) NOT NULL,
    s_house_number varchar(20) NOT NULL,
    s_city varchar(20) NOT NULL,
    s_country varchar(20) NOT NULL,
    n_zipcode int NOT NULL,
    PRIMARY KEY (n_address_id)
);

CREATE TABLE EMPLOYEE (
    n_employee_id serial UNIQUE NOT NULL,
    s_first_name varchar(128) NOT NULL,
    s_last_name varchar(128) NOT NULL,
    d_date_of_birth date,
    n_branch_id int NOT NULL,
    n_salary numeric(15, 2) NOT NULL,
    n_commission numeric(3, 3),
    n_address_id int,
    PRIMARY KEY (n_employee_id),
    FOREIGN KEY (n_address_id) REFERENCES ADDRESSES (n_address_id)
);

CREATE TABLE CUSTOMER (
    n_customer_id serial UNIQUE NOT NULL,
    s_first_name varchar(128) NOT NULL,
    s_last_name varchar(128) NOT NULL,
    d_date_of_birth date NOT NULL,
    s_license_id varchar(3) NOT NULL,
    n_address_id int,
    PRIMARY KEY (n_customer_id),
    FOREIGN KEY (n_address_id) REFERENCES ADDRESSES (n_address_id)
);

CREATE TABLE BRANCH (
    n_branch_id serial UNIQUE NOT NULL,
    n_manager_id int,
    n_parking_spaces int,
    n_address_id int,
    PRIMARY KEY (n_branch_id),
    FOREIGN KEY (n_address_id) REFERENCES ADDRESSES (n_address_id),
    FOREIGN KEY (n_manager_id) REFERENCES EMPLOYEE (n_employee_id)
);

CREATE TABLE PRICE (
    n_price_id serial UNIQUE NOT NULL,
    s_price_class varchar(128) NOT NULL,
    n_price_per_day numeric(15, 2),
    n_price_per_kilometer numeric(15, 2),
    n_security_deposit numeric(15, 2),
    PRIMARY KEY (n_price_id)
);

CREATE TABLE CAR (
    n_car_id serial UNIQUE NOT NULL,
    s_brand varchar(13),
    n_mileage int,
    d_date_bought date,
    n_price_id int NOT NULL,
    n_branch_id int NOT NULL,
    b_is_available bool NOT NULL,
    PRIMARY KEY (n_car_id),
    FOREIGN KEY (n_price_id) REFERENCES PRICE (n_price_id),
    FOREIGN KEY (n_branch_id) REFERENCES BRANCH (n_branch_id)
);

CREATE TABLE MAINTAINS (
    n_maintain_id serial UNIQUE NOT NULL,
    n_employee_id int NOT NULL,
    n_car_id int NOT NULL,
    s_comment varchar(128),
    d_date_maintained date NOT NULL DEFAULT CURRENT_DATE,
    PRIMARY KEY (n_maintain_id),
    FOREIGN KEY (n_employee_id) REFERENCES EMPLOYEE (n_employee_id),
    FOREIGN KEY (n_car_id) REFERENCES CAR (n_car_id)
);

CREATE TABLE RENT (
    n_rent_id serial UNIQUE NOT NULL,
    n_car_id int NOT NULL,
    n_duration int NOT NULL,
    n_free_kilometers int DEFAULT 100,
    n_customer_id int NOT NULL,
    n_employee_id int NOT NULL,
    b_is_returned bool NOT NULL DEFAULT FALSE,
    d_date_rented date NOT NULL DEFAULT CURRENT_DATE,
    d_date_returned date,
    n_employee_id_returned int,
    n_mileage_returned int,
    PRIMARY KEY (n_rent_id),
    FOREIGN KEY (n_car_id) REFERENCES CAR (n_car_id),
    FOREIGN KEY (n_customer_id) REFERENCES CUSTOMER (n_customer_id),
    FOREIGN KEY (n_employee_id) REFERENCES EMPLOYEE (n_employee_id)
);

CREATE TABLE PAYMENT (
    n_rent_id int NOT NULL,
    n_payment_amount numeric(15, 2) NOT NULL,
    d_payment_date date NOT NULL DEFAULT CURRENT_DATE,
    PRIMARY KEY (n_rent_id, d_payment_date),
    FOREIGN KEY (n_rent_id) REFERENCES RENT (n_rent_id)
);

ALTER TABLE EMPLOYEE
    ADD CONSTRAINT branch_emp FOREIGN KEY (n_branch_id) REFERENCES BRANCH (n_branch_id);

CREATE UNIQUE INDEX IX_Rent
ON RENT (n_customer_id, b_is_returned)
WHERE
    b_is_returned = FALSE;

INSERT INTO ADDRESSES (s_street, s_house_number, s_city, s_country, n_zipcode)
    VALUES 
    ('Coblitzallee', 1, 'Mannheim', 'Germany', 68163), 
    ('Hans-Thoma-Straße', 2, 'Mannheim', 'Germany', 68163), 
    ('Mainzer Landstraße', 14, 'Frankfurt', 'Germany', 65933), 
    ('Apple Campus', 2, 'Cupertino', 'USA', 1011);

INSERT INTO BRANCH (n_manager_id, n_parking_spaces, n_address_id)
    VALUES 
    (NULL, 10, 1), 
    (NULL, 4, 2), 
    (NULL, 3, 3);

INSERT INTO EMPLOYEE (s_first_name, s_last_name, d_date_of_birth, n_branch_id, n_salary, n_commission, n_address_id)
    VALUES 
    ('Jon', 'James', DATE '1985-12-16', 1, 20000.00, 0.5, 1), 
    ('Michael', 'Kurt', DATE '1995-05-10', 2, 20000.00, 0.5, 2), 
    ('Aylin', 'Bauer', DATE '1989-01-01', 2, 50000.00, 0.5, 3);

UPDATE
    BRANCH
SET
    n_manager_id = n_branch_id;

INSERT INTO PRICE (s_price_class, n_price_per_day, n_price_per_kilometer, n_security_deposit)
    VALUES 
    ('Luxury Line', 1000.00, 1.20, 10000.00), 
    ('Business Line', 250.00, 0.3, 1000.00), 
    ('Economic Line', 99.00, 0.3, 0.00);

INSERT INTO CUSTOMER (s_first_name, s_last_name, d_date_of_birth, s_license_id, n_address_id)
    VALUES 
    ('Jan', 'Müller', DATE '1989-12-12', 'B', 4), 
    ('Silvie', 'Müller', DATE '1990-01-12', 'BE', 4);

INSERT INTO CAR (s_brand, n_mileage, d_date_bought, n_price_id, n_branch_id, b_is_available)
    VALUES 
    ('Mercedes', 200000, DATE '2002-01-01', 1, 1, FALSE), 
    ('Opel', 150000, DATE '2012-01-01', 2, 1, FALSE), 
    ('Audi', 150000, DATE '2012-01-01', 3, 2, TRUE);

INSERT INTO MAINTAINS (n_employee_id, n_car_id, s_comment, d_date_maintained)
    VALUES 
    (1, 2, 'everything is clean', DATE '2021-05-12'), 
    (1, 1, 'bumper got dented', DATE '2021-05-12'), 
    (2, 1, NULL, DATE '2021-05-21');

INSERT INTO RENT (n_car_id, n_duration, n_free_kilometers, n_customer_id, n_employee_id, b_is_returned, d_date_rented)
    VALUES 
    (1, 5, 100, 1, 1, FALSE, DATE '2021-05-12'), 
    (2, 1, 100, 2, 1, FALSE, DATE '2021-05-12');

INSERT INTO PAYMENT (n_rent_id, n_payment_amount, d_payment_date)
    VALUES 
    (1, 1250.00, DATE '2021-05-12'), 
    (2, 99.00, DATE '2021-05-12');


CREATE VIEW car_overview AS
SELECT
    c.n_car_id Car_id,
    c.s_brand Car_brand,
    p.n_price_per_day Price,
    p.s_price_class Price_Class,
    a.s_street || ' ' || a.s_house_number Current_Location,
    a.n_zipcode Zipcode
FROM
    car AS c
    LEFT JOIN price AS p ON (c.n_price_id = p.n_price_id)
    LEFT JOIN branch AS b ON (c.n_branch_id = b.n_branch_id)
    LEFT JOIN addresses AS a ON (b.n_address_id = a.n_address_id)
GROUP BY
    Car_id,
    Price,
    Price_Class,
    Current_Location,
    Zipcode;


/*
PROCEDURE:
rent_car() is a procedure that creates a new rent. 
First, it checks if the car is available and if the customer has any active rents.
If the car is available and the customer has no active rents, then the car is set to unavailable and
the branches parking space is raised by one. Afterwards a new rent is created, containing the necessary information.
If the car is unavailable or the customer already has a rent, then the procedure rises an error.
*/
CREATE OR REPLACE PROCEDURE rent_car (carID int, customerID int, employeeID int, duration int)
LANGUAGE plpgsql
AS '
BEGIN
    IF (
        SELECT
            b_is_available
        FROM
            CAR
        WHERE
            CAR.n_car_id = carID) AND NOT (
    SELECT
        count(*)
    FROM
        RENT
    WHERE
        RENT.n_customer_id = customerID AND RENT.b_is_returned = FALSE) > 0 THEN
        UPDATE
            CAR
        SET
            b_is_available = FALSE
        WHERE
            CAR.n_car_id = carID;
        UPDATE
            BRANCH
        SET
            n_parking_spaces = n_parking_spaces + 1
        WHERE
            n_branch_id = (
                SELECT
                    n_branch_id
                FROM
                    CAR
                WHERE
                    CAR.n_car_id = carID);
        INSERT INTO RENT (n_car_id, n_duration, n_customer_id, n_employee_id, b_is_returned)
            VALUES (carID, duration, customerID, employeeID, FALSE);
    ELSE
        RAISE EXCEPTION ''car is not available/ customer already has an active rent'';
    END IF;
END;
';

/*
FUNCTION:
This function is triggered by an update. If a car is returned, this function checks if the free kilometers 
were exceeded. If so, then the customer has to make a new payment according to the price class of the rented car.
Then the mileage of the car is set to the mileage after the rent. Afterwards the car status gets set back to available and 
the branches parking space is reduced by one.
*/
CREATE OR REPLACE FUNCTION car_returned ()
    RETURNS TRIGGER
    LANGUAGE PLPGSQL
    AS '
BEGIN
    IF NEW.b_is_returned THEN
        IF (NEW.n_mileage_returned - (
            SELECT
                n_mileage
            FROM
                CAR
            WHERE
                CAR.n_car_id = NEW.n_car_id)) > NEW.n_free_kilometers THEN
            INSERT INTO PAYMENT (n_rent_id, n_payment_amount)
                VALUES (NEW.n_rent_id, ((NEW.n_mileage_returned - (
                            SELECT
                                n_mileage FROM CAR
                            WHERE
                                CAR.n_car_id = NEW.n_car_id)) * (
                            SELECT
                                price.n_price_per_kilometer FROM CAR
                            LEFT JOIN PRICE ON (CAR.n_price_id = PRICE.n_price_id)
                        WHERE
                            CAR.n_car_id = NEW.n_car_id)));
        END IF;
        UPDATE
            CAR
        SET
            n_mileage = NEW.n_mileage_returned,
            b_is_available = TRUE
        WHERE
            CAR.n_car_id = NEW.n_car_id;
        UPDATE
            BRANCH
        SET
            n_parking_spaces = n_parking_spaces - 1
        WHERE
            BRANCH.n_branch_id = (
                SELECT
                    n_branch_id
                FROM
                    RENT
                LEFT JOIN CAR ON (RENT.n_car_id = CAR.n_car_id)
            WHERE
                CAR.n_car_id = NEW.n_car_id);
    END IF;
    RETURN NEW;
END;
';

/*
TRIGGER:
This trigger calls the function car_returned() for each row that gets updated in the table RENT.
*/
CREATE TRIGGER car_returned
    AFTER UPDATE ON RENT
    FOR EACH ROW
    EXECUTE PROCEDURE car_returned ();

