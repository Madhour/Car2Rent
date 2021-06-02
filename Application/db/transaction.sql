/* 
1.) Transaction that makes an update. The update on the table RENT triggers the function car_returned(). 
Example: Customer returns rental car with rent id 1 back to the store.
Employee with id 1 handles the return.
The customer exceeded the free kilometers and has to pay an additional fee that is stored in payment.
After the return, the employee maintains the car, e.g. cleans it and notes down any new damages.
 */
BEGIN TRANSACTION;
UPDATE
    RENT
SET
    b_is_returned = TRUE,
    n_employee_id_returned = 1,
    n_mileage_returned = 211000,
    d_date_returned = CURRENT_DATE
WHERE
    RENT.n_rent_id = 1;
INSERT INTO MAINTAINS (n_employee_id, n_car_id, s_comment)
    VALUES (1, 1, 'the customer returned the car in a good condition');
COMMIT;


/*
2.) Transaction that calls the procedure rent_car(). Here the transaction raises an error because the customer already has an active rent.
Example: Car with id no. 1 is rented by costomer with id no. 2 for 5 days. Employee no. 1 handled the rent. 
The employee creates a new rent but since the customer already has an active rent, he can't rent a car. Because this is a transaction, the process
is just aborted and the DB is rollback to its previous state.
 */
BEGIN TRANSACTION;
CALL rent_car (1, 2, 1, 5);
INSERT INTO PAYMENT (n_rent_id, n_payment_amount)
    VALUES ((
            SELECT
                max(n_rent_id)
            FROM
                RENT),
            5 * (
                SELECT
                    n_price_per_day FROM CAR
                LEFT JOIN PRICE ON (CAR.n_price_id = PRICE.n_price_id)
            WHERE
                CAR.n_car_id = 1));
COMMIT;


/*
3.) Transaction that calls the procedure rent_car(), same as before but this time the transaction is successful.
Example: Car with id no. 1 is rented by costomer with id no. 1 for 2 days. Employee no. 1 handled the rent. 
The employee creates a new rent and because it doesn't raise any errors, it goes through and the customer pays the employee (days rented * price per day).
 */
BEGIN TRANSACTION;
CALL rent_car (1, 1, 1, 2);
INSERT INTO PAYMENT (n_rent_id, n_payment_amount)
    VALUES ((
            SELECT
                max(n_rent_id)
            FROM
                RENT),
            5 * (
                SELECT
                    n_price_per_day FROM CAR
                LEFT JOIN PRICE ON (CAR.n_price_id = PRICE.n_price_id)
            WHERE
                CAR.n_car_id = 1));
COMMIT;

