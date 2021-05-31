from flask import Flask, redirect, url_for, render_template, request
from app import app, engine, session, views
from datetime import datetime

#Queries
def qSalesPerBranch():
    salesPerBranch = engine.execute(
    'SELECT b.n_branch_id, COALESCE(CAST(SUM(amount) as FLOAT), 0)\
    FROM RENT AS r LEFT JOIN (SELECT p.n_rent_id,  SUM(p.n_payment_amount) AS amount FROM PAYMENT AS p GROUP BY p.n_rent_id) AS psum ON (r.n_rent_id = psum.n_rent_id)\
               LEFT JOIN CAR AS c ON (r.n_car_id = c.n_car_id)\
               RIGHT JOIN BRANCH AS b ON (b.n_branch_id = c.n_branch_id)\
               GROUP BY b.n_branch_id\
               ORDER BY b.n_branch_id;').fetchall()
    branch = [row[0] for row in salesPerBranch]
    revenue = [row[1] for row in salesPerBranch]
    return branch, revenue

def qRents():
    rents = engine.execute(
    '''
    SELECT n_rent_id, n_car_id, n_duration, n_free_kilometers, n_customer_id, n_employee_id, b_is_returned, d_date_rented, d_date_returned, n_employee_id_returned, n_mileage_returned
    FROM RENT
    ORDER BY n_rent_id;
    ''').fetchall()
    rent_id = [row[0] for row in rents]
    car_id  = [row[1] for row in rents]
    duration  = [row[2] for row in rents]
    free_kilometers = [row[3] for row in rents]
    customer_id  = [row[4] for row in rents]
    employee_id  = [row[5] for row in rents]
    is_returned  = [row[6] for row in rents]
    date_rented  = [row[7] for row in rents]
    date_returned  = ["-" if row[8] == None else row[8] for row in rents]
    employee_id_returned  = ["-" if row[9] == None else row[9] for row in rents]
    mileage_returned = ["-" if row[10] == None else row[10] for row in rents]

    return rent_id, car_id, duration, free_kilometers, customer_id, employee_id, is_returned, date_rented, date_returned, employee_id_returned, mileage_returned

def qRentsActive():
    rents = engine.execute(
    '''
    SELECT n_rent_id, n_car_id, n_duration, n_free_kilometers, n_customer_id, n_employee_id, b_is_returned, d_date_rented, d_date_returned, n_employee_id_returned, n_mileage_returned
    FROM RENT
    WHERE b_is_returned = false
    ORDER BY n_rent_id;
    ''').fetchall()
    rent_id = [row[0] for row in rents]
    car_id  = [row[1] for row in rents]
    duration  = [row[2] for row in rents]
    free_kilometers = [row[3] for row in rents]
    customer_id  = [row[4] for row in rents]
    employee_id  = [row[5] for row in rents]
    is_returned  = [row[6] for row in rents]
    date_rented  = [row[7] for row in rents]
    date_returned  = ["-" if row[8] == None else row[8] for row in rents]
    employee_id_returned  = ["-" if row[9] == None else row[9] for row in rents]
    mileage_returned = ["-" if row[10] == None else row[10] for row in rents]

    return rent_id, car_id, duration, free_kilometers, customer_id, employee_id, is_returned, date_rented, date_returned, employee_id_returned, mileage_returned


def qSalesPerEmployee():
    salesPerEmployee = engine.execute(
    "SELECT e.s_first_name ||' '|| e.s_last_name AS employee_Name, COALESCE(CAST(sum(p.n_payment_amount) as FLOAT), 0) AS revenue, COALESCE(CAST(COUNT(r.n_rent_id) AS INT), 0) AS sales\
               FROM RENT AS r RIGHT JOIN PAYMENT AS p ON (p.n_rent_id = r.n_rent_id)\
               RIGHT JOIN EMPLOYEE AS e ON (e.n_employee_id = r.n_employee_id)\
               GROUP BY e.n_employee_id\
               ORDER BY e.n_employee_id;").fetchall()
    employee = [row[0] for row in salesPerEmployee]
    revenue = [row[1] for row in salesPerEmployee]
    sales = [row[2] for row in salesPerEmployee]
    return employee, revenue, sales

def qListCars():
    listCars = engine.execute(
    'SELECT * FROM CAR WHERE b_is_available = true ORDER BY n_car_id;').fetchall()

    car_id = [row[0] for row in listCars]
    brand = [row[1] for row in listCars]
    mileage = [row[2] for row in listCars]
    date_bought = [row[3] for row in listCars]
    price_id = [row[4] for row in listCars]
    branch_id = [row[5] for row in listCars]
    is_available = [row[6] for row in listCars]

    return car_id, brand, mileage, date_bought, price_id, branch_id, is_available

def qListCustomers():
    listCustomers = engine.execute(
    "SELECT c.n_customer_id, c.s_first_name, c.s_last_name, c.dt_date_of_birth, c.s_license_id, a.s_street ||' '|| a.s_house_number as address FROM CUSTOMER as c LEFT JOIN addresses as a ON (c.n_address_id = a.n_address_id);").fetchall()

    customer_id = [row[0] for row in listCustomers]
    fname = [row[1] for row in listCustomers]
    lname = [row[2] for row in listCustomers]
    dob = [row[3] for row in listCustomers]
    license_id = [row[4] for row in listCustomers]
    address = [row[5] for row in listCustomers]


    return customer_id, fname, lname, dob, license_id, address

