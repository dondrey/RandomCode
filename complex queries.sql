SELECT * FROM Person.Person;

SELECT COUNT(*) FROM Person.Person;

SELECT * FROM HumanResources.Department;

SELECT * FROM HumanResources.Employee;

--display only the details of employees who either earn the 
--highest salary or the lowest salary in each department 
--from the employee table.
select x.BusinessEntityID, x.JobTitle, x.SickLeaveHours
from HumanResources.Employee e
join (select *,
max(SickLeaveHours) over (partition by JobTitle) as max_salary,
min(SickLeaveHours) over (partition by JobTitle) as min_salary
from HumanResources.Employee) x
on e.BusinessEntityID = x.BusinessEntityID
and (e.SickLeaveHours = x.max_salary or e.SickLeaveHours = x.min_salary)
order by x.JobTitle, x.SickLeaveHours;

--Print duplicated names only*
SELECT * FROM (
--Print rows with more than one same LastName**
SELECT BusinessEntityID, LastName, RN
FROM (SELECT BusinessEntityID, LastName, ROW_NUMBER() 
OVER (PARTITION BY LastName ORDER BY LastName) RN
FROM Person.Person) X
WHERE X.RN > 1)
--**
Y
WHERE Y.RN = 2;
--*

--Print second to the last name on the list
SELECT * FROM (
	SELECT BusinessEntityID, LastName, ROW_NUMBER()
	OVER (ORDER BY BusinessEntityID desc) RN
	FROM Person.Person) X
WHERE X.RN = 2;

drop table doctors;
create table doctors
(
id int primary key,
name varchar(50) not null,
speciality varchar(100),
hospital varchar(50),
city varchar(50),
consultation_fee int
);

insert into doctors values
(1, 'Dr. Shashank', 'Ayurveda', 'Apollo Hospital', 'Bangalore', 2500),
(2, 'Dr. Abdul', 'Homeopathy', 'Fortis Hospital', 'Bangalore', 2000),
(3, 'Dr. Shwetha', 'Homeopathy', 'KMC Hospital', 'Manipal', 1000),
(4, 'Dr. Murphy', 'Dermatology', 'KMC Hospital', 'Manipal', 1500),
(5, 'Dr. Farhana', 'Physician', 'Gleneagles Hospital', 'Bangalore', 1700),
(6, 'Dr. Maryam', 'Physician', 'Gleneagles Hospital', 'Bangalore', 1500),
(7,	'Dr. Suraj', 'Homeopathy', 'Katty Hospital', 'Manipal', 1000),
(8, 'Dr. Collins', 'Dermatology', 'KMC Hospital', 'Manipal', 1500),
9	Dr. Bello	Physician	Gleneagles Hospital	Bangalore	1700
10	Dr. Taye	Physician	Gleneagles Hospital	Bangalore	1500
11	Dr. Shammak	Ayurveda	Adio Hospital	Tunis	2500
12	Dr. Gben	Homeopathy	Fortis Hospital	Bangalore	2000
13	Dr. Timo	Homeopathy	KMC Hospital	Oscar	1000
14	Dr. Werna	Dermatology	KMC Hospital	Manipal	1500
15	Dr. Owena	Physician	Gleneagles Hospital	Bangalore	1700);

SELECT *, ROW_NUMBER()
OVER (PARTITION BY speciality ORDER BY name) RN
FROM doctors;

SELECT * FROM doctors;

select d1.id, d1.name, d1.speciality, d1.hospital
from doctors d1
join doctors d2
on d1.id <> d2.id and d1.hospital = d2.hospital and d1.speciality <> d2.speciality;


drop table login_details;
create table login_details(
login_id int primary key,
user_name varchar(50) not null,
login_date date);

--delete from login_details;
insert into login_details values
(101, 'Michael', getdate()),
(102, 'James', GETDATE()),
(103, 'Stewart', getdate()+1),
(104, 'Stewart', getdate()+1),
(105, 'Stewart', getdate()+1),
(106, 'Michael', getdate()+2),
(107, 'Michael', getdate()+2),
(108, 'Stewart', getdate()+3),
(109, 'Stewart', getdate()+3),
(110, 'James', getdate()+4),
(111, 'James', getdate()+4),
(112, 'James', getdate()+5),
(113, 'James', getdate()+6);

select * from login_details;

--From the login_details table, fetch the users who logged in consecutively 3 or more times.
SELECT DISTINCT user_name 
FROM (
	SELECT *,
	CASE WHEN user_name = LEAD(user_name) OVER(ORDER BY login_id)
		AND user_name = LEAD(user_name, 2) OVER(ORDER BY login_id)
	THEN user_name
	ELSE null
	END AS repeated_user
	FROM login_details) AS X
WHERE X.repeated_user IS NOT NULL;

drop table weather;
create table weather
(
id int,
city varchar(50),
temperature int,
day date
);
--delete from weather;
insert into weather values
(1, 'London', -1, '2021-01-01'),
(2, 'London', -2, '2021-01-02'),
(5, 'London', 2, '2021-01-05'),
(6, 'London', -5, '2021-01-06'),
(7, 'London', -7, '2021-01-07'),
(8, 'London', -5, '2021-01-08'),
(9, 'London', -1, '2021-01-01'),
(10, 'London', -2, '2021-01-02'),
(11, 'London', 4, '2021-01-03'),
(12, 'London', 1, '2021-01-04'),
(13, 'London', -2, '2021-01-05'),
(14, 'London', -5, '2021-01-06'),
(15, 'London', -7, '2021-01-07'),
(16, 'London', 5, '2021-01-08');

select * from weather;

/*From the weather table, 
fetch all the records when
London had extremely cold 
temperature for 3 consecutive days or more.*/
SELECT * FROM(
	SELECT *,
	CASE WHEN temperature < 0 
			AND LEAD(temperature) OVER(ORDER BY id) < 0
			AND LEAD(temperature, 2) OVER(ORDER BY id) < 0
		THEN 'Yes'
		WHEN temperature < 0 
			AND LAG(temperature) OVER(ORDER BY id) < 0
			AND LEAD(temperature) OVER(ORDER BY id) < 0
		THEN 'Yes'
		WHEN temperature < 0 
			AND LAG(temperature) OVER(ORDER BY id) < 0
			AND LAG(temperature, 2) OVER(ORDER BY id) < 0
		THEN 'Yes'
		ELSE null
		END AS temp_below_0
	FROM weather) Y
WHERE Y.temp_below_0 = 'Yes';


SELECT * FROM weather
WHERE temperature < 0;


drop table patient_logs;
create table patient_logs
(
  account_id int,
  date date,
  patient_id int
);

insert into patient_logs values 
(1, '2020-02-01', 100),
(1, '2020-01-27', 200),
(2, '2020-01-01', 300),
(2, '2020-01-21', 400),
(2, '2020-01-21', 300),
(2, '2020-01-01', 500),
(3, '2020-01-20', 400),
(1, '2020-03-04', 500),
(3, '2020-01-20', 450);

select * from patient_logs;


SELECT patient_id, account_id, COUNT(1) AS no_of_patients
FROM (
	SELECT MONTH(date) AS xmonth, account_id
	FROM patient_logs) AS Y
GROUP BY account_id;