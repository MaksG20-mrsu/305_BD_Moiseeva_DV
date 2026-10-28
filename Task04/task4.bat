
#!/bin/bash
cd "$(dirname "$0")"

echo "Создание базы данных..."
sqlite3 movies_rating.db < db_init.sql

echo "1. Пары пользователей, оценивших один фильм (первые 100)"
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box "
SELECT DISTINCT u1.name AS 'Пользователь 1',
       u2.name AS 'Пользователь 2',
       m.title AS 'Фильм'
FROM ratings r1
JOIN ratings r2
  ON r1.movie_id = r2.movie_id AND r1.user_id < r2.user_id
JOIN users u1 ON u1.id = r1.user_id
JOIN users u2 ON u2.id = r2.user_id
JOIN movies m ON m.id = r1.movie_id
LIMIT 100;"
echo ""

echo "2. Десять самых свежих оценок"
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box "
SELECT m.title AS 'Фильм', u.name AS 'Пользователь',
       r.rating AS 'Оценка', date(r.timestamp,'unixepoch') AS 'Дата отзыва'
FROM ratings r
JOIN users u ON u.id = r.user_id
JOIN movies m ON m.id = r.movie_id
ORDER BY r.timestamp DESC
LIMIT 10;"
echo ""

echo "3. Фильмы с максимальным и минимальным средним рейтингом"
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box "
WITH a AS (
 SELECT m.id, m.title, m.year, AVG(r.rating) avg_rating
 FROM movies m JOIN ratings r ON r.movie_id=m.id
 GROUP BY m.id,m.title,m.year
), e AS (SELECT MAX(avg_rating) mx, MIN(avg_rating) mn FROM a)
SELECT a.title AS 'Фильм', a.year AS 'Год',
 ROUND(a.avg_rating,3) AS 'Средний рейтинг',
 CASE WHEN a.avg_rating=e.mx THEN 'Да' ELSE 'Нет' END AS 'Рекомендуем'
FROM a CROSS JOIN e
WHERE a.avg_rating=e.mx OR a.avg_rating=e.mn
ORDER BY a.year,a.title;"
echo ""

echo "4. Количество и средняя оценка от женщин за 2010–2012 годы"
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box "
SELECT COUNT(*) AS 'Количество оценок',
       ROUND(AVG(r.rating),3) AS 'Средняя оценка'
FROM ratings r JOIN users u ON u.id=r.user_id
WHERE LOWER(u.gender) IN ('female','f','женский','ж')
AND date(r.timestamp,'unixepoch') >= '2010-01-01'
AND date(r.timestamp,'unixepoch') < '2013-01-01';"
echo ""

echo "5. Первые 20 фильмов со средним рейтингом и местом в рейтинге"
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box "
WITH a AS (
 SELECT m.id,m.title,m.year,AVG(r.rating) avg_rating
 FROM movies m JOIN ratings r ON r.movie_id=m.id
 GROUP BY m.id,m.title,m.year
), ranked AS (
 SELECT title,year,avg_rating,
        RANK() OVER (ORDER BY avg_rating DESC) rating_place
 FROM a
)
SELECT title AS 'Фильм',year AS 'Год',
 ROUND(avg_rating,3) AS 'Средняя оценка',
 rating_place AS 'Место в рейтинге'
FROM ranked
ORDER BY year,title
LIMIT 20;"
echo ""

echo "6. Десять последних зарегистрированных пользователей"
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box "
SELECT
 substr(name,instr(name,' ')+1) || ' ' ||
 substr(name,1,instr(name,' ')-1) || '|' || register_date
 AS 'Фамилия Имя|Дата регистрации'
FROM users
ORDER BY register_date DESC
LIMIT 10;"
echo ""

echo "7. Таблица умножения от 1 до 10 с помощью рекурсивного CTE"
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box "
WITH RECURSIVE multiplication(a,b) AS (
 SELECT 1,1
 UNION ALL
 SELECT CASE WHEN b=10 THEN a+1 ELSE a END,
        CASE WHEN b=10 THEN 1 ELSE b+1 END
 FROM multiplication
 WHERE a<10 OR b<10
)
SELECT a||'x'||b||'='||(a*b) AS 'Таблица умножения'
FROM multiplication;"
echo ""

echo "8. Все жанры фильмов с помощью рекурсивного CTE"
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box "
WITH RECURSIVE genre_split(movie_id,rest,genre) AS (
 SELECT id,genres||'|','' FROM movies
 WHERE genres IS NOT NULL AND genres<>''
 UNION ALL
 SELECT movie_id,
        substr(rest,instr(rest,'|')+1),
        trim(substr(rest,1,instr(rest,'|')-1))
 FROM genre_split WHERE rest<>''
)
SELECT DISTINCT genre AS 'Жанр'
FROM genre_split
WHERE genre<>''
ORDER BY genre;"
