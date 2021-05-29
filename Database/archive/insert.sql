--fill database with dummy data
INSERT INTO ADDRESSES (s_street, s_house_number, s_city, s_country, n_zipcode)
VALUES
('Coblitzallee', 1, 'Mannheim', 'Germany', 68163),
('Hans-Thoma-Straße', 2, 'Mannheim', 'Germany', 68163),
('Mannheimerstraße', 14, 'Kaiserslautern', 'Germany', 67655),
('Broadway', 13, 'New York', 'USA', 10007);

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
