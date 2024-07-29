# Условные операторы и функции в SQL (IF, NULLIF, IFNULL, COALESCE, CASE, DECODE*)
# https://youtu.be/Gl2o4d6kqSM


# IF(expr, value if true, value if false) - аналог ifelse() из R
# в зависимости от результата условного выражения возвращает одно из двух значений
SELECT employee_id, first_name, last_name,
       IF(salary > 10000, 'больщая з/п', 'малая з/п') AS salary_category
FROM employees;


# NULLIF(expr 1, expr 2) (для "порождения" nullов)
# возвращает NULL, если два выражения эквивалентны, в противном случае возвращается первое выражение
SELECT NULLIF(5, 2) AS result;
# результат - 5
SELECT NULLIF(5, 5) AS result;
# результат - null


SELECT NULLIF('март', 'апрель') AS result;
# результат - март
SELECT NULLIF('апрель', 'апрель') AS result;
# результат - null


# IFNULL(expr, value) (для замены nullов)
# если значение выражения равно NULL, возвращает значение, которое передается в качестве второго параметра,
# в противном случае возвращается значение выражения
SELECT IFNULL(NULL, 'поймали null') AS result;
# результат - поймали NULL
SELECT IFNULL(5, 'поймали null') AS result;
# результат - 5


SELECT employee_id, first_name, last_name,
       IFNULL(phone_number, 'не определено') AS phone_num,
       IFNULL(email, 'неизветсно') AS e_mail
FROM employees;


# COALESCE(expr 1, expr 2, ..., expr N) - аналог вложенного IFNULL(..., IFNULL(..., IFNULL(..., ...)))
# принимает список значений и возвращает первое из них, которое не равно NULL
SELECT employee_id, first_name, last_name,
       COALESCE(phone_number, email, 'нет контактных данных') AS contacts
FROM employees;
# возвращается телефон, если он определен; если он не определен, то возвращается электронный адрес;
# если и электронный адрес не определен, то возвращается строка "нет контактных данных"


# CASE
#   WHEN cond1 THEN value1
#   WHEN cond2 THEN value2
#   ...
#   ELSE defaultvalue
# END
# проверяет истинность набора условий и в зависимости от результата проверки может возвращать тот или иной результат
# условия проверяются последовательно, как будто во вложенном IF(), и возвращается первое значение, для которого которого
# условие истинно
SELECT department_id,
       CASE
           WHEN department_id = 10 THEN 'Administration'
           WHEN department_id = 20 THEN 'Marketing'
           WHEN department_id = 30 THEN 'Purchasing'
           WHEN department_id = 40 THEN 'Human Resources'
           WHEN department_id = 50 THEN 'Shipping'
           ELSE 'Marketing'
       END AS dep_name
FROM departments
WHERE department_id <= 80;


SELECT department_id,
       CASE
           WHEN department_id = 10 THEN 'Administration'
           WHEN department_id BETWEEN 20 AND 29 THEN 'Marketing'
           WHEN CONVERT(department_id, CHAR) LIKE '%30%' THEN 'Purchasing'
           WHEN department_id IN (40, 50) THEN 'Human Resources'
           ELSE 'Marketing'
       END AS dep_name
FROM departments
WHERE department_id <= 80;


SELECT department_id,
       CASE
           WHEN department_id = 10 AND manager_id <= 200 THEN 'Administration'
           WHEN department_id BETWEEN 20 AND 29 THEN 'Marketing'
           WHEN CONVERT(department_id, CHAR) LIKE '%30%' OR location_id > 1500 THEN 'Purchasing'
           WHEN department_id IN (40, 50) THEN 'Human Resources'
           ELSE 'Marketing'
       END AS dep_name
FROM departments
WHERE department_id <= 80;


select
    DEPARTMENT_ID,
    case when DEPARTMENT_ID = 10 then 'Administration' else 'Marketing' end as DEP_NAME
from DEPARTMENTS
where DEPARTMENT_ID <= 80
;


select
    DEPARTMENT_ID,
    case
        when DEPARTMENT_ID = 10 then
             case when MANAGER_ID < 500 then 'Administration' else 'Marketing' end
        else 'Marketing'
    end as DEP_NAME
from DEPARTMENTS
where DEPARTMENT_ID <= 80;









# DECODE(expr, value, result, default) - только в Oracle (в MySQL заменяется функцией IF() или CASE())!
# если значение выражения совпало со значением, передаваемым в качестве второго параметра, возвращает result,
# в противном случае возвращается NULL или значение, переданное в качестве четвертого параметра default
SELECT department_id,
       DECODE(department_id, 10, 'Administration') AS dep_name
FROM departments
WHERE department_id <= 50;
# для department_id = 10 выведет строку "Administration", а для остальных department_id - значение NULL


SELECT department_id,
       DECODE(department_id, 10, 'Administration', 'Marketing') AS dep_name
FROM departments
WHERE department_id <= 50;
# для department_id = 10 выведет строку "Administration", а для остальных department_id - строку "Marketing"


# можно использовать данную функцию со множеством пар выражение - значение (expr k, value k)
SELECT department_id,
       DECODE(department_id,
           10, 'Administration',
           20, 'Marketing',
           30, 'Purchasing',
           40, 'Human Resources',
           50, 'Shipping',
           'Marketing'
       ) AS dep_name
FROM departments
WHERE department_id <= 50;