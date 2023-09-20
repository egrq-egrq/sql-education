/*

https://stepik.org/course/63054/promo 
Interactive SQL Simulator 

*/


--### v0.1.1 hello world ###-- 

    

CREATE TABLE genre(
             genre_id INT PRIMARY KEY AUTO_INCREMENT, 
             name_genre VARCHAR(30)
);

CREATE TABLE book(
             book_id INT PRIMARY KEY AUTO_INCREMENT,
             title VARCHAR(50),
             author VARCHAR(30),
             price DECIMAL(8, 2),
             amount INT
);

INSERT INTO book (title, author, price, amount)
VALUES ('Мастер и Маргарита', 'Булгаков М.А.', 670.99, 3);
INSERT INTO book (title, author, price, amount)
VALUES ('Белая гвардия', 'Булгаков М.А.', 540.50, 5);
INSERT INTO book (title, author, price, amount)
VALUES ('Идиот', 'Достоевский Ф.М.', 460.00, 10);
INSERT INTO book (title, author, price, amount)
VALUES ('Братья Карамазовы', 'Достоевский Ф.М.', 799.01, 2);
SELECT * FROM book;



--### v0.1.2 selection DATA ###--



SELECT author,
       title, 
       price 
  FROM book;

SELECT title  AS Название, 
       author AS Автор
  FROM book;


SELECT title, amount,
       amount * 1.65 AS pack
  FROM book;

SELECT title, author, amount,
       ROUND ((price * 0.7), 2) AS new_price
  FROM book;

SELECT author, title,
       ROUND(IF(author = "Булгаков М.А.", price * 1.1, IF(author = "Есенин С.А.", price * 1.05, price)), 2) AS new_price
  FROM book;       

SELECT author, title, price
  FROM book
 WHERE amount < 10;

SELECT title, author, price, amount
  FROM book
 WHERE 600 < price < 500  
   AND price * amount >= 5000;

SELECT title, author
  FROM book
 WHERE price BETWEEN 540.50 AND 800
   AND amount IN (2, 3, 5, 7);

  SELECT author, 
         title
    FROM book
   WHERE amount BETWEEN 2 AND 14
ORDER BY author DESC, 
         title ASC;

  SELECT title, author
    FROM book
   WHERE author LIKE '%С.%' 
     AND (title LIKE '%_% % %_%' OR title LIKE '%_% %_%')
ORDER BY title ASC;



--### v0.1.3 requests and group operations ###--



SELECT DISTINCT amount
           FROM book; 

  SELECT author AS Автор,
         COUNT(author) AS Различных_книг,
         SUM(amount) AS Количество_экземпляров
    FROM book
GROUP BY Автор;

  SELECT author,
         MIN(price) AS 'Минимальная_цена',
         MAX(price) AS 'Максимальная_цена',
         AVG(price) AS 'Средняя_цена'
    FROM book 
GROUP BY author

  SELECT author,
         /* S */
         SUM(price * amount) AS 'Стоимость', 
         /* TAX */
         ROUND(SUM((price * amount * (18 / 100)) / (1 + (18 / 100))), 2) AS 'НДС', 
         /* S without tax */
         ROUND(SUM((price * amount) / (1 + (18 / 100))), 2) AS 'Стоимость_без_НДС' 
    FROM book
GROUP BY author;

SELECT MIN(price) AS 'Минимальная_цена',
       MAX(price) AS 'Максимальная_цена',
       ROUND(AVG(price), 2) AS 'Средняя_цена'
  FROM book;

SELECT ROUND(AVG(price), 2) AS 'Средняя_цена',
       SUM(price * amount) AS 'Стоимость'
  FROM book
 WHERE amount BETWEEN 5 AND 14;

  SELECT author,
         SUM(price * amount) AS 'Стоимость'
    FROM book 
   WHERE title <> 'Идиот' 
         AND title <> 'Белая гвардия'
GROUP BY author
  HAVING SUM(price * amount) > 5000
ORDER BY SUM(price * amount) DESC;



--### v0.1.4 nested requests ###--



  SELECT author,
         title, 
         price
    FROM book
   WHERE price <= (
                  SELECT AVG(price)
                    FROM book
                  )
ORDER BY price DESC;

  SELECT author,
         title,
         price
    FROM book
   WHERE (price - (SELECT MIN(price) FROM book)) <= 150
ORDER BY price ASC;

SELECT author,
       title,
       amount
  FROM book
 WHERE amount IN (
                 SELECT amount
                 FROM book
                 GROUP BY amount 
                 HAVING COUNT(amount) = 1
                 ); 

SELECT author,
       title,
       price
  FROM book
 WHERE price < ANY (
                   SELECT MIN(price)
                   FROM book
                   GROUP BY author
                   );

SELECT title,
       author,
       amount,
       (SELECT max(amount) FROM book) - amount AS 'Заказ'
  FROM book
 WHERE (SELECT MAX(amount) FROM book) - amount <> 0;



--### v0.1.5 DATA correction requests ###--



CREATE TABLE supply ( 
                    supply_id INT PRIMARY KEY AUTO_INCREMENT,
                    title VARCHAR(50),
                    author VARCHAR (30),
                    price DECIMAL(8,2),
                    amount INT
                    );

INSERT INTO supply (title, author, price, amount)
            VALUES ('Лирика', 'Пастернак Б.Л.', 518.99, 2),
                   ('Черный человек', 'Есенин С.А.', 570.20, 6),
                   ('Белая гвардия', 'Булгаков М.А.', 540.50, 7),
                   ('Идиот', 'Достоевский Ф.М.', 360.80, 3);

INSERT INTO book (
                  title
                , author
                , price
                , amount

                )
        SELECT title
             , author 
             , price
             , amount
        FROM supply
        WHERE author NOT IN (
                            'Булгаков М.А.'
                          , 'Достоевский Ф.М.'

                            );
SELECT * 
  FROM book;

INSERT INTO book (
                  title
                , author
                , price
                , amount
                ) 
            SELECT 
                  title
                , author
                , price
                , amount 
            FROM supply
            WHERE author NOT IN (
                                SELECT author
                                FROM book
                                );
SELECT * FROM book;


UPDATE book
   SET price = price * 0.9
 WHERE amount BETWEEN 5 AND 10;

SELECT * FROM book;


UPDATE book
   SET price = IF(buy = 0, price * 0.9, price)
     , buy = IF(buy > amount, amount, buy)
     
     ;

SELECT * FROM book;


UPDATE book
     , supply
SET book.amount = book.amount + supply.amount 
  , book.price = (book.price + supply.price) / 2     
WHERE book.title = supply.title 
  AND book.author = supply.author;

SELECT * 
  FROM book;


DELETE 
    FROM supply
    WHERE author IN (
        SELECT author
        FROM book
        GROUP BY author
        HAVING SUM(amount) > 10
);

SELECT *
    FROM supply;

/* 
- читаемость
- очевидность изменений при мерже в брэнчу
- легкость в работе с параметрами ( найти, закоммитить, изменить и тд)

попытался тут изобразить,
- что будет удобно дебажить и модифицировать
- что легко видно при мерже в брэнчу
- что просто удобно ревьювить
*/

CREATE TABLE ordering AS
SELECT author
    ,  title
    , (SELECT ROUND(AVG(amount)) FROM book) AS amount
FROM book
WHERE amount < (SELECT AVG(amount) FROM book);
SELECT * 
    FROM ordering;



--### v0.1.6 db 'business trip', selective requests ###--



SELECT name
     , city
     , per_diem
     , date_first
     , date_last
FROM trip
WHERE name LIKE '%а _%'
ORDER BY date_last DESC; 

SELECT DISTINCT name 
FROM trip
WHERE city 
    LIKE '%Москва%'
ORDER BY name;

SELECT city
    ,  COUNT(city) AS 'Количество'
FROM trip
GROUP BY 1
ORDER BY 1
;

SELECT city
    ,  COUNT(name) AS 'Количество'
  FROM trip
GROUP BY 1
ORDER BY 2 DESC
LIMIT 2
;

SELECT name
    ,  city
    ,  (DATEDIFF(date_last, date_first) + 1) AS 'Длительность'
  FROM trip
WHERE city NOT IN (
                    'Москва'
                 ,  'Санкт-Петербург'
                )
ORDER BY 3 DESC
       , 2 DESC 

;

SELECT name
    ,  city
    ,  date_first
    ,  date_last
  FROM trip
WHERE DATEDIFF(date_last, date_first) = (SELECT MIN(DATEDIFF(date_last, date_first)) FROM trip)
    ;

SELECT name
    ,  city
    ,  date_first
    ,  date_last
  FROM trip
WHERE MONTH(date_first) = MONTH(date_last)
ORDER BY 2 ASC 
      ,  1 ASC
    ;

SELECT
    MONTHNAME(date_first) AS "Месяц"
  , COUNT(MONTHNAME(date_first)) AS "Количество"
FROM
    trip
GROUP BY 
    1
ORDER BY
    2 DESC
  , 1 ASC
    ;

SELECT 
    name
  , city
  , date_first
  , (DATEDIFF(date_last, date_first) + 1) * per_diem AS 'Сумма'
FROM
    trip
WHERE 
    MONTH(date_first) = 2
    OR MONTH(date_first) = 3 
ORDER BY
    1 ASC
  , 2 DESC
    ;

SELECT 
    name
  , SUM(
        (DATEDIFF(date_last, date_first) + 1) * per_diem
        ) AS 'Сумма'
FROM
    trip
WHERE
    name IN (
            SELECT 
                name
            FROM 
                trip
            GROUP BY 
                name
            HAVING COUNT(name) > 3
    )
GROUP BY
    name
ORDER BY
    2 DESC
    ;



--### v0.1.7 db 'traffic disorder', correction requests ###--



CREATE TABLE
    fine ( 
        fine_id INT PRIMARY KEY AUTO_INCREMENT
      , name VARCHAR(30)
      , number_plate VARCHAR(6)
      , violation VARCHAR(50)
      , sum_fine DECIMAL(8, 2)
      , date_violation DATE
      , date_payment DATE
        )
    ;

INSERT INTO supply (title, author, price, amount)
            VALUES ('Лирика', 'Пастернак Б.Л.', 518.99, 2),
                   ('Черный человек', 'Есенин С.А.', 570.20, 6),
                   ('Белая гвардия', 'Булгаков М.А.', 540.50, 7),
                   ('Идиот', 'Достоевский Ф.М.', 360.80, 3)
    ;

INSERT INTO 
    fine ( 
        name
      , number_plate
      , violation
      , sum_fine
      , date_violation
      , date_payment
    )
VALUES 
    ('Баранов П.Е.', 'Р523ВТ', 'Превышение скорости(от 40 до 60)', NULL, '2020-02-14', NULL)
  , ('Абрамова К.А.', 'О111АВ', 'Проезд на запрещающий сигнал', NULL, '2020-02-23', NULL)
  , ('Яковлев Г.Р.', 'Т330ТТ ', 'Проезд на запрещающий сигнал', NULL, '2020-03-03', NULL)
    ;

UPDATE 
    fine f
  , traffic_violation tv
SET 
    f.sum_fine = tv.sum_fine
WHERE 
    f.sum_fine IS NULL 
    AND f.violation = tv.violation
    ;

SELECT 
    name
  , number_plate
  , violation
FROM
    fine
GROUP BY
    name
  , number_plate
  , violation
HAVING 
    COUNT(number_plate) > 1
ORDER BY
    name ASC
  , number_plate ASC
  , violation ASC
    ;

UPDATE 
    fine 
  , (
        SELECT 
            name
          , number_plate
          , violation
        FROM
            fine
        GROUP BY
            name
          , number_plate
          , violation
        HAVING 
            COUNT(number_plate) > 1
    ) AS buffer
SET 
    fine.sum_fine = fine.sum_fine * 2
WHERE 
    fine.date_payment IS NULL
    AND fine.name = buffer.name 
   ;

UPDATE 
    fine 
  , payment 
SET 
    fine.date_payment = payment.date_payment 
  , fine.sum_fine = IF (DATEDIFF(payment.date_payment, payment.date_violation) <= 20, fine.sum_fine / 2, fine.sum_fine)
WHERE 
    (fine.name, fine.number_plate, fine.violation)
  = (payment.name, payment.number_plate, payment.violation)
    AND fine.date_payment IS NULL
    ;

CREATE TABLE 
    back_payment AS
SELECT 
    name
  , number_plate
  , violation
  , sum_fine
  , date_violation
FROM 
    fine
WHERE 
    fine.date_payment IS NULL
    ;

DELETE FROM
    fine
WHERE
    DATEDIFF (date_violation, '2020-02-01') < 0
    ;



--### v0.2.1 connection between dbs ###--



CREATE TABLE
    author (
        author_id INT PRIMARY KEY AUTO_INCREMENT
      , name_author VARCHAR(50)
    )
    ;

INSERT INTO 
    author (
        name_author
        )
VALUES 
    ('Булгаков М.А.')
  , ('Достоевский Ф.М.')
  , ('Есенин С.А.')
  , ('Пастернак Б.Л.')
    ;

CREATE TABLE 
    book (
        book_id INT PRIMARY KEY AUTO_INCREMENT 
      , title VARCHAR(50) 
      , author_id INT NOT NULL
      , genre_id INT
      , price DECIMAL(8,2) 
      , amount INT 
      , FOREIGN KEY (author_id) REFERENCES author (author_id) 
      , FOREIGN KEY (genre_id) REFERENCES genre (genre_id)
    )
    ;
/* 
используйте DESCRIBE <table_name>  для получения информации о
столбцах таблицы (тип значений, является ключом или нет и т.д.) 
 */
DESCRIBE book;

CREATE TABLE 
    book (
        book_id INT PRIMARY KEY AUTO_INCREMENT 
      , title VARCHAR(50) 
      , author_id INT NOT NULL
      , genre_id INT
      , price DECIMAL(8,2) 
      , amount INT 
      , FOREIGN KEY (author_id) REFERENCES author (author_id) ON DELETE CASCADE
      , FOREIGN KEY (genre_id) REFERENCES genre (genre_id) ON DELETE SET NULL
    )
    ;
DESCRIBE 
    book
    ;

INSERT INTO 
    book (
        title
      , author_id
      , genre_id
      , price
      , amount
    )
VALUES
    ('Стихотворения и поэмы', 3, 2, 650.00 ,15)
  , ('Черный человек', 3, 2, 570.20,6)
  , ('Лирика', 4 , 2 , 518.99 ,2)
    ;



--### v0.2.2 selective requests, connectionion db  ###--



SELECT 
    title
  , name_genre
  , price
FROM
    genre 
	INNER JOIN book
    ON genre.genre_id = book.genre_id
WHERE 
    book.amount >= 8
ORDER BY 
    price DESC
    ;

SELECT 
    name_genre
FROM 
    genre 
	LEFT JOIN book
    ON genre.genre_id = book.genre_id
WHERE
    amount IS NULL
    ;

SELECT
    name_city
  , name_author
  , (DATE_ADD('2020-01-01', INTERVAL FLOOR(RAND() * 365) DAY)) AS 'Дата'
FROM
    city
  	CROSS JOIN author
ORDER BY 
	1 ASC
  ,	3 DESC
	;

SELECT 
	name_genre
  , title
  , name_author
FROM 
	genre
	INNER JOIN book ON genre.genre_id = book.genre_id
	INNER JOIN author ON book.author_id = author.author_id
WHERE 
	name_genre LIKE "%роман%"
ORDER BY 
	2 ASC
	;

SELECT 
	name_author
  , SUM(amount) AS 'Количество'
FROM
	author 
	LEFT JOIN book
	ON author.author_id = book.author_id
GROUP BY 
	1
HAVING 
	SUM(amount) < 10
    OR SUM(amount) IS NULL
ORDER BY 
	2 ASC
	;

-- Выбираем автора из таблицы "Автор"
SELECT 
	name_author
-- Выполняем внутренний джойн, привязывая таблицы  
FROM
	author 
	INNER JOIN book	ON author.author_id = book.author_id
-- Группировка по нашему единственному столбцу для выполнения куска с Having 
GROUP BY 
	name_author
-- Выполнение основного условия задачи - "... пишущих только в одном жанре"
HAVING 
	COUNT(DISTINCT(book.genre_id)) = 1
	;

-- Разжеванный пример:
-- SELECT name_author, name_genre /* выбираем автора и жанр */
-- FROM /* указываем таблицы, откуда мы хотим вытащить эту информацию */
--      genre /* первой берем таблицу с жанрами  */
--      INNER JOIN book ON genre.genre_id = book.genre_id /* у ней добавляем таблицу book по genre_id  */
--      INNER JOIN author ON book.author_id = author.author_id /* к таблицам genre и book добавляем таблицу author */
-- /* Мы последовательно сджойнили три наших таблицы и, пока что, в результирующей таблицы будут ВСЕ записи */
-- GROUP BY name_author, name_genre, genre.genre_id /* итоговый результат мы хотим видеть сгруппированным по авторам и жанрам */
-- HAVING genre.genre_id IN /* в сгруппированном результате покажи нам только те жанры, которые содержатся в: */
--     (
--         SELECT query_in_1.genre_id /* вложенный запрос, он выдаст только значения genre_id */
--         FROM /* создаются 2 временные таблицы, которые джойнятся по sum_amount: */
--             (/* в первой временной таблице мы выбираем id жанра и количество книг на складе, относящихся к этому жанру */
--                 SELECT genre_id, SUM(amount) as sum_amount /* вложенный подзапрос 1.1 */
--                 FROM book
--                 GROUP BY genre_id
--             ) query_in_1
--         INNER JOIN /* результат одного вложенного подзапроса 1.1 джойним с результатом второго вложенного подзапроса 1.2 */
--             (
--                 /* во второй временной таблице выбираем так же, но группируем по жанрам, внутри групп считаем количество книг
--                    и выбираем одну запись, у которой максимальное количество книг на складе, так как мы отсортировали по максимальному
--                    значению SUM(amount) и взяли первое (то есть самое большое)
--                 */
--                 SELECT genre_id, SUM(amount) as sum_amount /* вложенный подзапрос 1.2 */
--                 FROM book
--                 GROUP BY genre_id
--                 ORDER BY sum_amount DESC
--                 LIMIT 1
--             ) query_in_2
--         /* в первом джойне у нас получено 3 записи со значениями sum_amount: 31, 31, 7.
--            во втором джойне только одно значение sum_amount: 31.
--            Но в результирующей таблице будут только те записи sum_amount, у которых sum_amount одинаковые, т.е. 31
--            А так как в самом подзапросе мы просили показать только id жанра genre_id, то результат будет такой:
--            genre_id: 1 и 2, т.е. HAVING genre.genre_id IN (1,2)
--         */
--         ON query_in_1.sum_amount = query_in_2.sum_amount
--     )

SELECT 
	title
  , name_author
  , name_genre
  , price
  , amount  
FROM 
	author
	INNER JOIN book ON  author.author_id = book.author_id
    INNER JOIN genre ON book.genre_id = genre.genre_id
WHERE 
	genre.genre_id IN 
    (
        SELECT 
			query_in_1.genre_id 
        FROM 
            (
                SELECT 
					genre_id
				  , SUM(amount) as sum_amount 
                FROM 
					book
                GROUP BY 
					genre_id
            ) AS query_in_1
        INNER JOIN
            (
                SELECT 
					genre_id
				  , SUM(amount) as sum_amount
                FROM 
					book
                GROUP BY 
					genre_id
                ORDER BY 
					sum_amount DESC
                LIMIT 
					1
            ) AS query_in_2
        ON query_in_1.sum_amount = query_in_2.sum_amount
    )
ORDER BY 	
	1
	;

SELECT 
	title AS 'Название'
  , name_author AS 'Автор' 
  , (book.amount + supply.amount) AS 'Количество'
FROM
    book
    INNER JOIN author USING(author_id)
    INNER JOIN supply USING(title, price) 
        ; 



--### v0.2.3 correction requests, connection db  ###--



-- 1
UPDATE 
    book 
    INNER JOIN author USING(author_id)
    INNER JOIN supply ON book.title = supply.title 
        AND supply.author = author.name_author
SET 
    book.amount = book.amount + supply.amount
  , book.price = (book.price * book.amount + supply.price * supply.amount)/(book.amount + supply.amount)
  , supply.amount = 0   
WHERE 
    book.price != supply.price;

-- 2
-- INSERT INTO таблица (список_полей)
-- SELECT список_полей_из_других_таблиц
-- FROM 
--     таблица_1 
--     ... JOIN таблица_2 ON ...
--     ...

INSERT INTO 
    author (
        name_author
        )
SELECT 
    supply.author
FROM 
    author 
    RIGHT JOIN supply ON author.name_author = supply.author
WHERE 
    name_author IS NULL 
    ;

-- 3
INSERT INTO book(
    title
  , author_id
  , price
  , amount
    )
SELECT 
    title
  , author_id
  , price
  , amount
FROM 
    author 
    INNER JOIN supply ON author.name_author = supply.author
WHERE 
    amount != 0
    ;
SELECT 
    * 
FROM
    book
    ;

-- 4
UPDATE 
    book
SET 
    book.genre_id = 
        (
        SELECT 
            genre_id
        FROM 
           genre   
        WHERE 
            name_genre LIKE '%приключения%'
        )
WHERE 
    title LIKE '%остров сокровищ%' 
    AND author_id = (
                    SElECT 
                        author_id
                    FROM 
                        author
                    WHERE 
                        name_author LIKE '%стивенсон р.л.%'
                    )
                    ;
UPDATE 
    book
SET 
    book.genre_id = 
        (
        SELECT 
            genre_id
        FROM 
            genre   
        WHERE 
            name_genre LIKE '%поэзия%'
        )
WHERE 
    title LIKE '%стихотворения и поэмы%' 
    AND author_id = (
                    SElECT 
                        author_id
                    FROM 
                        author
                    WHERE 
                        name_author LIKE '%лермонтов м.ю.%'
                    )
                    ;        
SELECT 
    * 
FROM
    book
    ;

-- 5
DELETE FROM 
    author
WHERE  
    author_id IN (
                SELECT 
                    author_id
                FROM  
                    book
                GROUP BY
                    author_id
                HAVING 
                    SUM(amount) < 20
                )
                ;
SELECT * FROM author;
SELECT * FROM book;

-- 6
DELETE FROM 
    genre
WHERE  
    genre_id IN (
                SELECT
                    genre_id
                FROM  
                    book
                GROUP BY
                    genre_id
                HAVING 
                    COUNT(title) < 4
                )
                ;
SELECT * FROM author;
SELECT * FROM book;

-- 7 
-- DELETE FROM таблица_1
-- USING 
--     таблица_1 
--     INNER JOIN таблица_2 ON ...
-- WHERE ...

DELETE FROM
    author
USING
    book
    INNER JOIN author ON author.author_id = book.author_id
    INNER JOIN genre ON book.genre_id = genre.genre_id
WHERE 
    name_genre = 'Поэзия'
    ;
SELECT * FROM author;
SELECT * FROM book;



--### v0.2.4 db 'book\'s web market', selective requests  ###--



-- 1
SELECT DISTINCT
    buy.buy_id 
  , book.title
  , book.price
  , buy_book.amount
FROM
    client
    INNER JOIN buy USING(client_id)
    INNER JOIN buy_book USING(buy_id)
    INNER JOIN book USING(book_id)
WHERE 
    client.name_client = 'Баранов Павел'
ORDER BY 
    1
  , 2
    ;

-- 2
SELECT 
    author.name_author
  , book.title
  , COUNT(buy_book.amount) AS 'Количество'
FROM
    author
    INNER JOIN book USING(author_id)
    LEFT JOIN buy_book USING(book_id)
GROUP BY 
    1
  , 2
ORDER BY    
    1
  , 2
    ;

-- 3 
SELECT 
    city.name_city
  , COUNT(buy.client_id) AS 'Количество'
FROM 
    city 
    JOIN client USING(city_id)
    JOIN buy USING(client_id)
GROUP BY 
    1
ORDER BY 
    2 DESC
  , 1 ASC
    ;

-- 4 
SELECT 
    buy_id
  , date_step_end
FROM 
    buy_step 
WHERE 
    step_id = 1 
    AND date_step_end IS NOT NULL
    ;

-- 5
SELECT 
    buy_book.buy_id
  , client.name_client  
  , SUM(buy_book.amount * book.price) AS 'Стоимость'
FROM 
    buy_book
    JOIN buy USING(buy_id)
    JOIN client USING(client_id)
    JOIN book USING (book_id)
GROUP BY 
    1
  , 2
ORDER BY 
    1
    ;

-- 6 
SELECT  
    buy_step.buy_id
  , step.name_step
FROM 
    buy_step
    JOIN step USING(step_id)
WHERE 
    date_step_end IS NULL
    AND date_step_beg IS NOT NULL 
ORDER BY 
    1
    ;

-- 7 
SELECT
    buy.buy_id
  , (DATEDIFF(buy_step.date_step_end, buy_step.date_step_beg)) AS 'Количество_дней'  
  , IF(DATEDIFF(buy_step.date_step_end, buy_step.date_step_beg) > city.days_delivery , DATEDIFF(buy_step.date_step_end, buy_step.date_step_beg) - city.days_delivery, 0) AS 'Опоздание'
FROM    
    city
    JOIN client USING(city_id)
    JOIN buy USING(client_id)
    JOIN buy_step USING(buy_id)
    JOIN step USING(step_ID)
WHERE 
    buy_step.date_step_end IS NOT NULL 
    AND step.name_step = 'Транспортировка'
ORDER BY 
    1
    ;
  
-- 8 
SELECT DISTINCT
    client.name_client
FROM 
    author
    JOIN book USING(author_id) 
    JOIN buy_book USING(book_id)
    JOIN buy USING(buy_id)
    JOIN client USING(client_id)
WHERE 
    author.name_author LIKE 'достоевский %'
ORDER BY 
    1
    ;

-- 9 
SELECT 
    request_in.name_genre
  , MAX(request_sum) AS 'Количество'
FROM 
    (
        SELECT
            genre.name_genre
          , SUM(buy_book.amount) AS request_sum
        FROM 
            genre
            JOIN book USING(genre_id)
            JOIN buy_book USING(book_id)    
        GROUP BY 
            1
        LIMIT 
            1
    ) AS request_in
GROUP BY 
    1
    ;

-- 10 
-- SELECT столбец_1_1, столбец_1_2, ...
-- FROM 
--   ...
-- UNION
-- SELECT столбец_2_1, столбец_2_2, ...
-- FROM 
--   ...
-- или

-- SELECT столбец_1_1, столбец_1_2, ...
-- FROM 
--   ...
-- UNION ALL
-- SELECT столбец_2_1, столбец_2_2, ...
-- FROM 
--   ...

SELECT 
    YEAR(date_payment) AS 'Год'
  , MONTHNAME(date_payment) AS 'Месяц'
  , SUM(buy_archive.price * buy_archive.amount) AS 'Сумма'
FROM 
    buy_archive 
WHERE 
    buy_archive.date_payment IS NOT NULL
GROUP BY 
    2
  , 1
UNION 
SELECT 
    YEAR(buy_step.date_step_end) AS 'Год'
  , MONTHNAME(buy_step.date_step_end) AS 'Месяц'
  , SUM(book.price * buy_book.amount) AS 'Сумма' 
FROM 
    buy_step 
    JOIN buy_book USING(buy_id)
    JOIN book USING(book_id)
    JOIN step USING(step_id)
WHERE  
    date_step_end IS NOT Null 
    AND step.name_step = 'Оплата'  
GROUP BY 
    1
  , 2 
ORDER BY 
    2
  , 1
    ;

-- 11
SELECT 
    title 
  , SUM(request_in.volume_in) AS 'Количество'
  , SUM(request_in.sum_in) AS 'Сумма'
FROM
    (
        SELECT 
            book.title
          , SUM(buy_archive.amount) AS 'volume_in'
          , SUM(buy_archive.amount * buy_archive.price) AS 'sum_in'
        FROM 
            book 
            JOIN buy_archive USING(book_id) 
        GROUP BY 
            1
        UNION ALL
        SELECT 
            book.title
          , SUM(buy_book.amount) AS 'volume_in'
          , SUM(buy_book.amount * book.price) AS 'sum_in'
        FROM 
            buy_step
            JOIN step USING(step_id)
            JOIN buy USING(buy_id)
            JOIN buy_book USING(buy_id)
            JOIN book USING(book_id)
        WHERE 
            buy_step.date_step_end IS NOT Null 
            AND step.name_step = 'Оплата'         
        GROUP BY 
            1 
    ) AS request_in
GROUP BY 
    1
ORDER BY 
    3 DESC 
    ;



--### v0.2.5 db 'book\'s web market', correction requests  ###--



-- 1 
INSERT INTO 
    client 
        (
        name_client
      , city_id
      , email
        )
SELECT 
    'Попов Илья'
  , city_id =
  , 'popov@test'
FROM 
    city
WHERE  
    name_city = 'Москва'
    ;

-- 2 
INSERT INTO 
    buy 
        ( 
        buy_description
      , client_id 
        )
SELECT 
    'Связаться со мной по вопросу доставки'
  , (
        SELECT 
            client_id
        FROM 
            client 
        WHERE 
            name_client LIKE '%попов илья%'
    )
    ;

-- 3 
INSERT INTO 
    buy_book
        (
        buy_id
      , book_id
      , amount
        )
SELECT 
    '5'
  , (
        SELECT 
            book_id 
        FROM 
            book 
        WHERE 
            title LIKE '%лирика%' 
            AND author_id = 
                            (
                            SELECT 
                                author_id 
                            FROM   
                                author 
                            WHERE 
                                name_author LIKE '%пастернак%'
                            )
    )
  , '2'
FROM 
    book
WHERE 
    title LIKE '%лирика%' 
    ;
INSERT INTO 
    buy_book
        (
        buy_id
      , book_id
      , amount
        )
SELECT 
    '5'
  , (
        SELECT 
            book_id 
        FROM 
            book 
        WHERE 
            title LIKE '%белая гвардия%' 
            AND author_id = 
                            (
                            SELECT 
                                author_id 
                            FROM 
                                author 
                            WHERE 
                                name_author LIKE '%булгаков%'
                            )
        )
  ,   '1'
    ;
                        
-- 4 
UPDATE 
    book
    JOIN buy_book USING(book_id)
SET 
    book.amount = book.amount - buy_book.amount 
WHERE 
    buy_book.buy_id = '5'
    ;

-- 5 
CREATE TABLE 
    buy_pay AS
SELECT 
    book.title
  , author.name_author
  , book.price 
  , buy_book.amount 
  , (book.price * buy_book.amount) AS 'Стоимость'
FROM 
    author
    JOIN book USING(author_id)
    JOIN buy_book USING(book_id)
WHERE 
    buy_book.buy_id = '5'
ORDER BY 
    1
    ;

-- 6
CREATE TABLE 
    buy_pay AS
SELECT
    buy_id
  , SUM(buy_book.amount) AS 'Количество'
  , SUM(book.price * buy_book.amount) AS 'Итого'
 FROM 
    book
    JOIN buy_book USING(book_id)
WHERE 
    buy_book.buy_id = '5'
    ;

-- 7
INSERT INTO     
    buy_step 
        (
        buy_id
      , step_id
      , date_step_beg
      , date_step_end
        )  
SELECT 
    buy_id
  , step_id
  , NULL
  , NULL
FROM 
    buy
    CROSS JOIN step
WHERE 
    buy_id = '5'
    ;

-- 8     
UPDATE 
    buy_step
    JOIN step USING(step_id)
SET 
   date_step_beg = '2020-04-12'
WHERE 
    buy_step.buy_id = '5'
    AND step.name_step LIKE '%оплата%'
    ;

-- 9 
UPDATE 
    buy_step
    JOIN step USING(step_id)
SET 
   date_step_end = '2020-04-13'
WHERE 
    buy_step.buy_id = '5'
    AND step.name_step LIKE '%оплата%'
    ;
UPDATE 
    buy_step
    JOIN step USING(step_id)
SET 
   date_step_beg = '2020-04-13'
WHERE 
    buy_step.buy_id = '5'
    AND step.name_step LIKE '%упаковка%'
    ;
SELECT 
    * 
FROM 
    buy_step 
WHERE 
    buy_step_id = 17 
    OR buy_step_id = 18 
    OR buy_step_id = 20
    ;