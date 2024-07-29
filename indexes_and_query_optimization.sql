########################### Индексы ###########################
# пишутся для конкретной задачи
# используются, когда понимаем, что есть запросы, которые длятся долго

# - не создавать индексы заранее;
# - удалять неиспользуемые индексы;
# - не использовать индексы на небольших таблицах (до нескольких тысяч записей);
# - исходить из медленных запросов - создавать уникальные индексы под них;


# Типы индексов в MySQL:
# 1. B-Tree Index: faster when you insert values in the middle
# 2. B+Tree Index (InnoDB storage engine - used in MySQL 5.5 and later versions): faster for sorting
# 3. Hash Index: faster for testing for equality (= or !=)

# Индекс автоматически создается для primary key
# В MySQL InnoDB engine индексы также автоматически создаются для foreign keys
# Если атрибут определяется как UNIQUE, индекс также будет создан для него автоматически

# Когда поля стоит индексировать:
# 1. всегда в WHERE и проверяются на равенство (= или !=), но под вопросом для >, >=, <, <=, BETWEEN, LIKE (на IN не распространяется)
# 2. всегда в GROUP BY (в этом случае поле, по которому производится группировка, будет перед полем, по которому считается
#    аггрегирующая функция MIN() или MAX())
# 3. иногда в ORDER BY - если значение целочисленное, в остальных случаях надо знать (проверять), как БД проиндексирует это значение
# - Правила Оптимизатора MySQL Для Сортировки:
#   3.1. Нельзя сортировать в разном порядке по нескольким колонкам (только один и тот же порядок ASC или DESC)
#   3.2. До колонок, по которым производится сортировка, в условии должны быть только проверки на равенство (=, !=),
#        (то есть не должно быть >, >=, <, <=, BETWEEN, LIKE и "IN перед ORDER BY"), но это не относится к случаю, когда
#        операторы диапазона и сортировка относятся к одной и той же колонке (например, WHERE A = 5, ORDER BY A)
# 4. если таблица участвует в JOIN и есть в ON как follower (то есть является таблицей, по которой происходит поиск
#    для присоединения к leader)
# 5. при использовании функций MIN() и MAX()
#    чтобы найти MIN() и MAX(), необходимо проверить только первую и последнюю строку индекса

# Когда поля не стоит индексировать:
# 1. HAVING, т.к. срабатывает уже при выдаче данных, после того, как выборка уже была сформирована
# 2. постоянно участвует в UPDATE, может быть в INSERT

# Первое Правило Оптимизатора MySQL:
# MySQL перестанет использовать ключевые части мультииндекса, как только он встретит в запросе в условии WHERE диапазон
# <, <=, >, >= либо BETWEEN (или колонку, по которой производится сортировка), однако он сможет далее использовать
# ключевые части индекса, если встречает диапазон IN()
# Т.е. последним используемым индексом ключевым полем будет то, где он встретил диапазон,
# оставшиеся поля индекса использоваться не будут
# При этом порядок полей в ДАННОМ запросе в условии важен (должны идти в том же порядке, который задан в индексе)!
# В целом MySQL не важно, в каком порядке идут условия в запросе

# Наиболее селективные колонки ставим в начало индекса, а наименее селективные или те, по которым производится сортировка или
# поиск по диапазону, - в конец индекса


######### B-Tree Index #########
# Общий принцип:
# 1. последовательность сортируется по возрастанию значений элементов и делится пополам
# 2. искомый элемент сравнивается с центральным элементом деления:
# если искомый элемент меньше центрального, то далее происходит деление левой половины предыдущего деления,
# иначе - правой половины предыдущего деления
# 3. алгоритм повторяется с шага 2

# 1. Индекс для одного поля
USE productsdb;
SELECT *
FROM products
WHERE manufacturer = 'Apple';
# время выполнения запроса 72 ms

# добавление индекса в таблицу:
ALTER TABLE products
ADD INDEX manufacturer_idx(manufacturer);

SELECT *
FROM products
WHERE manufacturer = 'Apple';
# время выполнения запроса 40 ms

# просмотр индексов в таблице:
SHOW INDEX FROM products;

# 2. Индекс для нескольких полей
# важно решить, какое поле в индекс вписывать первым!
SELECT *
FROM products
WHERE price > 50000 AND manufacturer = 'Apple';
# время выполнения запроса 94 ms

# добавление индекса в таблицу:
# 1-й вариант
ALTER TABLE products
ADD INDEX price_manufacturer_idx(price, manufacturer);

# 2-й вариант
ALTER TABLE products
ADD INDEX manufacturer_price_idx(manufacturer, price);

# выбор правильного варината:
SELECT price, COUNT(*)
FROM products
GROUP BY price;
# после первой части индекса число записей сократится до 1 (т.к. во всех группах по price по одной записи)
# далее необходимо будет сделать выборку из них (из 1 строки)

SELECT manufacturer, COUNT(*)
FROM products
GROUP BY manufacturer;
# в данном случае некоторым группам соответствует большее число строк, чем в предыдущем варианте
# значит после первой части индекса число записей может сократиться до 1-3 (т.к. в некоторых группах по manufacturer по 2-3 записи)
# далее необходимо будет сделать выборку из них (из 1-3 строк)

# то есть в первом случае выборка сокращается быстрее (отсеивается больше записей), поэтому выбираем индекс price_manufacturer_idx

# ЗАМЕТКА: чем меньшему количеству строк в группах соответствует значение атрибута - тем выше СЕЛЕКТИВНОСТЬ,
# такие атрибуты следует использовать в начале индекса!

ALTER TABLE products
ADD INDEX price_manufacturer_idx(price, manufacturer);

SELECT *
FROM products
WHERE price > 50000 AND manufacturer = 'Apple';
# время выполнения запроса 87 ms

SHOW INDEX FROM products;

# 3. Индекс для нескольких полей с ORDER BY
# ЗАМЕТКА: атрибуты в ORDER BY необходимо добавлять в "хвост" составного индекса!
SELECT *
FROM products
WHERE price > 50000 AND manufacturer = 'Apple'
ORDER BY product_count;
# время выполнения запроса 68 ms

ALTER TABLE products
ADD INDEX price_manufacturer_count_idx(price, manufacturer, product_count);

SELECT *
FROM products
WHERE price > 50000 AND manufacturer = 'Apple'
ORDER BY product_count;
# время выполнения запроса 64 ms

SHOW INDEX FROM products;

# EXPLAIN до добавления индекса
ALTER TABLE products
DROP INDEX manufacturer_idx;
ALTER TABLE products
DROP INDEX price_manufacturer_idx;
ALTER TABLE products
DROP INDEX price_manufacturer_count_idx;

EXPLAIN SELECT * FROM products
WHERE price > 50000 AND manufacturer = 'Apple';
# смотрим, насколько полно используется длина ключа

# EXPLAIN после добавления индекса
ALTER TABLE products
ADD INDEX manufacturer_idx(manufacturer);
ALTER TABLE products
ADD INDEX price_manufacturer_idx(price, manufacturer);
ALTER TABLE products
ADD INDEX price_manufacturer_count_idx(price, manufacturer, product_count);

EXPLAIN SELECT * FROM products
WHERE price > 50000 AND manufacturer = 'Apple';
# смотрим, насколько полно используется длина ключа

# ЗАМЕТКА: длину ключа необходимо использовать как можно наиболее полно!


######### B+Tree Index #########
# если необходимо указать структуру индекса в запросе, делается это через USING BTREE или USING HASH
USE hr;

DESCRIBE

SELECT *
FROM employees
WHERE hire_date > '2000-01-01' AND salary > 3500;

EXPLAIN SELECT * FROM employees
WHERE hire_date > '2000-01-01' AND salary > 3500;

SELECT hire_date, COUNT(*)
FROM employees
GROUP BY hire_date;
# селективность выше => 1-ое место в индексе

SELECT salary, COUNT(*)
FROM employees
GROUP BY salary;
# селективность ниже => 2-ое место в индексе

ALTER TABLE employees
ADD INDEX hiredate_salary_btreeIDX(hire_date, salary) USING BTREE;

ALTER TABLE employees
ADD INDEX hiredate_btreeIDX(hire_date) USING BTREE;

ALTER TABLE employees
ADD INDEX hiredate_salary_hashIDX(hire_date, salary) USING HASH;

EXPLAIN SELECT * FROM employees
WHERE hire_date > '2000-01-01' AND salary > 3500;
# будет использован B+Tree Index

EXPLAIN ANALYZE SELECT * FROM employees
WHERE hire_date > '2000-01-01' AND salary > 3500;

SELECT *
FROM employees
WHERE hire_date > '2000-01-01' AND salary > 3500;


######### Типы таблиц (ENGINE) #########
# просмотр поддерживаемых Engines:
SHOW ENGINES;

# изменение типа Engine:
ALTER TABLE employees ENGINE = InnoDB;


######### Техники оптимизации SQL-запросов #########
DESCRIBE employees;
# 1. Использование GROUP BY (+ JOINы и производные таблицы) вместо окнонных функций
SELECT DISTINCT
    first_name AS name,
    FIRST_VALUE(employee_id) OVER (
        PARTITION BY first_name
        ORDER BY hire_date, employee_id
        ) AS employee_id
FROM employees
ORDER BY name, employee_id;
# ищет минимальный id первого нанятого с таким именем рабочего по каждому имени

SELECT
    e.first_name as name,
    MIN(employee_id) AS employee_id
FROM employees e
INNER JOIN (
    SELECT
        first_name,
        MIN(hire_date) AS hire_date
    FROM employees
    GROUP BY first_name
    ) dt
ON e.first_name = dt.first_name AND e.hire_date = dt.hire_date
GROUP BY name
ORDER BY name, employee_id;

# 2. Использование производных таблиц (+ JOINы) вместо коррелированных подзапросов
SELECT employee_id,
       (SELECT MIN(hire_date)
        FROM employees i
        WHERE i.employee_id = o.employee_id) AS first_hire_date
FROM employees o;
# ищет первую дату, когда каждый работник был принят на работу

SELECT o.employee_id,
       first_hire_date
FROM employees o
INNER JOIN (
    SELECT employee_id,
           MIN(hire_date) AS first_hire_date
    FROM employees
    GROUP BY employee_id
    ) i
ON o.employee_id = i.employee_id;

SELECT employee_id,
       MIN(hire_date) AS first_hire_date
FROM employees
GROUP BY employee_id;

# 3. Использование UNION ALL (не удаляет дубликаты) вместо IN или нескольких OR
SELECT first_name, employee_id, hire_date
FROM employees
WHERE first_name IN ('Britney', 'Randall');

SELECT first_name, employee_id, hire_date
FROM employees
WHERE first_name = 'Britney'
UNION ALL
SELECT first_name, employee_id, hire_date
FROM employees
WHERE first_name = 'Randall';

# 4. Использование временных таблиц вместо общих табличных выражений (CTE)
# Общее табличное выражение - именованный временный результирующий набор, который существует в рамках скопа одного выражения
# и на который можно ссылаться позже в рамках этого выражения, возможно, множество раз
WITH
January1998Employees AS (
    SELECT employee_id, first_name, hire_date
    FROM employees
    WHERE hire_date >= '1998-01-01' AND hire_date < '1998-02-01'),
Next10Randalls AS (
    SELECT employee_id, first_name, hire_date
    FROM January1998Employees
    WHERE first_name = 'Randall'
    ORDER BY hire_date
    LIMIT 10 OFFSET 10
),
Next10Britneys AS (
    SELECT employee_id, first_name, hire_date
    FROM January1998Employees
    WHERE first_name = 'Britney'
    ORDER BY hire_date
    LIMIT 10 OFFSET 10
),
Next10Alexanders AS (
    SELECT employee_id, first_name, hire_date
    FROM January1998Employees
    WHERE first_name = 'Alexander'
    ORDER BY hire_date
    LIMIT 10 OFFSET 10
)
SELECT employee_id, first_name FROM Next10Randalls
UNION ALL
SELECT employee_id, first_name FROM Next10Britneys
UNION ALL
SELECT employee_id, first_name FROM Next10Alexanders;

CREATE TEMPORARY TABLE January1998Employees (
    employee_id INT,
    first_name VARCHAR(20),
    hire_date DATE,
    CONSTRAINT PK_TempT PRIMARY KEY (first_name, hire_date, employee_id)
);
INSERT INTO January1998Employees
SELECT employee_id, first_name, hire_date
FROM employees
WHERE hire_date >= '1998-01-01' AND hire_date < '1998-02-01';
WITH
Next10Randalls AS (
    SELECT employee_id, first_name, hire_date
    FROM January1998Employees
    WHERE first_name = 'Randall'
    ORDER BY hire_date
    LIMIT 10 OFFSET 10
),
Next10Britneys AS (
    SELECT employee_id, first_name, hire_date
    FROM January1998Employees
    WHERE first_name = 'Britney'
    ORDER BY hire_date
    LIMIT 10 OFFSET 10
),
Next10Alexanders AS (
    SELECT employee_id, first_name, hire_date
    FROM January1998Employees
    WHERE first_name = 'Alexander'
    ORDER BY hire_date
    LIMIT 10 OFFSET 10
)
SELECT employee_id, first_name FROM Next10Randalls
UNION ALL
SELECT employee_id, first_name FROM Next10Britneys
UNION ALL
SELECT employee_id, first_name FROM Next10Alexanders;

# 5. Принудительно изменение порядка соединения таблиц
# 6. Inlining UDFs
# 7. Использование EXISTS вместо IN
# 8. Сжатие таблиц или индексов
# 9. Материализованные представления
# 10. Hint a different cardinality estimator
# 11. Создать копию данных


######### Еще техники оптимизации запросов #########
# Source: https://blog.devart.com/how-to-optimize-sql-query.html
# 1. Использование явного приведения типов данных
# неявное преобразование типов приводит к тому, что существующие индексы могут не использоваться
SELECT *
FROM employees
WHERE employee_id = '101';
# сравнение будет запущено только после неявного преобразования типа int в varchar

SELECT *
FROM employees
WHERE EXTRACT(YEAR FROM hire_date) = '1999';
# сравнение будет запущено только после неявного преобразования типа int в varchar

# решение: использовать CAST() или строковые диапазоны для дат
SELECT *
FROM employees
WHERE employee_id = CAST('101' AS UNSIGNED);

SELECT *
FROM employees
WHERE hire_date >= '1999-01-01' AND hire_date < '2000-01-01';

SELECT *
FROM employees
WHERE EXTRACT(YEAR FROM hire_date) = CAST('1999' AS UNSIGNED);

# 2. Использование UNION [ALL] вместо OR
# MySQL обрабатывает каждый OR по отдельности, существующие индексы могут не использоваться
SELECT *
FROM employees
WHERE first_name = 'Kevin' OR job_id = 'SH_CLERK';

# решение: разделить разпрос на несколько запросов и объединить их с помощью UNION [ALL]
SELECT *
FROM employees
WHERE first_name = 'Kevin'
UNION
SELECT *
FROM employees
WHERE job_id = 'SH_CLERK';

# 3. Использование подстановочных символов в LIKE только в конце фразы
# LIKE с подстановочным символом в начале фразы не может быть оптимизирован индексом!
SELECT *
FROM employees
WHERE first_name LIKE 'Al%';

# если же необходимо произвести поиск по последним символам слова, числа или фразы, то рекомендуется
# создать постоянный вычисляемый столбец и запустить на нем функцию REVERSE() для облегчения обратного поиска (MS SQL Server)
CREATE TABLE employees_reverse AS SELECT * FROM employees;
ALTER TABLE employees_reverse
ADD COLUMN reversed_first_name VARCHAR(20) AFTER first_name;
INSERT INTO employees_reverse (reversed_first_name)
SELECT REVERSE(first_name) FROM employees_reverse;
# далее для этой таблицы необходимо создать индексы, в т.ч. для колонки reversed_first_name, и делать запросы

SELECT *
FROM employees_reverse
WHERE reversed_first_name LIKE 'ne%';
# ищет информацию о всех работниках, имя которых заканчивается на "en"

# 4. Избегать большого количества JOINов
# большое количество таблиц для извлечения данных может привести к неэффективному плану выполнения;
# при создании плана оптимизатору SQL-запросов необходимо определить, как соединяются таблицы, в каком порядке,
# как и когда применять фильтры и агрегирование

# решение: разделить один запрос на несколько отдельных запросов, которые впоследствии могут быть объединены
# (удалив ненужные соединения, подзапросы, таблицы и т.д.)

# 5. Избегать использования SELECT DISTINCT (особенно с JOIN)
USE productsdb;
SELECT DISTINCT product_name
FROM products
JOIN orders
ON products.id = orders.product_id;
# выбирает все различные товары, на которые были сделаны заказы

# решение:
# использовать SELECT с подзапросом с WHERE EXISTS (или добавить больше атрибутов в SELECT для получения уникальных строк*)
# в отношениях лидер-последователь вместо того, чтобы использовать JOIN:
# SELECT DISTINCT … FROM leader JOIN follower …
# правильно использовать подзапросы с EXISTS:
# SELECT … FROM leader WHERE EXISTS (SELECT … FROM follower WHERE … соединение_follower_с_leader)
# подзапросы с EXISTS выполняются довольно быстро, поскольку возвращения набора строк не происходит
SELECT product_name
FROM products
WHERE EXISTS (
    SELECT *
    FROM orders
    WHERE orders.product_id = products.id);

# 6. Использовать SELECT с конкретными полями (+ покрывающие индексы) вместо SELECT *
# в случае больших баз данных не рекомендуется извлекать все данные, поскольку это потребует больше ресурсов
# рекомендуется использовать покрывающие индексы, которые содержат все поля, используемые в запросе

# Смысл покрывающих индексов в том, что MySQL может вытаскивать данные непосредственно из самого индекса,
# не читая при этом всю строку и вовсе не читая строку. Для такой оптимизации нужно чтобы все поля указанные в SELECT,
# имелись в индексе

# 7. Использовать SELECT ... LIMIT для выборки результатов запроса
# чтобы убедиться, что запрос выдаст требуемый результат, можно использовать эту команду для выборки нескольких строк
# в качестве образца

# 8. Запускать запросы в непиковые часы
# решение: использовать WITH (NOLOCK) в конце запроса (MS SQL Server)
# в MySQL эквивалент выглядит так:
# SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
# SELECT * FROM table;
# SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
# или
# SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
# SELECT * FROM table;
# COMMIT;

# 9. Свести к минимуму большие операции записи

# 10. Соединять таблицы с помощью INNER JOIN, а не через условие WHERE
# инструкция WHERE производит перекрестное (декартово) произведение для объединения таблиц, которое занимает много времени

# 11. Использовать EXISTS вместо IN для извлечения результатов из подзапроса
# использование EXISTS эффективнее и оптимальнее, чем использование IN, поскольку не происходит возвращение набора строк

# 12. Использование массовых операторов INSERT и UPDATE вместо циклов для вставки/обнолвения данных

# 13. Избегать использования коррелирующих подзапросов
# JOINы предпочтительнее коррелирующих подзапросов
# время исполнения запроса с использованием JOIN почти всегда будет быстрее, чем у подзапроса

# 14. Избегать использования INNER JOIN с условиями равенства (=, !=) или OR


######### Метрики производительности запросов #########
# Source: https://www.analyticsvidhya.com/blog/2021/10/a-detailed-guide-on-sql-query-optimization/


######### Порядок операций в запросах #########
USE hr;
SELECT last_name, first_name
FROM employees
WHERE department_id = 60;
# порядок выполнения команд в запросе выше:
# 1. FROM employees, которая извлекает данные
# 2. WHERE department_id = 60, которая фильтрует данные и "сужает" их диапазон
# 3. SELECT last_name, first_name, которая выводит окончательный результат запроса
# То есть порядок выполнения простых запросов с SELECT, FROM, WHERE следующий: 1. FROM, 2. WHERE, 3. SELECT

SELECT last_name, first_name
FROM employees
WHERE department_id = 60
ORDER BY first_name;
# порядок выполнения команд в запросе выше:
# 1. FROM employees, которая извлекает данные
# 2. WHERE department_id = 60, которая фильтрует данные и "сужает" их диапазон
# 3. SELECT last_name, first_name, которая выводит окончательный результат запроса
# 4. ORDER BY first_name, которая сортирует окончательные данные в указанном порядке
# То есть порядок выполнения запросов следующий: 1. FROM, 2. WHERE, 3. SELECT, 4. ORDER BY

SELECT department_id, COUNT(*)
FROM employees
WHERE salary > 10000
GROUP BY department_id
ORDER BY COUNT(*) DESC;
# порядок выполнения команд в запросе выше:
# 1. FROM employees, которая извлекает данные
# 2. WHERE salary > 10000, которая фильтрует данные и "сужает" их диапазон
# 3. GROUP BY department_id, которая генерирует одну запись для каждого уникального значения в группирующей колонке
# 4. SELECT department_id, COUNT(*), которая применяет к сгруппированным данным аггрегирующую функцию
# 5. ORDER BY COUNT(*) DESC, которая сортирует окончательные данные в указанном порядке
# То есть порядок выполнения запросов следующий: 1. FROM, 2. WHERE, 3. GROUP BY, 4. SELECT, 5. ORDER BY

SELECT department_id
FROM employees
WHERE department_id != 80
GROUP BY department_id
HAVING AVG(salary) > 10000;
# порядок выполнения команд в запросе выше:
# 1. FROM employees, которая извлекает данные
# 2. WHERE department_id != 80, которая фильтрует данные и "сужает" их диапазон
# 3. GROUP BY department_id, которая генерирует одну запись для каждого уникального значения в группирующей колонке
# 4. HAVING AVG(salary) > 10000, которая фильтрует группы и "сужает" диапазон данных
# 5. SELECT department_id, которая выводит окончательный результат запроса
# То есть порядок выполнения запросов следующий: 1. FROM, 2. WHERE, 3. GROUP BY, 4. HAVING, 5. SELECT

SELECT employee_id, last_name
FROM employees
JOIN departments USING(department_id)
WHERE departments.manager_id > 140;
# порядок выполнения команд в запросе выше:
# 1. FROM employees, которая извлекает данные
# 2. JOIN departments USING(department_id), которая генерирует промежуточный результат, комбинируя обе таблицы
# 3. WHERE departments.manager_id > 140, которая фильтрует данные и "сужает" их диапазон
# 5. SELECT employee_id, last_name, которая выводит окончательный результат запроса
# То есть порядок выполнения запросов следующий: 1. FROM, 2. JOIN, 3. WHERE, 4. SELECT

# ЗАМЕТКА
# Общий порядок выполнения команд в запросе:
# 1. FROM, 2. JOIN, 3. WHERE, 4. GROUP BY, 5. HAVING, 6. SELECT, 7. DISTINCT, 8. ORDER BY, 9. LIMIT
