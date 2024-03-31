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

-- 2. What is the race/ethnicity breakdown of employees in the company?

-- 3. What is the age distribution of employees in the company?

-- 4. How many employees work at headquarters versus remote locations?

-- 5. What is the average length of employment for employees who have been terminated?

-- 6. How does the gender distribution vary across departments and job titles?

-- 7. What is the distribution of job titles across the company?

-- 8. Which department has the highest turnover rate?

-- 9. What is the distribution of employees across locations by city and state?

-- 10. How has the company's employee count changed over time based on hire and term dates?

-- 11. What is the tenure distribution for each department?


