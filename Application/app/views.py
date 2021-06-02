from flask import Flask, redirect, url_for, render_template, request
from app import app, engine, session
from app.query import *
from datetime import datetime


#Home route
@app.route("/")
def index():
    return manager_dashboard()

#Manager dashboard
@app.route("/manager_dashboard")
def manager_dashboard():
    branch, bRevenue = qSalesPerBranch()
    employee, eRevenue, eSales = qSalesPerEmployee()
    return render_template('manager_dashboard.html', branch=branch, bRevenue=bRevenue, employee=employee, eRevenue=eRevenue, eSales=eSales)

#Shows all rents
@app.route("/list_rents")
def list_rents():
    rent_id, car_id, duration, free_kilometers, customer_id, employee_id, is_returned, date_rented, date_returned, employee_id_returned, mileage_returned = qRents()
    return render_template('list_rents.html', rent_id=rent_id, car_id=car_id, duration=duration, free_kilometers=free_kilometers, customer_id=customer_id, employee_id=employee_id, is_returned=is_returned, date_rented=date_rented, date_returned=date_returned, employee_id_returned=employee_id_returned, mileage_returned=mileage_returned)

#Shows all available cars
@app.route("/list_cars")
def list_cars():
    car_id, brand, mileage, date_bought, price_id, branch_id, is_available = qListCars()
    return render_template('list_cars.html', car_id=car_id, brand=brand, mileage=mileage, date_bought=date_bought, price_id=price_id, branch_id=branch_id, is_available=is_available)

#Shows all customers
@app.route("/list_customers")
def list_customers():
    customer_id, fname, lname, dob, license_id, address = qListCustomers()
    return render_template('list_customers.html', customer_id=customer_id, fname=fname, lname=lname, dob=dob, license_id=license_id, address=address)

#Leads to new_rent page. New rents are created with POST form.
@app.route("/new_rent")
def new_rent():
    return render_template("new_rent.html")


#Passes active rents to front end, so the information can be updated
@app.route("/update_customer_rent")
def update_customer_rent():
    rent_id, car_id, duration, free_kilometers, customer_id, employee_id, is_returned, date_rented, date_returned, employee_id_returned, mileage_returned = qRentsActive()
    return render_template('update_customer_rent.html', rent_id=rent_id, car_id=car_id, duration=duration, free_kilometers=free_kilometers, customer_id=customer_id, employee_id=employee_id, is_returned=is_returned, date_rented=date_rented, date_returned=date_returned, employee_id_returned=employee_id_returned, mileage_returned=mileage_returned)

#Receives the values to be updated and updates the row in the database
@app.route("/update_rent/<int:rentid>", methods=["POST","GET"])
def update(rentid):
    duration = request.form['duration']
    test = engine.execute("UPDATE RENT SET n_duration = %s WHERE n_rent_id = %s;" %(duration, rentid))
    return update_customer_rent()

#Begins a transaction for returning a car. Check ../db/transaction.sql for more info.
@app.route("/return_rent/<rentID>/<eID>/<mileage>/<comment>", methods=["POST","GET"])
def return_rent(rentID, eID, mileage, comment):
    test = engine.execute('''
    BEGIN TRANSACTION;
    update RENT
    set b_is_returned = true, 
    n_employee_id_returned = %s,
    n_mileage_returned = %s,
    d_date_returned = CURRENT_DATE
    where RENT.n_rent_id = %s;

    INSERT INTO MAINTAINS(n_employee_id, n_car_id, s_comment)
    VALUES
    (%s, (SELECT n_car_id from RENT where n_rent_id = %s), '%s');

    COMMIT;
    ''' %(eID,mileage,rentID,eID, rentID, comment))
    return update_customer_rent()


#Deletes a car or deactivates it if it has already been used (e.g. in old rents)
@app.route("/delete_car/<int:id>", methods=["POST","GET"])
def delete_Car(id):
    try:
        update = engine.execute("DELETE FROM CAR WHERE n_car_id = %s;" %(id))
    except:
        update = engine.execute("UPDATE CAR SET b_is_available = false WHERE n_car_id = %s;" %(id))
    return list_cars()


#Creates a new car by receiving the necessary information from a form via POST
@app.route("/add_car", methods=["POST","GET"])
def add_car():
    brand = request.form['carBrand']
    mileage = request.form['Mileage']
    date_bought = request.form['Date']
    price = request.form['Price']
    branch = request.form['Branch']
    try:
        available = [True if str(request.form['Available']) == 'on' else False][0] 
    except:
        available = False

    test = engine.execute('\
    INSERT INTO CAR (s_brand, n_mileage, d_date_bought, n_price_id, n_branch_id, b_is_available)\
    VALUES\
    (%s, %s, %s, %s, %s, %s)',(brand, int(mileage), datetime.strptime(date_bought, '%Y-%m-%d').strftime("%d-%m-%Y"), int(price), int(branch), available))
    return list_cars()

#Creates a new address by receiving the necessary information from a form via POST
def cNewAddress(street, houseno, city, country, zipcode):
    insert = engine.execute('\
    INSERT INTO ADDRESSES (s_street, s_house_number, s_city, s_country, n_zipcode)\
    VALUES\
    (%s, %s, %s, %s, %s)',(street, houseno, city, country, zipcode))

    idReturn = [row[0] for row in engine.execute('SELECT MAX(n_address_id)FROM ADDRESSES;').fetchall()][0]

    return idReturn

#Creates a new customer by receiving the necessary information from a form via POST
@app.route("/add_customer", methods=["POST","GET"])
def add_customer():
    addressID = cNewAddress(request.form['street'], request.form['house_number'], request.form['city'], request.form['country'], request.form['zipcode'])
    
    fname = request.form['fname']
    lname = request.form['lname']
    dob = request.form['dob']
    carLicense = request.form['license']

    test = engine.execute('\
    INSERT INTO CUSTOMER (s_first_name, s_last_name, d_date_of_birth, s_license_id, n_address_id)\
    VALUES\
    (%s, %s, %s, %s, %s)',(fname, lname, dob, carLicense, addressID))
    return list_customers()

#Creates a new rent by receiving the necessary information from a form via POST. Check ../db/transaction.sql for more info.
@app.route("/add_rent", methods=["POST","GET"])
def add_rent():
    carid = request.form['carid']
    duration = request.form['duration']
    customer = request.form['customer']
    employee = request.form['employee']

    insert = engine.execute('''
    BEGIN TRANSACTION;

    CALL rent_car(%s,%s,%s,%s);

    INSERT INTO PAYMENT (n_rent_id, n_payment_amount)
    VALUES
    ((SELECT max(n_rent_id) FROM RENT), 
    %s * (SELECT n_price_per_day FROM CAR LEFT JOIN PRICE ON (CAR.n_price_id = PRICE.n_price_id) WHERE CAR.n_car_id = %s));

    COMMIT;
    ''',(carid, customer, employee, duration, duration, carid))
    return list_rents()