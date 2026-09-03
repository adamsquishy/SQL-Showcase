-- ====================================================================
-- PROJECT: Enterprise HR Data Analytics Case Study
-- DIALECT: Oracle SQL (Optimized for Oracle Live SQL HR Schema)
-- PURPOSE: Analyze department headcounts, salary distributions, 
--          and identify top talent across the organization.
-- ====================================================================

-- TASK 1: Comprehensive Department Overview
-- Combines employees, departments, and locations to map company footprint.
SELECT 
    d.department_name,
    l.city,
    COUNT(e.employee_id) AS total_employees,
    ROUND(AVG(e.salary), 2) AS average_salary,
    SUM(e.salary) AS total_department_payroll
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
LEFT JOIN locations l ON d.location_id = l.location_id
GROUP BY d.department_name, l.city
HAVING COUNT(e.employee_id) > 0
ORDER BY total_department_payroll DESC;


-- TASK 2: Top Earners per Department
-- Utilizes the DENSE_RANK() window function to find the highest-paid 
-- employees in each department, handling salary ties seamlessly.
WITH RankedEmployees AS (
    SELECT 
        e.employee_id,
        e.first_name || ' ' || e.last_name AS employee_name,
        d.department_name,
        e.salary,
        DENSE_RANK() OVER (
            PARTITION BY e.department_id 
            ORDER BY e.salary DESC
        ) AS salary_rank
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id
)
SELECT 
    department_name,
    employee_name,
    salary,
    CASE 
        WHEN salary_rank = 1 THEN 'Highest Paid'
        WHEN salary_rank = 2 THEN 'Second Highest Paid'
        ELSE 'Top Tier'
    END AS compensation_tier
FROM RankedEmployees
WHERE salary_rank <= 2
ORDER BY department_name, salary_rank;
