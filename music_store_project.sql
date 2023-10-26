-- Question: Who is the Senior Most employee based on job title?

SELECT first_name||' '||last_name AS most_senior_employee FROM employee
ORDER BY levels DESC
LIMIT 1

-- Answer: Mohan Madan


-- Question: Which Country has the most invoices?

SELECT billing_country, COUNT(*) AS invoice_count FROM invoice
GROUP BY billing_country
ORDER BY invoice_count DESC
LIMIT 1

-- Answer: USA


-- Question: What are top 3 values of total invoice?

SELECT ROUND(total) FROM invoice
ORDER BY total DESC
LIMIT 3

-- Answer: 23.76, 19.8, 19.8


/* Question: Which city has the best customers? We would like to throw a promotional Music Festival in the city
we made the most money. Write the query that returns one city that has highest sum of invoice total. Return both 
the city name and sum of all invoice totals.*/

SELECT billing_city, SUM(total) AS invoice_total FROM invoice
GROUP BY billing_city
ORDER BY invoice_total DESC
LIMIT 1

-- Answer: Prague -> 30

/* Question: Who is the best customer? The customer who has spent the most money will be declared the best customer. Write
a query that returns the person who has spent the money.*/

SELECT first_name||' '||last_name AS customer_name, ROUND(SUM(total)) FROM customer AS c
INNER JOIN invoice AS i ON 
c.customer_id = i.customer_id
GROUP BY first_name, last_name
ORDER BY SUM(total) DESC
LIMIT 1

-- Answer: R Madhav


/*Question: Write query to return the email, first_name, last_name, and Genre of all rock music listeners. Return
your list ordered alphabetically by email starting with A:*/

SELECT email, first_name, last_name, g.name AS genre FROM customer AS c
INNER JOIN invoice AS i ON
c.customer_id = i.customer_id
INNER JOIN invoice_line AS il ON
i.invoice_id = il.invoice_id
INNER JOIN track AS t ON
il.track_id = t.track_id
INNER JOIN genre AS g ON
t.genre_id = g.genre_id
WHERE g.name = 'Rock'
GROUP BY email, first_name, last_name, g.name
ORDER BY email



/* Question: Let's invite the artists who have written the most rock music on our dataset. Write a query which 
returns the artist name and total track count of the top 10 rock bands.*/

SELECT a.name AS artist_name, COUNT(*) AS track_count FROM artist AS a
INNER JOIN Album AS al ON a.artist_id = al.artist_id
INNER JOIN track AS t ON al.album_id = t.album_id 
INNER JOIN genre AS g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
GROUP BY a.name
ORDER BY COUNT(*) DESC
LIMIT 10



/* Question: Return all the track names that have a song length longer than the average song length. Return
the name and milliseconds for each track. Order by the song length with the longest song length first.*/

SELECT name, milliseconds FROM track
WHERE milliseconds > (SELECT AVG(milliseconds) FROM track)
ORDER BY milliseconds DESC



/* Question: Find out how much amount spent by each customer on artists? Write a query to return customer name,
artist name and total spent*/

SELECT first_name||' '||last_name AS customer_name, a.name AS artist_name, SUM(il.unit_price*il.quantity) AS total_spend 
FROM customer AS c
INNER JOIN invoice AS i ON c.customer_id = i.customer_id
INNER JOIN invoice_line AS il ON il.invoice_id = i.invoice_id 
INNER JOIN track AS t ON t.track_id = il.track_id
INNER JOIN album AS al ON al.album_id = t.album_id
INNER JOIN artist AS a ON a.artist_id = al.artist_id
GROUP BY first_name, last_name, artist_name
ORDER BY customer_name,artist_name,total_spend DESC



/* Question: We want to find out the most popular music genre for each country. We determine the most popular
genre as the genre with the highest amount of purchases. Write a query that returns each country along with the
top genre. For countries where the maximum number of purchases is shared return all genres.*/

WITH view1 AS 
(SELECT c.country AS country_name, g.name AS genre_name, COUNT(*) AS purchases, 
ROW_NUMBER() OVER (PARTITION BY c.country ORDER BY COUNT(*) DESC) AS row_n
FROM customer AS c
INNER JOIN invoice AS i ON c.customer_id = i.customer_id
INNER JOIN invoice_line AS il ON i.invoice_id = il.invoice_id
INNER JOIN track AS t ON il.track_id = t.track_id
INNER JOIN genre AS g ON t.genre_id = g.genre_id
GROUP BY c.country, g.name)

SELECT * FROM view1
WHERE row_n<2



/* Question: Write a query that determines the customer that has spent the most on music for each country. Write
 a query that returns the country along with the top customer and how much they spent. For countries where the 
 top amount spent is shared, provide all customers who spent this amount.*/
 
 WITH view2 AS (SELECT c.country AS country_name, c.first_name||' '||c.last_name AS customer_name,SUM(i.total) AS total_spend,
 ROW_NUMBER() OVER (PARTITION BY c.country ORDER BY SUM(total)) AS row_n 
 FROM customer AS c
 INNER JOIN invoice AS i ON c.customer_id = i.customer_id
 GROUP BY c.country, c.first_name, c.last_name)
 
 SELECT * FROM view2
 WHERE row_n<2