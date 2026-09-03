-- ====================================================================
-- PROJECT: Enterprise HR Data Analytics Case Study
-- ====================================================================

-- TASK 1: Comprehensive Department Overview
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


-- TASK 2: Top Earners per Department
-- This query identifies the top 2 highest-paid employees in each department.

WITH RankedEmployees AS (          -- Create a Common Table Expression (CTE) named RankedEmployees
    SELECT 
        e.employee_id,             -- Employee ID
        e.first_name || ' ' || e.last_name AS employee_name,  -- Concatenate first + last name
        d.department_name,         -- Department name
        e.salary,                  -- Employee salary
        DENSE_RANK() OVER (        -- Window function to rank salaries within each department
            PARTITION BY d.department_id   -- Restart ranking for each department
            ORDER BY e.salary DESC          -- Highest salary gets rank 1
        ) AS salary_rank           -- Name the computed rank column
    FROM hr.employees e            -- Pull data from EMPLOYEES table
    JOIN hr.departments d          -- Join to DEPARTMENTS to get department names
        ON e.department_id = d.department_id
)

SELECT 
    department_name,               -- Show department name
    employee_name,                 -- Show employee name
    salary,                        -- Show salary
    CASE                           -- Convert numeric rank into readable text
        WHEN salary_rank = 1 THEN 'Highest Paid'
        WHEN salary_rank = 2 THEN 'Second Highest Paid'
        ELSE 'Top Tier'            -- Only used if you ever expand beyond rank <= 2
    END AS compensation_tier
FROM RankedEmployees               -- Query the ranked results from the CTE
WHERE salary_rank <= 2             -- Only show the top 2 earners per department
ORDER BY 
    department_name,               -- Sort alphabetically by department
    salary_rank,                   -- Then by rank (1 before 2)
    salary DESC;                   -- If tied, show higher salary first
