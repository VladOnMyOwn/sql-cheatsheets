########################### Сводные таблицы ###########################


# Общий принцип:
# данные группируются по колонке индексов (index в Pandas) и для каждого признака создается отдельная колонка (columns в Pandas),
# с агрегирующей функцией (values и aggfunc в Pandas)
# Общий синтаксис:
# SELECT имя_колонки_индекса,
#        АГРЕГРУЮЩАЯ_ФУНКЦИЯ(IF(условие на 1 колонку, колонка_значение, NULL)) [AS имя_колонки],
#        АГРЕГРУЮЩАЯ_ФУНКЦИЯ(IF(условие на 2 колонку, колонка_значение, NULL)) [AS имя_колонки],
#        ...
#        АГРЕГРУЮЩАЯ_ФУНКЦИЯ(IF(условие на N колонку, колонка_значение, NULL)) [AS имя_колонки]
# FROM имя_таблицы
# GROUP BY имя_колонки_индекса;
USE productsdb;
SELECT product_id,  # index
       AVG(IF(MONTH(created_at) = 1, price, NULL)) AS January,  # columns, aggfunc, values
       AVG(IF(MONTH(created_at) = 2, price, NULL)) AS February,  # columns, aggfunc, values
       AVG(IF(MONTH(created_at) = 3, price, NULL)) AS March,  # columns, aggfunc, values
       AVG(IF(MONTH(created_at) = 4, price, NULL)) AS April,  # columns, aggfunc, values
       AVG(IF(MONTH(created_at) = 5, price, NULL)) AS May,  # columns, aggfunc, values
       AVG(IF(MONTH(created_at) = 6, price, NULL)) AS June  # columns, aggfunc, values
FROM orders
GROUP BY product_id;

######### автоматизация запросов на создание сводных таблиц #########
CREATE DATABASE meetings;
USE meetings;
CREATE TABLE meeting
(
    id INT,
    meeting_id INT,
    field_key VARCHAR(100),
    field_value VARCHAR(100)
);
INSERT INTO meeting
VALUES (1, 1, 'first_name', 'Alec');
INSERT INTO meeting
VALUES (2, 1, 'last_name', 'Jones');
INSERT INTO meeting
VALUES (3, 1, 'occupation', 'engineer');
INSERT INTO meeting
VALUES (4, 2, 'first_name', 'John');
INSERT INTO meeting
VALUES (5, 2, 'last_name', 'Doe');
INSERT INTO meeting
VALUES (6, 2, 'occupation', 'engineer');
SELECT * FROM meeting;

# автоматизация создания сводной таблицы:
SET @pivot_query = NULL;
SELECT GROUP_CONCAT(
    DISTINCT
    CONCAT('MAX(IF(field_key = \'', t.field_key, '\', field_value, NULL)) AS ', t.field_key)
    ) INTO @pivot_query
FROM meeting AS t;
SET @pivot_query = CONCAT('SELECT meeting_id, ', @pivot_query, ' FROM meeting GROUP BY meeting_id;');
PREPARE create_pivot_statement FROM @pivot_query;
EXECUTE create_pivot_statement;
DEALLOCATE PREPARE create_pivot_statement;
# GROUP_CONCAT соединяет полученные строки
# DISTINCT нужен, чтобы не отбирать одинаковые значения из столбца field_key
# алиас "AS t" можно убарть
# через "SELECT @pivot_query;" можно посмотреть, что хранит в себе переменная @pivot_query после выполнения данного запроса
# переменная @pivot_query хранит запрос на создание сводной таблицы

USE productsdb;
SET @pivot_query_products = NULL;
SELECT GROUP_CONCAT(
    DISTINCT
    CONCAT('AVG(IF(MONTH(created_at) = ', MONTH(created_at), ', price, NULL)) AS ', MONTHNAME(created_at))
    ) INTO @pivot_query_products
FROM orders;
SET @pivot_query_products = CONCAT('SELECT product_id, ', @pivot_query_products, ' FROM orders GROUP BY product_id;');
PREPARE create_pivot_products_statement FROM @pivot_query_products;
EXECUTE create_pivot_products_statement;
DEALLOCATE PREPARE create_pivot_products_statement;
