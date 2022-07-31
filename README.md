# Learning-SQL using Postgres instead of Mysql



Example code for Learning SQL by Alan Beaulieu 2nd ed. modified to suit Postgres

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
