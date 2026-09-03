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


-- ============================================================
-- TASK 2: Historical Role Promotions & Longevity
-- Goal: Measure employee tenure and detect whether they have changed roles.
-- Uses Oracle date arithmetic and job_history table.
-- ============================================================

SELECT 
    e.employee_id,                 -- Employee identifier
    e.first_name || ' ' || e.last_name AS employee_name,  -- Full name
    e.hire_date,                   -- Date the employee was hired
    ROUND((SYSDATE - e.hire_date) / 365, 1) AS years_with_company,
        -- Oracle date arithmetic:
        -- SYSDATE - hire_date = number of days employed
        -- Divide by 365 to convert to years
        -- ROUND(..., 1) gives one decimal place

    COUNT(jh.job_id) AS historical_role_changes,
        -- Count how many entries exist in job_history for this employee
        -- Each row represents a past role change (promotion or transfer)

    CASE 
        WHEN COUNT(jh.job_id) > 0 THEN 'Promoted/Transferred'
            -- If job_history has entries, employee changed roles
        ELSE 'Steadfast in Current Role'
            -- No job_history entries → employee has stayed in same role
    END AS career_path_status
FROM hr.employees e                -- Base employee