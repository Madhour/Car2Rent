--map car to branch to address and map car to price (thats relevant for later when car is plotted on map)
CREATE VIEW car_overview AS
SELECT  c.n_car_id Car_id,
        c.s_brand Car_brand, 
        p.n_price_per_day Price,
        p.s_price_class Price_Class,
        a.s_street || ' ' || a.s_house_number Current_Location,
        a.n_zipcode Zipcode
FROM car AS c
LEFT JOIN price AS p ON (c.n_price_id = p.n_price_id)
LEFT JOIN branch AS b ON (c.n_branch_id = b.n_branch_id)
LEFT JOIN addresses AS a ON (b.n_address_id = a.n_address_id)
GROUP BY Car_id, Price, Price_Class, Current_Location, Zipcode;


--creates an overview of all sales made by one employee