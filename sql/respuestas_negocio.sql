-- Pergunta 1:
--Obter apenas customers com mais de 1500 vendas em Janeiro, que façam aniversário na data de hoje
SELECT  c.customer_id,
        c.first_name,
        c.birth_date,
        COUNT(DISTINCT order_id) as orders_sold
FROM customer c
INNER JOIN item i ON c.customer_id = i.seller_id
INNER JOIN OrderData od ON i.item_id = od.item_id
WHERE 
    -- match de mês e dia de nasc. do customer com mês e dia atual e apenas vendas de janeiro 2020
    DATEPART(MONTH, c.birth_date) = DATEPART(MONTH, GETDATE())
    AND DATEPART(DAY, c.birth_date) = DATEPART(DAY, GETDATE())
    AND od.order_date BETWEEN '2020-01-01' AND '2020-01-31'
GROUP BY c.customer_id, c.first_name, c.birth_date
HAVING COUNT(DISTINCT order_id) > 1500 -- obtendo apenas customers com mais de 1500 vendas no mês
;

-- Pergunta 2:
-- Para cada mês de 2020, obter os 5 customers que mais venderam em valor total na categoria Celulares. 
-- Mês e ano | Nome e Sobrenome | Quantidade de vendas realizadas, qtd. de produtos vendidos e valor total transacionado
WITH CategoryFilter AS (
    SELECT category_id
    FROM category
    WHERE name = 'Celulares'
), 

RankSales AS (
    SELECT
        YEAR(od.order_date) AS year,
        MONTH(od.order_date) AS month,
        CONCAT(c.first_name, ' ', c.last_name) AS seller, -- nome completo do vendedor 
        COUNT(DISTINCT od.order_id) AS orders_sold,
        SUM(od.quantity) AS quantity_sold,
        SUM(od.order_value_total) AS order_total,
        ROW_NUMBER() OVER (
            -- ordernar os maiores valores totais vendidos, por mês e ano
            PARTITION BY YEAR(od.order_date), MONTH(od.order_date)
            ORDER BY SUM(od.order_value_total) DESC
        ) AS ranking
    FROM OrderData od
    INNER JOIN item i ON od.item_id = i.item_id
    INNER JOIN CategoryFilter cf ON i.category_id = cf.category_id -- filtrando a categoria de interesse 
    INNER JOIN customer c ON i.seller_id = c.customer_id
    WHERE od.order_date BETWEEN '2020-01-01' AND '2020-12-31' -- apenas 2020 
    GROUP BY YEAR(od.order_date), MONTH(od.order_date), c.customer_id, c.first_name, c.last_name
)

SELECT year, month, seller, orders_sold, quantity_sold, order_total
FROM RankSales
WHERE ranking <=5 -- obtendo apenas os top 5 vendedores de cada ano e mês 
ORDER BY year, month, ranking
;

-- Pergunta 3:
CREATE OR ALTER PROCEDURE  UpdateItemHistory
AS
BEGIN
    SET NOCOUNT ON; -- não retornar row count pelo tamanho da tabela Items 
    
    -- Atualiza histórico diário de itens com preço e status atual 
    INSERT INTO ItemUpdate (item_id, date_update, price, status, update_timestamp)
    SELECT  item_id,
            GETDATE() AS date_update, 
            price,
            status,
            SYSDATETIME() as update_timestamp
    FROM item;
END;
GO

EXEC UpdateItemHistory;
