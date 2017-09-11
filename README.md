# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

# Some blog JSON API, SQL tasks
Технические характеристики компьютера, на котором была произведена
разработка:
* Процессор Core i5 5-го поколения;
* 4 ГБ оперативной памяти DDR3 1333 МГЦ;
* Запоминающее устройство HDD.
## Часть 1. JSON API для блога.
Структура базы данных состоит из следующих таблиц (указаны поля помимо
создаваемых в Rails по умолчанию):
1. users, имеет поля:
* login, строковое поле.
2. Таблица posts с полями:
* user_id – внешний ключ к таблице users, целочисл.;
* title – строчный тип;
* content – текстовое поле;
* user_ip – строковое поле;
* average_rate, тип: чисто с плавающей запятой;
* login - строковое поле.
3. Таблица rates:
* post_id – внешний ключ, целочисленный тип;
* value – целочисл.
Был реализован функционал обработки запросов:
1. Создать пост, POST /posts, принимает параметры: post: [login, title,
content, user_ip], все параметры обязательны. Возвращает параметры
нового поста.
2. Оценить пост, POST /rates/evaluate_post, принимает параметры: rate:
[post_id, value], параметры обязательны. Возвращает новую среднюю
оценку поста.
3. Получить несколько наилучшим образом оцененных постов, POST
/posts/get_top_posts, принимает обязательный параметр top_count,
целочисленный тип.
4. Получить все IP, с которых постили пользователи, со списком логинов
постивших пользователей, POST /posts/get_user_ips.
Функционирование приложения было описано и протестировано с помощью
технологии BDD-тестирования Rspec.
Допущения, проведенные во время разработки тестового задания:
Была проведена денормализация таблицы posts: добавлено поле средней
оценки average_rate для ускорения поиска наилучшим образом оцененных
постов. Также было продублировано поле login (из таблицы users) для
оптимизации скорости поиска пересечения по user_ip и login при разработке
четвертого пункта ТЗ.
Примечания:
Функционирование приложения полностью соответствует трем пунктам ТЗ,
для четвертого не удалось достигнуть скорости обработки в 100 мс. На
данном оборудовании среднее время обработки около 200-250 мс.
Дополнительно были подключены следующие гемы: pry-rails, rspec.
## Часть 2. Задание на знание SQL
```SQL
CREATE TEMP TABLE USERS(id bigserial, group_id bigint);
INSERT INTO users(group_id) VALUES (1), (1), (1), (2), (1), (3);
-- группировка по group_id (по непрерывным группам) с подсчетом кол-ва
записей в группе
SELECT group_id, COUNT(*)
FROM (
  SELECT id,
         id - ROW_NUMBER() OVER (PARTITION BY group_id ORDER BY id)
  AS res, group_id
  FROM users) new_table
  GROUP BY group_id, res
  ORDER BY group_id;
-- группировка по group_id (по непрерывным группам) с подсчетом кол-ва
записей в группе
SELECT group_id, MIN(new_table.id)
FROM (
  SELECT id,
         id - ROW_NUMBER() OVER (PARTITION BY group_id ORDER BY id)
  AS res, group_id
  FROM users) new_table
  GROUP BY group_id, res
  ORDER BY group_id;
```
Примечания: данный код не сортирует записи в порядке id записей.
