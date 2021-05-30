#Python3.8
FROM python:3.8-slim

#Working directory to /Application
WORKDIR /Application


#Copy files
ADD . /Application


#Install dependencies
RUN pip install -r requirements.txt

EXPOSE 5000

CMD ["python", "./app/app.py"] 