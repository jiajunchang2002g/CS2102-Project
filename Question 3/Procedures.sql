CREATE OR REPLACE PROCEDURE rent_solo 
(IN car VARCHAR(8), IN customer CHAR(9), IN start_date DATE, IN end_date DATE)
 AS
 $$
 BEGIN
 INSERT INTO rent VALUES (customer, car, start_date, end_date);
 END
 $$ LANGUAGE plpgsql;

 CREATE OR REPLACE PROCEDURE rent_group
 (IN car VARCHAR(8), IN customer CHAR(9), 
 IN start_date DATE, IN end_date DATE, 
 IN passenger1 CHAR(9), IN passenger2 CHAR(9),
 IN passenger3 CHAR(9), IN passenger4 CHAR(9))
 AS
 $$
 BEGIN
 INSERT INTO rent VALUES 
 (passenger1, car, start_date, end_date),
 (passenger2, car, start_date, end_date),
 (passenger3, car, start_date, end_date),
 (passenger4, car, start_date, end_date); 
 END
 $$ LANGUAGE plpgsql;