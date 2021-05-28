--1.) How Many Cars per price class

SELECT P.s_price_class AS price_Class, count(c.n_car_id) AS available_Cars
FROM  CAR AS C LEFT JOIN PRICE AS P ON (C.n_price_id = P.n_price_id)
WHERE C.b_is_available = true
GROUP BY P.s_price_class;

--2.) All available cars and their location (Branch), filtered by price class = Economic Line
SELECT c.n_car_id AS car_ID, c.s_brand AS car_Brand, c.n_mileage AS car_Mileage, c.dt_date_bought AS Year_Of_Manufacture, a.s_street ||' '|| a.s_house_number AS car_location
FROM CAR AS c LEFT JOIN BRANCH AS b ON (c.n_branch_id = b.n_branch_id)
              LEFT JOIN ADDRESSES AS a ON (b.n_address_id = a.n_address_id)
              LEFT JOIN PRICE AS p ON (c.n_price_id = p.n_price_id)
WHERE c.b_is_available = true AND p.s_price_class = 'Economic Line';

--3.) Rent history of all customers
SELECT  c.n_customer_id AS customer_ID, c.s_first_name ||' '|| c.s_last_name AS customer_Name, r.n_rent_id AS rent_ID, ca.s_brand AS car_Brand, r.d_date_rented AS date_rented, r.b_is_returned AS is_returned
FROM RENT AS r LEFT JOIN CUSTOMER AS c ON (r.n_customer_id = c.n_customer_id)
               LEFT JOIN CAR AS ca ON (r.n_car_id = ca.n_car_id);

    -- Rent history of one particular customer
    SELECT  r.n_rent_id AS rent_ID, ca.s_brand AS car_Brand, r.d_date_rented AS date_rented, r.b_is_returned AS is_returned
    FROM RENT AS r LEFT JOIN CUSTOMER AS c ON (r.n_customer_id = c.n_customer_id)
                   LEFT JOIN CAR AS ca ON (r.n_car_id = ca.n_car_id)
    WHERE c.n_customer_id = 1
    ORDER BY date_rented;

    -- amount of rents per customer
    SELECT  c.s_first_name ||' '|| c.s_last_name AS customer_Name, count(*) amount_Of_Rents
    FROM RENT AS r LEFT JOIN CUSTOMER AS c ON (r.n_customer_id = c.n_customer_id)
    GROUP BY customer_Name;

--4.) Amount of money made by branches
SELECT b.n_branch_id AS branch_ID, SUM(p.n_payment_amount) AS branch_Revenue
FROM PAYMENT AS p LEFT JOIN RENT AS r ON (p.n_rent_id = r.n_rent_id)
                  LEFT JOIN CAR AS c ON (r.n_car_id = c.n_car_id)
                  LEFT JOIN BRANCH AS b ON (c.n_branch_id = b.n_branch_id)
GROUP BY branch_ID;

--alternatively:
SELECT b.n_branch_id, SUM(amount)
FROM RENT AS r LEFT JOIN (SELECT p.n_rent_id,  SUM(p.n_payment_amount) AS amount FROM PAYMENT AS p GROUP BY p.n_rent_id) AS psum ON (r.n_rent_id = psum.n_rent_id)
               LEFT JOIN CAR AS c ON (r.n_car_id = c.n_car_id)
               RIGHT JOIN BRANCH AS b ON (b.n_branch_id = c.n_branch_id)
               GROUP BY b.n_branch_id;

--5.) Select amount of rents in the branch with the most free parking spaces
SELECT b.n_branch_id, count(*)
FROM BRANCH AS b RIGHT JOIN (RENT AS r LEFT JOIN CAR AS c ON (r.n_car_id = c.n_car_id)) AS rc ON (rc.n_branch_id = b.n_branch_id)
WHERE b.n_parking_spaces = (SELECT max(b.n_parking_spaces) FROM BRANCH AS b)
GROUP BY b.n_branch_id;

-- amount of rents per city
SELECT a.s_city AS city, sum(rc.sum_rents) AS sum_Rents
FROM BRANCH AS b LEFT JOIN (SELECT c.n_branch_id, count(*) AS sum_Rents
FROM RENT AS r LEFT JOIN CAR AS c ON (r.n_car_id = c.n_car_id)
GROUP BY c.n_branch_id) AS rc ON (b.n_branch_id = rc.n_branch_id) 
LEFT JOIN ADDRESSES AS a ON (b.n_address_id = a.n_address_id)
GROUP BY a.s_city;


--6.) Arbitrary query to demonstrate set operations
SELECT n_payment_amount AS payment, d_payment_date
FROM PAYMENT
WHERE d_payment_date BETWEEN DATE '2021-05-01' AND DATE '2021-05-15'

UNION ALL 

SELECT n_payment_amount AS payment, d_payment_date
FROM PAYMENT
WHERE d_payment_date BETWEEN DATE '2021-05-16' AND DATE '2021-05-31';
-- change accordingly to use except. So that one can say out of all sales made in the month, how many were made in the first week.


--7.) Revenue by employees
SELECT e.s_first_name ||' '|| e.s_last_name AS employee_Name, sum(p.n_payment_amount) AS net_sales
FROM RENT AS r RIGHT JOIN PAYMENT AS p ON (p.n_rent_id = r.n_rent_id)
               LEFT JOIN EMPLOYEE AS e ON (r.n_employee_id = e.n_employee_id)
GROUP BY e.n_employee_id;

SELECT e.s_first_name ||' '|| e.s_last_name AS employee_Name, COALESCE(sum(p.n_payment_amount), 0) AS net_sales
FROM RENT AS r RIGHT JOIN PAYMENT AS p ON (p.n_rent_id = r.n_rent_id)
               RIGHT JOIN EMPLOYEE AS e ON (e.n_employee_id = r.n_employee_id)
GROUP BY e.n_employee_id;


-- this one is the best one 
SELECT e.s_first_name ||' '|| e.s_last_name AS employee_Name, COALESCE(sum(p.n_payment_amount), 0) AS revenue, COALESCE(COUNT(r.n_rent_id), 0) AS sales
FROM RENT AS r RIGHT JOIN PAYMENT AS p ON (p.n_rent_id = r.n_rent_id)
               RIGHT JOIN EMPLOYEE AS e ON (e.n_employee_id = r.n_employee_id)
GROUP BY e.n_employee_id;