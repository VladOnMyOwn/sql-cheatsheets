########################### Определение структуры данных (DDL) ###########################


######### Создание и удаление базы данных #########
# 1. Создание базы данных
CREATE DATABASE productsdb;  # выдаст ошибку, если БД с таким названием на сервере уже существует
CREATE DATABASE IF NOT EXISTS productsdb;  # ошибок выдано не будет

# 2. Установка базы данных
USE productsdb;

# 3. Удаление базы данных
DROP DATABASE productsdb;  # выдаст ошибку, если БД с таким названием на сервере не существует
DROP DATABASE IF EXISTS productsdb;  # ошибок выдано не будет


######### Создание, изменение и удаление таблиц #########
# 1. Создание таблиц
# Общий синтаксис команды:
# CREATE TABLE название_таблицы
# (название_столбца1 тип_данных атрибуты_столбца1,
#  название_столбца2 тип_данных атрибуты_столбца2,
#  ................................................
#  название_столбцаN тип_данных атрибуты_столбцаN,
#  атрибуты_уровня_таблицы
# )
CREATE DATABASE productsdb;
USE productsdb;
CREATE TABLE customers (
    id INT,
    age INT,
    first_name VARCHAR(20),
    last_name VARCHAR(20)
);
CREATE TABLE IF NOT EXISTS customers (
    id INT,
    age INT,
    first_name VARCHAR(20),
    last_name VARCHAR(20)
);

# 2. Переименование таблиц
RENAME TABLE customers TO clients;

# 3. Полное удаление данных из таблицы (очистка таблицы)
TRUNCATE TABLE clients;

# 4. Удаление таблиц
DROP TABLE clients;
DROP TABLE IF EXISTS clients;

# 5. Изменение таблиц и столбцов
# Общий синтаксис команды:
# ALTER TABLE название_таблицы
# {
#   ADD [COLUMN] название_столбца тип_данных_столбца [атрибуты_столбца] [FIRST | AFTER название_уже_существующего_столбца] |
#   DROP [COLUMN] название_столбца |
#   MODIFY [COLUMN] название_столбца тип_данных_столбца [атрибуты_столбца] |
#   CHANGE [COLUMN] название_столбца новое_название_столбца тип_данных_столбца [атрибуты_столбца] |
#   * ALTER [COLUMN] название_столбца SET DEFAULT значение_по_умолчанию |
#   * ADD [CONSTRAINT] определение_ограничения |
#   * DROP [CONSTRAINT] имя_ограничения
# }

# добавление (ADD) нового столбца:
ALTER TABLE customers
ADD address VARCHAR(50) NULL;

ALTER TABLE customers
ADD COLUMN address VARCHAR(50) NULL;

# репозиционирование/перестановка (ADD ... FIRST/AFTER) столбца:
# вставка нового столбца на первое место в таблице
ALTER TABLE customers
ADD address VARCHAR(50) NULL FIRST;

# вставка нового столбца после указанного столбца
ALTER TABLE customers
ADD address VARCHAR(50) NULL AFTER age;

# удаление (DROP) столбца:
ALTER TABLE customers
DROP address;

ALTER TABLE customers
DROP COLUMN address;

# изменение типа данных (MODIFY) столбца:
ALTER TABLE customers
MODIFY first_name CHAR(100) NULL;

ALTER TABLE customers
MODIFY COLUMN first_name CHAR(100) NULL;
# ЗАМЕТКА: MODIFY меняет в колонке всё - тип данных и все её атрибуты (старые атрибуты будут удалены)

# переименование и изменение типа данных (CHANGE) столбца:
ALTER TABLE customers
CHANGE age age_new INT NOT NULL DEFAULT 18;

ALTER TABLE customers
CHANGE COLUMN age_new age INT NOT NULL DEFAULT 18;

# остальные команды рассмотрены далее


######### Типы данных #########
# 1. Символьные типы
# CHAR: представляет строку фиксированной длины, может хранить до 255 байт (символов)
# VARCHAR: представляет строку переменной длины, может хранить до 65535 байт (символов)
# начиная с MySQL 5.6 типы CHAR и VARCHAR по умолчанию используют кодировку UTF-8, которая позволяет использовать
# до 3 байт для хранения символа в зависимости от языка (для многих европейских языков по 1 байту на символ, для
# ряда восточно-европейских и ближневосточных - 2 байта, а для китайского, японского, корейского - по 3 байта на символ)
# Типы для текста неопределенной длины:
# TINYTEXT: представляет текст длиной до 255 байт
# TEXT: представляет текст длиной до 65 КБ
# MEDIUMTEXT: представляет текст длиной до 16 МБ
# LARGETEXT: представляет текст длиной до 4 ГБ

# 2. Числовые типы
# Целочисленные типы:
# 1. TINYINT: представляет целые числа от -128 до 127, занимает 1 байт
# BOOL/BOOLEAN: фактически не представляет отдельный тип, а является псевдонимом для типа TINYINT(1) и
# может хранить два значения 0 и 1. Однако данный тип может также в качестве значения принимать
# встроенные константы TRUE (число 1) и FALSE (число 0)
# 1.1. TINYINT UNSIGNED: представляет целые числа от 0 до 255, занимает 1 байт
# 2. SMALLINT: представляет целые числа от -32768 до 32767, занимает 2 байтa
# 2.1. SMALLINT UNSIGNED: представляет целые числа от 0 до 65535, занимает 2 байтa
# 3. MEDIUMINT: представляет целые числа от -8388608 до 8388607, занимает 3 байта
# 3.1. MEDIUMINT UNSIGNED: представляет целые числа от 0 до 16777215, занимает 3 байта
# 4. INT/INTEGER: представляет целые числа от -2147483648 до 2147483647, занимает 4 байта (2^(8*4=32) приближенно = 2^2 * 10^3)
# 4.1. INT UNSIGNED: представляет целые числа от 0 до 4294967295, занимает 4 байта
# 5. BIGINT: представляет целые числа от -9 223 372 036 854 775 808 до 9 223 372 036 854 775 807, занимает 8 байт
# 5.1. BIGINT UNSIGNED: представляет целые числа от 0 до 18 446 744 073 709 551 615, занимает 8 байт
# Дробные типы:
# 1. DECIMAL/DEC/FIXED/NUMERIC: хранит числа с фиксированной точностью, размер данных зависит от хранимого значения
# данный тип может принимать два параметра precision и scale: DECIMAL(precision, scale = 0)
# precision - максимальное количество цифр (включая цифры после запятой), д.б. в диапазоне от 1 до 65
# scale - максимальное количество цифр после запятой, д.б. в диапазоне от 0 до значения параметра precision,
# 2. FLOAT: хранит дробные числа с плавающей точкой одинарной точности от -3.4028 * 10^38 до 3.4028 * 10^38, занимает 4 байта
# может принимать форму FLOAT(M,D), где M - общее количество цифр, а D - количество цифр после запятой
# 3. DOUBLE/DOUBLE PRECISION/REAL: хранит дробные числа с плавающей точкой двойной точности от -1.7976 * 10^308 до 1.7976 * 10^308,
# занимает 8 байт
# может принимать форму DOUBLE(M,D), где M - общее количество цифр, а D - количество цифр после запятой

# 3. Типы для работы с датой и временем
# DATE: хранит даты с 1 января 1000 года до 31 деабря 9999 года (c "1000-01-01" до "9999-12-31"), занимает 3 байта
# по умолчанию используется формат "yyyy-mm-dd" (хранится всегда в этом формате)
# принимаемые форматы: "yyyy-mm-dd", "yyyy-m-dd", "yy-m-dd", "yyyymmdd", "yyyy.mm.dd"
# TIME: хранит время от -838:59:59 до 838:59:59, занимает 3 байта
# по умолчанию применяется формат "hh:mm:ss" (хранится всегда в этом формате), 24-часовой формат
# принимаемые форматы: "hh:mi", "hh:mi:ss", "hhmiss"
# DATETIME: хранит дату и время в диапазоне с 1 января 1000 года по 31 декабря 9999 года, занимает 8 байт
# (с "1000-01-01 00:00:00" до "9999-12-31 23:59:59")
# по умолчанию используется формат "yyyy-mm-dd hh:mm:ss" (хранится всегда в этом формате)
# принимаемые форматы: все остальные форматы для DATE и TIME
# TIMESTAMP: хранит дату и время в диапазоне от "1970-01-01 00:00:01" UTC до "2038-01-19 03:14:07" UTC, занимает 4 байта
# принимаемые форматы: все остальные форматы для DATE и TIME
# YEAR: хранит год в виде 4 цифр в диапазоне от 1901 до 2155, занимает 1 байт

# 4. Составные типы
# ENUM: хранит одно значение из списка допустимых значений, занимает 1-2 байта
# SET: может хранить несколько значений (до 64 значений) из некоторого списка допустимых значений, занимает 1-8 байт

# 5. Бинарные типы
# TINYBLOB: хранит бинарные данные в виде строки длиной до 255 байт
# BLOB: хранит бинарные данные в виде строки длиной до 65 КБ
# MEDIUMBLOB: хранит бинарные данные в виде строки длиной до 16 МБ
# LARGEBLOB: хранит бинарные данные в виде строки длиной до 4 ГБ


######### Атрибуты столбцов и таблиц #########
# 1. PRIMARY KEY - задает первичный ключ таблицы
# присвоение данного атрибута по умолчанию означает присвоение атрибутов UNIQUE и NOT NULL
# первичный ключ уникально идентифицирует строку в таблице
# в качестве первичного ключа могут выступать столбцы любого типа данных
# первичный ключ может быть составным (состоять из нескольких столбцов)
# (дропается только через DROP PRIMARY KEY!)
USE productsdb;

# установка первичного ключа на уровне поля:
CREATE TABLE customers (
    id INT PRIMARY KEY,
    age INT,
    first_name VARCHAR(20),
    last_name VARCHAR(20)
);

# установка первичного ключа на уровне таблицы:
CREATE TABLE IF NOT EXISTS customers (
    id INT,
    age INT,
    first_name VARCHAR(20),
    last_name VARCHAR(20),
    PRIMARY KEY (id)
);

# сосотавной первичный ключ
CREATE TABLE order_lines (
    order_id INT,
    product_id INT,
    quantity INT,
    price DECIMAL(16, 2),
    PRIMARY KEY(order_id, product_id)
);

# добавление первичного ключа в существующую таблицу:
# через ADD (только для ограничений, которые мржно определять на уровне таблицы)
ALTER TABLE customers
ADD PRIMARY KEY (id);

ALTER TABLE customers
MODIFY id INT AUTO_INCREMENT PRIMARY KEY;  # в MODIFY обязательно указывать тип данных поля

# удаление первичного ключа из существующей таблицы (единственный способ!):
ALTER TABLE customers
DROP PRIMARY KEY;

# 2. AUTO_INCREMENT - позволяет указать, что значение столбца будет автоматически увеличиваться при добавлении новой строки
# работает для столбцов, которые представляют целочисленный тип или числа с плавающей точкой
# по умолчанию значения начинаются с 1
CREATE TABLE IF NOT EXISTS customers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    age INT,
    first_name VARCHAR(20),
    last_name VARCHAR(20)
);

# добавление ограничения в существующую таблицу:
ALTER TABLE customers
MODIFY id INT AUTO_INCREMENT;

# изменение начального значения:
ALTER TABLE customers
AUTO_INCREMENT=100;

# 3. UNIQUE - указывает, что столбец может хранить только уникальные значения
# (дропается только через DROP INDEX имя_ограничения или DROP CONSTRAINT имя_ограничения!)
# установка ограничения на уровне поля:
CREATE TABLE IF NOT EXISTS customers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    age INT,
    first_name VARCHAR(20),
    last_name VARCHAR(20),
    phone VARCHAR(13) UNIQUE
);

# установка ограничения на уровне таблицы:
CREATE TABLE IF NOT EXISTS customers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    age INT,
    first_name VARCHAR(20),
    last_name VARCHAR(20),
    email VARCHAR(30),
    phone VARCHAR(20),
    UNIQUE(email, phone)
);

# добавление ограничения в существующую таблицу:
ALTER TABLE customers
ADD UNIQUE (email, phone);

ALTER TABLE customers
MODIFY phone VARCHAR(20) NOT NULL UNIQUE;

ALTER TABLE customers
ADD CONSTRAINT customers_contact_uq UNIQUE (email, phone);

# удаление ограничения из существующей таблицы:
ALTER TABLE customers
DROP INDEX customers_contact_uq;

ALTER TABLE customers
DROP CONSTRAINT customers_contact_uq;

# 4. NULL и NOT NULL
# по умолчанию столбец допускает значение NULL, т.е. действует ограничение NULL
# (дропается через MODIFY столбец ... NULL ...)
CREATE TABLE IF NOT EXISTS customers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    age INT,
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    email VARCHAR(30) NULL,
    phone VARCHAR(20) NOT NULL,
    UNIQUE(email, phone)
);

# добавление ограничения в существующую таблицу:
ALTER TABLE customers
MODIFY age INT NOT NULL;

# удаление ограничения из существующей таблицы:
ALTER TABLE customers
MODIFY age INT NULL;

# 5. DEFAULT - определяет значение по умолчанию для столбца
# если при добавлении данных для столбца не будет предусмотрено значение, то для него будет использоваться значение по умолчанию
# (дропается через ALTER столбец DROP DEFAULT)
CREATE TABLE IF NOT EXISTS customers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    age INT NOT NULL DEFAULT 18,
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    email VARCHAR(30) UNIQUE,
    phone VARCHAR(20) NOT NULL UNIQUE
);

# добавление ограничения в существующую таблицу:
ALTER TABLE customers
ALTER age SET DEFAULT 18;

ALTER TABLE customers
MODIFY age INT NOT NULL DEFAULT 18;

# удаление ограничения из существующей таблицы:
ALTER TABLE customers
ALTER age DROP DEFAULT;

# 6. CHECK - задает ограничение для диапазона значений, которые могут храниться в столбце
# (дропается только через DROP CHECK имя_ограничения или DROP CONSTRAINT имя_ограничения!)
# установка ограничения на уровне поля:
CREATE TABLE IF NOT EXISTS customers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    age INT NOT NULL DEFAULT 18 CHECK(age > 0 AND age <= 100),
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    email VARCHAR(30) UNIQUE CHECK(email != ''),
    phone VARCHAR(20) NOT NULL UNIQUE CHECK(phone != '')
);
# ЗАМЕТКА: пустая строка не эквивалентна значению NULL!

# установка ограничения на уровне таблицы:
CREATE TABLE IF NOT EXISTS customers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    age INT NOT NULL DEFAULT 18,
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    email VARCHAR(30) UNIQUE,
    phone VARCHAR(20) NOT NULL UNIQUE,
    CHECK((age > 0 AND age <= 100) AND (email != '') AND (phone != ''))
);

# добавление ограничения в существующую таблицу:
ALTER TABLE customers
ADD CHECK (age > 0 AND first_name LIKE '%slav');

# удаление ограничения из существующей таблицы:
# производится только через именованное ограничение (см. далее)

# 7. CONSTRAINT - оператор для установки имени ограничений
# указываются после ключевого слова CONSTRAINT перед атрибутами на уровне таблицы
# смысл заключается в том, что впоследствии через эти имена мы сможем управлять ограничениями: удалять или изменять их
# установить имя можно для ограничений PRIMARY KEY, FOREIGN KEY, CHECK, UNIQUE
# (для ограничений, которые можно опредеделить на уровне таблицы)

# установка имен ограничений при создании таблицы:
CREATE TABLE IF NOT EXISTS customers (
    id INT AUTO_INCREMENT,
    age INT NOT NULL DEFAULT 18,
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    email VARCHAR(30) UNIQUE,
    phone VARCHAR(20) NOT NULL,
    CHECK((email != '') AND (phone != '')),
    CONSTRAINT customers_pk PRIMARY KEY (id),
    CONSTRAINT customers_age_check CHECK (age > 0 AND age <= 100),
    CONSTRAINT customers_phone_uq UNIQUE (phone)
);

# добавление именованых ограничений в существующую таблицу:
ALTER TABLE customers
ADD CONSTRAINT customers_age_check CHECK (age > 0 AND age <= 100);

# удаление именованых ограничений из существующей таблицы:
# через CONSTRAINT имя_ограничения
ALTER TABLE customers
DROP CONSTRAINT customers_age_check;

# через ОГРАНИЧЕНИЕ имя_ограничения
ALTER TABLE customers
DROP CHECK customers_age_check;

# 8. CREATE INDEX - используется для создания индексов в таблице
# индексы используются для более быстрого извлечения данных из БД, ускорения поиска/запросов
# ЗАМЕТКА: обновление таблиц с индексами занимает больше времени, чем обновление таблиц без них
# (потому что индексы также требуют обновления), поэтому необходимо создавать индексы только для тех полей, по которым поиск
# будет производиться часто!
# (дропается только через DROP INDEX имя_ограничения!)

# дубликаты разрешены:
CREATE INDEX idx_cname
ON customers (first_name, last_name);

# дубликаты запрещены - то же самое, что задание ограничения UNIQUE (см. в структуре таблицы в индексах):
CREATE UNIQUE INDEX uq_idx_cname
ON customers (first_name, last_name);

# удаление индекса:
ALTER TABLE customers
DROP INDEX idx_cname;

# 9. FOREIGN KEY - задает внешний ключ таблицы
# общий синтаксис установки внешнего ключа на уровне таблицы:
# [CONSTRAINT имя_ограничения]
# FOREIGN KEY (столбец1, столбец2, ... столбецN)
# REFERENCES главная_таблица (столбец_главной_таблицы1, столбец_главной_таблицы2, ... столбец_главной_таблицыN)
# [ON DELETE действие]
# [ON UPDATE действие]
# с помощью ON DELETE и ON UPDATE можно установить действия, которые выполняются соответственно при удалении и изменении
# связанной строки из главной таблицы
# в качестве действия могут использоваться следующие опции:
# 1. CASCADE: автоматически удаляет или изменяет строки из зависимой таблицы при удалении или изменении
# связанных строк в главной таблице
# 2. SET NULL: при удалении или обновлении связанной строки из главной таблицы устанавливает для столбца внешнего
# ключа значение NULL (в этом случае столбец внешнего ключа должен поддерживать установку NULL)
# 3. RESTRICT/NO ACTION: отклоняет удаление или изменение строк в главной таблице при наличии связанных строк в зависимой таблице
# 4*. SET DEFAULT: при удалении связанной строки из главной таблицы устанавливает для столбца внешнего ключа значение по умолчанию,
# которое задается с помощью атрибута DEFAULT
# (дропается только через DROP FOREIGN KEY имя_ограничения или DROP CONSTRAINT имя_ограничения!)
CREATE TABLE orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    created_at DATE,
    FOREIGN KEY (customer_id) REFERENCES customers (id)
);

CREATE TABLE IF NOT EXISTS orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    created_at DATE,
    CONSTRAINT orders_customers_fk FOREIGN KEY (customer_id) REFERENCES customers (id)
);

# каскадное удаление/обновление:
# позволяет при удалении строки из главной таблицы автоматически удалить все связанные строки из зависимой
CREATE TABLE IF NOT EXISTS orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    created_at Date,
    FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE CASCADE
);

# установка NULL
CREATE TABLE IF NOT EXISTS orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NULL,
    created_at Date,
    FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE SET NULL
);
# замечание: необходимо, чтобы столбец внешнего ключа допускал значение NULL!

# добавление внешнего ключа в существующую таблицу:
ALTER TABLE orders
ADD FOREIGN KEY (customer_id) REFERENCES customers (id);

ALTER TABLE orders
ADD CONSTRAINT orders_customers_fk FOREIGN KEY (customer_id) REFERENCES customers (id);

# удаление внешнего ключа из существующей таблицы:
ALTER TABLE orders
DROP FOREIGN KEY orders_customers_fk;

ALTER TABLE orders
DROP CONSTRAINT orders_customers_fk;


######### Создание, изменение и удаление представлений #########
# представление - это виртуальная таблица, основанная на результирующем наборе SQL-выражения
# поля в представлении - это поля из одной или нескольких таблиц базы данных

# 1. Создание представлений:
CREATE VIEW old_customers AS
SELECT first_name, last_name
FROM customers
WHERE age > 70;

SELECT * FROM old_customers;

# 2. Изменение представлений:
CREATE OR REPLACE VIEW old_customers AS
SELECT first_name, last_name, age
FROM customers
WHERE age > 75;

SELECT * FROM old_customers;

# 3. Удаление представлений:
DROP VIEW old_customers;





########################### Операции с данными (DML) ###########################


######### Добавление данных #########
# общий синтаксис:
# INSERT [INTO] имя_таблицы [(список_столбцов)] VALUES (значение1, значение2, ... значениеN)
# можно опускать при добавлении столбцы, для которых определены атрибуты NULL или DEFAULT
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(30) NOT NULL,
    manufacturer VARCHAR(20) NOT NULL,
    product_count INT DEFAULT 0,
    price DECIMAL NOT NULL
);

# добавление строки:
INSERT INTO products(product_name, manufacturer, product_count, price)
VALUES ('iPhone X', 'Apple', 5, 76000);

SELECT * FROM products;

# опускаем все столбцы, для которых заданы атрибуты NULL или DEFAULT:
INSERT products(product_name, manufacturer, price)
VALUES ('Galaxy S9', 'Samsung', 63000);

SELECT * FROM products;

# можно явно указать вставку значения по умолчанию в поле, для которого определен атрибут DEFAULT:
INSERT products(product_name, manufacturer, price, product_count)
VALUES ('Nokia 9', 'HDM Global', 41000, DEFAULT);

SELECT * FROM products;

# можно явно указать вставку значения NULL в поле, для которого определен атрибут NULL (не определен NOT NULL):
INSERT products(product_name, manufacturer, price, product_count)
VALUES ('Nokia 9', 'HDM Global', 41000, NULL);

SELECT * FROM products;

# множественное добавление:
INSERT products(product_name, manufacturer, price, product_count)
VALUES ('iPhone 8', 'Apple', 51000, 3),
       ('P20 Lite', 'Huawei', 34000, 4),
       ('Galaxy S8', 'Samsung', 46000, 2);

SELECT * FROM products;


######### Обновление данных #########
# применяется для обновления уже имеющихся строк
# общий синтаксис:
# UPDATE имя_таблицы
# SET столбец1 = значение1, столбец2 = значение2, ... столбецN = значениеN
# [WHERE условие_обновления]
# если включен безопасный режим, MySQL не запускает UPDATE или DELETE, если пытаться выполнить их без операторов
# WHERE и LIMIT, даже если нет условия с ключевым столбцом
SET SQL_SAFE_UPDATES=0; # отключение безопасного режима

# обновление одного столбца:
UPDATE products
SET price = price + 3000;

SELECT * FROM products;

# обновление с использованием условия WHERE:
UPDATE products
SET manufacturer = 'Samsung Inc.'
WHERE manufacturer = 'Samsung';

SELECT * FROM products;

# обновление нескольких столбцов:
UPDATE products
SET manufacturer = 'Samsung',
    product_count = product_count + 3
WHERE manufacturer = 'Samsung Inc.';

SELECT * FROM products;

# использование ключевых слов DEFAULT и NULL для установки соответственно значения по умолчанию или NULL:
UPDATE products
SET product_count = DEFAULT
WHERE manufacturer = 'Huawei';

SELECT * FROM products;

SET SQL_SAFE_UPDATES=1;  # включение безопасного режима


######### Удаление данных #########
# удаляет данные из таблицы
# общий синтаксис:
# DELETE FROM имя_таблицы
# [WHERE условие_удаления]
SET SQL_SAFE_UPDATES=0; # отключение безопасного режима

DELETE FROM products
WHERE manufacturer = 'Huawei';

SELECT * FROM products;

DELETE FROM products
WHERE manufacturer = 'Apple' AND Price < 60000;

SELECT * FROM products;

# удаление всех строк таблицы:
DELETE FROM products;

SET SQL_SAFE_UPDATES=1; # включение безопасного режима

