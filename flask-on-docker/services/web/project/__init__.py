from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask import Flask, render_template, request, redirect

app = Flask(__name__)
#app.config.from_object("project.config.Config")
db = SQLAlchemy(app)

#Routes
@app.route("/")
def Index():
    return render_template('index.html')

#Create
@app.route("/create", methods = ['POST'])
def create():
    return render_template('create.html')

#Read
@app.route("/read")
def read():
    return render_template('read.html')

#Delete
@app.route("/edit_delete")
def edit_delete():
    return render_template('edit_delete.html')

if __name__ == "__main__":
    app.debug = True
    app.run(host='localhost', port=5000)

# Data Table Identification
# identify all columns by name and data type

#Cars
class Car(db.Model):
    __tablename__ = 'car'
    id = db.Column(db.Integer, primary_key=True)
    brand = db.Column(db.String)
    kilometers = db.Column(db.Integer)
    price_id = db.Column(db.Integer)
    branch_id = db.Column(db.Integer)
    is_available = db.Column(db.Boolean)
    licence_class = db.Column(db.String)
    dt_year = db.Column(db.Integer)

    def __init__(self, brand, kilometers, price_id, branch_id, is_available, licence_class, dt_year):
        self.brand = brand
        self.price_id = price_id
        self.branch_id = branch_id
        self.is_available = is_available
        self.licence_class = licence_class
        self.dt_year = dt_year
        self.kilometers = kilometers

#Transactions
class Transactions(db.Model):
    __tablename__ = 'transactions'
    id = db.Column(db.Integer, primary_key=True)
    customer_id = db.Column(db.Integer)
    employee_id = db.Column(db.Float)
    timestamp = db.Column(db.Integer)
   

    def __init__(self, employee_id, timestamp, customer_id):
        self.employee_id = employee_id
        self.customer_id = customer_id
        self.timestamp = timestamp

#Customer
class Customer(db.Model):
    __tablename__ = 'customer'
    id = db.Column(db.Integer, primary_key=True)
    license_id = db.Column(db.Integer)
    adress_id = db.Column(db.Integer)
    date_of_birth = db.Column(db.Integer)
    first_name = db.Column(db.String)
    last_name = db.Column(db.String)
   

    def __init__(self, license_id, adress_id, date_of_birth, first_name, last_name):
        self.license_id = license_id
        self.adress_id = adress_id
        self.date_of_birth = date_of_birth
        self.first_name = first_name
        self.last_name = last_name

#Employee
class Employee(db.Model):
    __tablename__ = 'employees'
    id = db.Column(db.Integer, primary_key=True)
    first_name = db.Column(db.String)
    last_name = db.Column(db.String)
    date_of_birth = db.Column(db.Integer)
    branch_id = db.Column(db.Integer)
    salary = db.Column(db.Integer)
    commission = db.Column(db.Integer)
    address_id = db.Column(db.Integer)

    def __init__(self, first_name, last_name, branch_id, date_of_birth, salary, commission, address_id):
        self.first_name = first_name
        self.last_name = last_name
        self.date_of_birth = date_of_birth
        self.salary = salary
        self.commission = commission
        self.address_id = address_id
        self.branch_id = branch_id

#Adresses
class Adresses(db.Model):
    __tablename__ = 'adresses'
    id = db.Column(db.Integer, primary_key=True)
    country = db.Column(db.String)
    street = db.Column(db.String)
    city = db.Column(db.String)
    house_number = db.Column(db.Integer)
    zipcode = db.Column(db.Integer)
   

    def __init__(self, country, street, city, house_number, zipcode):
        self.country = country
        self.street = street
        self.city = city
        self.house_number = house_number
        self.zipcode = zipcode

#Branch   
class Branch(db.Model):
    __tablename__ = 'branch'
    id = db.Column(db.Integer, primary_key=True)
    manager_id = db.Column(db.Integer)
    parking_spaces = db.Column(db.Integer)
    address_id = db.Column(db.Integer)

    def __init__(self, manager_id, parking_spaces, address_id):
        self.manager_id = manager_id
        self.parking_spaces = parking_spaces
        self.address_id = address_id
            
#Price
class Price(db.Model):
    __tablename__ = 'price'
    id = db.Column(db.Integer, primary_key=True)
    price_class = db.Column(db.String)
    price_per_day = db.Column(db.Integer)
    price_per_kilometer = db.Column(db.Integer)
    security_deposit = db.Column(db.Integer)

    def __init__(self, price_class, price_per_day, price_per_kilometer, security_deposit):
        self.price_class = price_class
        self.price_per_day = price_per_day
        self.price_per_kilometer = price_per_kilometer
        self.security_deposit = security_deposit

#Rent
class Rent(db.Model):
    __tablename__ = 'rent'
    id = db.Column(db.Integer, primary_key=True)
    car_id = db.Column(db.Integer)
    duration = db.Column(db.Integer)
    free_kilometers = db.Column(db.Integer)
    customer_id = db.Column(db.Integer)
    employee_id = db.Column(db.Integer)
    transaction_id = db.Column(db.Integer)
    is_returned = db.Column(db.Boolean)
    date_returned = db.Column(db.Integer)
    date_rented = db.Column(db.Integer)
    employee_id_returned = db.Column(db.Integer)
    mileage_returned = db.Column(db.Integer)

    def __init__(self, duration, free_kilometers, transaction_id, is_returned, car_id, customer_id, employee_id, date_returned, date_rented, employee_id_returned, mileage_returned):
        self.duration = duration
        self.free_kilometers = free_kilometers
        self.transaction_id = transaction_id
        self.is_returned = is_returned
        self.car_id = car_id
        self.customer_id = customer_id
        self.employee_id = employee_id
        self.date_returned = date_returned
        self.date_rented = date_rented
        self.employee_id_renturned = employee_id_returned
        self.mileage_returned = mileage_returned

#Payment
class Payment(db.Model):
    __tablename__ = 'payment'
    rent_id = db.Column(db.Integer)
    payment_amount = db.Column(db.Integer)
    payment_date = db.Column(db.Integer)
    
    def __init__(self, rent_id, payment_amount,  payment_date):
        self.rent_id = rent_id
        self.payment_amount = payment_amount
        self.payment_date =  payment_date

#Maintains
class Maintains(db.Model):
    __tablename__ = 'maintains'
    id = db.Column(db.Integer, primary_key=True)
    employee_id = db.Column(db.Integer)
    car_id = db.Column(db.Integer)
    comment = db.Column(db.String)
    date_maintained = db.Column(db.Integer)
    
    def __init__(self, employee_id, car_id, comment, date_maintained):
        self.employee_id = employee_id
        self.car_id = car_id
        self.comment =  comment
        self.date_maintained =  date_maintained
