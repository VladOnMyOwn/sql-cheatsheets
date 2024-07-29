# ВрEменные таблицы

WITH
temp_1 AS (
    SELECT DISTINCT department_id, department_name
    FROM departments
    WHERE department_id BETWEEN 90 AND 150
    ),
temp_2 AS (
    SELECT DISTINCT first_name, last_name, department_id
    FROM employees
    WHERE department_id BETWEEN 90 AND 150
    )
SELECT a.*, b.department_name
FROM temp_2 a
LEFT JOIN temp_1 b
ON a.department_id = b.department_id;
