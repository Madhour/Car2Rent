DROP VIEW IF EXISTS car_overview;
ALTER TABLE IF EXISTS EMPLOYEE DROP CONSTRAINT IF EXISTS branch_emp;
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

--contains all addresses and is refered to in branch, customer and employee tables
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

--contains employee information
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

--contains customer information
CREATE TABLE CUSTOMER
(
n_customer_id 	SERIAL UNIQUE		NOT NULL,
s_first_name 	VARCHAR(128) 		NOT NULL,
s_last_name   VARCHAR(128)			NOT NULL,
dt_date_of_birth  DATE,
s_license_id   VARCHAR(3),--customers need a license class b to rent car
n_address_id	INT,
PRIMARY KEY (n_customer_id),
FOREIGN KEY (n_address_id) REFERENCES ADDRESSES(n_address_id) 
);

--company is divided into departments. Each department has employee who manages the branch
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

--each car has a price class that sets price per day etc.
CREATE TABLE PRICE
(
n_price_id         SERIAL UNIQUE		NOT NULL,
s_price_class      VARCHAR(128)         NOT NULL,
n_price_per_day      NUMERIC(15, 2),
n_price_per_kilometer NUMERIC(15, 2),
n_security_deposit  NUMERIC(15, 2),
PRIMARY KEY (n_price_id)
);

--each branch has cars that are parked there. Cars have a unique Number and single location.
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
n_duration          INT              NOT NULL,  --in days
n_free_kilometers INT   DEFAULT 100,
n_customer_id   INT     NOT NULL,
n_employee_id   INT     NOT NULL,
b_is_returned           BOOL              NOT NULL DEFAULT false, 
d_date_rented         DATE             NOT NULL DEFAULT CURRENT_DATE,
d_date_returned     DATE,
n_employee_id_returned INT,
n_mileage_returned INT,
PRIMARY KEY (n_rent_id),
FOREIGN KEY (n_car_id) REFERENCES CAR(n_car_id),
FOREIGN KEY (n_customer_id) REFERENCES CUSTOMER(n_customer_id), 
FOREIGN KEY (n_employee_id) REFERENCES EMPLOYEE(n_employee_id) 
);

--many payments per rent are possible: a rent can be payed in many smaller payments or an exceeded km amount can be added later on
CREATE TABLE PAYMENT
(
n_rent_id INT       NOT NULL,
n_payment_amount NUMERIC(15,2)  NOT NULL,
d_payment_date DATE     NOT NULL DEFAULT CURRENT_DATE, 
PRIMARY KEY (n_rent_id, d_payment_date),
FOREIGN KEY (n_rent_id) REFERENCES  RENT(n_rent_id)
);

-- definition WE: cannot exist by its attributes alone, therefore, it must use a foreign key in conjunction with its attributes to create a primary key

ALTER TABLE EMPLOYEE
    ADD CONSTRAINT branch_emp 
    FOREIGN KEY (n_branch_id) REFERENCES BRANCH(n_branch_id);