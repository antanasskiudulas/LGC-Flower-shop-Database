CREATE SCHEMA lgcdb;
USE lgcdb;
/*Data Definition statements required to represent schema*/
/*Performs a check operation before creating each table*/
CREATE TABLE IF NOT EXISTS customer(
	first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	delivery_houseNo INT NOT NULL,
	delivery_street VARCHAR(255) NOT NULL,
	delivery_postCode VARCHAR(255) NOT NULL,
	billing_houseNo INT NOT NULL,
	billing_street VARCHAR(255) NOT NULL,
	billing_postCode VARCHAR(255) NOT NULL,
	email VARCHAR(255) NOT NULL UNIQUE,
	PRIMARY KEY(email)
);

/*Represents the table structure of strong entity; stock item*/
CREATE TABLE IF NOT EXISTS stock_item(
	latin_name VARCHAR(255) NOT NULL,
	popular_name VARCHAR(255) NOT NULL,
	aftercare VARCHAR(255),
	sunlight VARCHAR(255) NOT NULL,
	moisture DOUBLE NOT NULL,
	soil VARCHAR(50) NOT NULL,
	description VARCHAR(255),
	season VARCHAR(50),
	plant_category VARCHAR(255) NOT NULL,
	plant_height DOUBLE DEFAULT '0.00' NOT NULL,
	plant_spread DOUBLE DEFAULT '0.00' NOT NULL,
	flowering_period VARCHAR(50),
	flowering_color VARCHAR(50),
	foliage_color VARCHAR(50),
	PRIMARY KEY(popular_name)
);

/*Represents the table structure of weak entity; item*/
CREATE TABLE IF NOT EXISTS item(
	id INT NOT NULL AUTO_INCREMENT,
	popular_name VARCHAR(255) NOT NULL,
	item_price DECIMAL(10,2) DEFAULT '0.00' NOT NULL,
	discount DECIMAL(10,2) DEFAULT '0.00',
	PRIMARY KEY(id)
);
/*Changing the constraints of item table to forma relation with stock items*/
ALTER TABLE item ADD CONSTRAINT fk_item_popular_name FOREIGN KEY (popular_name) REFERENCES stock_item(popular_name) ON UPDATE CASCADE ON DELETE CASCADE;


CREATE TABLE IF NOT EXISTS item_list(
	order_date DATETIME NOT NULL,
	customer_email VARCHAR(255) NOT NULL,
	popular_name VARCHAR(255) NOT NULL,
	each_item_qty INT NOT NULL,
	PRIMARY KEY(order_date, customer_email)
);

/*Represents the table structure of weak entity; invoice*/
CREATE TABLE IF NOT EXISTS customer_order(
	date_dispatched DATETIME NOT NULL,
	date_payment_received DATETIME NOT NULL,
	date_invoice_sent DATETIME NOT NULL,
	order_status VARCHAR(10) DEFAULT 'RECEIVED' NOT NULL,
	order_date DATETIME NOT NULL UNIQUE,
	customer_email VARCHAR(255) NOT NULL UNIQUE,
	PRIMARY KEY(customer_email, order_date),
	CONSTRAINT fk_customer_order_email FOREIGN KEY (customer_email) REFERENCES customer (email) ON UPDATE CASCADE ON DELETE CASCADE
);
/*Applying new foreign key constraints based on the item
The cascade on update and delete ensures that dependants are also affected by these actions*/
ALTER TABLE item_list ADD CONSTRAINT fk_item_list_order_date FOREIGN KEY(order_date) REFERENCES customer_order(order_date) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE item_list ADD CONSTRAINT fk_item_list_customer_email FOREIGN KEY(customer_email) REFERENCES customer(email) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE item_list ADD CONSTRAINT fk_item_list_popular_name FOREIGN KEY(popular_name) REFERENCES stock_item(popular_name) ON UPDATE CASCADE ON DELETE CASCADE;

/*Represents the table structure of weak entity; invoice*/
CREATE TABLE IF NOT EXISTS invoice(
	customer_email VARCHAR(255) NOT NULL UNIQUE,
	order_date DATETIME NOT NULL,
	PRIMARY KEY(customer_email,order_date),
	CONSTRAINT fk_invoice_customer_email FOREIGN KEY (customer_email) REFERENCES customer (email) ON UPDATE CASCADE ON DELETE CASCADE
);

/*Represents the table structure of strong entity; supplier*/
CREATE TABLE IF NOT EXISTS supplier(
	company_name VARCHAR(255) NOT NULL UNIQUE,
	house_no INT NOT NULL,
	post_code VARCHAR(10) NOT NULL,
	street VARCHAR(255) NOT NULL,
	PRIMARY KEY(company_name)
);

/*Represents the table structure of weak entity; purchase order*/
CREATE TABLE IF NOT EXISTS purchase_order(
	supplier_name VARCHAR(255) NOT NULL UNIQUE,
	order_id INT NOT NULL,
	order_status VARCHAR(10) DEFAULT 'RECEIVED' NOT NULL,
	order_date DATETIME NOT NULL UNIQUE,
	date_order_received DATETIME NOT NULL,
	date_payment_sent DATETIME NOT NULL,
	PRIMARY KEY(supplier_name, order_date),
	CONSTRAINT fk_purchase_order_supplier_name FOREIGN KEY (supplier_name) REFERENCES supplier(company_name) ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT fk_purchase_order_order_id FOREIGN KEY (order_id) REFERENCES item(id) ON UPDATE CASCADE ON DELETE CASCADE
);
/*Represents the table structure of weak entity; feedback*/
CREATE TABLE IF NOT EXISTS feedback(
	staff_id INT NOT NULL UNIQUE,
	customer_email VARCHAR(255) NOT NULL UNIQUE,
	feedback VARCHAR (255),
	PRIMARY KEY(staff_id, customer_email)
);
/*Represents the table structure of strong entity; staff*/
CREATE TABLE IF NOT EXISTS staff(
	staff_id INT AUTO_INCREMENT NOT NULL UNIQUE,
	staff_first_name VARCHAR(255) NOT NULL,
	staff_last_name VARCHAR(255) NOT NULL,
	post_code VARCHAR(15) NOT NULL,
	street VARCHAR(50) NOT NULL,
	house_no INT NOT NULL,
	hours VARCHAR(20) NOT NULL,
	role VARCHAR(20) NOT NULL,
	pay_rate DECIMAL(10,2) DEFAULT '0.00' NOT NULL,
	PRIMARY KEY(staff_id)
);
/*since feedback is linked to staff, we'll updated the previous tables with new constraints*/
ALTER TABLE feedback ADD CONSTRAINT fk_feedback_staff_id FOREIGN KEY(staff_id) REFERENCES staff(staff_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE feedback ADD CONSTRAINT fk_feedback_customer_email FOREIGN KEY(customer_email) REFERENCES customer(email) ON UPDATE CASCADE ON DELETE CASCADE;


/*Data manipulation statements*/
/*Populating the customer table with records*/
INSERT INTO customer(first_name, last_name, delivery_houseNo, delivery_street, delivery_postCode, billing_houseNo, billing_street, billing_postCode, email)
VALUES('Antanas', 'Skiudulas', 189, 'Lynn Road', 'PE133DY', 31, 'Cherry Road', 'LN21SF', 'antanasas123@hotmail.co.uk'),
('Bill', 'Johnson', 41, 'Fake Avenue', 'SN144PO', 33, 'Fake Avenue', 'SN144PO', 'bill.johnson@gmail.com');

/*Populating stock item table with records*/
INSERT INTO stock_item(latin_name, popular_name, aftercare, sunlight, moisture, soil, description, season, plant_category, plant_height, plant_spread, flowering_period, flowering_color, foliage_color)
VALUES('Rosa', 'Rose', 'Example', 'Full-sun', 100.00, 'Clay soil', 'Red flower with green leaves', 'Summer', 'Rosa', 17.50, 10.00, '56-day', 'Red', 'Green'),
('Lotus', 'Nelumbo nucifera', 'Example', 'Full-sun', 100.00, 'Clay soil', 'Species of aquatic plant in the family Nelumbonaceae', 'Summer', 'Nelumbo', 13.50, 6.00, '56-day', 'Pink', 'Green');

/*Populating item table with records*/
INSERT INTO item(id, popular_name, item_price, discount)
VALUES(1, 'Rose', 0.53, 0.10),
(2, 'Nelumbo nucifera', 0.43, 0.10);

/*Populating the customer order table with records*/
INSERT INTO customer_order(date_dispatched, date_payment_received, date_invoice_sent, order_status, order_date, customer_email)
VALUES('2017-11-28 08:13:21', '2017-11-27 14:23:43', '2018-01-08 13:36:11', 'DISPATCHED', '2017-11-24 11:56:35', 'antanasas123@hotmail.co.uk'),
('2017-11-28 08:13:21', '2017-11-27 14:23:43', '2017-12-21 17:32:45', 'PENDING', '2017-11-24 11:56:23', 'bill.johnson@gmail.com');

/*Populating the item list table with records*/
INSERT INTO item_list(order_date, customer_email, popular_name, each_item_qty)
VALUES('2017-11-24 11:56:35', 'antanasas123@hotmail.co.uk', 'Rose', 3),
('2017-11-24 11:56:23', 'bill.johnson@gmail.com', 'Nelumbo nucifera', 2);

/*Populating the invoices table with records*/
INSERT INTO invoice(customer_email, order_date)
VALUES('antanasas123@hotmail.co.uk', '2018-01-08 13:36:11'),
('bill.johnson@gmail.com', '2017-12-21 17:32:45');

/*Populating supplier table with records*/
INSERT INTO supplier(company_name, house_no, post_code, street)
VALUES('Flowery INC', 200, 'BS332NS', 'Business Street'),
('Flora', 885, 'FR233TS', 'Flora Road');

/*Populating purchase order table with records*/
INSERT INTO purchase_order(supplier_name, order_id, order_status, order_date, date_order_received, date_payment_sent)
VALUES('Flowery INC', 1, 'PENDING', '2017-11-27 14:23:43', '2017-11-26 11:44:11', '2017-11-27 12:22:32'),
('Flora', 2, 'DISPATCHED', '2017-11-11 14:23:43', '2017-11-12 11:44:11', '2017-11-13 12:22:32');

/*Populating staff table with records*/
INSERT INTO staff(staff_id, staff_first_name, staff_last_name, post_code, street, house_no, hours, role, pay_rate)
VALUES(101, 'Joshua', 'Bigs', 'PE133HN', 'Prince of Wales', 20, '9:00AM-5:00PM', 'Warehouse Operator', 7.50),
(102, 'Trisha', 'Fey', 'LN323SS', 'Gateway', 131, '9:00AM-5:00PM', 'Warehouse Manager', 10.50),
(103, 'Tim', 'Bradley', 'PT133NP', 'Church road', 01, '9:00AM-5:00PM', 'Warehouse Operator', 7.50);

/*Populating feedback table with records*/
INSERT INTO feedback(staff_id, customer_email, feedback)
VALUES(101, 'antanasas123@hotmail.co.uk', 'Good service'),
(102, 'bill.johnson@gmail.com', 'A+');

/*Updating, deleting and reinserting*/
UPDATE staff
SET staff_first_name = 'Bob', staff_last_name = 'Bobbins'
WHERE staff_id = 101;

DELETE FROM staff
WHERE staff_id = 101;

/*Reinserting the old value*/
INSERT INTO staff(staff_id, staff_first_name, staff_last_name, post_code, street, house_no, hours, role, pay_rate)
VALUES(101, 'Bob', 'Bobbins', 'PE133HN', 'Prince of Wales', 20, '9:00AM-5:00PM', 'Warehouse Operator', 7.50);
/*Inner join between staff and feedback*/
SELECT staff.staff_id, staff.staff_first_name, staff.staff_last_name, staff.role
FROM staff
INNER JOIN feedback ON staff.staff_id = feedback.staff_id
ORDER BY staff.staff_id;

/*Inner left join between staff and feedback*/
SELECT staff.staff_id, staff.staff_first_name, staff.staff_last_name, staff.role
FROM staff
LEFT JOIN feedback ON staff.staff_id = feedback.staff_id
ORDER BY staff.staff_first_name;

/*Inner left join between staff and feedback*/
SELECT staff.staff_id, staff.staff_first_name, staff.staff_last_name, staff.role
FROM staff
RIGHT JOIN feedback ON staff.staff_id = feedback.staff_id
ORDER BY staff.staff_last_name;

/*Creating union between two tables*/
SELECT staff_id FROM staff
UNION
SELECT staff_id FROM feedback
ORDER BY staff_id;

/*Backing up the original tables*/
CREATE TABLE IF NOT EXISTS copy_of_customer LIKE customer;
INSERT copy_of_customer SELECT * FROM customer;

CREATE TABLE IF NOT EXISTS copy_of_stock_item LIKE stock_item;
INSERT copy_of_stock_item SELECT * FROM stock_item;

CREATE TABLE IF NOT EXISTS copy_of_item LIKE item;
INSERT copy_of_item SELECT * FROM item;

CREATE TABLE IF NOT EXISTS copy_of_item_list LIKE item_list;
INSERT copy_of_item_list SELECT * FROM item_list;

CREATE TABLE IF NOT EXISTS copy_of_customer_order LIKE customer_order;
INSERT copy_of_customer_order SELECT * FROM customer_order;

CREATE TABLE IF NOT EXISTS copy_of_invoice LIKE invoice;
INSERT copy_of_invoice SELECT * FROM invoice;

CREATE TABLE IF NOT EXISTS copy_of_supplier LIKE supplier;
INSERT copy_of_supplier SELECT * FROM supplier;

CREATE TABLE IF NOT EXISTS copy_of_purchase_order LIKE purchase_order;
INSERT copy_of_purchase_order SELECT * FROM purchase_order;

CREATE TABLE IF NOT EXISTS copy_of_feedback LIKE feedback;
INSERT copy_of_feedback SELECT * FROM feedback;

CREATE TABLE IF NOT EXISTS copy_of_staff LIKE staff;
INSERT copy_of_staff SELECT * FROM staff;

/*Creating and configuring new user*/
CREATE USER 'derek'@'localhost' IDENTIFIED BY 'invalid';
GRANT SELECT ON * . * TO 'derek'@'localhost';