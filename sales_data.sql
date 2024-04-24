-- CREATE A TABLE
CREATE TABLE salesdate (
    order_id INTEGER,	
	order_status VARCHAR(50),	
	customer VARCHAR (50),	
	order_date DATE,	
	order_quantity INTEGER,
	sales INTEGER,	
	discount FLOAT,
	discount_value INTEGER,	
	product_category VARCHAR(100),	
	product_sub_category VARCHAR(100)
   
);

--IMPORT DATA TO SQL
COPY salesdata FROM 'C:\Users\lenovo\Desktop\data.csv' WITH CSV HEADER;


--DATA CHECK
SELECT *
FROM salesdata;


--OVERALL YEAR PERFORMANCE PER YEAR (TOTAL SALES AND TOTAL QUANTITY)
SELECT EXTRACT(YEAR FROM order_date) AS "Year", SUM(order_quantity) AS "Total Quantity", SUM(sales) AS "Total Sales"
FROM salesdata
WHERE order_status = 'Order Finished'
GROUP BY "Year"
ORDER BY "Year";


--OVERALL YEAR PERFORMANCE PER SUB CATEGORY FOR 2011 AND 2012
SELECT EXTRACT(YEAR FROM order_date) AS "Year", product_sub_category, SUM(sales) AS "Total Sales"
FROM salesdata
WHERE order_status = 'Order Finished' 
   AND EXTRACT(YEAR FROM order_date) IN (2011,2012)
GROUP BY "Year", product_sub_category
ORDER BY "Year", "Total Sales" DESC;


--OVERALL YEAR PERFORMANCE PER SUB CATEGORY FOR 2011 AND 2012
SELECT product_sub_category,
      SUM(CASE WHEN EXTRACT(YEAR FROM order_date)= 2011 THEN sales ELSE 0 END ) AS "Sales 2011",
	  SUM(CASE WHEN EXTRACT(YEAR FROM order_date)= 2012 THEN sales ELSE 0 END ) AS "Sales 2012"
FROM salesdata
WHERE order_status = 'Order Finished' 
GROUP BY product_sub_category


--OVERALL YEAR PERFORMANCE PER SUB CATEGORY FOR 2011 AND 2012 WITH GROWTH RATE (2012-2011/2012)
SELECT *, ROUND((("Sales 2012"-"Sales 2011")*100.0/"Sales 2012"),2) "Growth Rate"
FROM (SELECT product_sub_category,
      SUM(CASE WHEN EXTRACT(YEAR FROM order_date)= 2011 THEN sales ELSE 0 END ) AS "Sales 2011",
	  SUM(CASE WHEN EXTRACT(YEAR FROM order_date)= 2012 THEN sales ELSE 0 END ) AS "Sales 2012"
       FROM salesdata
       WHERE order_status = 'Order Finished' 
       GROUP BY product_sub_category) AS subquery
ORDER BY "Growth Rate" DESC;


-- BURN RATE PER YEAR (TOTAL DISCOUNT*100/TOTAL SALES)
SELECT EXTRACT(YEAR FROM order_date) AS "Year", SUM(sales) AS "Total sales", 
       SUM(discount_value) AS "Total discount",
	   ROUND((SUM(discount_value)*100.0/SUM(sales)),2) AS "Burn Rate"      
FROM salesdata
WHERE order_status = 'Order Finished'
GROUP BY "Year"
ORDER BY "Burn Rate" DESC;


-- BURN RATE 2012 SUB CATEGORY AND CATEGORY WISE (TOTAL DISCOUNT*100/TOTAL SALES)
SELECT EXTRACT(YEAR FROM order_date) AS "Year", product_category, product_sub_category,
       SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2012 THEN sales ELSE 0 END) AS "Total sales", 
       SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2012 THEN discount_value ELSE 0 END) AS "Total Discount"
FROM salesdata
WHERE order_status = 'Order Finished' 
      AND EXTRACT(YEAR FROM order_date) = 2012
GROUP BY "Year", product_category, product_sub_category


--FINAL QUERY FOR ABOVE
SELECT *, ROUND(("Total Discount"*100.0/"Total sales"),2) AS "Burn Rate"
FROM (
	SELECT EXTRACT(YEAR FROM order_date) AS "Year", product_category, product_sub_category,
       SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2012 THEN sales ELSE 0 END) AS "Total sales", 
       SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2012 THEN discount_value ELSE 0 END) AS "Total Discount"
    FROM salesdata
    WHERE order_status = 'Order Finished' 
      AND EXTRACT(YEAR FROM order_date) = 2012
    GROUP BY "Year", product_category, product_sub_category
	) AS subquery
ORDER BY "Total sales" DESC;


-- Customers Transactions per Year
SELECT EXTRACT(YEAR FROM order_date) AS "Year",
        COUNT(DISTINCT customer) AS "Number Of Customers"
 FROM salesdata
 WHERE order_status = 'Order Finished'
 GROUP BY "Year";
 
 -- New Customer Over the Years
 SELECT customer, MIN(order_date) AS "firstorder"
        FROM salesdata
        WHERE order_status = 'Order Finished'
        GROUP BY customer 

SELECT EXTRACT(YEAR FROM "firstorder") AS "Year", COUNT(customer)
FROM (
      SELECT customer, MIN(order_date) AS "firstorder"
        FROM salesdata
        WHERE order_status = 'Order Finished'
        GROUP BY customer
        ) AS subquery
GROUP BY "Year"
ORDER BY "Year";

