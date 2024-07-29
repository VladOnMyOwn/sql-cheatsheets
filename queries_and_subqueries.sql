########################### Запросы ###########################


######### Операторы фильтрации #########
# 1. IN - определяет набор значений, которые должны иметь столбцы
# общий синтаксис:
# WHERE выражение [NOT] IN (выражение)
# набор может вычисляться динамически на основании еще одного запроса, либо это могут быть константные значения
SELECT * FROM products
WHERE manufacturer IN ('Samsung', 'HTC', 'Huawei');

SELECT * FROM products
WHERE manufacturer NOT IN ('Samsung', 'HTC', 'Huawei');

# 2. BETWEEN - определяет диапазон значений с помощью начального и конечного значения, которому должно соответствовать выражение
# общий синтаксис:
# WHERE выражение [NOT] BETWEEN начальное_значение AND конечное_значение
# начальное и конечное значения также ВКЛЮЧАЮТСЯ в диапазон
SELECT * FROM products
WHERE price BETWEEN 20000 AND 50000;

SELECT * FROM products
WHERE price NOT BETWEEN 20000 AND 50000;

SELECT * FROM products
WHERE price * product_count BETWEEN 90000 AND 150000;

# 3. LIKE - принимает шаблон строки, которому должно соответствовать выражение
# общий синтаксис:
# WHERE выражение [NOT] LIKE шаблон_строки
# используются спциальные символы подстановки:
# %: любая подстрока с любым количеством символов или пустая подстрока (0 символов и более)
# _: подстрока из одного символа (1 символ)
SELECT * FROM products
WHERE product_name LIKE '_Phone%';

# 3. REGEXP - позволяет задать регулярное выражение, которому должно соответствовать значение столбца
# общий синтаксис:
# WHERE выражение [NOT] REGEXP регулярное_выражение
# используются спциальные символы подстановки:
# ^: указывает на начало строки (относится ко всем последующим символам, идущим подряд)
# $: указывает на конец строки (относится ко всем предыдущим символам, идущим подряд)
# .: соответствует любому одиночному символу (только 1 символ (не 0)!)
# [символы]: соответствует любому одиночному символу из скобок
# [начальный_символ-конечный_символ]: соответствует любому одиночному символу из диапазона символов
# |: отделяет (без пробелов) два шаблона строки, одному из которых должно соответствовать значение
# "любое количество символов" (аналог %) никак не обозначается

SELECT * FROM products
WHERE product_name REGEXP 'Phone';
# строка должна содержать "Phone"

SELECT * FROM products
WHERE product_name REGEXP '^Phone';
# строка должна начинаться с "Phone"

SELECT * FROM products
WHERE product_name REGEXP 'Phone$';
# строка должна заканчиваться на "Phone"

SELECT * FROM products
WHERE product_name REGEXP 'iPhone [78]';
# строка должна содержать "iPhone 7" или "iPhone 8"

SELECT * FROM products
WHERE product_name REGEXP 'iPhone [6-8]';
# строка должна содержать либо "iPhone 6", либо "iPhone 7", либо "iPhone 8"

SELECT * FROM products
WHERE product_name REGEXP 'Phone|Galaxy';
# строка должна содержать либо "Phone", либо "Galaxy"

SELECT * FROM products
WHERE product_name REGEXP '.Phone';
# строка должна содержать "Phone" с любым одиночным символом в начале этой подстроки


######### Получение диапазона строк #########
# общий синтаксис:
# LIMIT [offset,] rowcount
# если передается один параметр, то он указывает на количество извлекаемых строк
# если передается два параметра, то первый параметр устанавливает смещение относительно начала, то есть
# сколько строк нужно пропустить, а второй параметр так же указывает на количество извлекаемых строк
SELECT * FROM products
LIMIT 3;

SELECT * FROM products
LIMIT 2, 3;
# LIMIT k, n: пропускается k первых строк и выбираются строки с (k+1) по (k+n)
# в данном случае k = 2, n = 3

SELECT * FROM products
ORDER BY product_count * price DESC
LIMIT 2, 3;


######### Группировка #########
# GROUP BY группирует данные, HAVING фильтрует группы
# общий синтаксис:
# SELECT столбцы
# FROM таблица
# [WHERE условие_фильтрации_строк]
# [GROUP BY столбцы_для_группировки]
# [HAVING условие_фильтрации_групп]
# [ORDER BY столбцы_для_сортировки]
# если в выражении SELECT есть несколько полей и используются АГРЕГАТНЫЕ ФУНКЦИИ, то необходимо использовать выражение GROUP BY
# если есть только одно поле и к нему применяется агрегатная функция, то GROUP BY не нужен

# правильно, работает:
SELECT manufacturer, COUNT(*) AS models_count
FROM products
GROUP BY manufacturer;
# COUNT(*) счиатет все строки в выборке, в том числе строки с NULL
# COUNT(имя_столбца) считает все строки в столбце, игнорируя значения NULL

# неправильно, не работает:
SELECT manufacturer, COUNT(*) AS models_count
FROM products;

# группировка по нескольким столбцам:
SELECT manufacturer, product_count, COUNT(*) AS models_count
FROM products
GROUP BY manufacturer, product_count;

SELECT manufacturer, COUNT(*) AS models_count
FROM products
WHERE price > 30000
GROUP BY manufacturer
ORDER BY models_count DESC;

# филтрация групп:
SELECT manufacturer, COUNT(*) AS models_count
FROM products
GROUP BY manufacturer
HAVING COUNT(*) > 1;

SELECT manufacturer, COUNT(*) AS models_count
FROM products
WHERE price * product_count > 80000
GROUP BY manufacturer
HAVING COUNT(*) > 1;

SELECT manufacturer, COUNT(*) AS models, SUM(product_count) AS units
FROM products
WHERE price * product_count > 80000
GROUP BY manufacturer
HAVING units > 2
ORDER BY units DESC;


######### Коррелирующие и некоррелирующие подзапросы #########
# некоррелирующие подзапросы - подзапросы, результат которых не зависит от строк, которые выбираются в основном запросе
# некоррелирующий подзапрос выполняется только один раз для всего внешнего запроса
# коррелирующие подзапросы - подзапросы, результаты которых зависят от строк, которые выбираются в основном запросе
# коррелирующие подзапросы выполняются для каждой отдельной строки внешнего запроса
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS orders;
CREATE TABLE products
(
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(30) NOT NULL,
    manufacturer VARCHAR(20) NOT NULL,
    product_count INT DEFAULT 0,
    price DECIMAL NOT NULL
);
CREATE TABLE orders
(
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    product_count INT DEFAULT 1,
    created_at DATE NOT NULL,
    price DECIMAL NOT NULL,
    FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE
);
INSERT INTO products (product_name, manufacturer, product_count, price)
VALUES ('iPhone X', 'Apple', 2, 76000),
       ('iPhone 8', 'Apple', 2, 51000),
       ('iPhone 7', 'Apple', 5, 42000),
       ('Galaxy S9', 'Samsung', 2, 56000),
       ('Galaxy S8', 'Samsung', 1, 46000),
       ('Honor 10', 'Huawei', 2, 26000),
       ('Nokia 8', 'HMD Global', 6, 38000);
INSERT INTO orders (product_id, created_at, product_count, price)
VALUES
(
    (SELECT id FROM products WHERE product_name = 'Galaxy S8'),
    '2018-05-21',
    2,
    (SELECT price FROM products WHERE product_name = 'Galaxy S8')
),
(
    (SELECT id FROM products WHERE product_name = 'iPhone X'),
    '2018-05-23',
    1,
    (SELECT price FROM products WHERE product_name = 'iPhone X')
),
(
    (SELECT id FROM products WHERE product_name = 'iPhone 8'),
    '2018-05-21',
    1,
    (SELECT price FROM products WHERE product_name = 'iPhone 8')
);

# некоррелирующие подзапросы:
SELECT * FROM products
WHERE price = (
    SELECT MIN(price)
    FROM products);

SELECT * FROM products
WHERE price > (
    SELECT AVG(price)
    FROM products);

# коррелирующий подзапрос к внешней таблице:
SELECT  created_at, price,
        (SELECT product_name
         FROM products
         WHERE id = orders.product_id) AS product
FROM orders;
# для каждой строки из таблицы orders будет выполняться подзапрос, результат которого зависит от столбца product_id

# коррелирующий подзапрос к основной таблице:
SELECT product_name, manufacturer, price,
       (SELECT AVG(price)
        FROM products AS sub_prods
        WHERE sub_prods.manufacturer = prods.manufacturer)  AS avg_price
FROM products AS prods
WHERE price > (
    SELECT AVG(price)
    FROM products AS sub_prods
    WHERE sub_prods.manufacturer = prods.manufacturer);
# для каждой строки из таблицы products будет выполняться подзапрос, результат которого зависит от столбца manufacturer
# в данном случае из каждой строки таблицы products берется производитель и для него ищется средняя цена
# выбираются такие товары, цена которых больше средней цены товаров данного производителя

# JOINы предпочтительнее коррелирующих подзапросов!
# время исполнения запроса с использованием JOIN почти всегда будет быстрее, чем у подзапроса

# В основной запрос мы можем вводить подзапросы четырьмя способами:
# 1. В качестве спецификации столбца в выражении SELECT
SELECT *,
       (SELECT product_name
        FROM products
        WHERE id = orders.product_id) AS product
FROM orders;

# 2. В качестве таблицы для выборки в выражении FROM

# 3. В условии в выражении WHERE
SELECT *
FROM products
WHERE price > (
    SELECT AVG(price)
    FROM products);

SELECT *
FROM products
WHERE id IN (
    SELECT product_id
    FROM Orders);
# лучше использовать JOIN

SELECT *
FROM products
WHERE price < ALL(
    SELECT price
    FROM products
    WHERE manufacturer = 'Apple');
# лучше использовать MIN

SELECT *
FROM products
WHERE price < ANY(
    SELECT price
    FROM products
    WHERE manufacturer = 'Apple');
# эквивалентно SOME
# лучше использовать MAX

# ЗАМЕТКА:
# как работает оператор ALL (все):
# x > ALL(1, 2) эквивалентно x > MAX(1, 2)
# x < ALL(1, 2) эквивалентно x < MIN(1, 2)
# x = ALL(1, 2) эквивалентно (x = 1) AND (x = 2)
# x != ALL(1, 2) эквивалентно x NOT IN (1, 2)
# как работает оператор ANY/SOME (некоторые, хотя бы один):
# x > ANY(1, 2) эквивалентно x > MIN(1, 2)
# x < ANY(1, 2) эквивалентно x < MAX(1, 2)
# x = ANY(1, 2) эквивалентно x IN (1, 2)
# x != ANY(1, 2) эквивалентно (x != 1) OR (x != 2)

# 4. В условии в выражении HAVING
SELECT manufacturer, COUNT(*) AS models, SUM(product_count) AS units
FROM products
WHERE price * product_count > 80000
GROUP BY manufacturer
HAVING units > ANY(
    SELECT SUM(product_count)
    FROM products
    GROUP BY manufacturer)
ORDER BY units DESC;

# В команде INSERT можно использовать подзапросы для определения значения, которое вставляется в один из столбцов:
# см. выше

# В команде UPDATE можно использовать подзапросы двумя способами:
# 1. В качестве устанавливаемого значения после оператора SET
UPDATE orders
SET price = (
    SELECT price
    FROM products
    WHERE id = orders.product_id) + 3000
WHERE id = 1;

# 2. Как часть условия в выражении WHERE
UPDATE orders
SET product_count = product_count + 2
WHERE product_id IN (
    SELECT id
    FROM products
    WHERE manufacturer = 'Apple');

# В команде DELETE можно использовать подзапросы как часть условия в выражении WHERE:
DELETE FROM orders
WHERE product_id = (
    SELECT id
    FROM products
    WHERE product_name = 'Galaxy S8');

# Подзапросы с использованием оператора EXISTS
# проверяет, возвращает ли подзапрос какое-либо (хотя бы одно) значение
# используется для определения того, что как минимум одна строка в таблице удовлетворяет некоторому условию
# подзапросы с EXISTS выполняются довольно быстро, поскольку возвращения набора строк не происходит
# общий синтаксис:
# WHERE [NOT] EXISTS (подзапрос)

SELECT *
FROM products
WHERE EXISTS (
    SELECT *
    FROM orders
    WHERE orders.product_id = products.id);
# находит все товары из таблицы products, на которые есть заказы в таблице orders

SELECT *
FROM products
WHERE NOT EXISTS (
    SELECT *
    FROM orders
    WHERE orders.product_id = products.id);
# находит все товары из таблицы products, на которые нет заказов в таблице orders

# ЗАМЕТКА: использование EXISTS эффективнее и оптимальнее, чем использование IN, поскольку не происходит возвращение набора строк!
