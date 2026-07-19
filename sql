Расчет ROMI и чистой прибыли в разрезе каналов
SELECT 
    o.Канал,
    SUM(o."Финальная цена") AS Gross_Revenue,
    SUM(o.Себестоимость) AS Total_Cost,
    SUM(o.Налог) AS Total_Tax,
    SUM(o."Финальная цена" - o.Себестоимость - o.Налог) AS Net_Profit,
    mc.Расходы AS Marketing_Spend,
    ROUND(((SUM(o."Финальная цена" - o.Себестоимость - o.Налог) - mc.Расходы) * 100.0 / mc.Расходы), 2) AS ROMI_Percent
FROM orders o
JOIN (
    SELECT Канал, SUM(Расходы) AS Расходы 
    FROM marketing_costs 
    GROUP BY Канал
) mc ON o.Канал = mc.Канал
WHERE o.Статус = 'Оплачен'
GROUP BY o.Канал, mc.Расходы
ORDER BY Net_Profit DESC;
---------------------------------------------------
Расчет CAC) по каналам привлечения
SELECT 
    u.Канал,
    mc.Total_Spend AS Marketing_Costs,
    COUNT(DISTINCT o.user_id) AS Total_Paying_Customers,
    ROUND((mc.Total_Spend * 1.0 / COUNT(DISTINCT o.user_id)), 2) AS CAC
FROM users u
JOIN orders o ON u.user_id = o.user_id
JOIN (
    SELECT Канал, SUM(Расходы) AS Total_Spend 
    FROM marketing_costs 
    GROUP BY Канал
) mc ON u.Канал = mc.Канал
WHERE o.Статус = 'Оплачен'
GROUP BY u.Канал, mc.Total_Spend
ORDER BY CAC ASC;
------------------------------------------------------------------------------
Студенты с повторными покупками для RFM
SELECT 
    user_id,
    COUNT(order_id) AS Total_Orders,
    SUM("Финальная цена") AS Total_LTV,
    MAX("Дата заказа") AS Last_Order_Date
FROM orders
WHERE Статус = 'Оплачен'
GROUP BY user_id
HAVING COUNT(order_id) > 1
ORDER BY Total_LTV DESC;
