![Logo](/Docs/assets/Logo_v2.png)
===

## Usage 

To use the Application a Docker Container needs to be started as in the following.

```bash
cd services/web

docker-compose exec web python manage.py create_db
```

##  Used Technologies

Python 3.9.5 ; Flask 1.1.2 ; SQLAlchemy 2.5.1; psycopg2 2.8.6



## Table of Contents
- [Introduction](#Introduction)
- [Team](#Team)
- [Application](#Application)
  - [Specification](#Specification)
  - [ERM](#ERM)
  - [Normalization](#Normalization)
  - [Backend](#Backend)
  - [Frontend](#Frontend)  
- [Learnings](#Learnings)

## Introduction

Car rental services aren´t always that easy to manage. Most importantly when it comes to handling a massive Dataload of Customers, their Adresses, Transactions, the Fleet and so on. CarRent is a WebApp for Employees of Car Renting Companies that exactly solves that provblem. It is build to support the employees with the feature to grow if the Rental company needs to switch or buy new cars.

## Team

- [Ayman Madhour](https://github.com/Madhour)
- [Lukas Bach](https://github.com/lukasbach00)
- [Jorgo Paschaloglou](https://github.com/JorgoPascha)

## Application

The Application is completely Dockerized and uses a Flask server including .html Templates to build the Frontend and connect to the Postgres Database in the Backend. 

### ERM

<br><br>

![ER](https://github.com/Madhour/CarRent/blob/main/Application/database/erm/ERM_Final.png?raw=true)

<br><br>

### Normalization

<br><br>

![Norm](https://github.com/Madhour/CarRent/blob/main/Application/database/erm/3_Normalform-Page-1.png?raw=true)

## Backend 

### Specification

Cars: car_id, brand, mileage, date_bought, price_id, branch_id, is_available (available/already rented)
- Every car is tracked and categorized by the above mentioned values. If it is already rented is_available will be 0 otherwise 1.
---

Customer: customer_id, first_name, last_name, date_of_birth, license_id, adress_id
- Customers are stored by customer_id, etc. A customer must have a license. The attribute "license_id" contains the class, allowed to drive.
---

Employee: employee_id, first_name, last_name, date_of_birth, branch_id, salary, commision, adress_id
- Employees are tracked as well. An Employee can manage a branch and issues the rental.
---

Branch: branch_id, manager_id, parking_spaces, adress_id
- Every location is supervised by a manager. A car can be rented from any branch. If a car is rented, the free parking space is increased
---

Rent: rent_id, car_id, duration, free_kilometers, customer_id, employee_id, is_returned, date_rented, date_returned, employee_id_returned, mileage_returned
- A customer can only rent one car. mileage_returned is at first null and upon return updated. Every car that is rented must be issued by an employee.
- The price is derived from the car price which is stored in another table "Price".
---

Price: price_id, price_class, price_per_day, price_per_kilometer, security_deposit
- Prices are usually per day. If a fix amount of kilometers is exceeded then an additional price is due.d (Every car has a fix insurance price.)
---

Maintains: maintain_id, employee_id, car_id, comment, date_maintained
- After the rental is returned, the employee has to maintain the car, e.g. clean it and note down any possible damages
---

Payment: rent_id, payment_amount, payment_date
- Every rent has a payment. If a certain km amount was exceeded, then the customer has to pay additional fees upon return
---

Addresses: address_id, street, house_number, city, country, zipcode
- Customers, Employees and Branches refer to addresses. This is useful because it ensures that every address follows the same format/structure
---

## Frontend

![Frontend](https://github.com/Madhour/CarRent/blob/main/Application/client/static/Frontend.PNG?raw=true)

The Frontend uses Flask to provide the routing and functionality of the application. Therefore the user gets directed to the action Fields: Insert; Edit/Delete and Read.
Using the predefined SQL Querys the User can See all Entries in table Cars for example to See the whole fleet. In addition to that the entries can be filtered. Through a creation form the user can add a new Car if the Company buys a new car. The Employee can change an entry if a customer rents a car.

## Learnings

