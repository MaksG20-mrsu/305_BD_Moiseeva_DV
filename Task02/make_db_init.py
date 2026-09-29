import csv
import re
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parent
OUTPUT_FILE = BASE_DIR / "db_init.sql"


def read_csv(filename, delimiter=","):
    """Чтение исходного файла."""
    with open(
        BASE_DIR / filename,
        "r",
        encoding="utf-8-sig",
        newline=""
    ) as file:
        return list(csv.reader(file, delimiter=delimiter))


def sql_value(value):
    """Преобразование значения в SQL."""
    if value is None or value == "":
        return "NULL"

    value = str(value)

    return "'" + value.replace("'", "''") + "'"


def insert_statement(table, columns, values):
    """Формирование SQL-команды INSERT."""
    columns_sql = ", ".join(columns)
    values_sql = ", ".join(values)

    return (
        f"INSERT INTO {table} "
        f"({columns_sql}) VALUES ({values_sql});"
    )


def main():
    sql = [
        "PRAGMA foreign_keys = OFF;",
        "BEGIN TRANSACTION;",
        "DROP TABLE IF EXISTS ratings;",
        "DROP TABLE IF EXISTS tags;",
        "DROP TABLE IF EXISTS movies;",
        "DROP TABLE IF EXISTS users;",
        "",
        """CREATE TABLE movies (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    year INTEGER,
    genres TEXT
);""",
        """CREATE TABLE ratings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    movie_id INTEGER,
    rating REAL,
    timestamp INTEGER
);""",
        """CREATE TABLE tags (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    movie_id INTEGER,
    tag TEXT,
    timestamp INTEGER
);""",
        """CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    name TEXT,
    email TEXT,
    gender TEXT,
    register_date TEXT,
    occupation TEXT
);""",
        "",
    ]

    # Загрузка фильмов
    movies = read_csv("movies.csv")

    for row in movies[1:]:
        movie_id, title, genres = row[:3]

        match = re.search(r"\((\d{4})\)\s*$", title)
        year = match.group(1) if match else None

        values = [
            str(int(movie_id)),
            sql_value(title),
            str(int(year)) if year else "NULL",
            sql_value(genres),
        ]

        sql.append(
            insert_statement(
                "movies",
                ["id", "title", "year", "genres"],
                values,
            )
        )

    # Загрузка оценок
    ratings = read_csv("ratings.csv")

    for row in ratings[1:]:
        user_id, movie_id, rating, timestamp = row[:4]

        values = [
            str(int(user_id)),
            str(int(movie_id)),
            str(float(rating)),
            str(int(timestamp)),
        ]

        sql.append(
            insert_statement(
                "ratings",
                ["user_id", "movie_id", "rating", "timestamp"],
                values,
            )
        )

    # Загрузка тегов
    tags = read_csv("tags.csv")

    for row in tags[1:]:
        user_id, movie_id, tag, timestamp = row[:4]

        values = [
            str(int(user_id)),
            str(int(movie_id)),
            sql_value(tag),
            str(int(timestamp)),
        ]

        sql.append(
            insert_statement(
                "tags",
                ["user_id", "movie_id", "tag", "timestamp"],
                values,
            )
        )

    # Загрузка пользователей.
    # В users.txt поля разделены символом |
    users = read_csv("users.txt", delimiter="|")

    for row in users:
        user_id, name, email, gender, register_date, occupation = row[:6]

        values = [
            str(int(user_id)),
            sql_value(name),
            sql_value(email),
            sql_value(gender),
            sql_value(register_date),
            sql_value(occupation),
        ]

        sql.append(
            insert_statement(
                "users",
                [
                    "id",
                    "name",
                    "email",
                    "gender",
                    "register_date",
                    "occupation",
                ],
                values,
            )
        )

    sql.extend([
        "",
        "COMMIT;",
        "PRAGMA foreign_keys = ON;",
    ])

    OUTPUT_FILE.write_text(
        "\n".join(sql) + "\n",
        encoding="utf-8",
    )

    print("Файл db_init.sql успешно создан.")
    print(f"Фильмов: {len(movies) - 1}")
    print(f"Оценок: {len(ratings) - 1}")
    print(f"Тегов: {len(tags) - 1}")
    print(f"Пользователей: {len(users)}")


if __name__ == "__main__":
    main()