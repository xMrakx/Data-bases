--1.Добавить внешние ключи.
ALTER TABLE [booking]
ADD FOREIGN KEY(id_client) REFERENCES client(id_client)

ALTER TABLE [room_in_booking]
ADD FOREIGN KEY(id_booking) REFERENCES booking(id_booking)
ALTER TABLE [room_in_booking]
ADD FOREIGN KEY(id_room) REFERENCES room(id_room)

ALTER TABLE [room]
ADD FOREIGN KEY(id_hotel) REFERENCES hotel(id_hotel)
ALTER TABLE [room]
ADD FOREIGN KEY(id_room_category) REFERENCES room_category(id_room_category)

--2.Выдать информацию о клиентах гостиницы “Космос”,
--проживающих в номерах категории “Люкс” на1 апреля 2019г..
SELECT  client.name, phone, [room].number FROM [client]
INNER JOIN [booking] ON [client].id_client = [booking].id_client
INNER JOIN [room_in_booking] ON [booking].id_booking = [room_in_booking].id_booking
INNER JOIN [room] ON [room].id_room = [room_in_booking].id_room
INNER JOIN [hotel] ON [room].id_hotel = [hotel].id_hotel
INNER JOIN [room_category] ON [room].id_room_category = [room_category].id_room_category
WHERE [hotel].name = 'Космос' 
AND '2019-04-01' BETWEEN [room_in_booking].checkin_date AND [room_in_booking].checkout_date
AND [room_category].name = 'Люкс'

--3.Дать список свободных номеров всех гостиниц на 22 апреля.
SELECT number FROM [room]
WHERE id_room NOT IN (
SELECT id_room FROM room_in_booking
WHERE '2019-04-22' BETWEEN checkin_date AND checkout_date)

--4.Дать количество проживающих в гостинице “Космос” на 23 марта по каждой категории номеров
SELECT COUNT([room_in_booking].id_room), [room_category].name FROM [room_in_booking]
INNER JOIN [room] ON [room_in_booking].id_room = [room].id_room
INNER JOIN [room_category] ON [room].id_room_category = [room_category].id_room_category
WHERE '2019-03-23' BETWEEN checkin_date AND checkout_date
AND id_hotel IN (SELECT id_hotel FROM hotel WHERE name = 'Космос')
GROUP BY [room_category].name

--5.Дать список последних проживавших клиентов по всем комнатам гостиницы “Космос”,
--выехавшим в апреле с указанием даты выезда.
SELECT [client].name, checkout_date FROM [client]
INNER JOIN [booking] ON [client].id_client = [booking].id_client
INNER JOIN [room_in_booking] ON [booking].id_booking = [room_in_booking].id_booking
INNER JOIN [room] ON [room_in_booking].id_room = [room].id_room
INNER JOIN [hotel] ON [room].id_hotel = [hotel].id_hotel
WHERE checkout_date BETWEEN '2019-04-01' AND '2019-04-30'
AND [hotel].name = 'Космос'

--6.Продлить на 2 дня дату проживания в гостинице “Космос” всем клиентам
--комнат категории “Бизнес”, которые заселились 10 мая.
UPDATE [room_in_booking]
SET checkout_date = DATEADD(day, 2, checkout_date)
WHERE checkin_date = '2019-05-10'
AND id_room IN (
SELECT id_room FROM [room]
INNER JOIN [room_category] ON [room].id_room_category = [room_category].id_room_category
WHERE [room_category].name = 'Бизнес')

--7Найти все "пересекающиеся " вариантыпроживания. Правильное состояние: не может быть забронирован
--один номер на одну дату несколько раз, т.к. нельзя заселиться нескольким клиентам в один номер.
--Записи в таблице room_in_booking с id_room_in_booking = 5 и 2154 являются примером неправильного 
--состояния, которые необходимо найти. Результирующий кортеж выборки должен содержать информацию о двух конфликтующих номерах.
SELECT * FROM [dbo].[room_in_booking] AS [room_in_booking_1]
INNER JOIN [dbo].[room_in_booking] AS [room_in_booking_2]
ON (([room_in_booking_1].[checkin_date] <= [room_in_booking_2].[checkout_date]
AND [room_in_booking_2].[checkout_date] <= [room_in_booking_1].[checkout_date])
OR ([room_in_booking_2].[checkin_date] <= [room_in_booking_1].[checkout_date]
AND [room_in_booking_1].[checkout_date] <= [room_in_booking_2].[checkout_date])
OR ([room_in_booking_1].[checkin_date] <= [room_in_booking_2].[checkin_date] 
AND [room_in_booking_1].[checkout_date] >= [room_in_booking_2].[checkout_date])
OR ([room_in_booking_2].[checkin_date] <= [room_in_booking_1].[checkin_date] 
AND [room_in_booking_2].[checkout_date] >= [room_in_booking_1].[checkout_date]))
AND ([room_in_booking_1].[id_room] = [room_in_booking_2].[id_room])
AND ([room_in_booking_1].[id_booking] != [room_in_booking_2].[id_booking])
ORDER BY [room_in_booking_1].[id_room_in_booking] ASC

--8.Создать бронирование в транзакции.
BEGIN TRANSACTION booking;

INSERT INTO [booking] (id_client, booking_date)
VALUES (1, '2022-04-01')
INSERT INTO [room_in_booking] (id_booking, id_room, checkin_date, checkout_date)
VALUES ((SELECT id_booking from [booking]
	WHERE id_client = 1 AND booking_date = '2022-04-01'), 4, '2022-04-12', '2022-04-20')
COMMIT;

--9.Добавить необходимые индексы для всех таблиц
CREATE NONCLUSTERED INDEX IX_id_booking_id_client
ON [booking]
(
	id_booking,
	id_client
)

CREATE NONCLUSTERED INDEX IX_id_booking_id_room
ON [room_in_booking]
(
	id_booking,
	id_room
)

CREATE NONCLUSTERED INDEX IX_id_hotel_id_room_category
ON [room]
(
	id_hotel,
	id_room_category
)
