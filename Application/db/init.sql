DROP VIEW IF EXISTS car_overview;
ALTER TABLE IF EXISTS EMPLOYEE DROP CONSTRAINT IF EXISTS branch_emp;
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
DROP FUNCTION IF EXISTS car_returned();


CREATE TABLE ADDRESSES
(
n_address_id	 	SERIAL UNIQUE		NOT NULL,
s_street 			VARCHAR(128) 		NOT NULL,
s_house_number	VARCHAR(20) 		NOT NULL,
s_city			VARCHAR(20) 	    NOT NULL,
s_country			VARCHAR(20) 		NOT NULL,
n_zipcode			INT					NOT NULL,
PRIMARY KEY (n_address_id) 
);


CREATE TABLE EMPLOYEE
(
n_employee_id 	SERIAL UNIQUE		NOT NULL,
s_first_name 	VARCHAR(128) 		NOT NULL,
s_last_name   VARCHAR(128)			NOT NULL,
dt_date_of_birth  DATE,
n_branch_id INT         NOT NULL,
n_salary    NUMERIC(15, 2)                   NOT NULL,
n_commission NUMERIC(3,3),
n_address_id	INT,
PRIMARY KEY (n_employee_id),
FOREIGN KEY (n_address_id) REFERENCES ADDRESSES(n_address_id)
);


CREATE TABLE CUSTOMER
(
n_customer_id 	SERIAL UNIQUE		NOT NULL,
s_first_name 	VARCHAR(128) 		NOT NULL,
s_last_name   VARCHAR(128)			NOT NULL,
dt_date_of_birth  DATE  NOT NULL,
s_license_id   VARCHAR(3) NOT NULL,
n_address_id	INT,
PRIMARY KEY (n_customer_id),
FOREIGN KEY (n_address_id) REFERENCES ADDRESSES(n_address_id) 
);

CREATE TABLE BRANCH
(
n_branch_id 	SERIAL UNIQUE		NOT NULL,
n_manager_id    INT,
n_parking_spaces    INT,
n_address_id		INT,
PRIMARY KEY (n_branch_id),
FOREIGN KEY (n_address_id) REFERENCES ADDRESSES(n_address_id),
FOREIGN KEY (n_manager_id) REFERENCES EMPLOYEE(n_employee_id)
);


CREATE TABLE PRICE
(
n_price_id         SERIAL UNIQUE		NOT NULL,
s_price_class      VARCHAR(128)         NOT NULL,
n_price_per_day      NUMERIC(15, 2),
n_price_per_kilometer NUMERIC(15, 2),
n_security_deposit  NUMERIC(15, 2),
PRIMARY KEY (n_price_id)
);


CREATE TABLE CAR
( 
n_car_id           SERIAL UNIQUE		NOT NULL,
s_brand              VARCHAR(13),
n_mileage    INT,
dt_date_bought     DATE,
n_price_id INT                    NOT NULL,
n_branch_id      INT              NOT NULL,
b_is_available      BOOL             NOT NULL,
PRIMARY KEY (n_car_id),
FOREIGN KEY (n_price_id) REFERENCES PRICE(n_price_id),
FOREIGN KEY (n_branch_id) REFERENCES BRANCH(n_branch_id)
);

CREATE TABLE MAINTAINS
(
n_maintain_id   SERIAL UNIQUE NOT NULL,
n_employee_id   INT NOT NULL,
n_car_id INT NOT NULL,
s_comment VARCHAR(128),
d_date_maintained DATE NOT NULL DEFAULT CURRENT_DATE,
PRIMARY KEY (n_maintain_id),
FOREIGN KEY (n_employee_id) REFERENCES EMPLOYEE(n_employee_id),
FOREIGN KEY (n_car_id) REFERENCES CAR(n_car_id)
);

CREATE TABLE RENT
(
n_rent_id SERIAL UNIQUE NOT NULL,
n_car_id    INT	 NOT NULL,
n_duration          INT              NOT NULL,
n_free_kilometers INT   DEFAULT 100,
n_customer_id   INT     NOT NULL,
n_employee_id   INT     NOT NULL,
b_is_returned           BOOL              NOT NULL DEFAULT false, 
d_date_rented         DATE             NOT NULL DEFAULT CURRENT_DATE,
d_date_returned     DATE,
n_employee_id_returned INT NOT NULL,
n_mileage_returned INT,
PRIMARY KEY (n_rent_id),
FOREIGN KEY (n_car_id) REFERENCES CAR(n_car_id),
FOREIGN KEY (n_customer_id) REFERENCES CUSTOMER(n_customer_id), 
FOREIGN KEY (n_employee_id) REFERENCES EMPLOYEE(n_employee_id)
);


CREATE TABLE PAYMENT
(
n_rent_id INT       NOT NULL,
n_payment_amount NUMERIC(15,2)  NOT NULL,
d_payment_date DATE     NOT NULL DEFAULT CURRENT_DATE, 
PRIMARY KEY (n_rent_id, d_payment_date),
FOREIGN KEY (n_rent_id) REFERENCES  RENT(n_rent_id)
);

ALTER TABLE EMPLOYEE
    ADD CONSTRAINT branch_emp 
    FOREIGN KEY (n_branch_id) REFERENCES BRANCH(n_branch_id);

CREATE UNIQUE INDEX IX_Rent --This ensures that every customer can only have one active rent at a time
ON RENT(n_customer_id, b_is_returned)
WHERE b_is_returned = false;



INSERT INTO ADDRESSES (s_street, s_house_number, s_city, s_country, n_zipcode)
VALUES
('Coblitzallee', 1, 'Mannheim', 'Germany', 68163),
('Hans-Thoma-Straße', 2, 'Mannheim', 'Germany', 68163),
('Mainzer Landstraße', 14, 'Frankfurt', 'Germany', 65933),
('Apple Campus', 2, 'Cupertino', 'USA', 1011);

INSERT INTO BRANCH (n_manager_id, n_parking_spaces, n_address_id)
VALUES
(null, 10, 1),
(null, 4, 2),
(null, 3, 3);

INSERT INTO EMPLOYEE (s_first_name, s_last_name, dt_date_of_birth, n_branch_id, n_salary, n_commission, n_address_id)
VALUES
('Jon', 'James', DATE '1985-12-16', 1, 20000.00, 0.5, 1),
('Michael', 'Kurt', DATE '1995-05-10', 2, 20000.00, 0.5, 2),
('Aylin', 'Bauer', DATE '1989-01-01', 2, 50000.00, 0.5, 3);

UPDATE BRANCH
set n_manager_id = n_branch_id;



INSERT INTO PRICE (s_price_class, n_price_per_day, n_price_per_kilometer, n_security_deposit)
VALUES
('Luxury Line', 1000.00, 1.20, 10000.00),
('Business Line', 250.00, 0.3, 1000.00),
('Economic Line', 99.00, 0.3, 0.00);

INSERT INTO CUSTOMER (s_first_name, s_last_name, dt_date_of_birth, s_license_id,  n_address_id)
VALUES
('Jan','Müller', DATE '1989-12-12', 'B', 4),
('Silvie','Müller', DATE '1990-01-12', 'BE', 4);


INSERT INTO CAR (s_brand, n_mileage, dt_date_bought, n_price_id, n_branch_id, b_is_available)
VALUES
('Mercedes', 200000, DATE '2002-01-01', 1, 1, false),
('Opel', 150000, DATE '2012-01-01', 2, 1, false),
('Audi', 150000, DATE '2012-01-01', 3, 2, true);

INSERT INTO MAINTAINS (n_employee_id, n_car_id,s_comment, d_date_maintained)
VALUES
(1,2, 'everything is clean', DATE '2021-05-12'),
(1,1, 'bumper got dented', DATE '2021-05-12'),
(2,1, null, DATE '2021-05-21');


INSERT INTO RENT (n_car_id, n_duration, n_free_kilometers, n_customer_id, n_employee_id, b_is_returned, d_date_rented)
VALUES
(1, 5, 100, 1, 1, false, DATE '2021-05-12'),
(2, 1, 100, 2, 1, false, DATE '2021-05-12');

INSERT INTO PAYMENT (n_rent_id, n_payment_amount, d_payment_date)
VALUES
(1, 1250.00, DATE '2021-05-12'),
(2, 99.00, DATE '2021-05-12');

create or replace procedure rent_car( 
    carID INT,
    customerID INT,
    employeeID INT,
    duration INT
)
language plpgsql
AS '
BEGIN
    
    IF (SELECT b_is_available
        FROM CAR
        WHERE   CAR.n_car_id = carID) 
        AND NOT
        (SELECT count(*)
        FROM RENT
        WHERE RENT.n_customer_id = customerID AND RENT.b_is_returned = false) > 0
    THEN
        UPDATE CAR
        SET b_is_available = false
        WHERE CAR.n_car_id = carID;

        UPDATE BRANCH
        SET n_parking_spaces = n_parking_spaces + 1
        WHERE n_branch_id = (SELECT n_branch_id FROM CAR WHERE CAR.n_car_id = carID);

        INSERT INTO RENT (n_car_id, n_duration, n_customer_id, n_employee_id, b_is_returned)
        VALUES
        (carID, duration, customerID, employeeID, false);
    
    ELSE 
        RAISE EXCEPTION ''car is not available/ customer already has an active rent''; 
    END IF;

END;'
;



CREATE OR REPLACE FUNCTION car_returned()
	RETURNS TRIGGER
	LANGUAGE PLPGSQL
	AS '
		BEGIN			
			IF new.b_is_returned
            
            THEN

                
                IF (new.n_mileage_returned - (select n_mileage FROM CAR WHERE CAR.n_car_id = new.n_car_id)) > new.n_free_kilometers

                THEN 

                INSERT INTO PAYMENT (n_rent_id, n_payment_amount)
                VALUES
                (new.n_rent_id, ((new.n_mileage_returned - (select n_mileage FROM CAR WHERE CAR.n_car_id = new.n_car_id)) * 
                (select price.n_price_per_kilometer FROM CAR LEFT JOIN PRICE ON (CAR.n_price_id = PRICE.n_price_id) where CAR.n_car_id = new.n_car_id)));

                END IF;


            UPDATE CAR
            SET 
             n_mileage = new.n_mileage_returned,
             b_is_available = true
            WHERE CAR.n_car_id = new.n_car_id;

            UPDATE BRANCH
            SET n_parking_spaces = n_parking_spaces - 1
            WHERE BRANCH.n_branch_id = (select n_branch_id from RENT LEFT JOIN CAR ON (RENT.n_car_id = CAR.n_car_id) where CAR.n_car_id = new.n_car_id);

	   	    END IF;
	   	
	   	RETURN NEW;
		END;
		';

CREATE TRIGGER car_returned 
AFTER UPDATE
ON RENT
FOR EACH ROW
EXECUTE PROCEDURE car_returned();

CREATE VIEW car_overview AS
SELECT  c.n_car_id Car_id,
        c.s_brand Car_brand, 
        p.n_price_per_day Price,
        p.s_price_class Price_Class,
        a.s_street || ' ' || a.s_house_number Current_Location,
        a.n_zipcode Zipcode
FROM car AS c
LEFT JOIN price AS p ON (c.n_price_id = p.n_price_id)
LEFT JOIN branch AS b ON (c.n_branch_id = b.n_branch_id)
LEFT JOIN addresses AS a ON (b.n_address_id = a.n_address_id)
GROUP BY Car_id, Price, Price_Class, Current_Location, Zipcode;
