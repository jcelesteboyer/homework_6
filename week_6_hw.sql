1. Show all customers whose last names start with T. Order them by first name from A-Z.

SELECT * 
FROM customer
WHERE last_name LIKE 'T%'
ORDER BY first_name;
-- First, I selected all the columns from the customer table where the data in the last name column
-- matched 'T'. The % is the wildcard character used with the LIKE operator which just subs in the other characters. 
-- Finally I order by the first name column, which automatically put it in ascending order. 
-- The data output is a table where only the rows with a last name that starts with a 'T' are remaining. 
-- And those rows are in alphabetical order. 

2.Show all rentals returned from 5/28/2005 to 6/1/2005

SELECT * 
FROM rental
WHERE return_date BETWEEN '2005-05-28' AND '2005-06-01';
-- I selected all the columns from the rental table. 
-- Then I specified only rows of data where the column 'return_date' were inbetween those two dates. 
-- I made sure to follow the agreed upon datetime order of yyyy-mm-dd. 
-- The output displayed the table but with only rows where movies were returned inbetween those dates. 

3. How would you determine which movies are rented the most?

SELECT i.inventory_id, i.film_id, title, COUNT(r.rental_id) AS total_amount_rented
FROM rental AS r
INNER JOIN inventory AS i
ON r.inventory_id = i.inventory_id
INNER JOIN film AS f
ON i.film_id = f.film_id
GROUP BY i.inventory_id, title
ORDER BY total_amount_rented DESC;
-- For this problem, three tables needed to be joined together. 
-- First, I joined the rental and inventory tables by inventory_id. 
-- Second, I joined the inventory and film tables by film_id. 
-- I selected only the columns of importance and also counted the rental_id and renamed the column 'total_amount_rented.
-- The new table is grouped by the inventory_id and title
-- and the column total_amount_rented is used to order everything by most times to least. 


4. Show how much each customer spent on movies (for all time) . Order them from least to most.

SELECT customer.customer_id, SUM(amount) AS total_amount, first_name, last_name
FROM payment
INNER JOIN customer
ON payment.customer_id = customer.customer_id
GROUP BY customer.customer_id
ORDER BY total_amount;
-- From the payment and customer tables, I selected the customer_id column, first/last names, and sum of the amount column. 
-- I renamed the sum of the amount column to total_amount. 
-- I joined the two tables together using the common customer_id column. 
-- I grouped the data by the customer_id so that I could see all the customers transactions in one row 
-- as the total of money they have spent with this movie rental place. 
-- Finally I ordered it by the total_amount column so that the least amount was on top. 
-- The final output was four rows: 1 with ID, the total amount, first and last name. 

5. Which actor was in the most movies in 2006 (based on this dataset)? 
   Be sure to alias the actor name and count as a more descriptive name. 
   Order the results from most to least.

SELECT CONCAT(first_name,last_name) AS actor_name, COUNT(a.actor_id) AS num_of_films
FROM actor AS a
INNER JOIN film_actor as fa
ON a.actor_id = fa.actor_id
INNER JOIN film as f
ON fa.film_id = f.film_id
WHERE release_year = 2006
GROUP BY actor_name, a.actor_id
ORDER BY num_of_films DESC;
-- The two columns I have selected are a combination of first/last name (renamed actor_name) 
-- and the actor_id column. This column I had counted and renamed as num_of_films. 
-- I needed to join three tables in order to get all the information needed:  actor, film_actor, and film. 
-- I eliminated any rows where the release_year was not equal to 2006. 
-- Finally, I grouped by the actors and ordered the num_of_films in descending order so that we could see the highest count on top. 
-- The output gives us the two rows selected saying that Gina Degeneres has the most at 42. 

6. Write an explain plan for 4 and 5. Show the queries and explain what is happening in each one. 
   Use the following link to understand how this works http://postgresguide.com/performance/explain.html 

-- This is the explain plan for #4:
EXPLAIN ANALYZE
SELECT customer.customer_id, SUM(amount) AS total_amount, first_name, last_name
FROM payment
INNER JOIN customer
ON payment.customer_id = customer.customer_id
GROUP BY customer.customer_id
ORDER BY total_amount;
-- Explain/Analyze excuted the code and the output was a query plan. 
-- Each step was documented . For instance, the first step was a 'sort key' where it summed up the payment. 
-- Then it did a group key by the customer.customer_id. 
-- Finally it did a hash cond where it joined the two tables via the customer_id column. 
-- There is also information inbetween the steps about seq scanning and how much time that took. 
-- The final two lines say the planning time and the excution time. 

-- This is the explain plan for #5: 
EXPLAIN ANALYZE
SELECT CONCAT(first_name,last_name) AS actor_name, COUNT(a.actor_id) AS num_of_films
FROM actor AS a
INNER JOIN film_actor as fa
ON a.actor_id = fa.actor_id
INNER JOIN film as f
ON fa.film_id = f.film_id
WHERE release_year = 2006
GROUP BY actor_name, a.actor_id
ORDER BY num_of_films DESC;
-- The first action in the query plan was the sort key to count and sort the a.actor_id in descending order. 
-- Next it did a group kep where is concat the first and last name. 
-- Then the hash kkey which joined the two tables together via actor_id and then again by film_id. 
-- Finally it filtered by the release_year. 
-- The last two lines were the planning time and the execution time. 


7. What is the average rental rate per genre?

SELECT AVG(rental_rate), name AS genre
FROM film as f
INNER JOIN film_category  as fc
ON f.film_id = fc.film_id
INNER JOIN category as c
ON fc.category_id = c.category_id
GROUP BY genre;
-- The two cloumns needed are the genre and rental rate. To rental rate I used the AVG function. 
-- I joined three tables together in order to get all the info needed: film, film_category and category. 
-- The output was two columns: the avg rental rate and the genre. Looks like the games genre is the highest rate. 

8. How many films were returned late? Early? On time?

SELECT COUNT(CASE WHEN rental_duration > date_part('day',return_date - rental_date) THEN 'Returned Early' END) AS Return_early,
COUNT(CASE WHEN rental_duration < date_part('day', return_date - rental_date) THEN 'Returned Late' END) AS Return_late, 
COUNT(CASE WHEN rental_duration = date_part('day', return_date - rental_date) THEN 'Returned on Time' END) AS Return_on_time
FROM film
INNER JOIN inventory
ON film.film_id = inventory.film_id
INNER JOIN rental
ON inventory.inventory_id = rental.inventory_id;
-- First I had to use a CASE statement to say that when a certain condition is met then the result would be counted.
-- Inside the case satement, the day part of the dates needed to be extracted and subtracted from one another. 
-- A new alias is given to those three columns created. 
-- Then the three tables needed to be joined together via film_id and inventory_id. 


9. What categories are the most rented and what are their total sales?

SELECT c.name, SUM(f.rental_rate) AS total_sales, COUNT(r.rental_id) as times_rented
FROM rental AS r
INNER JOIN inventory AS i
ON r.inventory_id = i.inventory_id
INNER JOIN film AS f
ON i.film_id = f.film_id
INNER JOIN film_category as fc
ON f.film_id = fc.film_id
INNER JOIN category AS c
ON fc.category_id = c.category_id
GROUP BY c.name
ORDER BY times_rented;
-- A total of 5 different tables needed to be joined together in order to get the three peices of info needed.
-- The category name is needed to know the genre, the summation of the rental rates, and how many times they were rented. 
-- The group by was used to organize by the genre. 
-- Everything was ordered by the most rented movie. 
-- THe output was three rows and it said that sports was the most rented with total sales of 3617.21


10. Create a view for 8 and a view for 9. Be sure to name them appropriately. 

CREATE VIEW time_of_returns AS
SELECT COUNT(CASE WHEN rental_duration > date_part('day',return_date - rental_date) THEN 'Returned Early' END) AS Return_early,
COUNT(CASE WHEN rental_duration < date_part('day', return_date - rental_date) THEN 'Returned Late' END) AS Return_late, 
COUNT(CASE WHEN rental_duration = date_part('day', return_date - rental_date) THEN 'Returned on Time' END) AS Return_on_time
FROM film
INNER JOIN inventory
ON film.film_id = inventory.film_id
INNER JOIN rental
ON inventory.inventory_id = rental.inventory_id;

CREATE VIEW most_rented_genres AS
SELECT c.name, SUM(f.rental_rate) AS total_sales, COUNT(r.rental_id) as times_rented
FROM rental AS r
INNER JOIN inventory AS i
ON r.inventory_id = i.inventory_id
INNER JOIN film AS f
ON i.film_id = f.film_id
INNER JOIN film_category as fc
ON f.film_id = fc.film_id
INNER JOIN category AS c
ON fc.category_id = c.category_id
GROUP BY c.name
ORDER BY times_rented;