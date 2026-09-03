-- ====================================================================
-- PROJECT: Talent Retention & Compensation Benchmarking
-- DIALECT: Oracle SQL (Optimized for Oracle Live SQL HR Schema)
-- PURPOSE: Evaluate employee tenure, track historical role promotions,
--          and flag staff paid significantly below their department average.
-- ====================================================================


-- ============================================================
-- TASK 1: Compensation Disparity Analysis
-- Goal: Identify employees whose salary is below their department average.
-- Uses a CTE to compute department-level salary averages first.
-- ============================================================

WITH DepartmentAverages AS (       -- Begin a Common Table Expression (CTE)
    SELECT 
        department_id,             -- Grouping key: each department
        AVG(salary) AS avg_dept_salary  -- Compute average salary for that department
    FROM hr.employees              -- Source table containing all employees
    GROUP BY department_id         -- Required because AVG() is an aggregate function
)

SELECT 
    e.employee_id,                 -- Unique identifier for each employee
    e.first_name || ' ' || e.last_name AS employee_name,  -- Build full name
    d.department_name,             -- Human-readable department name
    e.salary AS employee_salary,   -- Employee's actual salary
    ROUND(da.avg_dept_salary, 2) AS department_average,   -- Department average salary (rounded)
    ROUND(e.salary - da.avg_dept_salary, 2) AS salary_variance  -- Difference from average
FROM hr.employees e                -- Main employee table
JOIN hr.departments d              -- Join to get department names
    ON e.department_id = d.department_id
JOIN DepartmentAverages da         -- Join to the CTE to compare salary vs average
    ON e.department_id = da.department_id
WHERE e.salary < da.avg_dept_salary  -- Filter: only employees earning below average
ORDER BY salary_variance ASC;      -- Sort by largest negative gap first (most underpaid)