create table library(
isbn varchar(250)primary key,
book_title varchar(200),
category varchar(50),
rental_price float,
status varchar(200),						
author varchar(250),
publisher varchar(200)
);
select * from library;

create table branch(
branch_id VARCHAR(10) PRIMARY KEY,
manager_id VARCHAR(10),
branch_address VARCHAR(30),
contact_no VARCHAR(15)
);

select * from branch

create table empolyees(
emp_id varchar(20) primary key,
emp_name varchar(50),
position varchar(30),
salary float,
branch_id varchar(20)
)
select * from empolyees

create table members(
member_id varchar(20) primary key,
member_name varchar(100),
member_address varchar(250),
reg_date date
)
select * from members;

create table IssueStatus(
issued_id varchar(20) primary key,
issued_member_id varchar(20),
issued_book_name varchar(100),
issued_date date,
issued_book_isbn varchar(200),
issued_emp_id varchar(30)
);

select * from IssueStatus;

CREATE TABLE return_status(
return_id VARCHAR(10) PRIMARY KEY,
issued_id VARCHAR(30),
return_book_name VARCHAR(80),
return_date DATE,
return_book_isbn VARCHAR(50)
);


select * from return_status

--foreign key
alter table IssueStatus
add constraint fk_members
foreign key (issued_member_id)
references members(member_id)

alter table IssueStatus
add constraint fk_library
foreign key (issued_book_isbn)
references library(isbn);

alter table IssueStatus
add constraint fk_empolyees
foreign key (issued_emp_id)
references empolyees(emp_id);

alter table empolyees
add constraint fk_branch
foreign key (branch_id)
references branch(branch_id);

alter table return_status
add constraint fk_IssueStatus
foreign key (issued_id )
references IssueStatus(issued_id);

insert into issuestatus(issued_id) values('IS101');
insert into issuestatus(issued_id) values('IS105');
insert into issuestatus(issued_id) values('IS103');

UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';

--Project work
/*Create a New Book Record**
"978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B.
Lippincott & Co.')"*/

INSERT INTO library(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes',
'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM library;


--Update an Existing Member's Address**
UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';

select * from members;
/*Delete a Record from the Issued Status Table**
Objective: Delete the record with issued_id = 'IS121' from the issued_status table.*/
DELETE FROM issuestatus
WHERE issued_id = 'IS121';

select * from IssueStatus
WHERE issued_id = 'IS121';

/*Task 4: Retrieve All Books Issued by a Specific Employee**
Objective: Select all books issued by the employee with emp_id = 'E101'.*/
SELECT * FROM issuestatus
WHERE issued_emp_id = 'E101'

/*Task 5: List Members Who Have Issued More Than One Book**
Objective: Use GROUP BY to find members who have issued more than one book.*/
 SELECT
    issued_emp_id,
    COUNT(issued_id) as total_book_issued
FROM IssueStatus
GROUP BY issued_emp_id
HAVING COUNT(issued_id) > 1


SELECT
    issued_emp_id,
    COUNT(*)
FROM IssueStatus
GROUP BY 1
HAVING COUNT(*) > 1

/*Task 6: Create Summary Tables**: Used CTAS to generate new tables based on
query results - each book and total book_issued_cnt*/
create table book_count
as
select 
l.isbn,
l.book_title,
count(ist.issued_id) as no_issued
from library as l
join
IssueStatus as ist
on ist.issued_book_isbn =l.isbn
group by 1;

select * from book_count;

--Task 7. **Retrieve All Books in a Specific Category*/
SELECT * FROM library
WHERE category = 'Classic';

/*Task 8: Find Total Rental Income by Category*/
SELECT 
    l.category,
    SUM(l.rental_price),
    COUNT(*)
FROM 
issuestatus as ist
JOIN
library as l
ON l.isbn = ist.issued_book_isbn
GROUP BY 1

/*Task 9 List Members Who Registered in the Last 180 Days*/
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days'


insert into members(member_id, member_name, member_address, reg_date)
values
('C118', 'sam','145 main St', '2024-06-01'),
('C119', 'john','133 main St', '2024-05-01')
;

/*List Employees with Their Branch Manager's Name and their branch details*/
select * from empolyees as e1
join 
 branch as b
 on b.branch_id = e1.branch_id
 join
 empolyees as e2
 on b.manager_id = e2.emp_id

 select
 e1. *,
  b.manager_id,
 e2.emp_name as manager
 from empolyees as e1
join 
 branch as b
 on b.branch_id = e1.branch_id
 join
 empolyees as e2
 on b.manager_id = e2.emp_id


/*Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold 7usd**/
CREATE TABLE expensive_books AS
SELECT * FROM library
WHERE rental_price > 7.00;

select * from expensive_books;

/*Task 12: **Retrieve the List of Books Not Yet Returned*/
--use (*) after select and remove distinct to get all details.
SELECT 
distinct ist.issued_book_name
from  IssueStatus as ist
left join
return_status as rs
on ist.issued_id = rs.issued_id
where rs.return_id is null;

-- sql advance question
/*Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue*/

--issued_ststud == member == books == return_status
SELECT
  *
FROM IssueStatus as ist
JOIN 
members as m
	ON m.member_id = ist.issued_member_id
JOIN 
library as li
ON li.isbn = ist.issued_book_isbn
LEFT JOIN 
return_status as rs
ON rs.issued_id = ist.issued_id

--filter books which is return
--overdue > 30
SELECT
    ist.issued_member_id,
    m.member_name,
    li.book_title,
    ist.issued_date,
	rs.return_date,
	(CURRENT_DATE - ist.issued_date) as over_due_date
FROM IssueStatus as ist
JOIN 
members as m
	ON m.member_id = ist.issued_member_id
JOIN 
library as li
ON li.isbn = ist.issued_book_isbn
LEFT JOIN 
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE 
    rs.return_date IS NULL
    AND
	(CURRENT_DATE - ist.issued_date) > 30
	order by 1;

/*Task 14: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are
returned (based on entries in the return_status table)*/
insert into return_status(return_id, issued_id, return_date, return_book_isbn)
values
('RS125', 'IS130', current_date, 'good');
select * from return_status
where issued_id = 'IS130';

select  * from IssueStatus
where issued_book_isbn = '978-0-451-52994-2';

select * from library
where isbn = '978-0-451-52994-2';

update library
set status = 'no'
where isbn = '978-0-451-52994-2';

--again
update library
set status = 'yes'
where isbn = '978-0-451-52994-2';
select * from library

--store procdures
CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(10), p_issued_id VARCHAR(10), p_book_quality VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
    v_isbn VARCHAR(50);
    v_book_name VARCHAR(80);
    
BEGIN
    -- all your logic and code
    -- inserting into returns based on users input
    INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
    VALUES
    (p_return_id, p_issued_id, CURRENT_DATE, p_book_quality);

    SELECT 
        issued_book_isbn,
        issued_book_name
        INTO
        v_isbn,
        v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    UPDATE library
    SET status = 'yes'
    WHERE isbn = v_isbn;

    RAISE NOTICE 'Thank you for returning the book: %', v_book_name;
    
END;
$$
-- Testing FUNCTION add_return_records

select * from library

SELECT * FROM library
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM IssueStatus
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS120';
      
/*Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, 
showing the number of books issued, the number of books returned, and the total
revenue generated from book rentals.*/
CREATE TABLE branch_reports       
AS
SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) as number_book_issued,
    COUNT(rs.return_id) as number_of_book_return,
    SUM(li.rental_price) as total_revenue
FROM issuestatus as ist
JOIN 
empolyees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
JOIN 
library as li
ON ist.issued_book_isbn = li.isbn
GROUP BY 1, 2;

SELECT * FROM branch_reports;

/*Task 16: CTAS: Create a Table of Active Members**
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members 
containing members who have issued at least one book in the last 2 months*/
CREATE TABLE active_members
AS
SELECT * FROM members
WHERE member_id IN (SELECT 
                        DISTINCT issued_member_id   
                    FROM IssueStatus
                    WHERE 
                        issued_date >= CURRENT_DATE - INTERVAL '2 month'
                    );

SELECT * FROM active_members;
/*Task 17: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch.*/
SELECT 
    e.emp_name,
    b.*,
    COUNT(ist.issued_id) as no_book_issued
FROM IssueStatus as ist
JOIN
empolyees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
GROUP BY 1, 2

/*Task 18: Identify Members Issuing High-Risk Books**  
Write a query to identify members who have issued books more than twice 
with the status "damaged" in the books table. Display the member name, book title,
and the number of times they've issued damaged books.*/
CREATE OR REPLACE PROCEDURE issue_book(p_issued_id VARCHAR(10), p_issued_member_id VARCHAR(30), p_issued_book_isbn VARCHAR(30), p_issued_emp_id VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
-- all the variabable
    v_status VARCHAR(10);

BEGIN
-- all the code
    -- checking if book is available 'yes'
    SELECT 
        status 
        INTO
        v_status
    FROM library
    WHERE isbn = p_issued_book_isbn;

    IF v_status = 'yes' THEN

        INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES
        (p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);

        UPDATE library
            SET status = 'no'
        WHERE isbn = p_issued_book_isbn;

        RAISE NOTICE 'Book records added successfully for book isbn : %', p_issued_book_isbn;


    ELSE
        RAISE NOTICE 'Sorry to inform you the book you have requested is unavailable book_isbn: %',
		p_issued_book_isbn;
    END IF;
END;
$$

-- Testing The function
SELECT * FROM library;
-- "978-0-553-29698-2" -- yes
-- "978-0-375-41398-8" -- no
SELECT * FROM IssueStatus;

SELECT * FROM library
WHERE isbn = '978-0-375-41398-8'



/*Task 19: Stored Procedure**
Objective:
Create a stored procedure to manage the status of books in a library system.*/

CREATE OR REPLACE PROCEDURE issued_book(p_issued_id VARCHAR(10), p_issued_member_id VARCHAR(30), p_issued_book_isbn VARCHAR(30), p_issued_emp_id VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
-- all the variabable
    v_status VARCHAR(10);

BEGIN
-- all the code
    -- checking if book is available 'yes'
    SELECT 
        status 
        INTO
        v_status
    FROM library
    WHERE isbn = p_issued_book_isbn;

    IF v_status = 'yes' THEN

        INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES
        (p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);

        UPDATE library
            SET status = 'no'
        WHERE isbn = p_issued_book_isbn;

        RAISE NOTICE 'Book records added successfully for book isbn : %', p_issued_book_isbn;


    ELSE
        RAISE NOTICE 'Sorry to inform you the book you have requested is unavailable book_isbn: %', p_issued_book_isbn;
    END IF;
END;
$$


select * from library;
select * from branch;
select * from empolyees;
select * from members;
select * from IssueStatus;
select * from return_status;
SELECT * FROM branch_reports;
SELECT * FROM active_members;



