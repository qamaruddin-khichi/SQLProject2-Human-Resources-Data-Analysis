# HR Data Analysis Using MySQL

## Table of Contents
1. [About](#about)
2. [Purpose of Project](#purpose-of-project)
3. [About Data](#about-data)
4. [Questions which are Answered](#questions-which-are-answered)
5. [Summary of Findings](#summary-of-findings)
6. [SQL Code](#sql-code)
7. [Conclusion](#conclusion)

## About

This project focuses on analyzing HR data using MySQL to derive insights into various aspects of employee demographics, tenure, and turnover. By conducting thorough data analysis, the project aims to provide valuable insights that can inform HR strategies and decision-making processes within organizations.

## Purpose of Project

The primary purpose of this project is to explore and understand the HR data to uncover patterns and trends related to employee demographics, tenure, and turnover. By analyzing this data, the project aims to address key questions such as gender and race distribution, age demographics, employee location preferences, average tenure, and turnover rates across departments and job titles. The ultimate goal is to provide actionable insights that can assist HR professionals in making informed decisions to improve employee satisfaction, retention, and organizational effectiveness.

## About Data

The dataset used for this analysis contains HR data with over 22,000 rows spanning from the year 2000 to 2020. The dataset comprises the following fields:

| Field          | Type       |
| -------------- | ---------- |
| emp_id         | varchar(20)|
| first_name     | text       |
| last_name      | text       |
| birthdate      | date       |
| gender         | text       |
| race           | text       |
| department     | text       |
| jobtitle       | text       |
| location       | text       |
| hire_date      | date       |
| termdate       | date       |
| location_city  | text       |
| location_state | text       |
| age            | int        |

The data includes information such as employee ID, name, birthdate, gender, race, department, job title, location, hire date, termination date, location city, location state, and age.

## Questions which are Answered

1. What is the gender breakdown of employees in the company?
2. What is the race/ethnicity breakdown of employees in the company?
3. What is the age distribution of employees in the company?
4. How many employees work at headquarters versus remote locations?
5. What is the average length of employment for employees who have been terminated?
6. How does the gender distribution vary across departments and job titles?
7. What is the distribution of job titles across the company?
8. What is the distribution of employees across locations by state?
9. How has the company's employee count changed over time based on hire and term dates?
10. What is the tenure distribution for each department?

## Summary of Findings
- There are more male employees.
- White race is the most dominant, while Native Hawaiian and American Indian are the least dominant.
- The age distribution shows a larger number of employees between 25-34 years old.
- A significant number of employees work at headquarters compared to remote locations.
- The average length of employment for terminated employees is approximately 7 years.
- Gender distribution across departments is fairly balanced, with slightly more male employees.
- Marketing department has the highest turnover rate, while Research and Development, Support, and Legal departments have the least.
- A significant number of employees come from the state of Ohio.
- The net change in employees has increased over the years.
- The average tenure for each department is approximately 8 years, with Legal and Auditing having the highest and Services, Sales, and Marketing having the lowest.

## SQL Code

```sql
-- Creating Database
CREATE DATABASE hrdata;

USE hrdata;

SELECT *
FROM hr;

-- ----------------------------------------------------------------------------------------------------
-- ------------------------------------- DATA CLEANING ------------------------------------------------
-- ----------------------------------------------------------------------------------------------------

-- Changing 1st column name

ALTER TABLE hr
CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NULL;

-- Checking the data types of columns

DESCRIBE hr;

-- Updating the birthdate column

UPDATE hr
SET birthdate = CASE
	WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;

-- Changing birthdate datatype

ALTER TABLE hr
MODIFY COLUMN birthdate DATE;

-- Updating the hiredate column

UPDATE hr
SET hire_date = CASE
	WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;

-- Changing hiredate datatype

ALTER TABLE hr
MODIFY COLUMN hire_date DATE;

-- Updating the termdate column

select termdate
from hr;

UPDATE hr 
SET termdate = IF(
    termdate IS NOT NULL AND termdate != DATE_FORMAT(STR_TO_DATE(termdate, '%Y-%m-%d %H:%i:%s UTC'), '%Y-%m-%d'),
    DATE(STR_TO_DATE(termdate, '%Y-%m-%d %H:%i:%s UTC')),
    termdate
)
WHERE termdate IS NOT NULL 
AND termdate != ' ' 
AND termdate != '';

UPDATE hr
SET termdate = NULL
WHERE termdate = '';

-- Changing termdate datatype

ALTER TABLE hr
MODIFY COLUMN termdate DATE;

-- Adding Age column in the table

ALTER TABLE hr ADD COLUMN age INT;

-- Calculating age

UPDATE hr
SET age = timestampdiff(YEAR, birthdate, CURDATE());

-- ----------------------------------------------------------------------------------------------------
-- ---------------------------------- Answering Questions ---------------------------------------------
-- ----------------------------------------------------------------------------------------------------

-- 1. What is the gender breakdown of employees in the company?

SELECT gender, COUNT(gender) AS count
FROM hr
GROUP BY gender;

-- 2. What is the race/ethnicity breakdown of employees in the company?

SELECT race, COUNT(race) AS count
FROM hr
GROUP BY race
ORDER BY count DESC;

-- 3. What is the age distribution of employees in the company?

SELECT
	CASE
		WHEN age >= 18 AND age <= 24 THEN '18-24' 
		WHEN age >= 25 AND age <= 34 THEN '25-34'
		WHEN age >= 35 AND age <= 44 THEN '35-44'
		WHEN age >= 45 AND age <= 54 THEN '45-54'
		WHEN age >= 55 AND age <= 64 THEN '55-64'
		ELSE '65+'
	END AS age_group, COUNT(age) AS count
    FROM hr
    GROUP BY age_group
    ORDER BY age_group DESC;

-- 4. How many employees work at headquarters versus remote locations?

SELECT location, COUNT(location) AS count
FROM hr
GROUP BY location;

-- 5. What is the average length of employment for employees who have been terminated?

SELECT
	ROUND(AVG(DATEDIFF(termdate, hire_date))/365,0) AS avg_employment_lenght
    FROM hr
    WHERE termdate <= CURDATE();

-- 6. How does the gender distribution vary across departments and job titles?

SELECT department, gender, COUNT(gender) AS count
FROM hr
GROUP BY department, gender
ORDER BY count DESC;

-- 7. What is the distribution of job titles across the company?

SELECT jobtitle, COUNT(jobtitle) AS count
FROM hr
GROUP BY jobtitle
ORDER BY count DESC;

-- 8. What is the distribution of employees across locations by city and state?

SELECT location_state, COUNT(location_state) AS count
FROM hr
GROUP BY location_state
ORDER BY count DESC;

-- 9. How has the company's employee count changed over time based on hire and term dates?

SELECT
	year,
    hires,
    terminations,
    hires - terminations AS net_change,
    ROUND((hires - terminations)/hires*100,2) AS net_change_percent
    FROM
		(SELECT YEAR(hire_date) AS year,
        COUNT(hire_date) AS hires,
        SUM(CASE WHEN termdate IS NOT NULL AND termdate <= CURDATE() THEN 1 ELSE 0 END) AS terminations
        FROM hr
	GROUP BY YEAR(hire_date)
    ) AS subquery
    ORDER BY year DESC;

-- 10. What is the tenure distribution for each department?

SELECT department, ROUND(AVG(DATEDIFF(termdate, hire_date)/365),0) AS avg_tenure
FROM hr
GROUP BY department
ORDER BY avg_tenure DESC;
```
## Conclusion

This project provides valuable insights into HR data, revealing patterns and trends that can be instrumental in enhancing HR strategies and decision-making processes within organizations. By understanding employee demographics, tenure, and turnover, organizations can optimize their HR practices to foster a positive work environment, improve employee satisfaction, and ultimately drive organizational success.
