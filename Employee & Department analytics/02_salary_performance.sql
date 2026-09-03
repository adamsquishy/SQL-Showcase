-- ====================================================================
-- PROJECT: Talent Retention & Compensation Benchmarking
-- DIALECT: Oracle SQL (Optimized for Oracle Live SQL HR Schema)
-- PURPOSE: Evaluate employee tenure, track historical role promotions,
--          and flag staff paid significantly below their department average.
-- ====================================================================

-- TASK 1: Compensation Disparity Analysis
-- Employs a CTE to benchmark individual salaries against department 
-- averages, highlighting employees who may be flight risks.
WITH DepartmentAverages AS (
    SELECT 
        department_id,
        AVG(salary) AS avg_dept_salary
    FROM hr.employees
    GROUP BY department_id
)
SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    d.department_name,
    e.salary AS employee_salary,
    ROUND(da.avg_dept_salary, 2) AS department_average,
    ROUND(e.salary - da.avg_dept_salary, 2) AS salary_variance
FROM hr.employees e
JOIN hr.departments d ON e.department_id = d.department_id
JOIN DepartmentAverages da ON e.department_id = da.department_id
WHERE e.salary < da.avg_dept_salary
ORDER BY salary_variance ASC;


-- TASK 2: Historical Role Promotions & Longevity
-- Tracks employee tenure using Oracle date arithmetic and checks the 
-- job_history table to see who has successfully changed roles.
SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    e.hire_date,
    ROUND((SYSDATE - e.hire_date) / 365, 1) AS years_with_company,
    COUNT(jh.job_id) AS historical_role_changes,
    CASE 
        WHEN COUNT(jh.job_id) > 0 THEN 'Promoted/Transferred'
        ELSE 'Steadfast in Current Role'
    END AS career_path_status
FROM hr.employees e
LEFT JOIN hr.job_history jh ON e.employee_id = jh.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name, e.hire_date
ORDER BY years_with_company DESC;
