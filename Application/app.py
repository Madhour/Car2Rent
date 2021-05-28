from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask import Flask, render_template, request, redirect
from flask_bootstrap import Bootstrap
from flask_wtf import FlaskForm
from wtforms import SubmitField, SelectField, RadioField, HiddenField, StringField, IntegerField, FloatField
from wtforms.validators import InputRequired, Length, Regexp, NumberRange
from datetime import datetime
from datetime import date
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from decimal import Decimal

app = Flask(__name__)
Bootstrap(app)
db = SQLAlchemy(app)

engine = create_engine('postgresql://postgres@localhost/carrent')
#engine = create_engine('postgresql://postgres:Khei1234@localhost/carrent')

# create a configured "Session" class
Session = sessionmaker(bind=engine)

# create a Session
session = Session()


#Routes
@app.route("/")
def index():
    cNewAddress()
    return render_template('index.html')

@app.route("/new_rent")
def new_rent():
    return render_template('new_rent.html')

@app.route("/list_rents")
def list_rents():
    return render_template('list_rents.html')

@app.route("/return_car")
def return_car():
    return render_template('return_car.html')

@app.route("/new_customer")
def new_customer():
    return render_template('new_customer.html')

@app.route("/list_customers")
def list_customers():
    customer_id, fname, lname, dob, license_id, address = qListCustomers()
    return render_template('list_customers.html', customer_id=customer_id, fname=fname, lname=lname, dob=dob, license_id=license_id, address=address)

@app.route("/update_customer_rent")
def update_customer_rent():
    return render_template('update_customer_rent.html')

#@app.route("/list_cars/<string:car_id>")
@app.route("/list_cars")
def list_cars():
    car_id, brand, mileage, date_bought, price_id, branch_id, is_available = qListCars()
    return render_template('list_cars.html', car_id=car_id, brand=brand, mileage=mileage, date_bought=date_bought, price_id=price_id, branch_id=branch_id, is_available=is_available)

@app.route("/manager_dashboard")
def manager_dashboard():
    branch, bRevenue = qSalesPerBranch()
    employee, eRevenue, eSales = qSalesPerEmployee()
    print(branch)
    return render_template('manager_dashboard.html', branch=branch, bRevenue=bRevenue, employee=employee, eRevenue=eRevenue, eSales=eSales)

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
    'SELECT * FROM CAR WHERE b_is_available = true;').fetchall()

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

#Create
#def cNewAddress(street, houseno, city, country, zipcode):
def cNewAddress():
    street="leicester rd"
    houseno="1a"
    city="manchester"
    country="england"
    zipcode="1234"
    #listCustomers = engine.execute("INSERT INTO ADDRESSES (s_street, s_house_number, s_city, s_country, n_zipcode) VALUES (?, ?, ?, ?, ?)", street, houseno, city, country, zipcode)

    return 

def cNewCustomer(fname, lname, dob, license, address):
    #creates address in address id
    
    return

if __name__ == "__main__":
    app.debug = True
    app.run(host='0.0.0.0', port=5001)