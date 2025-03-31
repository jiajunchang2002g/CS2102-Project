/* constraint 1 */

CREATE OR REPLACE FUNCTION check_valid_rental()
RETURNS TRIGGER AS $$
DECLARE count INT;
BEGIN
    SELECT COUNT(*) INTO count
    FROM rent
    WHERE (plate = NEW.plate
    AND start_date <= NEW.end_date
    AND end_date >= NEW.start_date);

    IF count > 0 THEN 
	RAISE EXCEPTION 'The same car cannot be rented on two different rent with overlapping dates';
	END IF;
	RETURN NEW;
	
END; $$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER on_rent_date AFTER INSERT OR UPDATE ON rent
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION check_valid_rental();

/* constraint 2 */
CREATE OR REPLACE FUNCTION check_diff_car_overlap_date()
RETURNS TRIGGER AS $$
DECLARE count INT;
BEGIN
    SELECT COUNT(*) INTO count
    FROM rent 
    WHERE (r.passenger = NEW.passenger
	AND NOT r.plate = NEW.plate
    AND start_date < NEW.end_date
    AND end_date > NEW.start_date);
	
    IF count > 0 THEN 
	RAISE EXCEPTION 'A passenger cannot be on two different cars rented with overlapping dates.';
	END IF;
	RETURN NEW;
	
END; $$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER on_ride_car_date AFTER INSERT OR UPDATE ON ride
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION check_diff_car_overlap_date();

/* contraint 3 */

CREATE OR REPLACE FUNCTION check_sufficient_capacity()
RETURNS TRIGGER AS $$
DECLARE max INT; count INT;
BEGIN
    SELECT COUNT(*) INTO count
    FROM ride
    WHERE (plate = NEW.plate
    AND start_date = NEW.end_date
    AND end_date = NEW.start_date);

    IF count > max THEN 
	RAISE EXCEPTION 'The number of passengers is more than the capacity of the car.';
 	END IF;
	RETURN NEW;
	
END; $$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER on_ride_capacity AFTER INSERT OR UPDATE ON ride
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION check_sufficient_capacity();

/* constraint 4 */
CREATE OR REPLACE FUNCTION check_license()
RETURNS TRIGGER AS $$
DECLARE count INT;
BEGIN
    SELECT COUNT(*) INTO count
    FROM ride r, customer c 
    WHERE (r.plate = NEW.plate
    AND r.start_date = NEW.end_date
    AND r.end_date = NEW.start_date
	AND r.passenger = c.nric
	AND c.license = TRUE);
	
    IF count = 0 THEN 
	RAISE EXCEPTION 'One or more of the passengers must have driver’s licenses.';
	END IF;
	RETURN NEW;
	
END; $$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER on_ride_license AFTER INSERT OR UPDATE ON ride
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION check_license();