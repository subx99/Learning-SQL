/*
Learning SQL, by Alan Beaulieu
O’Reilly Media, Inc

Example code modified to suit using Postgres instead of Mysql
Used with the hard copy book borrowed from a library.

Original source of sample code from:
https://github.com/kaya320/LearningSQL_Alan_Beaulieu/blob/master/LearningSQL%20Example.sql
(may vary from the original supplied with the book - unverified)

Changes:
 - Modified to remove enum constraints in tables as not supported. Replaced with CHAR().
 - id: smallint unsigned '...' auto-increment not supported. Replaced with SERIAL.
 - Float and double values not supported, replaced with REAL
 - Date format changed to suit Postgres style.  Original example using strings has been changed to various configuration dates using the following to replace the string 'yyyy-mm-dd'
        (now() - interval '48 DAY')::date AS 
   days set with random intervals to provide different dates in the tables.

*/


/* begin table creation */

create table department
 (dept_id SERIAL not null,
  name varchar(20) not null,
  constraint pk_department primary key (dept_id)
 );

create table branch
 (branch_id SERIAL not null,
  name varchar(20) not null,
  address varchar(30),
  city varchar(20),
  state varchar(2),
  zip varchar(12),
  constraint pk_branch primary key (branch_id)
 );

create table employee
 (emp_id SERIAL not null,
  fname varchar(20) not null,
  lname varchar(20) not null,
  start_date date not null,
  end_date date,
  superior_emp_id smallint,
  dept_id smallint,
  title varchar(20),
  assigned_branch_id smallint,
  constraint fk_e_emp_id 
    foreign key (superior_emp_id) references employee (emp_id),
  constraint fk_dept_id
    foreign key (dept_id) references department (dept_id),
  constraint fk_e_branch_id
    foreign key (assigned_branch_id) references branch (branch_id),
  constraint pk_employee primary key (emp_id)
 );

create table product_type
 (product_type_cd varchar(10) not null,
  name varchar(50) not null,
  constraint pk_product_type primary key (product_type_cd)
 );

create table product
 (product_cd varchar(10) not null,
  name varchar(50) not null,
  product_type_cd varchar(10) not null,
  date_offered date,
  date_retired date,
  constraint fk_product_type_cd foreign key (product_type_cd) 
    references product_type (product_type_cd),
  constraint pk_product primary key (product_cd)
 );

create table customer
 (cust_id SERIAL not null,
  fed_id varchar(12) not null,
  cust_type_cd char(1) not null,
  address varchar(30),
  city varchar(20),
  state varchar(20),
  postal_code varchar(10),
  constraint pk_customer primary key (cust_id)
 );

create table individual
 (cust_id integer not null,
  fname varchar(30) not null,
  lname varchar(30) not null,
  birth_date date,
  constraint fk_i_cust_id foreign key (cust_id)
    references customer (cust_id),
  constraint pk_individual primary key (cust_id)
 );

create table business
 (cust_id integer not null,
  name varchar(40) not null,
  state_id varchar(10) not null,
  incorp_date date,
  constraint fk_b_cust_id foreign key (cust_id)
    references customer (cust_id),
  constraint pk_business primary key (cust_id)
 );

create table officer
 (officer_id SERIAL not null,
  cust_id integer not null,
  fname varchar(30) not null,
  lname varchar(30) not null,
  title varchar(20),
  start_date date not null,
  end_date date,
  constraint fk_o_cust_id foreign key (cust_id)
    references business (cust_id),
  constraint pk_officer primary key (officer_id)
 );

create table account
 (account_id SERIAL not null,
  product_cd varchar(10) not null,
  cust_id integer not null,
  open_date date not null,
  close_date date,
  last_activity_date date,
  status varchar(10),
  open_branch_id smallint,
  open_emp_id smallint,
  avail_balance real,
  pending_balance real,
  constraint fk_product_cd foreign key (product_cd)
    references product (product_cd),
  constraint fk_a_cust_id foreign key (cust_id)
    references customer (cust_id),
  constraint fk_a_branch_id foreign key (open_branch_id)
    references branch (branch_id),
  constraint fk_a_emp_id foreign key (open_emp_id)
    references employee (emp_id),
  constraint pk_account primary key (account_id)
 );

create table transaction
 (txn_id SERIAL not null,
  txn_date date not null,
  account_id integer not null,
  txn_type_cd char(3),
  amount real not null,
  teller_emp_id smallint,
  execution_branch_id smallint,
  funds_avail_date date,
  constraint fk_t_account_id foreign key (account_id)
    references account (account_id),
  constraint fk_teller_emp_id foreign key (teller_emp_id)
    references employee (emp_id),
  constraint fk_exec_branch_id foreign key (execution_branch_id)
    references branch (branch_id),
  constraint pk_transaction primary key (txn_id)
 );

/* end table creation */



/* begin data population */



/* department data */

insert into department (name)
values ('Operations');
insert into department (name)
values ('Loans');
insert into department (name)
values ('Administration');

/* branch data */
insert into branch (name, address, city, state, zip)
values ('Headquarters', '3882 Main St.', 'Waltham', 'MA', '02451');
insert into branch (name, address, city, state, zip)
values ('Woburn Branch', '422 Maple St.', 'Woburn', 'MA', '01801');
insert into branch (name, address, city, state, zip)
values ('Quincy Branch', '125 Presidential Way', 'Quincy', 'MA', '02169');
insert into branch (name, address, city, state, zip)
values ('So. NH Branch', '378 Maynard Ln.', 'Salem', 'NH', '03079');

/* employee data */
insert into employee (fname, lname, start_date, 
  dept_id, title, assigned_branch_id)
values ('Michael', 'Smith', '2001-06-22', 
  (select dept_id from department where name = 'Administration'), 
  'President', 
  (select branch_id from branch where name = 'Headquarters'));
insert into employee (fname, lname, start_date, 
  dept_id, title, assigned_branch_id)
values ('Susan', 'Barker', '2002-09-12', 
  (select dept_id from department where name = 'Administration'), 
  'Vice President', 
  (select branch_id from branch where name = 'Headquarters'));
insert into employee (fname, lname, start_date, 
  dept_id, title, assigned_branch_id)
values ('Robert', 'Tyler', '2000-02-09',
  (select dept_id from department where name = 'Administration'), 
  'Treasurer', 
  (select branch_id from branch where name = 'Headquarters'));
insert into employee (fname, lname, start_date, 
  dept_id, title, assigned_branch_id)
values ('Susan', 'Hawthorne', '2002-04-24', 
  (select dept_id from department where name = 'Operations'), 
  'Operations Manager', 
  (select branch_id from branch where name = 'Headquarters'));
insert into employee (fname, lname, start_date, 
  dept_id, title, assigned_branch_id)
values ('John', 'Gooding', '2003-11-14', 
  (select dept_id from department where name = 'Loans'), 
  'Loan Manager', 
  (select branch_id from branch where name = 'Headquarters'));
insert into employee (fname, lname, start_date, 
  dept_id, title, assigned_branch_id)
values ('Helen', 'Fleming', '2004-03-17', 
  (select dept_id from department where name = 'Operations'), 
  'Head Teller', 
  (select branch_id from branch where name = 'Headquarters'));
insert into employee (fname, lname, start_date, 
  dept_id, title, assigned_branch_id)
values ('Chris', 'Tucker', '2004-09-15', 
  (select dept_id from department where name = 'Operations'), 
  'Teller', 
  (select branch_id from branch where name = 'Headquarters'));
insert into employee (fname, lname, start_date, 
  dept_id, title, assigned_branch_id)
values ('Sarah', 'Parker', '2002-12-02', 
  (select dept_id from department where name = 'Operations'), 
  'Teller', 
  (select branch_id from branch where name = 'Headquarters'));
insert into employee (fname, lname, start_date, 
  dept_id, title, assigned_branch_id)
values ('Jane', 'Grossman', '2002-05-03', 
  (select dept_id from department where name = 'Operations'), 
  'Teller', 
  (select branch_id from branch where name = 'Headquarters'));
insert into employee (fname, lname, start_date, 
  dept_id, title, assigned_branch_id)
values ('Paula', 'Roberts', '2002-07-27', 
  (select dept_id from department where name = 'Operations'), 
  'Head Teller', 
  (select branch_id from branch where name = 'Woburn Branch'));
insert into employee (fname, lname, start_date, 
  dept_id, title, assigned_branch_id)
values ('Thomas', 'Ziegler', '2000-10-23', 
  (select dept_id from department where name = 'Operations'), 
  'Teller', 
  (select branch_id from branch where name = 'Woburn Branch'));
insert into employee (fname, lname, start_date, 
  dept_id, title, assigned_branch_id)
values ('Samantha', 'Jameson', '2003-01-08', 
  (select dept_id from department where name = 'Operations'), 
  'Teller', 
  (select branch_id from branch where name = 'Woburn Branch'));
insert into employee (fname, lname, start_date, 
  dept_id, title, assigned_branch_id)
values ('John', 'Blake', '2000-05-11', 
  (select dept_id from department where name = 'Operations'), 
  'Head Teller', 
  (select branch_id from branch where name = 'Quincy Branch'));
insert into employee (fname, lname, start_date, 
  dept_id, title, assigned_branch_id)
values ('Cindy', 'Mason', '2002-08-09', 
  (select dept_id from department where name = 'Operations'), 
  'Teller', 
  (select branch_id from branch where name = 'Quincy Branch'));
insert into employee (fname, lname, start_date, 
  dept_id, title, assigned_branch_id)
values ('Frank', 'Portman', '2003-04-01', 
  (select dept_id from department where name = 'Operations'), 
  'Teller', 
  (select branch_id from branch where name = 'Quincy Branch'));
insert into employee (fname, lname, start_date, 
  dept_id, title, assigned_branch_id)
values ('Theresa', 'Markham', '2001-03-15', 
  (select dept_id from department where name = 'Operations'), 
  'Head Teller', 
  (select branch_id from branch where name = 'So. NH Branch'));
insert into employee (fname, lname, start_date, 
  dept_id, title, assigned_branch_id)
values ('Beth', 'Fowler', '2002-06-29', 
  (select dept_id from department where name = 'Operations'), 
  'Teller', 
  (select branch_id from branch where name = 'So. NH Branch'));
insert into employee (fname, lname, start_date, 
  dept_id, title, assigned_branch_id)
values ('Rick', 'Tulman', '2002-12-12', 
  (select dept_id from department where name = 'Operations'), 
  'Teller', 
  (select branch_id from branch where name = 'So. NH Branch'));

/* create data for self-referencing foreign key 'superior_emp_id' */
create temporary table emp_tmp as
select emp_id, fname, lname from employee;

update employee set superior_emp_id =
 (select emp_id from emp_tmp where lname = 'Smith' and fname = 'Michael')
where ((lname = 'Barker' and fname = 'Susan')
  or (lname = 'Tyler' and fname = 'Robert'));
update employee set superior_emp_id =
 (select emp_id from emp_tmp where lname = 'Tyler' and fname = 'Robert')
where lname = 'Hawthorne' and fname = 'Susan';
update employee set superior_emp_id =
 (select emp_id from emp_tmp where lname = 'Hawthorne' and fname = 'Susan')
where ((lname = 'Gooding' and fname = 'John')
  or (lname = 'Fleming' and fname = 'Helen')
  or (lname = 'Roberts' and fname = 'Paula') 
  or (lname = 'Blake' and fname = 'John') 
  or (lname = 'Markham' and fname = 'Theresa')); 
update employee set superior_emp_id =
 (select emp_id from emp_tmp where lname = 'Fleming' and fname = 'Helen')
where ((lname = 'Tucker' and fname = 'Chris') 
  or (lname = 'Parker' and fname = 'Sarah') 
  or (lname = 'Grossman' and fname = 'Jane'));  
update employee set superior_emp_id =
 (select emp_id from emp_tmp where lname = 'Roberts' and fname = 'Paula')
where ((lname = 'Ziegler' and fname = 'Thomas')  
  or (lname = 'Jameson' and fname = 'Samantha'));   
update employee set superior_emp_id =
 (select emp_id from emp_tmp where lname = 'Blake' and fname = 'John')
where ((lname = 'Mason' and fname = 'Cindy')   
  or (lname = 'Portman' and fname = 'Frank'));    
update employee set superior_emp_id =
 (select emp_id from emp_tmp where lname = 'Markham' and fname = 'Theresa')
where ((lname = 'Fowler' and fname = 'Beth')   
  or (lname = 'Tulman' and fname = 'Rick'));    

drop table emp_tmp;

/* product type data */
insert into product_type (product_type_cd, name)
values ('ACCOUNT','Customer Accounts');
insert into product_type (product_type_cd, name)
values ('LOAN','Individual and Business Loans');
insert into product_type (product_type_cd, name)
values ('INSURANCE','Insurance Offerings');

/* product data */
insert into product (product_cd, name, product_type_cd, date_offered)
values ('CHK','checking account','ACCOUNT','2000-01-01');
insert into product (product_cd, name, product_type_cd, date_offered)
values ('SAV','savings account','ACCOUNT','2000-01-01');
insert into product (product_cd, name, product_type_cd, date_offered)
values ('MM','money market account','ACCOUNT','2000-01-01');
insert into product (product_cd, name, product_type_cd, date_offered)
values ('CD','certificate of deposit','ACCOUNT','2000-01-01');
insert into product (product_cd, name, product_type_cd, date_offered)
values ('MRT','home mortgage','LOAN','2000-01-01');
insert into product (product_cd, name, product_type_cd, date_offered)
values ('AUT','auto loan','LOAN','2000-01-01');
insert into product (product_cd, name, product_type_cd, date_offered)
values ('BUS','business line of credit','LOAN','2000-01-01');
insert into product (product_cd, name, product_type_cd, date_offered)
values ('SBL','small business loan','LOAN','2000-01-01');

/* residential customer data */

insert into customer (fed_id, cust_type_cd,
  address, city, state, postal_code)
values ('111-11-1111', 'I', '47 Mockingbird Ln', 'Lynnfield', 'MA', '01940');
insert into individual (cust_id, fname, lname, birth_date)
select cust_id, 'James', 'Hadley', '1972-04-22' from customer
where fed_id = '111-11-1111';
insert into customer (fed_id, cust_type_cd,
  address, city, state, postal_code)
values ('222-22-2222', 'I', '372 Clearwater Blvd', 'Woburn', 'MA', '01801');
insert into individual (cust_id, fname, lname, birth_date)
select cust_id, 'Susan', 'Tingley', '1968-08-15' from customer
where fed_id = '222-22-2222';
insert into customer (fed_id, cust_type_cd,
  address, city, state, postal_code)
values ('333-33-3333', 'I', '18 Jessup Rd', 'Quincy', 'MA', '02169');
insert into individual (cust_id, fname, lname, birth_date)
select cust_id, 'Frank', 'Tucker', '1958-02-06' from customer
where fed_id = '333-33-3333';
insert into customer (fed_id, cust_type_cd,
  address, city, state, postal_code)
values ('444-44-4444', 'I', '12 Buchanan Ln', 'Waltham', 'MA', '02451');
insert into individual (cust_id, fname, lname, birth_date)
select cust_id, 'John', 'Hayward', '1966-12-22' from customer
where fed_id = '444-44-4444';
insert into customer (fed_id, cust_type_cd,
  address, city, state, postal_code)
values ('555-55-5555', 'I', '2341 Main St', 'Salem', 'NH', '03079');
insert into individual (cust_id, fname, lname, birth_date)
select cust_id, 'Charles', 'Frasier', '1971-08-25' from customer
where fed_id = '555-55-5555';
insert into customer (fed_id, cust_type_cd,
  address, city, state, postal_code)
values ('666-66-6666', 'I', '12 Blaylock Ln', 'Waltham', 'MA', '02451');
insert into individual (cust_id, fname, lname, birth_date)
select cust_id, 'John', 'Spencer', '1962-09-14' from customer
where fed_id = '666-66-6666';
insert into customer (fed_id, cust_type_cd,
  address, city, state, postal_code)
values ('777-77-7777', 'I', '29 Admiral Ln', 'Wilmington', 'MA', '01887');
insert into individual (cust_id, fname, lname, birth_date)
select cust_id, 'Margaret', 'Young', '1947-03-19' from customer
where fed_id = '777-77-7777';
insert into customer (fed_id, cust_type_cd,
  address, city, state, postal_code)
values ('888-88-8888', 'I', '472 Freedom Rd', 'Salem', 'NH', '03079');
insert into individual (cust_id, fname, lname, birth_date)
select cust_id, 'Louis', 'Blake', '1977-07-01' from customer
where fed_id = '888-88-8888';
insert into customer (fed_id, cust_type_cd,
  address, city, state, postal_code)
values ('999-99-9999', 'I', '29 Maple St', 'Newton', 'MA', '02458');
insert into individual (cust_id, fname, lname, birth_date)
select cust_id, 'Richard', 'Farley', '1968-06-16' from customer
where fed_id = '999-99-9999';

/* corporate customer data */

insert into customer (fed_id, cust_type_cd,
  address, city, state, postal_code)
values ('04-1111111', 'B', '7 Industrial Way', 'Salem', 'NH', '03079');
insert into business (cust_id, name, state_id, incorp_date)
select cust_id, 'Chilton Engineering', '12-345-678', '1995-05-01' from customer
where fed_id = '04-1111111';
insert into officer (cust_id, fname, lname,
  title, start_date)
select cust_id, 'John', 'Chilton', 'President', '1995-05-01'
from customer
where fed_id = '04-1111111';
insert into customer (fed_id, cust_type_cd,
  address, city, state, postal_code)
values ('04-2222222', 'B', '287A Corporate Ave', 'Wilmington', 'MA', '01887');
insert into business (cust_id, name, state_id, incorp_date)
select cust_id, 'Northeast Cooling Inc.', '23-456-789', '2001-01-01' from customer
where fed_id = '04-2222222';
insert into officer (cust_id, fname, lname,
  title, start_date)
select cust_id, 'Paul', 'Hardy', 'President', '2001-01-01'
from customer
where fed_id = '04-2222222';
insert into customer (fed_id, cust_type_cd,
  address, city, state, postal_code)
values ('04-3333333', 'B', '789 Main St', 'Salem', 'NH', '03079');
insert into business (cust_id, name, state_id, incorp_date)
select cust_id, 'Superior Auto Body', '34-567-890', '2002-06-30' from customer
where fed_id = '04-3333333';
insert into officer (cust_id, fname, lname,
  title, start_date)
select cust_id, 'Carl', 'Lutz', 'President', '2002-06-30'
from customer
where fed_id = '04-3333333';
insert into customer (fed_id, cust_type_cd,
  address, city, state, postal_code)
values ('04-4444444', 'B', '4772 Presidential Way', 'Quincy', 'MA', '02169');
insert into business (cust_id, name, state_id, incorp_date)
select cust_id, 'AAA Insurance Inc.', '45-678-901', '1999-05-01' from customer
where fed_id = '04-4444444';
insert into officer (cust_id, fname, lname,
  title, start_date)
select cust_id, 'Stanley', 'Cheswick', 'President', '1999-05-01'
from customer
where fed_id = '04-4444444';

/* residential accounts */

insert into account (product_cd, cust_id, open_date,
  last_activity_date, status, open_branch_id,
  open_emp_id, avail_balance, pending_balance)
select a.prod_cd, c.cust_id, a.open_date, a.last_date, 'ACTIVE',
  e.branch_id, e.emp_id, a.avail, a.pend
from customer c cross join 
 (select b.branch_id, e.emp_id 
  from branch b inner join employee e on e.assigned_branch_id = b.branch_id
  where b.city = 'Woburn' limit 1) e
  cross join
 (select 'CHK' prod_cd, (now() - interval '1 DAY')::date AS open_date, (now() - interval '15 DAY')::date AS last_date,
    1057.75 avail, 1057.75 pend union all
  select 'SAV' prod_cd, (now() - interval '15 DAY')::date AS open_date, (now() - interval '25 DAY')::date AS last_date,
    500.00 avail, 500.00 pend union all
  select 'CD' prod_cd, (now() - interval '25 DAY')::date AS open_date, (now() - interval '40 DAY')::date AS last_date,
    3000.00 avail, 3000.00 pend) a
where c.fed_id = '111-11-1111';

insert into account (product_cd, cust_id, open_date,
  last_activity_date, status, open_branch_id,
  open_emp_id, avail_balance, pending_balance)
select a.prod_cd, c.cust_id, a.open_date, a.last_date, 'ACTIVE',
  e.branch_id, e.emp_id, a.avail, a.pend
from customer c cross join 
 (select b.branch_id, e.emp_id 
  from branch b inner join employee e on e.assigned_branch_id = b.branch_id
  where b.city = 'Woburn' limit 1) e
  cross join
 (select 'CHK' prod_cd, (now() - interval '44 DAY')::date AS open_date, (now() - interval '55 DAY')::date AS last_date,
    2258.02 avail, 2258.02 pend union all
  select 'SAV' prod_cd, (now() - interval '4 DAY')::date AS open_date, (now() - interval '29 DAY')::date AS last_date,
    200.00 avail, 200.00 pend) a
where c.fed_id = '222-22-2222';

insert into account (product_cd, cust_id, open_date,
  last_activity_date, status, open_branch_id,
  open_emp_id, avail_balance, pending_balance)
select a.prod_cd, c.cust_id, a.open_date, a.last_date, 'ACTIVE',
  e.branch_id, e.emp_id, a.avail, a.pend
from customer c cross join 
 (select b.branch_id, e.emp_id 
  from branch b inner join employee e on e.assigned_branch_id = b.branch_id
  where b.city = 'Quincy' limit 1) e
  cross join
 (select 'CHK' prod_cd, (now() - interval '5 DAY')::date AS open_date, (now() - interval '13 DAY')::date AS last_date,
    1057.75 avail, 1057.75 pend union all
  select 'MM' prod_cd, (now() - interval '23 DAY')::date AS open_date, (now() - interval '46 DAY')::date AS last_date,
    2212.50 avail, 2212.50 pend) a
where c.fed_id = '333-33-3333';

insert into account (product_cd, cust_id, open_date,
  last_activity_date, status, open_branch_id,
  open_emp_id, avail_balance, pending_balance)
select a.prod_cd, c.cust_id, a.open_date, a.last_date, 'ACTIVE',
  e.branch_id, e.emp_id, a.avail, a.pend
from customer c cross join 
 (select b.branch_id, e.emp_id 
  from branch b inner join employee e on e.assigned_branch_id = b.branch_id
  where b.city = 'Waltham' limit 1) e
  cross join
 (select 'CHK' prod_cd, (now() - interval '2 DAY')::date AS open_date, (now() - interval '5 DAY')::date AS last_date,
    534.12 avail, 534.12 pend union all
  select 'SAV' prod_cd, (now() - interval '53 DAY')::date AS open_date, (now() - interval '225 DAY')::date AS last_date,
    767.77 avail, 767.77 pend union all
  select 'MM' prod_cd, (now() - interval '231 DAY')::date AS open_date, (now() - interval '400 DAY')::date AS last_date,
    5487.09 avail, 5487.09 pend) a
where c.fed_id = '444-44-4444';

insert into account (product_cd, cust_id, open_date,
  last_activity_date, status, open_branch_id,
  open_emp_id, avail_balance, pending_balance)
select a.prod_cd, c.cust_id, a.open_date, a.last_date, 'ACTIVE',
  e.branch_id, e.emp_id, a.avail, a.pend
from customer c cross join 
 (select b.branch_id, e.emp_id 
  from branch b inner join employee e on e.assigned_branch_id = b.branch_id
  where b.city = 'Salem' limit 1) e
  cross join
 (select 'CHK' prod_cd, (now() - interval '31 DAY')::date AS open_date, (now() - interval '44 DAY')::date AS last_date,
    2237.97 avail, 2897.97 pend) a
where c.fed_id = '555-55-5555';

insert into account (product_cd, cust_id, open_date,
  last_activity_date, status, open_branch_id,
  open_emp_id, avail_balance, pending_balance)
select a.prod_cd, c.cust_id, a.open_date, a.last_date, 'ACTIVE',
  e.branch_id, e.emp_id, a.avail, a.pend
from customer c cross join 
 (select b.branch_id, e.emp_id 
  from branch b inner join employee e on e.assigned_branch_id = b.branch_id
  where b.city = 'Waltham' limit 1) e
  cross join
 (select 'CHK' prod_cd, (now() - interval '3 DAY')::date AS open_date, (now() - interval '15 DAY')::date AS last_date,
    122.37 avail, 122.37 pend union all
  select 'CD' prod_cd, (now() - interval '42 DAY')::date AS open_date, (now() - interval '66 DAY')::date AS last_date,
    10000.00 avail, 10000.00 pend) a
where c.fed_id = '666-66-6666';

insert into account (product_cd, cust_id, open_date,
  last_activity_date, status, open_branch_id,
  open_emp_id, avail_balance, pending_balance)
select a.prod_cd, c.cust_id, a.open_date, a.last_date, 'ACTIVE',
  e.branch_id, e.emp_id, a.avail, a.pend
from customer c cross join 
 (select b.branch_id, e.emp_id 
  from branch b inner join employee e on e.assigned_branch_id = b.branch_id
  where b.city = 'Woburn' limit 1) e
  cross join
 (select 'CD' prod_cd, (now() - interval '28 DAY')::date AS open_date, (now() - interval '56 DAY')::date AS last_date,
    5000.00 avail, 5000.00 pend) a
where c.fed_id = '777-77-7777';

insert into account (product_cd, cust_id, open_date,
  last_activity_date, status, open_branch_id,
  open_emp_id, avail_balance, pending_balance)
select a.prod_cd, c.cust_id, a.open_date, a.last_date, 'ACTIVE',
  e.branch_id, e.emp_id, a.avail, a.pend
from customer c cross join 
 (select b.branch_id, e.emp_id 
  from branch b inner join employee e on e.assigned_branch_id = b.branch_id
  where b.city = 'Salem' limit 1) e
  cross join
 (select 'CHK' prod_cd, (now() - interval '22 DAY')::date AS open_date, (now() - interval '55 DAY')::date AS last_date,
    3487.19 avail, 3487.19 pend union all
  select 'SAV' prod_cd, (now() - interval '58 DAY')::date AS open_date, (now() - interval '77 DAY')::date AS last_date,
    387.99 avail, 387.99 pend) a
where c.fed_id = '888-88-8888';

insert into account (product_cd, cust_id, open_date,
  last_activity_date, status, open_branch_id,
  open_emp_id, avail_balance, pending_balance)
select a.prod_cd, c.cust_id, a.open_date, a.last_date, 'ACTIVE',
  e.branch_id, e.emp_id, a.avail, a.pend
from customer c cross join 
 (select b.branch_id, e.emp_id 
  from branch b inner join employee e on e.assigned_branch_id = b.branch_id
  where b.city = 'Waltham' limit 1) e
  cross join
 (select 'CHK' prod_cd, (now() - interval '18 DAY')::date AS open_date, (now() - interval '90 DAY')::date AS last_date,
    125.67 avail, 125.67 pend union all
  select 'MM' prod_cd, (now() - interval '225 DAY')::date AS open_date, (now() - interval '270 DAY')::date AS last_date,
    9345.55 avail, 9845.55 pend union all
  select 'CD' prod_cd, (now() - interval '61 DAY')::date AS open_date, (now() - interval '332 DAY')::date AS last_date,
    1500.00 avail, 1500.00 pend) a
where c.fed_id = '999-99-9999';

/* corporate account data */

insert into account (product_cd, cust_id, open_date,
  last_activity_date, status, open_branch_id,
  open_emp_id, avail_balance, pending_balance)
select a.prod_cd, c.cust_id, a.open_date, a.last_date, 'ACTIVE',
  e.branch_id, e.emp_id, a.avail, a.pend
from customer c cross join 
 (select b.branch_id, e.emp_id 
  from branch b inner join employee e on e.assigned_branch_id = b.branch_id
  where b.city = 'Salem' limit 1) e
  cross join
 (select 'CHK' prod_cd, (now() - interval '108 DAY')::date AS open_date, (now() - interval '333 DAY')::date AS last_date,
    23575.12 avail, 23575.12 pend union all
  select 'BUS' prod_cd, (now() - interval '12 DAY')::date AS open_date, (now() - interval '148 DAY')::date AS last_date,
    0 avail, 0 pend) a
where c.fed_id = '04-1111111';

insert into account (product_cd, cust_id, open_date,
  last_activity_date, status, open_branch_id,
  open_emp_id, avail_balance, pending_balance)
select a.prod_cd, c.cust_id, a.open_date, a.last_date, 'ACTIVE',
  e.branch_id, e.emp_id, a.avail, a.pend
from customer c cross join 
 (select b.branch_id, e.emp_id 
  from branch b inner join employee e on e.assigned_branch_id = b.branch_id
  where b.city = 'Woburn' limit 1) e
  cross join
 (select 'BUS' prod_cd, (now() - interval '4 DAY')::date AS open_date, (now() - interval '31 DAY')::date AS last_date,
    9345.55 avail, 9345.55 pend) a
where c.fed_id = '04-2222222';
insert into account (product_cd, cust_id, open_date,
  last_activity_date, status, open_branch_id,
  open_emp_id, avail_balance, pending_balance)
select a.prod_cd, c.cust_id, a.open_date, a.last_date, 'ACTIVE',
  e.branch_id, e.emp_id, a.avail, a.pend
from customer c cross join 
 (select b.branch_id, e.emp_id 
  from branch b inner join employee e on e.assigned_branch_id = b.branch_id
  where b.city = 'Salem' limit 1) e
  cross join
 (select 'CHK' prod_cd, (now() - interval '18 DAY')::date AS open_date, (now() - interval '33 DAY')::date AS last_date,
    38552.05 avail, 38552.05 pend) a
where c.fed_id = '04-3333333';

insert into account (product_cd, cust_id, open_date,
  last_activity_date, status, open_branch_id,
  open_emp_id, avail_balance, pending_balance)
select a.prod_cd, c.cust_id, a.open_date, a.last_date, 'ACTIVE',
  e.branch_id, e.emp_id, a.avail, a.pend
from customer c cross join 
 (select b.branch_id, e.emp_id 
  from branch b inner join employee e on e.assigned_branch_id = b.branch_id
  where b.city = 'Quincy' limit 1) e
  cross join
 (select 'SBL' prod_cd, (now() - interval '48 DAY')::date AS open_date, (now() - interval '78 DAY')::date AS last_date,
    50000.00 avail, 50000.00 pend) a
where c.fed_id = '04-4444444';

/* put $100 in all checking/savings accounts on date account opened */

insert into transaction (txn_date, account_id, txn_type_cd,
  amount, funds_avail_date)
select a.open_date, a.account_id, 'CDT', 100, a.open_date
from account a
where a.product_cd IN ('CHK','SAV','CD','MM');

/* end*/
