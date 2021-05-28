import os


basedir = os.path.abspath(os.path.dirname(__file__))


class Config(object):
    
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SQLALCHEMY_DATABASE_URI = "postgresql://postgres:postgres@localhost:5432/carrent"
    SECRET_KEY = 'MLXH243GssUWwKdTWS7FDhdwYF56wPj8'