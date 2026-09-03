-- ============================================================
-- Historical Role Promotions & Longevity
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