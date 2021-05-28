-- constraint: customer can only rent one car at a time and only if that car is free
create or replace procedure rent_car( 
    carID INT,
    customerID INT,
    employeeID INT,
    duration INT
)
language plpgsql
AS '
BEGIN
    --if car is available
    IF (SELECT b_is_available
        FROM CAR
        WHERE   CAR.n_car_id = carID) 
        AND NOT
        (SELECT count(*)
        FROM RENT
        WHERE RENT.n_customer_id = customerID AND RENT.b_is_returned = false) > 0
    THEN
        -- set car to unavailable if it is rented
        UPDATE CAR
        SET b_is_available = false
        WHERE CAR.n_car_id = carID;

        -- because car is rented, one more parking space is added to the branch
        UPDATE BRANCH
        SET n_parking_spaces = n_parking_spaces + 1
        WHERE n_branch_id = (SELECT n_branch_id FROM CAR WHERE CAR.n_car_id = carID);

        -- after the car is set as unavailable, a new rent has to be created
        INSERT INTO RENT (n_car_id, n_duration, n_customer_id, n_employee_id, b_is_returned)
        VALUES
        (carID, duration, customerID, employeeID, false);
    
    ELSE 
        -- This error leads to ROLLBACK
        RAISE EXCEPTION ''car is not available/ customer already has an active rent''; 
    END IF;

END;'
;



CREATE OR REPLACE FUNCTION car_returned()
	RETURNS TRIGGER
	LANGUAGE PLPGSQL
	AS '
		BEGIN			
			IF new.b_is_returned
            
            THEN

            /*
            --set return date and mileage after rent
		    UPDATE RENT
			SET d_date_returned = CURRENT_DATE
		   	WHERE RENT.n_rent_id = new.n_rent_id;
            */

                --check if free mileage was exceeded and create new payment if yes
                IF (new.n_mileage_returned - (select n_mileage FROM CAR WHERE CAR.n_car_id = new.n_car_id)) > new.n_free_kilometers

                THEN 

                INSERT INTO PAYMENT (n_rent_id, n_payment_amount)
                VALUES
                (new.n_rent_id, ((new.n_mileage_returned - (select n_mileage FROM CAR WHERE CAR.n_car_id = new.n_car_id)) * 
                (select price.n_price_per_kilometer FROM CAR LEFT JOIN PRICE ON (CAR.n_price_id = PRICE.n_price_id) where CAR.n_car_id = new.n_car_id)));

                END IF;


            --update car mileage
            UPDATE CAR
            SET 
             n_mileage = new.n_mileage_returned,
             b_is_available = true
            WHERE CAR.n_car_id = new.n_car_id;

            --update branch parking space
            UPDATE BRANCH
            SET n_parking_spaces = n_parking_spaces - 1
            WHERE BRANCH.n_branch_id = (select n_branch_id from RENT LEFT JOIN CAR ON (RENT.n_car_id = CAR.n_car_id) where CAR.n_car_id = new.n_car_id);

	   	    END IF;
	   	
	   	RETURN NEW;
		END;
		';