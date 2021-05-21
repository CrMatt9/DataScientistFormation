SELECT *
FROM customers
WHERE address LIKE '%trail%' OR 
	address LIKE '%avenue%';
    
SELECT *
FROM customers
WHERE phone LIKE '%9';

SELECT address
FROM customers;

SELECT *
FROM customers
WHERE last_name REGEXP 'field$|^mac|rose' ;
-- $ implica ultimo tiene q ser eso ^ implica que el primero ha de ser esto

SELECT *
FROM customers
WHERE last_name REGEXP '[gim]e' ;
-- cualquiera de los caracteres dentro de esta 'lista'  puede estar delante de la e es decir encontrara
--  ge ie y me finalmente si queremos un avanico de valores, usaremos [a-d] en este abaico hay a b c y d

 SELECT *
 FROM customers
 WHERE phone IS NULL;

-- get orders that are not shipped
SELECT *
FROM orders
WHERE shipped_date IS NULL AND shipper_id IS NULL;

-- how to sort data
SELECT first_name, last_name, 10 AS points
FROM customers
ORDER BY points, birth_date DESC;

-- Podemos ordenar por columnas que no estan entre las seleccionadas, e incluso usando los alias que hemos creados
SELECT first_name, last_name, 10 AS points
FROM customers
ORDER BY 1, 2;
-- Si usamos esto usamos first y despues last name pero n es muy recomendable ya que si añadimos algo podemos cambiar el
-- orden sin querer, ademas no queda tan claro para la lectura

SELECT *
FROM order_items
WHERE order_id = 2
ORDER BY quantity * unit_price DESC;

SELECT *
FROM customers
LIMIT 6, 3;
-- 6 es un offset, nos dice q saltamos los 6 primeros y seleccionamos los siguientes 3

SELECT *
FROM customers
ORDER BY points DESC
LIMIT 3;
--  Coge los 3 customers que tienen mas puntos

SELECT order_id, orders.customer_id, first_name, last_name -- tengo q especificar de donde coger customer_id pq esta repetida esta coluna en ambas tables
FROM orders
JOIN customers
 ON orders.customer_id = customers.customer_id;
-- como coger info de dos tables asegurandonos que el customer id es la misma

SELECT order_id, o.customer_id, first_name, last_name
FROM orders o
JOIN customers c
	-- ON o.customer_id = c.customer_id;
 -- Utilizando estos alias podemos hacer mas sencilla la sintaxis
 
 SELECT o.order_id, product_id, quantity, oi.unit_price
 FROM order_items oi
 JOIN orders o
	ON oi.order_id = o.order_id;
-- Exercice
    
SELECT o.order_id,
	c.first_name,
    sh.name AS shipper
FROM orders o
JOIN customers c
	-- ON o.customer_id = c.customer_id; es lo mismo que usamos abajo
    USING (customer_id)
LEFT JOIN shippers sh -- LEFT para que aparezcan todas, sino as que tienen shipper null no aparecerian
	USING (shipper_id);
    
SELECT *
FROM order_items oi
JOIN order_item_notes oin
	USING (order_id, product_id);
    
SELECT 
	date,
    c.name AS client,
    amount,
    pm.name AS name
FROM payments p
JOIN clients c
	USING (client_id)
JOIN payment_methods pm
	ON p.payment_method = pm.payment_method_id;
-- Ejercicio con sql_invoicing

SELECT
	o.order_id,
    c.first_name
FROM orders. o
NATURAL JOIN customers c;
-- Lo que hace el natural JOIN es los junta por las columnas con el mismo nombre, muy facil y limpio pero peligroso.cross

SELECT 
	c.first_name AS customer,
    p.name AS product
FROM customers c
CROSS JOIN products p
ORDER BY c.first_name;

-- combina cada uno de los elementos con todos los otros ( los repite)
-- En este caso no tiene sentido pero tendria si tenemos por ejemplo 3 colores y diferentes tallas de camiseta
-- Se puede escoger una camiseta de diferente color y talla por lo q todas las combinaciones existen como producto

SELECT 
	c.first_name AS customer,
    p.name AS product
FROM customers c, products p
ORDER BY c.first_name;
 -- En este caso obtenemos lo mismo que arriba pero con sintaxis implicita ( no ta recomendable)
 
 SELECT 
	sh.name AS shipper,
    p.name AS product
 FROM shippers sh
 CROSS JOIN products p
 ORDER BY sh.name;
 
 SELECT 
	o.order_id,
    o.order_date,
    'Active' AS status
 FROM orders o
 WHERE order_date >= '2019-01-01'
 UNION -- Combine records from multiple querries
  SELECT 
	o.order_id,
    o.order_date,
    'Archived' AS status
 FROM orders o
 WHERE order_date < '2019-01-01';
 
 SELECT first_name AS CustomersANDShippers
 FROM customers
 UNION
 SELECT name
 FROM shippers;
 -- Podemos juntar estos records pq tienen las mismas columnas, si tuvieran diferentes daria un error
 
 INSERT INTO customers
 VALUES (
	DEFAULT,
    'John',
    'Smith',
    '1990-01-01',
    NULL, -- we could also use default here
    'C/Topota Mother 2',
    'Barcelona',
    'CA',
    DEFAULT
    );
    
-- Pero en este caso tenemos que poner muchos valores que ya se ponen solos y asignarles DEFAULT o null
-- Para evitar esto hacemos lo siguiente:
INSERT INTO customers (
	last_name,
    first_name, 
    birth_date,
    address,
    city,
    state
    )
VALUES (
	'Reyes',
    'Julia',
    '1999-06-29',
    'C/DeLasDiosas, 1',
    'Blanes',
    'GI'
    );

INSERT INTO shippers (name)
VALUES('Shipper1'),
	('Shipper2'),
    ('Shipper3');

-- Insertar varias filas de una sola estacada

INSERT INTO products (
	name,
    quantity_in_stock,
    unit_price
    )
    
VALUES (
	'Water',
    6,
    1.79
    ),
    (
    'chcocolate',
    123,
    0.99
    ),
    (
    'Milk',
    27,
    4.87
    );
-- Ejercicio añadir varios productos

-- How to insert data into multiple tables??
-- Shown here:
 INSERT INTO orders (customer_id, order_date, status)
 VALUES (1, '2021-02-01', 1);
 
 INSERT INTO order_items
 VALUES ( LAST_INSERT_ID(), 1, 1, 2.95),
	( LAST_INSERT_ID(), 2, 1, 5.95);
    
    
-- How to copy data from one table to another
CREATE TABLE orders_archived AS
SELECT * FROM orders; -- we call it a soft query

-- Doing that we copy all the data from orders to orders_archived.
-- Eventhought the pk and the ai options dosent copy, so we must set them up.

INSERT INTO orders_archived
SELECT *
FROM orders
WHERE order_date < '2019-01-01';

-- solo añadimos los datos que cumplen una condicion especifica (o varias)

CREATE TABLE invoices_archived AS
SELECT 
	i.invoice_id,
	i.number,
    c.name AS client,
    i.invoice_total,
    i.payment_total,
    i.invoice_date,
    i.payment_date,
    i.due_date
FROM invoices i
JOIN clients c
	USING (client_id)
WHERE payment_date IS NOT NULL;

-- Creamos una nueva tabla con los datos deseados de las tablas de invoices y clients con la condicion que el payment date no sea null
   
UPDATE invoices
SET payment_total = 10, payment_date = '2019-03-01'
WHERE invoice_id = 1;

-- To change data from a table and row which already exists

UPDATE invoices
SET payment_total = DEFAULT, payment_date = DEFAULT
WHERE invoice_id = 1;

-- We revert the changes

UPDATE invoices
SET 
	payment_total = invoice_total * 0.5,
	payment_date = due_date
WHERE invoice_id = 3;

-- We can also use expressions as those to change the data

-- NOW lets do it with multiple rows

UPDATE invoices
SET 
	payment_total = invoice_total * 0.5,
	payment_date = due_date
WHERE client_id IN (3, 4);

-- Cambia todos los del cliente 3 y 4

-- EXERCISE:

UPDATE customers
SET
	points = points + 50
WHERE birth_date < "1990-01-01";

-- adds 50 points to customers who has born before 1990

UPDATE invoices
SET 
	payment_total = invoice_total * 0.5,
	payment_date = due_date
WHERE client_id = 
	(SELECT client_id
	FROM clients
	WHERE name = 'Myworks')
    
-- So imagine we dont have the client id, we have just his name

UPDATE invoices
SET 
	payment_total = invoice_total * 0.5,
	payment_date = due_date
WHERE client_id IN 
	(SELECT client_id
	FROM clients
	WHERE state IN ('CA', 'NY'));
    
-- In case we have multiple selections fe state in CA and NY
-- We must use client_id IN not the equal
-- For a good practise firt execute the subquery then add it on the UPDATE

-- EXERCISE:

UPDATE orders
SET 
	comments = 'Gold Customer'
WHERE customer_id IN
	(SELECT customer_id
	FROM customers
	WHERE points > 3000);
    
    
DELETE FROM invoices
WHERE client_id = (
	SELECT *
	FROM clients
	WHERE name = 'Myworks'
);

-- Delete data

-- MODULO 5: Summarizing data

-- Funciones que se pueden utilizar:
-- MAX()
-- MIN()
-- AVG()
-- SUM()
-- COUNT()


SELECT 
	MAX(invoice_total) AS highest, 
	MIN(invoice_total) AS lowest,
    AVG(invoice_total) AS average,
    SUM(invoice_total) AS total,
    COUNT(invoice_total) AS number_of_invoices,
    COUNT(payment_date) AS count_of_payments,
    COUNT(*) AS total_records,
    COUNT(DISTINCT client_id) AS total_clients
FROM invoices
WHERE invoice_date > '2019-07-01';


-- EXERCICE:

SELECT
	'First half of 2019' AS date_range,
	SUM(invoice_total) AS total_sales,
    SUM(payment_total) AS total_payments,
    SUM(invoice_total - payment_total) AS what_we_expect
FROM invoices
WHERE invoice_date >= '2019-01-01' AND invoice_date < '2019-07-01'
UNION
SELECT
	'Second half of 2019' AS date_range,
	SUM(invoice_total) AS total_sales,
    SUM(payment_total) AS total_payments,
	SUM(invoice_total - payment_total) AS what_we_expect
FROM invoices
WHERE invoice_date >= '2019-07-01' AND invoice_date < '2020-01-01'
UNION
SELECT
	'Total' AS date_range,
	SUM(invoice_total) AS total_sales,
    SUM(payment_total) AS total_payments,
	SUM(invoice_total - payment_total) AS what_we_expect
FROM invoices
WHERE invoice_date BETWEEN '2019-01-01' AND '2019-12-31';


SELECT
	client_id,
	SUM(invoice_total) AS total_sales
FROM invoices
WHERE invoice_date >= '2019-07-01'
GROUP BY client_id
ORDER BY total_sales DESC;

-- Suma solo las ordenes de cada cliente
    
SELECT
	state,
    city,
	SUM(invoice_total) AS total_sales
FROM invoices i
JOIN clients USING (client_id)
GROUP BY state, city;

-- In this case we get the info where we have more sellings

-- Exercise:

SELECT
	p.date,
    pm.name,
	SUM(i.payment_total) AS total_payments
FROM invoices i
JOIN payments p USING (invoice_id)
JOIN payment_methods pm
	ON p.payment_method = pm.payment_method_id
GROUP BY p.date, p.payment_method
ORDER BY p.date;

-- HAVING clause

SELECT
	client_id,
    SUM(invoice_total) AS total_sales,
    COUNT(*) AS number_of_invoices
FROM invoices
GROUP BY client_id
HAVING total_sales > 500 AND number_of_invoices > 5;
    
    
-- We need the having statement beacause if we use the WHERE clause after the from we havent group the data yet
-- so it will give us an arror. To solve that it appears the HAVING clause.
-- Note that on the having clause the reference must be on the select clause.
    
    
-- Exercise:
    
SELECT
	c.name,
    SUM(i.invoice_total) AS total_spent
FROM invoices i
JOIN clients c USING (client_id)
WHERE c.city = 'Virginia'
GROUP BY client_id
HAVING total_spent > 100;


SELECT
	c.customer_id,
    c.first_name,
    c.last_name,
    SUM(oi.unit_price * oi.quantity) AS total_spent    
FROM customers c
JOIN orders o USING (customer_id)
JOIN order_items oi USING (order_id)
WHERE c.state = 'VA'
GROUP BY 	
	c.customer_id,
    c.first_name,
    c.last_name
HAVING total_spent > 100;

-- ROLLUP Operator:

SELECT
	state,
    city,
    SUM(invoice_total) AS total_sales
FROM invoices i
JOIN clients c USING (client_id)
GROUP BY 
	state,
    city
WITH ROLLUP;

-- Rollup te va haciendo las sumatorios de los subgrupos en el orden que estan puestos es decir en este caso
-- nos suma cada ciudad y dentro de cada ciudad el total de sales de cada estado es decir suma todas las ciudades
-- dentro de este. Por ultimo nos hace la suma de las ventas totales de todos los estdos


-- Exercise: 

SELECT 
	pm.name AS payment_method,
    SUM(p.amount) AS total
FROM payments p
JOIN payment_methods pm ON
	pm.payment_method_id = p.payment_method
GROUP BY pm.name
	WITH ROLLUP;



-- 6.COMPLEX QUERIS

-- Find products that are more expensive than Lettuce (id=3)
SELECT *
FROM products
WHERE unit_price > (
	SELECT unit_price
    FROM products
    WHERE product_id = 3
);

-- In sql_hr database:
-- Find employees whose earn more than average

SELECT *
FROM employees
WHERE salary > (
	SELECT 
		AVG(salary) AS average_salary
	FROM employees
);

-- Find the products that have never been ordered

USE sql_store;

SELECT *
FROM products
WHERE product_id NOT IN (
	SELECT DISTINCT product_id
	FROM order_items
);

-- Find clients without invoices
USE sql_invoicing;

SELECT *
FROM clients
WHERE client_id NOT IN (
	SELECT DISTINCT client_id
	FROM invoices
);


-- Find customers who have ordered lettuce (id = 3)
-- Select customer_id, first_name, last_name

USE sql_store;

-- With subquerries
SELECT customer_id, first_name, last_name
FROM customers
WHERE customer_id IN (
	SELECT DISTINCT customer_id
    FROM orders
	WHERE order_id IN (
		SELECT DISTINCT order_id
        FROM order_items
        WHERE product_id = 3
	)
);

-- With Joins

SELECT DISTINCT c.customer_id, c.first_name, c.last_name
FROM customers c
JOIN orders o USING (customer_id)
JOIN order_items oi USING (order_id)
WHERE oi.product_id = 3;










