Project description:
===

## Database:
- Database dump file with **insert statements** to populate DB
- One **View**
- One **Transaction**
- One stored **procedure**
- 7 SQL Queries with advanced constructs (Joins, renaming, nested queries, set operations, aggregate functions) and explanations

## Application:
- Backend in Python
- Flask + SQLAlchemy to connect DB

## Submission:
- [ ] Documentation w/ specification, ER Diagram, explanation
- [ ] Source code + DB dump
- [ ] 5-10 min video to present application functions
- [ ] Docker container


CarRent Scope:
===
## Database:
- as described above and in ER model

## Backend:
1. receive an object with various datatypes, e.g.:
```js
{"data": { 
    "carID":[value, value, value]
    "employee":912312731
    }
 "Key": 12}

 /*pass that object via get, fetch, etc.*/
```
- receive queries from frontend (and store in DB via SQLAlchemy)

## Frontend:
- look into code in /src/old_code
- 4 pages:


![panel](./src/main_screen.png)

