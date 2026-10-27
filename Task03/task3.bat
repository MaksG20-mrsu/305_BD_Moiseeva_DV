
#!/bin/bash


sqlite3 movies_rating.db < db_init.sql

echo "1. Составить список фильмов, имеющих хотя бы одну оценку. Сортировка по году и названию. Первые 10 фильмов."
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "SELECT DISTINCT m.title, m.year FROM movies AS m JOIN ratings AS r ON m.id = r.movie_id ORDER BY m.year, m.title LIMIT 10;"
echo " "

echo "2. Вывести пользователей, фамилии которых начинаются на букву A. Сортировка по дате регистрации. Первые 5 пользователей."
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "SELECT * FROM users WHERE substr(trim(name), instr(trim(name), ' ') + 1, 1) = 'A' ORDER BY date(register_date) LIMIT 5;"
echo " "

echo "3. Вывести эксперта, фильм, год выпуска, оценку и дату оценки в формате ГГГГ-ММ-ДД. Первые 50 записей."
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "SELECT u.name AS expert, m.title AS movie, m.year, r.rating, date(r.timestamp, 'unixepoch') AS rating_date FROM ratings AS r JOIN users AS u ON r.user_id = u.id JOIN movies AS m ON r.movie_id = m.id ORDER BY u.name, m.title, r.rating LIMIT 50;"
echo " "

echo "4. Вывести фильмы и присвоенные пользователями теги. Сортировка по году, названию и тегу. Первые 40 записей."
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "SELECT m.title, m.year, t.tag FROM movies AS m JOIN tags AS t ON m.id = t.movie_id ORDER BY m.year, m.title, t.tag LIMIT 40;"
echo " "

echo "5. Вывести все фильмы последнего года выпуска в базе данных."
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "SELECT title, year, genres FROM movies WHERE year = (SELECT MAX(year) FROM movies) ORDER BY title;"
echo " "

echo "6. Найти комедии после 2000 года, понравившиеся мужчинам (оценка не ниже 4.5). Вывести количество таких оценок."
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "SELECT m.title, m.year, COUNT(*) AS high_ratings FROM movies AS m JOIN ratings AS r ON m.id = r.movie_id JOIN users AS u ON r.user_id = u.id WHERE m.year > 2000 AND m.genres LIKE '%Comedy%' AND lower(u.gender) IN ('m', 'male', 'мужской') AND r.rating >= 4.5 GROUP BY m.id, m.title, m.year ORDER BY m.year, m.title;"
echo " "

echo "7. Вывести количество пользователей по каждой профессии."
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "SELECT occupation, COUNT(*) AS user_count FROM users GROUP BY occupation ORDER BY user_count DESC, occupation;"
echo " "

echo "Самая распространенная профессия."
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "SELECT occupation, COUNT(*) AS user_count FROM users GROUP BY occupation ORDER BY user_count DESC, occupation LIMIT 1;"
echo " "

echo "Самая редкая профессия."
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "SELECT occupation, COUNT(*) AS user_count FROM users GROUP BY occupation ORDER BY user_count ASC, occupation LIMIT 1;"
