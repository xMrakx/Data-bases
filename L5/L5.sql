--1.�������� ������� �����.
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

--2.������ ���������� � �������� ��������� �������,
--����������� � ������� ��������� ����� ��1 ������ 2019�.
SELECT  client.name, phone, [room].number FROM [client]
INNER JOIN [booking] ON [client].id_client = [booking].id_client
INNER JOIN [room_in_booking] ON [booking].id_booking = [room_in_booking].id_booking
INNER JOIN [room] ON [room].id_room = [room_in_booking].id_room
INNER JOIN [hotel] ON [room].id_hotel = [hotel].id_hotel
INNER JOIN [room_category] ON [room].id_room_category = [room_category].id_room_category
WHERE [hotel].name = '������' 
AND '2019-04-01' BETWEEN [room_in_booking].checkin_date AND [room_in_booking].checkout_date
AND [room_category].name = '����'

--3.���� ������ ��������� ������� ���� �������� �� 22 ������.
SELECT number FROM [room]
WHERE id_room NOT IN (
SELECT id_room FROM room_in_booking
WHERE '2019-04-22' BETWEEN checkin_date AND checkout_date)

--4.���� ���������� ����������� � ��������� ������� �� 23 ����� �� ������ ��������� �������
SELECT COUNT([room_in_booking].id_room), [room_category].name FROM [room_in_booking]
INNER JOIN [room] ON [room_in_booking].id_room = [room].id_room
INNER JOIN [room_category] ON [room].id_room_category = [room_category].id_room_category
WHERE '2019-03-23' BETWEEN checkin_date AND checkout_date
AND id_hotel IN (SELECT id_hotel FROM hotel WHERE name = '������')
GROUP BY [room_category].name

--5.���� ������ ��������� ����������� �������� �� ���� �������� ��������� �������,
--��������� � ������ � ��������� ���� ������.
SELECT [client].name, checkout_date FROM [client]
INNER JOIN [booking] ON [client].id_client = [booking].id_client
INNER JOIN [room_in_booking] ON [booking].id_booking = [room_in_booking].id_booking
INNER JOIN [room] ON [room_in_booking].id_room = [room].id_room
INNER JOIN [hotel] ON [room].id_hotel = [hotel].id_hotel
WHERE checkout_date BETWEEN '2019-04-01' AND '2019-04-30'
AND [hotel].name = '������'

--6.�������� �� 2 ��� ���� ���������� � ��������� ������� ���� ��������
--������ ��������� �������, ������� ���������� 10 ���.
UPDATE [room_in_booking]
SET checkout_date = DATEADD(day, 2, checkout_date)
WHERE checkin_date = '2019-05-10'
AND id_room IN (
SELECT id_room FROM [room]
INNER JOIN [room_category] on [room].id_room_category = [room_category].id_room_category
WHERE [room_category].name = '������')

--8.������� ������������ � ����������.
BEGIN TRANSACTION booking;

INSERT INTO [booking] (id_client, booking_date)
VALUES (1, '2022-04-01')
INSERT INTO [room_in_booking] (id_booking, id_room, checkin_date, checkout_date)
VALUES ((SELECT id_booking from [booking]
	WHERE id_client = 1 AND booking_date = '2022-04-01'), 4, '2022-04-12', '2022-04-20')
COMMIT;

--9.�������� ����������� ������� ��� ���� ������
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
