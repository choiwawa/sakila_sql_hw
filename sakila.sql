use sakila;

-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT  UPPER(concat(first_name, ' ',  last_name)) AS 'Actor Name' FROM actor;

-- 2a. find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
SELECT actor_id, first_name, last_name FROM actor
WHERE first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT actor_id, first_name, last_name FROM actor
WHERE last_name like "%GEN%";

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT actor_id, last_name, first_name FROM actor
WHERE last_name like "%LI%";

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM country
WHERE country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a. create a column in the table actor named description and use the data type BLOB 
ALTER TABLE actor ADD description BLOB(250);

-- 3b. Delete the description column.
ALTER TABLE actor DROP description;

-- 4a. List the last names of actors, as well as how many actors have that last name
SELECT last_name, COUNT(*) AS 'Number of Actors'
FROM actor GROUP BY last_name HAVING COUNT(*) >=0;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(*) AS 'Number of Actors'
FROM actor GROUP BY last_name HAVING COUNT(*) >=2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' and last_name = 'Williams';

-- 4d. In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor SET first_name = 'GROUCHO'
WHERE actor_id = 172;

-- 5a. You cannot locate the schema of the address table. Which query would you use address_idaddress_idstaffto re-create it?
SHOW CREATE TABLE  address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT staff.first_name, staff.last_name, address.address
FROM staff 
JOIN address
ON staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT staff.first_name, staff.last_name, payment.staff_id, payment.payment_date, payment.amount
FROM staff INNER JOIN payment 
ON staff.staff_id = payment.staff_id and payment_date like '2005-08%';

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT film.title, COUNT(film_actor.actor_id)
AS actor_count
FROM film JOIN film_actor
ON film.film_id = film_actor.film_id
GROUP BY film.film_id;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT COUNT(*) FROM inventory
WHERE film_id IN(
	SELECT film_id FROM film
    WHERE title = 'Hunchback Impossible');

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT customer.first_name, customer.last_name, SUM(payment.amount)
AS total_amount_paid
FROM customer JOIN payment
ON customer.customer_id = payment.payment_id
GROUP BY customer.customer_id
ORDER BY customer.last_name ASC;

-- 7a. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title FROM film WHERE language_id IN (
	SELECT language_id FROM Language
	WHERE name = 'English')
AND (title LIKE 'K%') OR (title LIKE 'Q%');

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name FROM actor WHERE actor_id IN (
	SELECT actor_id FROM film_actor WHERE film_id IN (
		SELECT film_id FROM film
        WHERE title = 'Alone Trip'));
        
-- 7c. Use joins to retrieve names and email addresses of all Canadian customers.
SELECT customer.first_name, customer.last_name, customer.email
FROM customer JOIN address ON customer.address_id = address.address_id
JOIN city ON city.city_id = address.city_id
JOIN country ON country.country_id = city.country_id
WHERE country = 'Canada';

-- 7d. Identify all movies categorized as family films.
SELECT title FROM film WHERE film_id IN (
    SELECT film_id FROM film_category WHERE category_id = (
        SELECT category_id FROM category WHERE name = "Family"));

-- 7e. Display the most frequently rented movies in descending order.
SELECT film.title, COUNT(rental.inventory_id) AS rental_frequency
FROM film JOIN inventory
ON film.film_id = inventory.film_id
JOIN rental ON rental.inventory_id = inventory.inventory_id
GROUP BY film.title
ORDER BY rental_frequency DESC;

-- 7f. display how much business, in dollars, each store brought in.
SELECT store.store_id, SUM(amount) AS gross
FROM payment JOIN rental ON payment.rental_id = rental.rental_id
JOIN inventory ON inventory.inventory_id = rental.inventory_id
JOIN store ON store.store_id = inventory.store_id
GROUP BY store.store_id;

-- 7g. display for each store its store ID, city, and country.
SELECT store.store_ID, city.city, country.country
FROM store JOIN address ON store.store_id = address.address_id
JOIN city ON city.city_id = address.city_id
JOIN country ON country.country_id = city.country_id;

-- 7h. List the top five genres in gross revenue in descending order. 
SELECT category.name, SUM(payment.amount) AS gross_revenue
FROM category JOIN film_category ON category.category_id = film_category.category_id
JOIN inventory ON inventory.film_id = film_category.film_id
JOIN rental ON rental.inventory_id = inventory.inventory_id
JOIN payment ON payment.rental_id = rental.rental_id
GROUP BY category.name
ORDER BY gross_revenue DESC
LIMIT 5;

-- 8a. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top5_genre_gross_revenue AS
SELECT category.name, SUM(payment.amount) AS gross_revenue
FROM category JOIN film_category ON category.category_id = film_category.category_id
JOIN inventory ON inventory.film_id = film_category.film_id
JOIN rental ON rental.inventory_id = inventory.inventory_id
JOIN payment ON payment.rental_id = rental.rental_id
GROUP BY category.name
ORDER BY gross_revenue DESC
LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top5_genre_gross_revenue;

-- 8c. Write a query to delete the view top_five_genres
DROP VIEW IF EXISTS top5_genre_gross_revenue;