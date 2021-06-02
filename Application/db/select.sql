--1.) List the amount of cars available per price class
SELECT
    P.s_price_class AS price_Class,
    count(c.n_car_id) AS available_Cars
FROM
    CAR AS C
    LEFT JOIN PRICE AS P ON (C.n_price_id = P.n_price_id)
WHERE
    C.b_is_available = TRUE
GROUP BY
    P.s_price_class;

--2.) Select all available 'economic Line' cars and their location
SELECT
    c.n_car_id AS car_ID,
    c.s_brand AS car_Brand,
    c.n_mileage AS car_Mileage,
    c.d_date_bought AS Year_Of_Manufacture,
    a.s_street || ' ' || a.s_house_number AS car_location
FROM
    CAR AS c
    LEFT JOIN BRANCH AS b ON (c.n_branch_id = b.n_branch_id)
    LEFT JOIN ADDRESSES AS a ON (b.n_address_id = a.n_address_id)
    LEFT JOIN PRICE AS p ON (c.n_price_id = p.n_price_id)
WHERE
    c.b_is_available = TRUE
    AND p.s_price_class = 'Economic Line';

--3.1) List the rent history of every customer
SELECT
    c.n_customer_id AS customer_ID,
    c.s_first_name || ' ' || c.s_last_name AS customer_Name,
    r.n_rent_id AS rent_ID,
    ca.s_brand AS car_Brand,
    r.d_date_rented AS date_rented,
    r.b_is_returned AS is_returned
FROM
    RENT AS r
    LEFT JOIN CUSTOMER AS c ON (r.n_customer_id = c.n_customer_id)
    LEFT JOIN CAR AS ca ON (r.n_car_id = ca.n_car_id);

--3.2) List the rent history of one particular customer, e.g. customer with id no. 1
SELECT
    r.n_rent_id AS rent_ID,
    ca.s_brand AS car_Brand,
    r.d_date_rented AS date_rented,
    r.b_is_returned AS is_returned
FROM
    RENT AS r
    LEFT JOIN CUSTOMER AS c ON (r.n_customer_id = c.n_customer_id)
    LEFT JOIN CAR AS ca ON (r.n_car_id = ca.n_car_id)
WHERE
    c.n_customer_id = 1
ORDER BY
    date_rented;

--3.3) List the amount of rents per customer
SELECT
    c.s_first_name || ' ' || c.s_last_name AS customer_Name,
    count(*) amount_Of_Rents
FROM
    RENT AS r
    LEFT JOIN CUSTOMER AS c ON (r.n_customer_id = c.n_customer_id)
GROUP BY
    customer_Name;

--4.1) Show the cumulated revenue of every branch
SELECT
    b.n_branch_id AS branch_ID,
    SUM(p.n_payment_amount) AS branch_Revenue
FROM
    PAYMENT AS p
    LEFT JOIN RENT AS r ON (p.n_rent_id = r.n_rent_id)
    LEFT JOIN CAR AS c ON (r.n_car_id = c.n_car_id)
    LEFT JOIN BRANCH AS b ON (c.n_branch_id = b.n_branch_id)
GROUP BY
    branch_ID;

--4.2) Show the cumulated revenue of every branch, including branches with zero revenue
SELECT
    b.n_branch_id,
    SUM(amount)
FROM
    RENT AS r
    LEFT JOIN (
        SELECT
            p.n_rent_id,
            SUM(p.n_payment_amount) AS amount
        FROM
            PAYMENT AS p
        GROUP BY
            p.n_rent_id) AS psum ON (r.n_rent_id = psum.n_rent_id)
    LEFT JOIN CAR AS c ON (r.n_car_id = c.n_car_id)
    RIGHT JOIN BRANCH AS b ON (b.n_branch_id = c.n_branch_id)
GROUP BY
    b.n_branch_id;

--5.1) List the amount of rents per city/branch
SELECT
    a.s_city AS city,
    sum(rc.sum_rents) AS sum_Rents
FROM
    BRANCH AS b
    LEFT JOIN (
        SELECT
            c.n_branch_id,
            count(*) AS sum_Rents
        FROM
            RENT AS r
            LEFT JOIN CAR AS c ON (r.n_car_id = c.n_car_id)
        GROUP BY
            c.n_branch_id) AS rc ON (b.n_branch_id = rc.n_branch_id)
    LEFT JOIN ADDRESSES AS a ON (b.n_address_id = a.n_address_id)
GROUP BY
    a.s_city;

--5.2) Show the total amount of rents in the branch with the most free parking spaces
SELECT
    b.n_branch_id,
    count(*)
FROM
    BRANCH AS b
    RIGHT JOIN (RENT AS r
        LEFT JOIN CAR AS c ON (r.n_car_id = c.n_car_id)) AS rc ON (rc.n_branch_id = b.n_branch_id)
WHERE
    b.n_parking_spaces = (
        SELECT
            max(b.n_parking_spaces)
        FROM
            BRANCH AS b)
GROUP BY
    b.n_branch_id;

--6.1) Out of all cars, how many were bought before 2010?
SELECT
    *
FROM
    CAR
EXCEPT
SELECT
    *
FROM
    CAR
WHERE
    d_date_bought >= DATE '2010-01-01';

--6.2) Lists all rents made in the first seven days of the month of may
SELECT
    *
FROM
    rent
WHERE
    d_date_rented BETWEEN DATE '2021-06-01'
    AND DATE '2021-06-30'
EXCEPT
SELECT
    *
FROM
    rent
WHERE
    d_date_rented >= DATE '2021-06-07';

--7.1) List the total revenue made by employees
SELECT
    e.s_first_name || ' ' || e.s_last_name AS employee_Name,
    sum(p.n_payment_amount) AS net_sales
FROM
    RENT AS r
    RIGHT JOIN PAYMENT AS p ON (p.n_rent_id = r.n_rent_id)
    LEFT JOIN EMPLOYEE AS e ON (r.n_employee_id = e.n_employee_id)
GROUP BY
    e.n_employee_id;

--7.2) List the total revenue made by employees, including employees that made zero revenue
SELECT
    e.s_first_name || ' ' || e.s_last_name AS employee_Name,
    COALESCE(sum(p.n_payment_amount), 0) AS revenue,
    COALESCE(COUNT(r.n_rent_id), 0) AS sales
FROM
    RENT AS r
    RIGHT JOIN PAYMENT AS p ON (p.n_rent_id = r.n_rent_id)
    RIGHT JOIN EMPLOYEE AS e ON (e.n_employee_id = r.n_employee_id)
GROUP BY
    e.n_employee_id;

