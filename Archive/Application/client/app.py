from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask import Flask, render_template, request, redirect
from flask_bootstrap import Bootstrap
from flask_wtf import FlaskForm
from wtforms import SubmitField, SelectField, RadioField, HiddenField, StringField, IntegerField, FloatField
from wtforms.validators import InputRequired, Length, Regexp, NumberRange
from datetime import date

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = "postgresql://postgres:postgres@localhost:5432/carrent"
app.config['SECRET_KEY'] = ''
#app.config['SECRET_KEY'] = 'MLXH243GssUWwKdTWS7FDhdwYF56wPj8'
Bootstrap(app)
db = SQLAlchemy(app)
migrate = Migrate(app, db)


#app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///' + db_name

#app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = True

# this variable, db, will be used for all SQLAlchemy commands

#<---------------------------------------------------------------->

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
    salary = db.Column(db.Integer)
    commission = db.Column(db.Integer)
    address_id = db.Column(db.Integer)

    def __init__(self, first_name, last_name, date_of_birth, salary, commission, address_id):
        self.first_name = first_name
        self.last_name = last_name
        self.date_of_birth = date_of_birth
        self.salary = salary
        self.commission = commission
        self.address_id = address_id

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
    duration = db.Column(db.Integer)
    free_kilometers = db.Column(db.Integer)
    transaction_id = db.Column(db.Integer)
    is_returned = db.Column(db.Boolean)

    def __init__(self, duration, free_kilometers, transaction_id, is_returned):
        self.duration = duration
        self.free_kilometers = free_kilometers
        self.transaction_id = transaction_id
        self.is_returned = is_returned

#Routes
@app.route("/")
def main():
    return render_template('index.html');
if __name__ == "__main__":
    app.debug = True
    app.run()


@app.route("/read")
def read():
    return render_template('read.html')

@app.route("/create")
def create():
    return render_template('create.html')

@app.route("/edit_delete")
def edit_delete():
    return render_template('edit_delete.html')

















"""
#Formcontrol
class AddRecord(FlaskForm):
    # id used only by update/edit
    id_field = HiddenField()
    brand = StringField('Brand name', [ InputRequired(),
        Regexp(r'^[A-Za-z\s\-\']+$', message="Invalid brand name"),
        Length(min=3, max=25, message="Invalid Brand name lengh")
        ])
    engine = StringField('Choose the engine', [ InputRequired(),
        Regexp(r'^[A-Za-z\s\-\']+$', message="Invalid engine"),
        Length(min=3, max=25, message="Invalid engine name lengh")
        ])
    trunkspace = FloatField('Choose trunkspace', [ InputRequired(),
        NumberRange(min=1.00, max=1200.99, message="Invalid trunkspace")
        ])
    transmission = SelectField('Choose the transmission', [ InputRequired()],
        choices=[ ('', ''), ('manual', 'Manual'),
        ('automatic', 'Automatic'),
         ])
    seats = IntegerField('Choose seats', [ InputRequired(),
        NumberRange(min=1.00, max=12.00, message="Invalid range")
        ])
    fuel = SelectField('Choose type of fuel', [ InputRequired()],
        choices=[ ('', ''), ('gasoline', 'Gasoline'),
        ('diesel', 'Diesel'),
        ('lpg', 'LPG'),
         ])
    price = FloatField('Retail price per day', [ InputRequired(),
        NumberRange(min=1.00, max=2000.00, message="Invalid price")
        ])
    status = SelectField('Choose status of car', [ InputRequired()],
        choices=[ ('', ''), ('available', 'Available'),
        ('unavailable', 'Unavailable'),
        ('in service', 'In Service'),
         ])
    year = SelectField('Choose building year', [ InputRequired()],
        choices=[ ('', ''), 
        ('2021', '2021'),('2020', '2020'),
        ('2019', '2019'),('2018', '2018'),
        ('2017', '2017'),('2016', '2016'),
        ('2015', '2015'),('2014', '2014'),
        ('2013', '2013'),('2012', '2012'),
        ('2011', '2011'),('2010', '2010'),
        ('2009', '2009'),('2008', '2008'),
        ('2007', '2007'),('2006', '2006'),
        ('2005', '2005'),('2004', '2004'),
        ('2003', '2003'),('2002', '2002'),
        ('2001', '2001'),('2000', '2000'),
         ])
    kilometer = IntegerField('Choose kilometer', [ InputRequired(),
        NumberRange(min=1.00, max=500000.00, message="Invalid range")])
    # updated - date - handled in the route function
    updated = HiddenField()
    submit = SubmitField('Add/Update Record')
"""

"""
# add a new car to the database
@app.route('/insert')
def insert():
    form1 = insert()
    if form1.validate_on_submit():
        brand = request.form['brand']
        engine = request.form['engine']
        trunkspace = request.form['trunkspace']
        transmission = request.form['transmission']
        seats = request.form['seats']
        fuel = request.form['fuel']
        price = request.form['price']
        status = request.form['status']
        year = request.form['year']
        kilometer = request.form['kilometer']
        #the data to be inserted into Car model - the table, cars
        record = Car(brand, engine, trunkspace, transmission, seats, fuel, price, status, year, kilometer, updated)
        # Flask-SQLAlchemy magic adds record to database
        db.session.add(record)
        db.session.commit()
        #create a message to send to the template
        #message = f"The data for car {brand} has been submitted."
    return render_template('insert.html');

# edit or delete - come here from form in /select_record
@app.route('/edit_or_delete', methods=['POST'])
def edit_or_delete():
    id = request.form['id']
    choice = request.form['choice']
    car = Car.query.filter(car.id == id).first()
    # two forms in this template
    form1 = AddRecord()
    form2 = DeleteForm()
    return render_template('edit_or_delete.html', car=car, form1=form1, form2=form2, choice=choice)

#list
@app.route('/list', methods=['GET'])
def list():
    return render_template('list.html');


# result of delete - this function deletes the record
@app.route('/delete_result', methods=['POST'])
def delete_result():
    id = request.form['id_field']
    purpose = request.form['purpose']
    car = Car.query.filter(Car.id == id).first()
    if purpose == 'delete':
        db.session.delete(car)
        db.session.commit()
        message = f"The Car {car.id} has been deleted from the database."
        return render_template('result.html', message=message)
    else:
        # this calls an error handler
        abort(405)


# result of edit - this function updates the record
@app.route('/edit_result', methods=['POST'])
def edit_result():
    id = request.form['id_field']
    # call up the record from the database
    car = Car.query.filter(Car.id == id).first()
    # update all values
    brand = request.form['brand']
    engine = request.form['engine']
    trunkspace = request.form['trunkspace']
    transmission = request.form['transmission']
    seats = request.form['seats']
    fuel = request.form['fuel']
    price = request.form['price']
    status = request.form['status']
    year = request.form['year']
    kilometer = request.form['kilometer']

    form1 = AddRecord()
    if form1.validate_on_submit():
        # update database record
        db.session.commit()
        # create a message to send to the template
        message = f"The data for car {car.id} has been updated."
        return render_template('result.html', message=message)
"""