from flask import Flask, redirect, url_for, render_template, request
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker


'''
WARNING: DEPRECEATED

USE /Application/run.py

'''



app = Flask(__name__)
db = SQLAlchemy(app)

#engine = create_engine('postgresql://postgres@localhost:5432/carrent')
engine = create_engine('postgresql://postgres:car2rent@database:5432/postgres')

Session = sessionmaker(bind=engine)

session = Session()


#init db
try:
    engine.execute("SELECT * FROM RENT where n_rent_id = 1;")
except:
    sql_statement = open("./db/init.sql", "r").read()
    engine.execute(sql_statement)


#Routes
@app.route("/")
def index():
    return manager_dashboard()

@app.route("/new_rent")
def new_rent():
    return render_template("new_rent.html")

@app.route("/list_rents")
def list_rents():
    rent_id, car_id, duration, free_kilometers, customer_id, employee_id, is_returned, date_rented, date_returned, employee_id_returned, mileage_returned = qRents()
    return render_template('list_rents.html', rent_id=rent_id, car_id=car_id, duration=duration, free_kilometers=free_kilometers, customer_id=customer_id, employee_id=employee_id, is_returned=is_returned, date_rented=date_rented, date_returned=date_returned, employee_id_returned=employee_id_returned, mileage_returned=mileage_returned)

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
    rent_id, car_id, duration, free_kilometers, customer_id, employee_id, is_returned, date_rented, date_returned, employee_id_returned, mileage_returned = qRentsActive()
    return render_template('update_customer_rent.html', rent_id=rent_id, car_id=car_id, duration=duration, free_kilometers=free_kilometers, customer_id=customer_id, employee_id=employee_id, is_returned=is_returned, date_rented=date_rented, date_returned=date_returned, employee_id_returned=employee_id_returned, mileage_returned=mileage_returned)

#@app.route("/list_cars/<string:car_id>")
@app.route("/list_cars")
def list_cars():
    car_id, brand, mileage, date_bought, price_id, branch_id, is_available = qListCars()
    return render_template('list_cars.html', car_id=car_id, brand=brand, mileage=mileage, date_bought=date_bought, price_id=price_id, branch_id=branch_id, is_available=is_available)

@app.route("/delete_car/<int:id>", methods=["POST","GET"])
def delete_Car(id):
    try:
        update = engine.execute("DELETE FROM CAR WHERE n_car_id = %s;" %(id))
    except:
        update = engine.execute("UPDATE CAR SET b_is_available = false WHERE n_car_id = %s;" %(id))
    return list_cars()


@app.route("/update_rent/<int:rentid>", methods=["POST","GET"])
def update(rentid):
    duration = request.form['duration']
    test = engine.execute("UPDATE RENT SET n_duration = %s WHERE n_rent_id = %s;" %(duration, rentid))
    return update_customer_rent()

@app.route("/return_rent/<rentID>/<eID>/<mileage>/<comment>", methods=["POST","GET"])
def return_rent(rentID, eID, mileage, comment):
    test = engine.execute('''
    BEGIN TRANSACTION;

    --Example: Customer returns rental car with rent id 1 back to the store.
    --Employee with id 1 handles the return. 
    --The customer exceeded the free kilometers and has to pay an additional fee that is stored in payment.
    update RENT
    set b_is_returned = true, 
    n_employee_id_returned = %s,
    n_mileage_returned = %s,
    d_date_returned = CURRENT_DATE
    where RENT.n_rent_id = %s;

    -- after the return, the employee maintains the car, e.g. cleans it and notes down any new damages.
    INSERT INTO MAINTAINS(n_employee_id, n_car_id, s_comment)
    VALUES
    (%s, (SELECT n_car_id from RENT where n_rent_id = %s), '%s');

    COMMIT;
    ''' %(eID,mileage,rentID,eID, rentID, comment))
    return update_customer_rent()

@app.route("/manager_dashboard")
def manager_dashboard():
    branch, bRevenue = qSalesPerBranch()
    employee, eRevenue, eSales = qSalesPerEmployee()
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

#Create
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
    INSERT INTO CAR (s_brand, n_mileage, dt_date_bought, n_price_id, n_branch_id, b_is_available)\
    VALUES\
    (%s, %s, %s, %s, %s, %s)',(brand, int(mileage), datetime.strptime(date_bought, '%Y-%m-%d').strftime("%d-%m-%Y"), int(price), int(branch), available))
    return list_cars()

def cNewAddress(street, houseno, city, country, zipcode):
    insert = engine.execute('\
    INSERT INTO ADDRESSES (s_street, s_house_number, s_city, s_country, n_zipcode)\
    VALUES\
    (%s, %s, %s, %s, %s)',(street, houseno, city, country, zipcode))

    idReturn = [row[0] for row in engine.execute('SELECT MAX(n_address_id)FROM ADDRESSES;').fetchall()][0]

    return idReturn

@app.route("/add_customer", methods=["POST","GET"])
def add_customer():
    addressID = cNewAddress(request.form['street'], request.form['house_number'], request.form['city'], request.form['country'], request.form['zipcode'])
    
    fname = request.form['fname']
    lname = request.form['lname']
    dob = request.form['dob']
    carLicense = request.form['license']

    test = engine.execute('\
    INSERT INTO CUSTOMER (s_first_name, s_last_name, dt_date_of_birth, s_license_id, n_address_id)\
    VALUES\
    (%s, %s, %s, %s, %s)',(fname, lname, dob, carLicense, addressID))
    return list_customers()

@app.route("/add_rent", methods=["POST","GET"])
def add_rent():
    carid = request.form['carid']
    duration = request.form['duration']
    customer = request.form['customer']
    employee = request.form['employee']

    insert = engine.execute('''
    BEGIN TRANSACTION;

    --Car with id no. 1 is rented by costomer with id no. 2 for 5 days. Employee no. 1 handled the rent.
    CALL rent_car(%s,%s,%s,%s);

    --Customer pays the employee (days rented * price per day)
    INSERT INTO PAYMENT (n_rent_id, n_payment_amount)
    VALUES
    ((SELECT max(n_rent_id) FROM RENT), 
    %s * (SELECT n_price_per_day FROM CAR LEFT JOIN PRICE ON (CAR.n_price_id = PRICE.n_price_id) WHERE CAR.n_car_id = %s));

    COMMIT;
    ''',(carid, customer, employee, duration, duration, carid))
    return list_rents()

if __name__ == "__main__":
    app.debug = True
    app.run(host='0.0.0.0')