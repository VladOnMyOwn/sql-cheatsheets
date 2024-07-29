# Оконные функции в SQL (Аналитические и ранжирующие функции)
# https://youtu.be/66PF_Ajn3XI

# Общий синтаксис:
# SELECT
#   НАЗВАНИЕ_ФУНКЦИИ (столбец_для_вычислений) OVER(
#   PARTITION BY столбец_для_группировки ORDER BY столбец_для_сортировки)
# FROM ...;
# при этом конструкция PARTITION BY ... ORDER BY ... не является обязательной

USE hr;

# FIRST_VALUE()
SELECT employee_id, first_name, last_name, job_id, salary,
       FIRST_VALUE(first_name) OVER (PARTITION BY job_id ORDER BY salary DESC) AS HIGHEST_PAID_EMPLOYEE
FROM employees
WHERE job_id IN ('FI_ACCOUNT', 'IT_PROG', 'PU_CLERK');


SELECT employee_id, first_name, last_name, job_id, salary,
       FIRST_VALUE(CONCAT(first_name, ' ', last_name)) OVER (PARTITION BY job_id ORDER BY salary DESC) AS HIGHEST_PAID_EMPLOYEE
FROM employees
WHERE job_id IN ('FI_ACCOUNT', 'IT_PROG', 'PU_CLERK');


SELECT employee_id, first_name, last_name, job_id, salary,
       FIRST_VALUE(CONCAT(first_name, ' ', last_name)) OVER (PARTITION BY job_id ORDER BY salary) AS LOWEST_PAID_EMPLOYEE
FROM employees
WHERE job_id IN ('FI_ACCOUNT', 'IT_PROG', 'PU_CLERK');


# LAST_VALUE()
SELECT employee_id, first_name, last_name, job_id, salary,
       FIRST_VALUE(CONCAT(first_name, ' ', last_name)) OVER (PARTITION BY job_id ORDER BY salary) AS LOWEST_PAID_EMPLOYEE,
       LAST_VALUE(CONCAT(first_name, ' ', last_name)) OVER (PARTITION BY job_id ORDER BY salary DESC) AS LOWEST_PAID_EMPLOYEE_2
FROM employees
WHERE job_id IN ('FI_ACCOUNT', 'IT_PROG', 'PU_CLERK');


# при использовании LAST_VALUE() необходимо указывать инструкцию
# ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
SELECT employee_id, first_name, last_name, job_id, salary,
       FIRST_VALUE(CONCAT(first_name, ' ', last_name)) OVER (PARTITION BY job_id ORDER BY salary) AS LOWEST_PAID_EMPLOYEE,
       LAST_VALUE(CONCAT(first_name, ' ', last_name)) OVER (PARTITION BY job_id ORDER BY salary DESC
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS LOWEST_PAID_EMPLOYEE_2
FROM employees
WHERE job_id IN ('FI_ACCOUNT', 'IT_PROG', 'PU_CLERK');


# NTH_VALUE()
SELECT employee_id, first_name, last_name, job_id, salary,
       NTH_VALUE(CONCAT(first_name, ' ', last_name), 1) OVER (PARTITION BY job_id ORDER BY salary DESC) AS HIGHEST_PAID_EMPLOYEE
FROM employees
WHERE job_id IN ('FI_ACCOUNT', 'IT_PROG', 'PU_CLERK');


SELECT employee_id, first_name, last_name, job_id, salary,
       NTH_VALUE(CONCAT(first_name, ' ', last_name), 2) OVER (PARTITION BY job_id ORDER BY salary DESC) AS 2ND_HIGHEST_PAID_EMPLOYEE
FROM employees
WHERE job_id IN ('FI_ACCOUNT', 'IT_PROG', 'PU_CLERK');


# при использовании NTH_VALUE() с параметром n > 1 необходимо указывать инструкцию
# RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
# иначе будут пропущены первые n-1 строк
SELECT employee_id, first_name, last_name, job_id, salary,
       NTH_VALUE(CONCAT(first_name, ' ', last_name), 2) OVER (PARTITION BY job_id ORDER BY salary DESC
           RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS 2ND_HIGHEST_PAID_EMPLOYEE
FROM employees
WHERE job_id IN ('FI_ACCOUNT', 'IT_PROG', 'PU_CLERK');


SELECT employee_id, first_name, last_name, job_id, salary,
       NTH_VALUE(salary, 3) OVER (PARTITION BY job_id ORDER BY salary DESC
           RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS 3RD_HIGHEST_PAID_EMPLOYEE
FROM employees
WHERE job_id IN ('FI_ACCOUNT', 'IT_PROG', 'PU_CLERK');


SELECT DISTINCT job_id,
                NTH_VALUE(salary, 3) OVER (PARTITION BY job_id ORDER BY salary DESC
                    RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS 3RD_HIGHEST_PAID_JOB
FROM employees
WHERE job_id IN ('FI_ACCOUNT', 'IT_PROG', 'PU_CLERK');


# LAG()
SELECT employee_id, first_name, last_name, job_id, salary,
       LAG(first_name, 1) OVER (PARTITION BY job_id ORDER BY salary) AS FIRST_NAME_LAG1
FROM employees
WHERE job_id IN ('FI_ACCOUNT', 'IT_PROG', 'PU_CLERK');
# для каждой строки выводит first_name предыдущей строки в рамках каждого разбиения, т.к. LAG 1-го порядка


SELECT employee_id, first_name, last_name, job_id, salary,
       LAG(first_name, -2) OVER (PARTITION BY job_id ORDER BY salary) AS FIRST_NAME_LAG2
FROM employees
WHERE job_id IN ('FI_ACCOUNT', 'IT_PROG', 'PU_CLERK');
# для i-ой строки выводит first_name (i-(-2))=(i+2)-ой строки в рамках каждого разбиения, т.к. LAG (-2)-го порядка
# если предыдущей строки не существует, то используется NULL-значение
# однако такое поведение можно поменять с помощью необязательного (третьего) параметра функции
# значение этого параметра будет использоваться в том случае, если соответствующей строки не существует


SELECT employee_id, first_name, last_name, job_id, salary,
       LAG(first_name, 2, '-') OVER (PARTITION BY job_id ORDER BY salary) AS FIRST_NAME_LAG2_INPLACE
FROM employees
WHERE job_id IN ('FI_ACCOUNT', 'IT_PROG', 'PU_CLERK');


# LEAD()
SELECT employee_id, first_name, last_name, job_id, salary,
       LEAD(first_name, 2) OVER (PARTITION BY job_id ORDER BY salary) AS FIRST_NAME_LEAD2
FROM employees
WHERE job_id IN ('FI_ACCOUNT', 'IT_PROG', 'PU_CLERK');
# делает то же самое, что и LAG() с отрицательным порядком (-k): для каждой i-ой строки берется (i+k)-я
# также имеет 3-й необязательные параметр для замены NULL-значений


SELECT employee_id, first_name, last_name, job_id, salary,
       LEAD(first_name, 1, '-') OVER (PARTITION BY job_id ORDER BY salary) AS FIRST_NAME_LEAD1_INPLACE
FROM employees
WHERE job_id IN ('FI_ACCOUNT', 'IT_PROG', 'PU_CLERK');


# RATIO_TO_REPORT() - не относится к MySQL
SELECT employee_id, first_name, last_name, job_id, salary,
       RATIO_TO_REPORT(salary) OVER (PARTITION BY job_id) AS RATIO_SALARY
FROM employees
WHERE job_id IN ('FI_ACCOUNT', 'IT_PROG');

# альтернатива в MySQL с использованием других оконных функций:
# 1-й вариант
SELECT employees.employee_id, first_name, last_name, job_id, salary,
       t.totalsalary AS total_salary,
       ROUND(salary/t.totalsalary, 6) AS ratio_salary_by_job
FROM employees
INNER JOIN (
    SELECT employee_id, SUM(salary) OVER (PARTITION BY job_id) AS totalsalary
    FROM employees
    ) AS t ON employees.employee_id=t.employee_id
ORDER BY job_id, salary;

# 2-й вариант
SELECT employee_id, first_name, last_name, job_id, salary,
       SUM(salary) OVER (PARTITION BY job_id ORDER BY salary
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS total_salary,
       salary/SUM(salary) OVER (PARTITION BY job_id ORDER BY salary
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS ratio_salary_by_job
FROM employees;
# в случаях, когда получаем расчетное поле с использованием обычного поля и агрегатной оконной функции с ORDER BY,
# используем ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING, чтобы оконная функция считала результат
# сразу по всему окну, а не от начала окна до текущей строки


SELECT employee_id, first_name, last_name, job_id, salary,
       SUM(salary)  OVER () AS total_salary,
       salary/SUM(salary)  OVER () AS ratio_salary
FROM employees;
# выводит долю зарплаты каждого сотрудника в общей зарплате всех сотрудников


# разделение (PARTITION BY) по нескольким полям:
SELECT employee_id, first_name, last_name, department_id, job_id, salary,
       salary/SUM(salary) OVER (PARTITION BY department_id, job_id
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS ratio_salary
FROM employees
WHERE job_id IN ('FI_ACCOUNT', 'IT_PROG');


# CUME_DIST() - cumulative distribution value
# значение кумулятивной функции распределения - значение площади под графиком распределения -
# процент значений выборки, которые <= значению в данной строке
# эту функцию необходимо использовать с ORDER BY по полю, по которому необходимо найти значение cdf
SELECT employee_id, first_name, last_name, job_id, salary,
       CUME_DIST() OVER (PARTITION BY job_id ORDER BY salary) AS cumulative_dist
FROM employees;


# DENSE_RANK() - ранг текущей строки в её разбиении, БЕЗ ПРОПУСКОВ рангов после подряд идущих одинаковых значений
# повторяющиеся значения получают одинаковый ранг
# эту функцию необходимо использовать с ORDER BY по полю, по которому необходимо найти ранги
SELECT employee_id, first_name, last_name, job_id, salary,
       DENSE_RANK() OVER (PARTITION BY job_id ORDER BY salary) AS ranks_without_gaps
FROM employees;

# RANK() - ранг текущей строки в её разбиении, С ПРОПУСКАМИ рангов после подряд идущих одинаковых значений
# повторяющиеся значения получают одинаковый ранг
# эту функцию необходимо использовать с ORDER BY по полю, по которому необходимо найти ранги
SELECT employee_id, first_name, last_name, job_id, salary,
       RANK() OVER (PARTITION BY job_id ORDER BY salary) AS ranks_with_gaps
FROM employees
WHERE job_id='SA_REP';


# PERCENT_RANK() - процентное значение ранга
# возвращает процент значений в рамках текущего разделения, строго меньших (-1 в числителе), чем значение в текущей строке,
# за исключением самого высокого значения (-1 в знаменателе)
# используемая для расчета формула: (rank - 1) / (rows - 1),
# где rank - ранг строки (с пропусками), rows - количество строк в данном разбиении
# эту функцию необходимо использовать с ORDER BY по полю, по которому необходимо найти процентное значение ранга
SELECT employee_id, first_name, last_name, job_id, salary,
       RANK() OVER (PARTITION BY job_id ORDER BY salary) AS ranks_with_gaps,
       PERCENT_RANK() OVER (PARTITION BY job_id ORDER BY salary) AS percent_ranks,
       (RANK() OVER (PARTITION BY job_id ORDER BY salary) - 1)/29 AS calculated_percent_ranks
FROM employees
WHERE job_id='SA_REP';


# ROW_NUMBER() - порядок текущей строки в её разбиении
SELECT employee_id, first_name, last_name, job_id, salary,
       ROW_NUMBER() OVER (PARTITION BY job_id ORDER BY salary) AS row_numbers
FROM employees;

# NTILE() - номер сегмента текущей строки в её разбиении
# разбивает каждое разбиение (partition) на N сегментов, присваивая каждой строке в разбиении номер её сегмента
SELECT employee_id, first_name, last_name, job_id, salary,
       NTILE(5) OVER (PARTITION BY job_id ORDER BY salary) AS bucket_number
FROM employees
WHERE job_id='SH_CLERK';


SELECT employee_id, first_name, last_name, job_id, salary,
       NTILE(7) OVER (PARTITION BY job_id ORDER BY salary) AS bucket_number
FROM employees
WHERE job_id='SH_CLERK';
# если количество строк в разбиении не делится на цело на N, то сначала идут сегменты бОльшей размерности,
# а потом сегмент меньшей размерности с оставшимся числом элементов
# если количество строк в разбиении < N, то выводятся номера строк в рамках их сегмента
