--1
--2
--2.1
--2.1.1: Task â€“ Select all records from the Employee table.
select * from employee;
--2.1.2: Task â€“ Select all records from the Employee table where last name is King.
select * from employee where lastname = 'King';
--2.1.3: Task â€“ Select all records from the Employee table where first name is Andrew and REPORTSTO is NULL.
select * from employee where firstname ='"Andrew' and reportsto is null;
--2.2
--2.2.1: Task â€“ Select all albums in Album table and sort result set in descending order by title.
select * from album order by title desc;
--2.2.2: Task â€“ Select first name from Customer and sort result set in ascending order by city
select firstname from customer order by city asc;
--2.3
--2.3.1: Task â€“ Insert two new records into Genre table
insert into genre (genreid, name) values (26, 'WubWubWub');
insert into genre (genreid, name) values (27, 'LoFi');
--2.3.2: Task – Insert two new records into Employee table
insert into employee (employeeid, lastname, firstname) values (9, 'Johnson', 'Smith');
insert into employee (employeeid, lastname, firstname) values (10, 'Pewtersmit', 'Johan');
--2.3.3: Task – Insert two new records into Customer table
insert into employee (employeeid, lastname, firstname) values (60, 'Skagg', 'Boz');
insert into employee (employeeid, lastname, firstname) values (61, 'Jenkins', 'Leroy');
--2.4
--2.4.1: Task – Update Aaron Mitchell in Customer table to Robert Walter
update customer set firstname='Robert', lastname='Walter' where firstname='Aaron' and lastname='Mitchell';
--2.4.2: Task – Update name of artist in the Artist table “Creedence Clearwater Revival” to “CCR”
update artist set "name" = 'CCR' where "name" = 'Creedence Clearwater Revival';
--2.5
--2.5.1: Task – Select all invoices with a billing address like “T%”
select * from invoice where billingaddress like 'T%';
--2.6
--2.6.1: Task – Select all invoices that have a total between 15 and 50
select * from invoice where total<50 and total>15;
--2.6.2: Task – Select all employees hired between 1st of June 2003 and 1st of March 2004
select * from employee where hiredate > '2003-06-01' and hiredate < '2004-03-01';
--2.7
--2.7.1: Task – Delete a record in Customer table where the name is Robert Walter (There may be constraints that rely on this, find out how to resolve them).
delete from invoiceline where invoiceid in (select invoiceid from invoice where customerid in (select customerid from customer where firstname = 'Robert' and lastname = 'Walter'));
delete from invoice where customerid in (select customerid from customer where firstname = 'Robert' and lastname = 'Walter');
delete from customer where firstname = 'Robert' and lastname = 'Walter';
--3
--3.1
--3.1.1: Task – Create a function that returns the current time.
create or replace function watch() returns time as '
begin
	return current_time;
end;'
LANGUAGE PLPGSQL;
select watch();
--3.1.2: Task – create a function that returns the length of a mediatype from the mediatype table
create or replace function medialength(in mtype integer) returns int as '
begin
	return (select sum(milliseconds) from track where mediatypeid = mtype);
end;'
LANGUAGE PLPGSQL;
select medialength(1);
--3.2
--3.2.1: Task – Create a function that returns the average total of all invoices
create or replace function avginvoice() returns int as '
begin
	return (select avg(total) from invoice);
end;'
LANGUAGE PLPGSQL;
select avginvoice();
--3.2.2: Task – Create a function that returns the most expensive track
CREATE or replace FUNCTION getMostExpensiveTracks() RETURNS setof track AS '
  select * from track where unitprice = (SELECT MAX(unitprice) FROM track);
' LANGUAGE SQL;
select * from getMostExpensiveTracks();
--3.3
--3.3.1: Task – Create a function that returns the average price of invoiceline items in the invoiceline table
create or replace function avginvoicelineitem() returns int as '
begin
	return (select avg(unitprice) from invoiceline);
end;'
LANGUAGE PLPGSQL;
select avginvoicelineitem();
--3.4
--3.4.1: Task – Create a function that returns all employees who are born after 1968.
CREATE or replace FUNCTION bornaftersixtyeight() RETURNS setof employee AS $$
  select * from employee where birthdate > '1968-12-31';
$$ LANGUAGE SQL;
select * from bornaftersixtyeight();
--4
--4.1
--4.1.1: Task – Create a stored procedure that selects the first and last names of all the employees.
create or replace function employeename_stored_proc(out success bool)
as $$
	begin
		select firstname, lastname from employee;
		success = true;
	end;
$$ language plpgsql;
rollback;
--4.2
--4.2.1 Task – Create a stored procedure that updates the personal information of an employee.
create or replace function updateemployee_stored_proc(employeeidin numeric, lastnamein text, firstnamein text, titlein text, birthdatein date, hiredatein date, addressin text, cityin text, statein text, countryin text, postalcodein text, phonein text,faxin text, emailin text) returns void
as $$
	begin
		update employee
    	set lastname = lastnamein,
    	firstname = firstnamein,
    	title = titlein,
    	birthdate = birthdatein,
    	hiredate = hiredatein,
    	address = addressin,
    	city = cityin,
    	state = statein,
    	country = countryin,
    	postalcode = postalcode,
    	phone = phonein,
    	fax = faxin,
    	email = emailin
        where employeeid = employeeidin;
	end;
$$ language plpgsql;
--test
select * from employee where employeeid = 1;
do $$
begin
    execute updateemployee_stored_proc(
	1,		'inserted',		'',
	'', 	'1970-01-01', 	'1970-01-01',
	'', 	'', 			'',
	'', 	'', 			'',
	'', 	''
	);
end;
$$ language plpgsql;
--4.2.2: Task – Create a stored procedure that returns the managers of an employee.
create or replace function whichManager(eid integer) returns int4 as $$
	begin
	select reportsto from employee where employeeid=eid;
	end;
$$ language plpgsql;
--4.3
--4.3.1: Task – Create a stored procedure that returns the name and company of a customer.
create or replace function nameCompany (idin int, out customernameout refcursor) as $$
begin
	select concat('customer: ', firstname, ' ', lastname, ', company: ', company) into customernameout
	from customer where customerid = idin;
end;
$$ language plpgsql;
--5
--5.1: Task – Create a transaction that given a invoiceId will delete that invoice (There may be constraints that rely on this, find out how to resolve them).
create or replace function deleteInvoice(iid integer) returns bool as $$
begin
	delete from invoiceline where invoiceid = iid;
	delete from invoice where invoiceid = iid;	
end;
$$ language plpgsql;
--5.2: Task – Create a transaction nested within a stored procedure that inserts a new record in the Customer table
create or replace function insertCustomer(idin integer, firstnamein text, lastnamein text, companyin text, addressin text, cityin text, statein text, countryin text, postalcodein text, phonein text, faxin text, emailin text, supportrepidin integer
) returns void as $$
begin
	insert into customer values (idin, firstnamein, lastnamein, companyin, addressin, cityin, statein, countryin, postalcodein, phonein, faxin, emailin, supportrepidin);
end;
$$ language plpgsql;
--6
--6.1
create or replace function test()
returns trigger as $$
	begin
		raise 'test';
	end;
$$ language plpgsql;
--6.1.1: Task - Create an after insert trigger on the employee table fired after a new record is inserted into the table.
create trigger after_employee_insert
	after insert on employee
	for each row
    execute procedure test();
--6.1.2: Task – Create an after update trigger on the album table that fires after a row is inserted in the table
create trigger after_album_update
	after update on album
	for each row
    execute procedure test();
--6.1.3: Task – Create an after delete trigger on the customer table that fires after a row is deleted from the table.
create trigger after_customer_delete
	after delete on customer
	for each row
    execute procedure test();
--7
--7.1: Task – Create an inner join that joins customers and orders and specifies the name of the customer and the invoiceId.
select concat(c.firstname, ' ' , c.lastname) as "Name", i.invoiceid as "Invoice Id"
from customer c
inner join invoice i on
c.customerid = i.customerid;
--7.2: Task – Create an (left)outer join that joins the customer and invoice table, specifying the CustomerId, firstname, lastname, invoiceId, and total.
select c.customerid, c.firstname, c.lastname, i.invoiceid, i.total
from customer c
left join invoice i on
c.customerid = i.customerid;
--7.3: Task – Create a right join that joins album and artist specifying artist name and title.
select ar."name" as "name", al.title as title
from album al
right join artist ar on
al.artistid = ar.artistid;
--7.4: Task – Create a cross join that joins album and artist and sorts by artist name in ascending order.
select *
from album
cross join artist
order by artist."name" asc;
--7.5: Task – Perform a self-join on the employee table, joining on the reportsto column.
 select *
 from employee e, employee m
 where e.reportsto = m.employeeid;
