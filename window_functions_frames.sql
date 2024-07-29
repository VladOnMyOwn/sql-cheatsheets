# Оконные функции в SQL (Фреймы (рамки/границы) оконных функций)
# https://youtu.be/yeIoV832zKw


# SELECT
#   НАЗВАНИЕ_ФУНКЦИИ(столбец_для_вычислений)
#   OVER
#   (
#     PARTITION BY столбец_для_группировки
#     ORDER BY столбец_для_сортировки
#     ROWS или RANGE выражение для ограничения строк в пределах группы
#   )
# FROM ...;

# рамка по умолчанию при использлвании ORDER BY в OVER() всегда RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW !
# (диапазон значений от начала до текущей строки)
# рамка по умолчанию без использлвания ORDER BY в OVER() всегда RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING !
# (диапазон значений от начала до конца)

# RANGE видит данные логически (фрейм определяется строками в диапазоне значений),
# ROWS видит данные позиционно (фрейм определяется позициями начальной и конечной строк)

# фрейм c RANGE по сути относится к столбцу в ORDER BY
# при этом RANGE для числового или временного выражения требует ORDER BY по числовому или временному выражению соответственно

# необходимо всегда задавать рамку там, где она поддерживается (помогает поднять производительность)

# Фреймы требуются в случаях:
# 1. Агрегирующие оконные функции с ORDER BY в OVER(), используемые для вычисления накопительных итогов, скользящих средних и т.д. !
# - Проблема: В ORDER BY передано не уникальное поле (например, дата).
# - Суть: Если не задать фрейм или использовать RANGE, функция рассматривает совпадающие значения в столбце
#   как часть одного и того же окна.
# - Решение: 1. значения в столбце, используемом ORDER BY, должны быть уникальны;
#            2. всегда задавать рамку там, где она поддерживается.
# 2. FIRST_VALUE()
# 3. LAST_VALUE() !
# - Проблема: Значение рамки по умолчанию простирается только до текущей строки.
# - Суть: Последняя строка рамки по умолчанию и есть строка, для которой выполняются вычисления.
# - Решение: Использовать фрейм ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
# 4. NTH_VALUE() !
# Те же проблемы, суть и решение, что и для LAST_VALUE().

# Фреймы не требуются для аналитических и ранжирующих оконных функций, которые работают со всем данным разбиением полностью
# такие функции не принимают столбец в качестве аргумента:
# CUME_DIST(), DENSE_RANK(), RANK(), PERCENT_RANK(), LAG(), LEAD(), NTILE(), ROW_NUMBER()


# Пример к случаю №1:
# можно получить столбец общей суммы по каждому разбиению
SELECT employee_id, first_name, last_name, hire_date, job_id, salary,
       SUM(salary) OVER (PARTITION BY job_id ORDER BY hire_date
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS sum_salary
FROM employees
WHERE job_id = 'IT_PROG' OR (job_id = 'SH_CLERK' AND hire_date >= '07.02.2007');
# задали необходимый фрейм

USE hr;
# можно получить столбец накопленной суммы (сверху вниз) по каждому разбиению разными способами
SELECT employee_id, first_name, last_name, hire_date, job_id, salary,
       SUM(salary) OVER (PARTITION BY job_id ORDER BY hire_date
           ROWS UNBOUNDED PRECEDING) AS cum_sum_salary1,
       SUM(salary) OVER (PARTITION BY job_id ORDER BY hire_date
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_sum_salary2
FROM employees
WHERE job_id = 'IT_PROG' OR (job_id = 'SH_CLERK' AND hire_date >= '07.02.2007');
# задали необходимый фрейм (без него нельзя даже в этом случае с рамкой по умолчанию!)


# можно получить столбец накопленной суммы (снизу вверх) по каждому разбиению единственным способом
SELECT employee_id, first_name, last_name, hire_date, job_id, salary,
       SUM(salary) OVER (PARTITION BY job_id ORDER BY hire_date DESC
           ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS cum_sum_salary_reverse
FROM employees
WHERE job_id = 'IT_PROG' OR (job_id = 'SH_CLERK' AND hire_date >= '07.02.2007');
# задали необходимый фрейм


# можно получить скользящую итоговую сумму k-го порядка (по предыдущим значениям) по каждому разбиению разными способами
SELECT employee_id, first_name, last_name, hire_date, job_id, salary,
       SUM(salary) OVER (PARTITION BY job_id ORDER BY hire_date
           ROWS 2 PRECEDING) AS 3sliding_total1,
       SUM(salary) OVER (PARTITION BY job_id ORDER BY hire_date
           ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS 3sliding_total2
FROM employees
WHERE job_id = 'IT_PROG' OR (job_id = 'SH_CLERK' AND hire_date >= '07.02.2007');
# задали необходимый фрейм
# RANGE 2 PRECEDING для i-ой строки задает диапазон от (i-2)-ой до i-ой строки (т.е. состоящий из 3-х строк)
# (считается скользящая сумма по текущей строке и двум предыдущим)


# есть случаи, когда ORDER BY не используется, но фрейм все равно указывать необходимо
SELECT employee_id, first_name, last_name, hire_date, job_id, salary,
       SUM(salary) OVER (PARTITION BY job_id
           ROWS 1 PRECEDING) AS 2sliding_total1,
       SUM(salary) OVER (PARTITION BY job_id
           ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) AS 2sliding_total2
FROM employees
WHERE job_id = 'IT_PROG' OR (job_id = 'SH_CLERK' AND hire_date >= '07.02.2007');
# считается скользящая сумма по текущей строке и одной предыдущей


# можно получить скользящую итоговую сумму k-го порядка (по следующим значениям) по каждому разбиению единственным способом
SELECT employee_id, first_name, last_name, hire_date, job_id, salary,
       SUM(salary) OVER (PARTITION BY job_id ORDER BY salary
           ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING) AS 2sliding_total
FROM employees
WHERE job_id = 'IT_PROG' OR (job_id = 'SH_CLERK' AND hire_date >= '07.02.2007');
# считается скользящая сумма по текущей строке и одной следующей


# можно посчитать сдвинутую скользящую среднюю k-го порядка (например, по всей таблице) несколькими способами
SELECT employee_id, first_name, last_name, hire_date, job_id, salary,
       AVG(salary) OVER (ORDER BY hire_date ROWS 4 PRECEDING) AS 5moving_average1,
       AVG(salary) OVER (ORDER BY hire_date ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS 5moving_average2,
       AVG(salary) OVER (ORDER BY hire_date ROWS 7 PRECEDING) AS 8moving_average1,
       AVG(salary) OVER (ORDER BY hire_date ROWS BETWEEN 7 PRECEDING AND CURRENT ROW) AS 8moving_average2
FROM employees;
# считается скользящая средняя, сдвинутая вперед на (k div 2) периодов для нечетных k
# считается промежуточный ряд, сдвинутый вперед на ((k - 1) / 2) для четных k


# INTERVAL в фреймах с RANGE (не относится к MySQL)
SELECT employee_id, first_name, last_name, hire_date, salary,
       AVG(salary) OVER (ORDER BY hire_date
           RANGE BETWEEN INTERVAL '3' MONTH PRECEDING AND CURRENT ROW) AS monthly_moving_avg
FROM employees
WHERE job_id = 'FI_ACCOUNT' OR (job_id = 'SH_CLERK' AND hire_date < '01.04.2005');
# возвращает среднее арифметическое строк, которые имеют значение в поле, по которому проиходит упорядочение (order by),
# меньшее до 3 месяцев, чем текущая строка, и строк, которые имеют то же значение в поле, по которому происходит упорядочение,
# что и текущая строка (даже если они находятся в другом разбиении)


# сравнение результатов работы запросов с ROWS и RANGE
SELECT employee_id, first_name, last_name, hire_date, job_id, salary,
       SUM(salary) OVER (PARTITION BY job_id ORDER BY hire_date
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS rows_salary,
       SUM(salary) OVER (PARTITION BY job_id ORDER BY hire_date
           RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS range_salary
FROM employees
WHERE job_id IN ('SH_CLERK', 'SA_REP');
# RANGE считает сумму по всем строкам с датами, находящимися в диапазоне от самой первой даты в данном разбиении до
# даты в текущей строке. При этом если в последующих строках есть даты, совпадающие с датой текущей строки, они также
# включаются в сумму


SELECT employee_id, first_name, last_name, hire_date, salary,
       SUM(salary) OVER (ORDER BY hire_date) AS sum_salary
FROM employees
WHERE job_id = 'IT_PROG' OR (job_id = 'SH_CLERK' AND hire_date >= '07.02.2007');
# по умолчанию используется RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW


SELECT employee_id, first_name, last_name, hire_date, salary,
       SUM(salary) OVER (ORDER BY hire_date) AS sum_salary,
       SUM(salary) OVER (ORDER BY hire_date
           RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS sum_salary2
FROM employees
WHERE job_id IN ('SH_CLERK', 'SA_REP');
# результат одинаков, т.к. по умолчанию в OVER(ORDER BY ...) используется фрейм RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW


SELECT employee_id, first_name, last_name, hire_date, salary,
       SUM(salary) OVER (ORDER BY hire_date) AS sum_salary,
       SUM(salary) OVER (ORDER BY hire_date
           RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS sum_salary2,
       SUM(salary) OVER () AS sum_salary3
FROM employees
WHERE job_id = 'IT_PROG' OR (job_id = 'SH_CLERK' AND hire_date >= '07.02.2007');
# результат в последней колонке будет считаться по всем строкам запроса, причем будет использован фрейм по умолчанию для OVER()
# RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING


# Заметка: сначала выполняется условие в WHERE, затем считаются поля с оконными функциями