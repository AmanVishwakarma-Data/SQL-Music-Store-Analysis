-- 1) Highest Level Employee
SELECT first_name, last_name, title, email 
FROM employee
ORDER BY levels DESC
LIMIT 1;

-- 2) Top 10 Countries by Number of Invoices
SELECT billing_country, COUNT(*) AS Number_Of_Invoice 
FROM invoice
GROUP BY billing_country
ORDER BY Number_Of_Invoice DESC 
LIMIT 10;

-- 3) Lowest 3 Invoice Transactions
SELECT * 
FROM invoice
ORDER BY total 
LIMIT 3;

-- 4) City That Generates the Highest Revenue
SELECT billing_city, SUM(total) AS Total_Value 
FROM invoice
GROUP BY billing_city
ORDER BY Total_Value DESC 
LIMIT 1;

-- 5) Highest Spending Customer Using CTE
WITH temp_table AS (
    SELECT customer_id, SUM(total) AS Total_Amount 
    FROM invoice
    GROUP BY customer_id
)
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS Customer_Name,
       t.Total_Amount
FROM customer c
JOIN temp_table t ON c.customer_id = t.customer_id
ORDER BY t.Total_Amount DESC
LIMIT 1;

-- 6) Customers Who Purchased Rock Music
SELECT DISTINCT c.customer_id,
       CONCAT(c.first_name, ' ', c.last_name) AS Customer_Name,
       c.email
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
ORDER BY c.customer_id;

-- 7) Top 3 Rock Artists by Number of Songs
SELECT a.artist_id, a.name AS artist_name, g.name AS genre_name,
       COUNT(*) AS No_Of_Songs
FROM artist a
JOIN album am ON a.artist_id = am.artist_id
JOIN track t ON am.album_id = t.album_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
GROUP BY a.artist_id, a.name, g.name
ORDER BY No_Of_Songs DESC
LIMIT 3;

-- 8) Favorite Genre in Each Country
WITH genre_count AS (
    SELECT c.country, g.name AS genre_name, COUNT(il.quantity) AS purchase,
           DENSE_RANK() OVER (PARTITION BY c.country ORDER BY COUNT(il.quantity) DESC) AS Rnk
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    JOIN track t ON il.track_id = t.track_id
    JOIN genre g ON t.genre_id = g.genre_id
    GROUP BY c.country, g.name
)
SELECT country, genre_name, purchase
FROM genre_count
WHERE Rnk = 1
ORDER BY purchase DESC;

-- 9) Highest Spending Customer in Each Country
WITH cte AS (
    SELECT c.customer_id,
           CONCAT(c.first_name, ' ', c.last_name) AS Customer_Name,
           c.email, c.phone, c.country,
           SUM(i.total) AS Total_Spending,
           DENSE_RANK() OVER (PARTITION BY country ORDER BY SUM(i.total) DESC) AS Rnk
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name, c.email, c.phone, c.country
)
SELECT *
FROM cte
WHERE Rnk = 1;
