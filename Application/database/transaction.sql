--1.) TRANSACTION example with procedure that is triggered upon update
BEGIN TRANSACTION;

--Example: Customer returns rental car with rent id 1 back to the store.
--Employee with id 1 handles the return. 
--The customer exceeded the free kilometers and has to pay an additional fee that is stored in payment.
update RENT
set b_is_returned = true, 
n_employee_id_returned = 1,
n_mileage_returned = 211000,
d_date_returned = CURRENT_DATE
where RENT.n_rent_id = 1;

-- after the return, the employee maintains the car, e.g. cleans it and notes down any new damages.
INSERT INTO MAINTAINS(n_employee_id, n_car_id, s_comment)
VALUES
(1, 1, 'the customer returned the car in a good condition');

COMMIT;


--2.) TRANSACTION example that calls a procedure
--Employee creates a new rent but since the customer already has an active rent, he can't rent a car
--The beauty of this is that because this is in a transaction, it just gets aborted and a ROLLBACK sets the DB back to its old state
BEGIN TRANSACTION;

--Car with id no. 1 is rented by costomer with id no. 2 for 5 days. Employee no. 1 handled the rent.
CALL rent_car(1,2,1,5);

--Customer pays the employee (days rented * price per day)
INSERT INTO PAYMENT (n_rent_id, n_payment_amount)
VALUES
((SELECT max(n_rent_id) FROM RENT), 
5 * (SELECT n_price_per_day FROM CAR LEFT JOIN PRICE ON (CAR.n_price_id = PRICE.n_price_id) WHERE CAR.n_car_id = 1));

COMMIT;


--3.) TRANSACTION example that calls a procedure
-- Employee creates a new rent for customer number 1 who has no active rents going on.
-- This rent is successful, so the customer creates a payment in the next step
BEGIN TRANSACTION;

--Car with id no. 1 is rented by costomer with id no. 2 for 5 days. Employee no. 1 handled the rent.
CALL rent_car(1,1,1,2);

--Customer pays the employee (days rented * price per day)
INSERT INTO PAYMENT (n_rent_id, n_payment_amount)
VALUES
((SELECT max(n_rent_id) FROM RENT), 
5 * (SELECT n_price_per_day FROM CAR LEFT JOIN PRICE ON (CAR.n_price_id = PRICE.n_price_id) WHERE CAR.n_car_id = 1));

COMMIT;

