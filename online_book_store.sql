-- creating new database
CREATE DATABASE online_book_store;

-- using database
USE online_book_store;

-- creating table
DROP TABLE IF EXISTS books;
CREATE TABLE books(
	Book_id INT AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(100),
    Author VARCHAR(100),
    Genre VARCHAR(100),
    Published_Year INT,
    Price NUMERIC(10,2),
    Stock INT);

SELECT * FROM books;

-- creating table
DROP TABLE IF EXISTS customers;
CREATE TABLE customers(
	Customer_id INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(100),
    City VARCHAR(100),
    Country VARCHAR(100));

SELECT * FROM customers;

-- creating table
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
  Order_id INT AUTO_INCREMENT PRIMARY KEY,
  Customer_id INT,
  Book_id INT,
  Order_Date DATE,
  Quantity INT,
  Total_Amount NUMERIC(10,2),
  CONSTRAINT fk_orders_customers
	FOREIGN KEY (Customer_id) REFERENCES
    customers(Customer_id),
  CONSTRAINT fk_orders_books
    FOREIGN KEY (Book_id) REFERENCES
    books(Book_id)) ENGINE=InnoDB;

SELECT * FROM orders;

-- 1. Retrieve all books in the 'Fiction' genre:
SELECT * FROM books
	WHERE Genre = 'Fiction';

-- 2. Find books published after the year 1950:
SELECT * FROM books
	WHERE Published_Year > 1950;

-- 3. List all the customers from canada:
SELECT * FROM Customers
	WHERE Country = 'Canada';

-- 4. Show orders placed in November 2023:
SELECT * FROM orders
	WHERE Order_Date BETWEEN '2023-11-01' AND '2023-11-30';

-- 5. Retrieve the total stock of books available:
SELECT SUM(Stock) AS Total_Stock 
	FROM books;

-- 6. Find the details of most expansive book:
SELECT * FROM books
	ORDER BY Price DESC
		LIMIT 1;

-- 7. Show all customers who orderd more then one quantity of books:
SELECT * FROM orders
	WHERE Quantity > 1;

-- 8. Retrieve all orders wheree total amount exceeds $20:
SELECT * FROM orders
	WHERE Total_Amount >20;

-- 9. List all genres available in the books table:
SELECT DISTINCT Genre FROM books;

-- 10. Find the book with the lowest stock:
SELECT * FROM books
	ORDER BY Stock ASC
		LIMIT 1;

-- 11. Calculate the total revenue generated from all orders:
SELECT SUM(Total_Amount) AS Total_revenue FROM orders;

-- 12. Retrieve the total no. of books sold for each genre:
SELECT b.Genre , SUM(o.Quantity) AS Total_Books_Sold
	FROM orders o
    JOIN books b ON o.Book_id = b.Book_id
    GROUP BY b.Genre;

-- 13. Find the avg price of books in the Fantasy Genre:
SELECT Genre, AVG(Price) AS Avg_Price
	FROM books
	WHERE Genre = 'Fantasy';

-- 14. List customers who have placed atleast 2 orders:
SELECT c.Customer_id , c.Name , COUNT(o.Order_id) AS Order_Count
	FROM orders o
    JOIN customers c ON c.Customer_id = o.Customer_id
    GROUP BY c.Customer_id , c.Name
    HAVING COUNT(o.Order_id) >= 2;

-- 15. Find most frequently ordered book:
SELECT b.Title , o.Book_id , o.Order_Date
	FROM orders o
    JOIN books b ON b.Book_id = o.Book_id
	ORDER BY o.Order_Date DESC
    LIMIT 1;

SELECT o.Book_id , b.Title , COUNT(o.Order_id) AS Order_Count
	FROM orders o
    JOIN books b ON b.Book_id = o.Book_id
    GROUP BY o.Book_id , b.Title
    ORDER BY COUNT(o.Order_id) DESC
    LIMIT 1;

-- 16. Show the Top 3 most expensive books of 'Fantasy' Genre:
SELECT * FROM books
	WHERE Genre = 'Fantasy'
    ORDER BY Price DESC
    LIMIT 3;

-- 17. Retrieve the total quantity of books sold by each author:
SELECT b.Author , SUM(o.Quantity) AS Total_Books_Sold
	FROM orders o
    JOIN books b ON o.Book_id = b.Book_id
    GROUP BY b.Author;

-- 18. List the cities where customers who spent over 30$ are located:
SELECT c.City , o.Total_Amount
	FROM orders o
	JOIN customers c ON o.Customer_id = c.Customer_id
	WHERE o.Total_Amount > 30
	GROUP BY c.City , o.Total_Amount;

-- 19. Find the customer who spent the most orders:
SELECT c.Customer_id , c.Name , c.Email , c.Country , SUM(o.Total_Amount) AS Total_Spent
	FROM orders o
    JOIN customers c ON o.Customer_id = c.Customer_id
    GROUP BY c.Customer_id , c.Name , c.Email , c.Country
    ORDER BY Total_Spent DESC LIMIT 1;

-- 20. Calculate the stock remaining after fulfilling all orders:
SELECT b.Book_id, b.Title, b.Stock, COALESCE(SUM(o.Quantity),0) AS Order_Quantity,
	b.Stock-COALESCE (SUM(o.Quantity),0) AS Remaining_Quantity
		FROM books b
        LEFT JOIN orders o ON b.book_id = o.book_id
        GROUP BY b.book_id;