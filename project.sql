-- FRESH START
DROP TABLE IF EXISTS Test_Event;
DROP TABLE IF EXISTS Airplane;
DROP TABLE IF EXISTS Model;
DROP TABLE IF EXISTS Test;
DROP TABLE IF EXISTS Traffic_Controller;
DROP TABLE IF EXISTS Technician;
DROP TABLE IF EXISTS Employee;
DROP TABLE IF EXISTS Unions;

--BELOW THIS ARE ALL THE TABLE CREATIONS
-- creation of the union
CREATE TABLE Unions(
    membership_id VARCHAR(20) PRIMARY KEY,
    membership_date DATE NOT NULL,
    membership_benefits TEXT,
    CONSTRAINT valid_membership_date CHECK (membership_date <= CURRENT_DATE)
);

-- creation of employee table (superclass)
CREATE TABLE Employee(
	-- ssn are only 9 digits longs
    ssn VARCHAR(9) PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    employee_address TEXT NOT NULL,
	-- because phone # is 10 digits
    phone_number VARCHAR(20) NOT NULL,
    salary DECIMAL(20, 2) NOT NULL CHECK (salary > 0),
    union_membership_id VARCHAR(20) NOT NULL,
	-- addtionon of unino memebership
    FOREIGN KEY (union_membership_id) REFERENCES Unions(membership_id) ON DELETE CASCADE
);

-- creating traffic controller employee (subclass)
CREATE TABLE Traffic_Controller(
    traffic_ssn CHAR(9) PRIMARY KEY,
    last_exam_date DATE NOT NULL,
	-- checking for referential.
    FOREIGN KEY (traffic_ssn) REFERENCES Employee(ssn) ON DELETE CASCADE,
	-- making sure the exam date is like active
    CONSTRAINT valid_exam_date CHECK (last_exam_date >= CURRENT_DATE - INTERVAL '1 year')
);

-- creating Technician table (subclass)
CREATE TABLE Technician(
    technician_ssn CHAR(9) PRIMARY KEY,
    expertise VARCHAR(200),
    FOREIGN KEY (technician_ssn) REFERENCES Employee(ssn) ON DELETE CASCADE
);

-- creating Model table
CREATE TABLE Model(
    model_number VARCHAR(20) PRIMARY KEY,
    model_name VARCHAR(100) NOT NULL,
    capacity INTEGER NOT NULL,
    weight DECIMAL(10, 2) NOT NULL,
    CONSTRAINT valid_capacity CHECK (capacity > 0),
    CONSTRAINT valid_weight CHECK (weight > 0)
);

-- creating airplane table
CREATE TABLE Airplane(
    registration_number VARCHAR(20) PRIMARY KEY,
    airplane_name VARCHAR(100),
    stationing_date DATE NOT NULL DEFAULT CURRENT_DATE,
    model_number VARCHAR(20) NOT NULL,
    FOREIGN KEY (model_number) REFERENCES Model(model_number) ON DELETE RESTRICT
);

-- creating the Test table
CREATE TABLE Test (
    faa_test_number VARCHAR(20) PRIMARY KEY,
    test_name VARCHAR(100) NOT NULL,
    test_type VARCHAR(50) NOT NULL,
    max_score INTEGER NOT NULL,
    CONSTRAINT valid_max_score CHECK (max_score > 0 AND max_score <= 100), -- adding not greater than the exam's guide score
    CONSTRAINT unique_test_name UNIQUE (test_name)
);

-- creating testevent table
CREATE TABLE Test_Event (
    testing_event_id SERIAL PRIMARY KEY,
    date DATE NOT NULL,
    hours_spent DECIMAL(5, 2) NOT NULL,
    score INTEGER NOT NULL,
    technician_ssn CHAR(9) NOT NULL,
    airplane_registration_number VARCHAR(20) NOT NULL,
    faa_test_number VARCHAR(20) NOT NULL,
    FOREIGN KEY (technician_ssn) REFERENCES Technician(technician_ssn) 
        ON DELETE RESTRICT ON UPDATE CASCADE,-- got this from documentation w3schools
    FOREIGN KEY (airplane_registration_number) 
        REFERENCES Airplane(registration_number) ON DELETE CASCADE,
    FOREIGN KEY (faa_test_number) REFERENCES Test(faa_test_number) ON DELETE CASCADE, 
		CONSTRAINT valid_hours CHECK (hours_spent > 0),
		CONSTRAINT valid_score CHECK (score >= 0)
);

-- BELOW THIS IS ARE THE TABLE INSERTIONS
-- I am ussing non real values like 0000, or 123456789, or street one, modelone, ffatestone

-- adding data for union
INSERT INTO Unions 
(membership_id, membership_date, membership_benefits) VALUES
('unionmember1', '2023-01-01', 'Health insurance, Dental, Vision, 401k matching'),
('unionmember2', '2023-02-01', 'Health insurance, Dental, Vision, 401k matching');
SELECT * FROM Unions;

-- adding data for employee
INSERT INTO Employee 
(ssn, employee_name, employee_address, phone_number, salary, union_membership_id) VALUES
('123456789', 'name one', '1111 street one', '0000000000', 75000.00, 'unionmember1'),
('234567890', 'name two', '2222 street two', '0000000000', 82000.00, 'unionmember1'),
('345678901', 'name three', '3333 street three', '0000000000', 65000.00, 'unionmember2'),
('456789012', 'name four', '4444 street four', '0000000000', 90000.00, 'unionmember2');
SELECT * FROM Employee;

-- test data into Traffic_Controller
INSERT INTO Traffic_Controller (traffic_ssn, last_exam_date) VALUES
('234567890', '2024-01-15'),
('345678901', '2024-02-20');
SELECT * FROM Traffic_Controller;

-- the techinical data
INSERT INTO Technician (technician_ssn, expertise) VALUES
('123456789', 'model11111, model22222'),
('456789012', 'model22222, model33333');
SELECT * FROM Technician;

-- model data
INSERT INTO Model (model_number, model_name, capacity, weight) VALUES
('model11111', 'model name one', 180, 70000.00),
('model22222', 'model name two', 150, 65000.00),
('model33333', 'model name three', 400, 180000.00);
SELECT * FROM Model;

-- data into Airplane
INSERT INTO Airplane (registration_number, airplane_name, stationing_date, model_number) VALUES
('regnum11111', 'airplane name one', '2023-06-15', 'model11111'),
('regnum22222', 'airplane name two', '2023-08-20', 'model22222'),
('regnum33333', 'airplane name three', '2023-10-25', 'model33333');
SELECT * FROM Airplane;

-- this is test data for Test
INSERT INTO Test (faa_test_number, test_name, test_type, max_score) VALUES
('ffatestone', 'test name one', 'test type one', 100),
('ffatesttwo', 'test name two', 'test type two', 100),
('ffatestthree', 'test name three', 'test type three', 100);
SELECT * FROM Test;

-- Test event data
INSERT INTO Test_Event (date, hours_spent, score, technician_ssn, airplane_registration_number, faa_test_number) VALUES
('2023-09-15', 4.5, 95, '123456789', 'regnum11111', 'ffatestone'), -- the tests are out of 100. the assumption
('2023-10-20', 3.0, 88, '456789012', 'regnum22222', 'ffatesttwo'), -- doesn't matter too much because we have contraint that
('2023-11-25', 5.0, 92, '123456789', 'regnum33333', 'ffatestthree'), -- test max score cannot be higher than what the test is ex. 101/100 isn't allowed.
('2023-12-10', 4.0, 90, '456789012', 'regnum11111', 'ffatesttwo');
SELECT * FROM Test_Event;

-- BELOW THIS ARE THE SQL TESTS

-- These are the sample queries in order. 
-- 1. insert a new technician into the database
INSERT INTO Employee -- we first have to put into Employee bc its superclass, then Technician which is subclass
(ssn, employee_name, employee_address, phone_number, salary, union_membership_id)
VALUES ('567890123', 'John Smith', '5555 Fifth Street', '5555555555', 78000.00, 'unionmember1');
SELECT * FROM Employee;

INSERT INTO Technician -- inserting technician usign stuff form employee
(technician_ssn, expertise)
VALUES ('567890123', 'model11111, model33333');
SELECT * FROM Technician;

-- 2. delete an existing airplane from the database.
DELETE FROM Airplane 
WHERE registration_number = 'regnum22222'; -- this was added on the previous step
SELECT * FROM Airplane;

-- 3. updating the expertise of an existing technician
UPDATE Technician 
SET expertise = 'model11111, model22222, model33333'
WHERE technician_ssn = '123456789';
SELECT * FROM Technician;

-- 4. List the details of the technician whose salary is greater than the average of the salary of all technicians
SELECT e.employee_name, e.ssn, e.salary, t.expertise
FROM Employee e
JOIN Technician t ON e.ssn = t.technician_ssn
WHERE e.salary > (SELECT AVG(salary) FROM Employee e2 JOIN Technician t2 ON e2.ssn = t2.technician_ssn);

-- 5.List all the model numbers that a given technician has the expertise, along with their capacity and weight information.
SELECT m.model_number, m.model_name, m.capacity, m.weight
FROM Model m
WHERE m.model_number IN (
    SELECT UNNEST(string_to_array(t.expertise, ', ')) -- needing to seprate comma
    FROM Technician t WHERE t.technician_ssn = '123456789'
	);

-- 6. List the total number of technicians who are experts in each model.
WITH ExpertiseArray AS (
    SELECT UNNEST(string_to_array(expertise, ', ')) as model_number -- this was difficult bc breaking down before counting 
    FROM Technician													-- maybe I need to change the logic
)
SELECT m.model_number, m.model_name, COUNT(ea.model_number) as expert_count
FROM Model m
LEFT JOIN ExpertiseArray ea ON m.model_number = ea.model_number
GROUP BY m.model_number, m.model_name;

-- 7. List the details (test number, test name, maximum score, etc.) of the FAA tests for a given airplane, sorted by the maximum scores.
SELECT DISTINCT t.faa_test_number, t.test_name, t.test_type, t.max_score
FROM Test t
JOIN Test_Event te ON t.faa_test_number = te.faa_test_number
WHERE te.airplane_registration_number = 'regnum11111' -- have to make sure there stuff in tables
ORDER BY t.max_score DESC;

-- 8. List the most recent annual medical examination and his/her union membership number for each traffic controller.
SELECT tc.traffic_ssn, tc.last_exam_date, e.union_membership_id
FROM Traffic_Controller tc
JOIN Employee e ON tc.traffic_ssn = e.ssn
ORDER BY tc.last_exam_date DESC;

-- 9. List the total number of tests done by each technician for a given airplane.
SELECT e.employee_name, COUNT(*) as test_count
FROM Test_Event te
JOIN Employee e ON te.technician_ssn = e.ssn
WHERE te.airplane_registration_number = 'regnum11111'
GROUP BY e.employee_name;

-- 10. List the name of the technician, the registration number of the airplane, and the FAA  
-- number of those tests done between September 2021 and December 2021, sorted by the FAA numbers.
SELECT e.employee_name, te.airplane_registration_number, te.faa_test_number
FROM Test_Event te
JOIN Employee e ON te.technician_ssn = e.ssn
WHERE te.date BETWEEN '2021-09-01' AND '2021-12-31' -- this is inclusive for the start to end date
ORDER BY te.faa_test_number;

-- Own sample test
-- trying to find avg test score for each plane
SELECT a.registration_number, a.airplane_name,         
    COUNT(*) as total_tests, 
    AVG(te.score) as avg_score    -- average score of all tests
FROM Airplane a
JOIN Test_Event te 
    ON a.registration_number = te.airplane_registration_number 
GROUP BY a.registration_number, a.airplane_name
ORDER BY avg_score DESC;    -- highest scores first. -- desc is for descending