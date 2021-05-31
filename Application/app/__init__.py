from flask import Flask 
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

app = Flask(__name__)
db = SQLAlchemy(app)

engine = create_engine('postgresql://postgres:car2rent@database:5432/postgres')

Session = sessionmaker(bind=engine)

session = Session()

#init db
try:
    engine.execute("SELECT * FROM RENT where n_rent_id = 1;")
except:
    sql_statement = open("./db/init.sql", "r").read()
    engine.execute(sql_statement)

from app import views
