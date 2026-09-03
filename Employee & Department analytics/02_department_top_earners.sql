-- Top Earners per Department
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