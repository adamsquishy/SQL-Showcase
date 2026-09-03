-- ====================================================================
-- PROJECT: Enterprise HR Data Analytics Case Study
-- ====================================================================

-- Comprehensive Department Overview
-- This query summarizes each department's size, average salary, and total payroll.

SELECT 
    d.department_name,              -- Select the department's name from the DEPARTMENTS table
    l.city,                         -- Select the city where the department is located (from LOCATIONS)
    COUNT(e.employee_id) AS total_employees,   -- Count how many employees belong to this department
    ROUND(AVG(e.salary), 2) AS average_salary,  -- Calculate the average salary, rounded to 2 decimals
    SUM(e.salary) AS total_department_payroll   -- Sum all salaries to get total payroll for the department
FROM hr.departments d              -- Start with the DEPARTMENTS table (aliased as d)
LEFT JOIN hr.employees e           -- Include employees, even if a department has none
    ON d.department_id = e.department_id   -- Match employees to their department
LEFT JOIN hr.locations l           -- Include location information
    ON d.location_id = l.location_id       -- Match department to its physical location
GROUP BY 
    d.department_name,             -- Group results by department name
    l.city                         -- And by city, so each department-location pair is summarized
ORDER BY 
    total_department_payroll DESC; -- Sort departments by highest payroll first
