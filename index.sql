/* Question 1: We want to understand more about the movies that families are watching. 
The following categories are considered family movies: Animation, Children, Classics, Comedy, Family and Music.
Create a query that lists each movie, the film category it is classified in, and the number of times it has been rented out.
 */

SELECT	f.title AS film_title,
	c.name AS category_name,
	OUNT(r.rental_id) AS rental_count
  FROM  category AS c
  JOIN  film_category AS fc 
    ON  c.category_id = fc.category_id
  JOIN  film AS f 
    ON  f.film_id = fc.film_id
  JOIN  inventory AS i 
    ON  i.film_id = f.film_id
  JOIN  rental AS r 
    ON  r.inventory_id = i.inventory_id
 WHERE  c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
 GROUP  BY  1, 2
 ORDER  BY  2, 1;

/* Question 2: We want to find out how the two stores compare in their count of rental orders during 
every month for all the years we have data for. 
Write a query that returns the store ID for the store, 
the year and month and the number of rental orders each store has fulfilled for that month.
Your table should include a column for each of the following:
year, month, store ID and count of rental orders fulfilled during that month. */

SELECT  DATE_PART('month', r.rental_date) AS rental_month, 
        DATE_PART('year', r.rental_date) AS rental_year,
        ste.store_id,
        COUNT(*)
  FROM 	store AS ste
  JOIN  staff AS stf
    ON  ste.store_id = stf.store_id
  JOIN  rental AS r ON stf.staff_id = r.staff_id
 GROUP  BY  1, 2, 3
 ORDER  BY  4 DESC;

/* Question 3: 
We would like to know who were our top 10 paying customers, how many payments they made on a monthly basis
during 2007, and what was the amount of the monthly payments. 
Can you write a query to capture the customer name, month and year of payment, 
and total payment amount for each month by these top 10 paying customers?*/

WITH t1 AS (SELECT  CONCAT(c.first_name, ' ', c.last_name) AS full_name, 
		    SUM(p.amount) AS pay_amount
	      FROM  customer c
	      JOIN  payment p 
                ON  p.customer_id = c.customer_id
	     GROUP  BY  1	
	     ORDER  BY  2 DESC
             LIMIT  10)
SELECT  DATE_TRUNC('month', p.payment_date) AS pay_mon,
	CONCAT(c.first_name, ' ', c.last_name) AS full_name,
	COUNT(p.amount) AS pay_countpermon,
	SUM(p.amount) AS pay_amount
  FROM  payment AS p
  JOIN  customer AS c 
    ON  c.customer_id = p.customer_id
 WHERE  CONCAT(c.first_name, ' ', c.last_name) IN (SELECT  full_name 
						     FROM  t1 ) 
   AND  p.payment_date BETWEEN '2007-01-01' AND '2008-01-01'
 GROUP  BY  1, 2
 ORDER  BY  2, 1;

/* Question 4: Finally, for each of these top 10 paying customers, 
I would like to find out the difference across their monthly payments during 2007. 
Please go ahead and write a query to compare the payment amounts in each successive month. 
Repeat this for each of these 10 paying customers. 
Also, it will be tremendously helpful if you can identify the customer name who paid the most difference in terms of payments.
*/

WITH t1 AS ( SELECT  f.title, 
		     c.name, 
                     f.rental_duration, 
 		     NTILE(4) OVER (ORDER BY f.rental_duration) AS standard_quartile
	       FROM  film AS f
               JOIN  film_category as fc  
                 ON  f.film_id = fc.film_id
	       JOIN  category AS c  
                 ON  fc.category_id = c.category_id
	      WHERE  c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
		   )
SELECT	name,
	standard_quartile,
	COUNT(standard_quartile)
  FROM  t1
 GROUP  BY  1, 2
 ORDER  BY  1, 2;