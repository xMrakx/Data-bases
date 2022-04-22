-- 1 Добавить внешние ключи.
ALTER TABLE [production]
ADD FOREIGN KEY(id_company) REFERENCES company(id_company)
ALTER TABLE [production]
ADD FOREIGN KEY(id_medicine) REFERENCES medicine(id_medicine)

ALTER TABLE [dealer]
ADD FOREIGN KEY(id_company) references company(id_company)

ALTER TABLE [order]
ADD FOREIGN KEY(id_production) REFERENCES production(id_production)
ALTER TABLE [order]
ADD FOREIGN KEY(id_dealer) REFERENCES dealer(id_dealer)
ALTER TABLE [order]
ADD FOREIGN KEY(id_pharmacy) REFERENCES pharmacy(id_pharmacy)

--2 Выдать информацию по всем заказам лекарства “Кордерон” компании “Аргус” с
--указанием названий аптек, дат, объема заказов.
SELECT [pharmacy].name, date, quantity FROM [order]
INNER JOIN [pharmacy] ON [pharmacy].id_pharmacy = [order].id_pharmacy
INNER JOIN [production] ON [production].id_production = [order].id_production
INNER JOIN [medicine] ON [medicine].id_medicine = [production].id_medicine
INNER JOIN [company] ON [company].id_company = [production].id_company
WHERE [company].name = 'Аргус' 
AND [medicine].name = 'Кордерон'

--3 Дать список лекарств компании “Фарма”, на которые не были сделаны заказы
--до 25 января
SELECT [medicine].name FROM [company]
INNER JOIN [production] ON [production].id_company = [company].id_company
INNER JOIN [medicine] ON [medicine].id_medicine = [production].id_medicine
WHERE [company].name = 'Фарма' 
AND [production].id_production NOT IN(
	SELECT [order].id_production FROM [order]
	INNER JOIN [production] ON [production].id_production = [order].id_production
	WHERE date < '2019-01-25' AND [company].name = 'Фарма'
	)

--4 Дать минимальный и максимальный баллы лекарств каждой фирмы, которая
--оформила не менее 120 заказов
SELECT [company].name , MIN(rating) , MAX(rating) FROM [production]
INNER JOIN [company] ON [company].id_company = [production].id_company
INNER JOIN [order] ON  [order].id_production = [production].id_production
GROUP BY [company].name
HAVING COUNT([order].id_order) >= 120

--5 Дать списки сделавших заказы аптек по всем дилерам компании 
-- “AstraZeneca”. Если у дилера нет заказов, в названии аптеки проставить NULL.
SELECT [pharmacy].name, [dealer].name FROM [pharmacy]
RIGHT JOIN [order] ON [order].id_pharmacy = [pharmacy].id_pharmacy
INNER JOIN [dealer] ON [dealer].id_dealer = [order].id_dealer
INNER JOIN [company] ON [company].id_company = [dealer].id_company
WHERE [company].name = 'AstraZeneca'

--6 Уменьшить на 20% стоимость всех лекарств, если она превышает 3000, а
--длительность лечения не более 7 дней.
UPDATE [production]
SET price = price * 0.8 
FROM [production] INNER JOIN [medicine] ON [medicine].id_medicine = [production].id_medicine
WHERE price > 3000 AND [medicine].cure_duration <= 7

--7 Добавить необходимые индексы.
CREATE INDEX dealer_id_company_index
          ON dealer (id_company);

CREATE INDEX order_id_production_index
          ON [order] (id_production);

CREATE INDEX order_id_dealer_index
          ON [order] (id_dealer);

CREATE INDEX order_id_pharmacy_index
          ON [order] (id_pharmacy);

CREATE INDEX production_id_company_index
          ON production (id_company);

CREATE INDEX production_id_medicine_index
          ON production (id_medicine);
