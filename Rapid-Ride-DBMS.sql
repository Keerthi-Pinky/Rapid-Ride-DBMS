SET SERVEROUTPUT ON;

DROP TABLE Payments;
DROP TABLE Trips;
DROP TABLE Distances;
DROP TABLE Vehicles;
DROP TABLE Vehicle_Owners;
DROP TABLE Vehicle_Types;
DROP TABLE Customers;

DROP SEQUENCE cust_id_seq;
DROP SEQUENCE VEHICLES_SEQ;
DROP sequence VEHICLE_OWNERS_SEQ;
DROP SEQUENCE Distance_Seq;
DROP SEQUENCE Trips_seq;
DROP SEQUENCE payment_seq;

CREATE TABLE Customers (
Customer_ID int,
Customer_name varchar(25),
Customer_email_ID varchar(25),
CreditCard Number,
Primary Key (Customer_ID)
);

CREATE TABLE Vehicle_Types (
Vehicle_type varchar(25), 
Rate_per_mile int,
Primary Key (Vehicle_type)
);

CREATE TABLE Vehicle_Owners (
Owner_ID int,
Name varchar(25),
Email varchar(25),
CreditCard number,
active varchar(5),
Primary Key (Owner_ID),
CONSTRAINT UC1_VEH_OWNERS UNIQUE(Email)
);

CREATE TABLE Vehicles (
Vehicle_ID int,
Owner_ID int,
Vehicle_type varchar(25),
Make varchar(25),
Year number,
Tag_number number,
State varchar(25),
Seating_capacity number,
Luggage_capacity number,
latest_location varchar(50),
active varchar(5),
Primary Key (Vehicle_ID),
constraint FK1_VEH FOREIGN KEY (Owner_ID) REFERENCES VEHICLE_OWNERS(Owner_ID),
constraint FK2_VEH FOREIGN KEY (Vehicle_type) REFERENCES VEHICLE_TYPES(Vehicle_type)
);

CREATE TABLE Distances (
Distance_ID int,
Source_town varchar(25),
Source_state varchar(25),
Destination_town varchar(25),
Destination_State varchar(25),
Distance float,
States_crossed int, 
Primary Key (Distance_ID)
);

CREATE TABLE Trips (
Trip_ID int,
Customer_ID int,
Owner_ID int,
Distance_ID int,
Source_town varchar(25),
Source_state varchar(25),
Destination_town varchar(25),
Destination_State varchar(25),
DateOfTrip date,
Vehicle_tag number, 
Num_of_passengers int, 
Luggage_amount int, 
PaymentAmount float, 
Primary Key (Trip_ID),
Foreign Key (Customer_ID) References Customers (Customer_ID),
Foreign Key (Owner_ID) References Vehicle_Owners (Owner_ID),
Foreign Key (Distance_ID) References Distances (Distance_ID)
);

CREATE TABLE Payments (
Payment_ID int,
PaymentSide varchar(25) CHECK (PaymentSide IN ('Customer', 'Owner')),
Trip_ID int,
Customer_ID int,
Owner_ID int,
PaymentAmount float, 
Primary Key (Payment_ID),
Foreign Key (Trip_ID) References Trips (Trip_ID),
Foreign Key (Customer_ID) References Customers (Customer_ID),
Foreign Key (Owner_ID) References Vehicle_Owners (Owner_ID)
);


CREATE SEQUENCE cust_id_seq START WITH 5 INCREMENT BY 1;
CREATE SEQUENCE Distance_Seq START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE VEHICLE_OWNERS_SEQ START WITH 1000 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE VEHICLES_SEQ START WITH 2000 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE Trips_SEQ START WITH 5000 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE payment_seq START WITH 1 INCREMENT BY 1;


-- start of procedure definitions
-- start of member 1 procedures
CREATE OR REPLACE PROCEDURE add_owner(p_owner_name vehicle_owners.name%type,p_owner_email vehicle_owners.email%type,p_owner_cc vehicle_owners.CreditCard%type,p_active varchar)
IS
begin
insert into VEHICLE_OWNERS values(VEHICLE_OWNERS_SEQ.NEXTVAL,p_owner_name,p_owner_email,p_owner_cc,p_active);
 
end;

/

CREATE OR REPLACE PROCEDURE get_owner_id(p_owner_email vehicle_owners.email%type)
IS
P_ID int;
begin
select vehicle_owners.owner_id INTO P_ID from vehicle_owners where p_owner_email= email;
dbms_output.put_line(p_id);
end;

/

CREATE OR REPLACE PROCEDURE delete_vehicle(p_owner_email vehicle_owners.email%type)
IS
begin
update vehicle_owners
set active='N'
where vehicle_owners.email=p_owner_email;
UPDATE vehicles set ACTIVE = 'N' where OWNER_ID = (SELECT OWNER_ID FROM vehicle_owners where EMAIL = p_owner_email );
Exception
        when no_data_found then
        Dbms_output.put_line('no rows found');
when too_many_rows then
        dbms_output.put_line('too many rows');
WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE ('error');
end;

/

CREATE OR REPLACE PROCEDURE insertVEHICLES(
p_veh_owner_id IN vehicles.owner_id%TYPE,
p_veh_type IN vehicles.vehicle_type%TYPE,
p_make IN vehicles.make%TYPE,
p_year IN vehicles.year%TYPE,
p_tagnum IN vehicles.tag_number%TYPE,
p_state IN vehicles.state%TYPE,
p_seating_cap IN vehicles.seating_capacity%TYPE,
p_luggage_cap IN vehicles.luggage_capacity%TYPE,
p_latest_location IN vehicles.latest_location%TYPE,
p_active varchar)
IS
BEGIN

INSERT INTO VEHICLES 
VALUES (vehicles_seq.nextval, p_veh_owner_id, p_veh_type, p_make,
p_year,p_tagnum,p_state,p_seating_cap,p_luggage_cap,p_latest_location,p_active);

COMMIT;
END;

/


CREATE OR REPLACE PROCEDURE displayVehicles(p_veh_type IN Vehicles.vehicle_type%TYPE)
IS
z_ID vehicles.vehicle_id%type;
z_Type vehicles.vehicle_type%type;
z_Make vehicles.make%type;
z_Year vehicles.year%type;
z_TagNumber vehicles.tag_number%type;
z_State vehicles.state%type;
z_LuggageCapacity vehicles.luggage_capacity%type;
z_SeatingCapacity vehicles.seating_capacity%type;
z_LastLocation vehicles.latest_location%type;
z_name varchar(25);
CURSOR C IS
SELECT V.vehicle_id,V.vehicle_type,V.make,V.year,V.tag_number,V.state,V.luggage_capacity,V.seating_capacity,V.latest_location,O.name
FROM vehicles V, vehicle_owners O
WHERE vehicle_type = p_veh_type AND V.owner_id=O.owner_id;
BEGIN
OPEN C;
LOOP
FETCH C INTO z_id,z_type,z_make,z_year,z_tagnumber,z_state,z_luggagecapacity,z_seatingcapacity,z_lastlocation,z_name;
EXIT WHEN C%NOTFOUND;
dbms_output.put_line('Vehicle ID: ' || z_id ||' Owner Name: ' || z_name ||' Vehicle Type: '||
z_type || ' Vehicle Make: ' || z_make || ' Year: ' || z_year || ' Tag Number: ' || z_tagnumber
|| ' State: ' || z_state || ' Seating Capactiy: ' || z_seatingcapacity || ' Luggage Capacity: ' 
||z_luggagecapacity || ' Last Location: ' || z_lastlocation);
END LOOP;
END;

/

CREATE OR REPLACE PROCEDURE displayStates
AS
    p_state vehicles.state%TYPE;
    p_count int;
    CURSOR C IS
    select state,count(*) from vehicles group by state;
BEGIN
    OPEN C;
    LOOP
    FETCH C INTO p_state,p_count;
    EXIT WHEN C%NOTFOUND;
    dbms_output.put_line(p_state ||':    '|| p_count);
    END LOOP;
END;

/
-- start of member 2 procedures

CREATE OR REPLACE FUNCTION AddACustomer(
Name CUSTOMERS.Customer_name%TYPE,  
email CUSTOMERS.Customer_email_ID%TYPE,  
Customer_CreditCard CUSTOMERS.CreditCard%TYPE)    
RETURN Number
IS  
BEGIN  
INSERT INTO CUSTOMERS(Customer_ID, Customer_name, Customer_email_ID, CreditCard)  
VALUES (cust_id_seq.nextval, Name, email, Customer_CreditCard);  
COMMIT; 
Return 1;
END;
  
/

CREATE OR REPLACE FUNCTION DeleteACustomer(email in varchar) 
RETURN Number
IS 
BEGIN 
DELETE 
FROM CUSTOMERS 
WHERE Customer_email_ID = email; 
RETURN 1; 
	  
EXCEPTION
when no_data_found then
dbms_output.put_line('no such employee');
END;

/

CREATE OR REPLACE FUNCTION FindCustomerID(email in varchar) 
RETURN Number 
IS 
cust_id int;
BEGIN 
SELECT Customer_ID into cust_id from CUSTOMERS where Customer_email_ID = email;
RETURN cust_id; 
	  
EXCEPTION
when no_data_found then
dbms_output.put_line('no such employee');
END;

/

--Function definition to update creditcard of the customer
CREATE OR REPLACE FUNCTION UpdateCreditCard(Cust_ID in CUSTOMERS.Customer_ID%TYPE, Customer_CreditCard in CUSTOMERS.CreditCard%TYPE)                                            
RETURN Number                                                                                
IS
BEGIN  
UPDATE CUSTOMERS
SET CreditCard = Customer_CreditCard
where Customer_ID = Cust_ID;
Return 1;                                                                                    
END;
/

--Procedure definition of the bottom 3 customers who spent the least amount of money with RapidRide
CREATE OR REPLACE PROCEDURE WorstCustomer(ErrorCode OUT int)                                            
IS  
cursor c1 is select SUM(P.PaymentAmount),C.customer_ID
FROM CUSTOMERS C, Payments P
where P.customer_ID = C.customer_ID and P.PaymentSide = 'Owner' and ROWNUM<=3   --rownum<=3 fetches the first 3 results
GROUP BY C.customer_ID                                                          -- Grouping by customer_id because the same customer can take ride from RapidRide several times
ORDER BY SUM(PaymentAmount) asc;                                                -- sorting them in ascending order because we need to fetch the 3 customers who spent the least
cust_id int;
Amount float;
BEGIN  
ErrorCode := 1;

	OPEN c1;
    		DBMS_output.put_line('The customers who spent the least amount of money with RapidRide are :');
	LOOP
		FETCH c1 into Amount,cust_id;
		EXIT WHEN c1%NOTFOUND;
		DBMS_output.put_line('Customer ID :' || ' ' || cust_id || ' ' || 'with' || ' ' || 'Payment Amount :' || Amount);
	END LOOP;
	CLOSE c1;

	EXCEPTION 
		WHEN others THEN
		ErrorCode := 0;
END;

/

--Procedure definition of the top 3 customers who spent the most amount of money with RapidRide
CREATE OR REPLACE PROCEDURE BestCustomer(ErrorCode OUT int)                                            
IS  
cursor c1 is select SUM(P.PaymentAmount),C.customer_ID
FROM CUSTOMERS C, Payments P
where P.customer_ID = C.customer_ID and P.PaymentSide = 'Owner' and ROWNUM<=3       --rownum<=3 fetches the first 3 results
GROUP BY C.customer_ID                                                              -- Grouping by customer_id because the same customer can take ride from RapidRide several times
ORDER BY SUM(PaymentAmount) desc;                                                   -- sorting them in descending order because we need to fetch the 3 customers who spent the most
cust_id int;
Amount float;
BEGIN  
ErrorCode := 1;

	OPEN c1;
    		DBMS_output.put_line('The customers who spent the most amount of money with RapidRide are : ');
	LOOP
		FETCH c1 into Amount,cust_id;
		EXIT WHEN c1%NOTFOUND;
		DBMS_output.put_line('Customer ID :' || ' ' || cust_id || ' ' || 'with' || ' ' || 'Payment Amount :' || Amount);
	END LOOP;
	CLOSE c1;

	EXCEPTION 
		WHEN others THEN
		ErrorCode := 0;
END;

/
-- start of member 3 procedure

CREATE OR REPLACE PROCEDURE AddNewDistance(
    Source_Town IN VARCHAR,
    Source_State IN VARCHAR,
    Destination_Town IN VARCHAR,
    Destination_State IN VARCHAR,
    States_crossed IN int,
    Distance IN FLOAT)
IS
BEGIN
    INSERT INTO Distances VALUES(
        Distance_Seq.NEXTVAL, Source_Town, Source_State, Destination_Town, Destination_State, Distance, States_Crossed     
    );
END;

/

CREATE OR REPLACE PROCEDURE ListOneLegDestinations(
    Starting_Point IN VARCHAR,
    ErrorCode OUT INT
)
AS
    CURSOR c_destinations IS SELECT Destination_Town, Distance FROM Distances 
    WHERE Source_Town = Starting_Point;
    Destination VARCHAR(25);
    Distance FLOAT;
BEGIN
    ErrorCode := 1;
    OPEN c_destinations;
    LOOP
        FETCH c_destinations INTO Destination, Distance;
        IF c_destinations%NOTFOUND
        THEN
            RAISE no_data_found;
            EXIT;
        END IF;
        DBMS_output.put_line(Destination || ' - ' || Distance || ' Miles');
    END LOOP;
    CLOSE c_destinations;
EXCEPTION
    WHEN OTHERS THEN
        ErrorCode := 0;
END;

/

CREATE OR REPLACE PROCEDURE ListAvailableRides(
    Starting_Point IN VARCHAR,
    Ending_Point IN VARCHAR,
    Seats_Required IN INT,
    Luggage_quantity IN INT,
    ErrorCode OUT INT
)
AS
Record_Found BOOLEAN := FALSE;
CURSOR c1 IS SELECT Vehicles.Vehicle_type, Vehicles.Seating_capacity, Vehicles.Luggage_capacity, Vehicles.tag_number from Vehicles, Distances
WHERE lower(Vehicles.latest_location) = lower(Starting_Point) 
AND Vehicles.Seating_capacity >= Seats_Required 
AND Vehicles.Luggage_capacity >= Luggage_quantity AND Vehicles.active='Y'
AND lower(Vehicles.latest_location) = lower(Distances.Source_Town)
AND lower(Distances.Destination_Town) = lower(Ending_Point);
BEGIN
    ErrorCode := 1;
    DBMS_output.put_line('Input Data -  Starting Point :' || Starting_Point||' , Ending Point: '|| Ending_Point ||' , Seats Required:'||Seats_Required||' , Luggage Quantity:'||Luggage_quantity);
    DBMS_output.put_line('List of Available Rides : ');
    FOR r_vehicles IN c1 LOOP
        record_found := TRUE;
        DBMS_output.put_line('Vehicle Type: '|| r_vehicles.Vehicle_type ||',  Vehicle Tag: '|| r_vehicles.tag_number ||',  Seating Capacity: '|| r_vehicles.Seating_capacity||',  Luggage Capacity: '|| r_vehicles.Luggage_capacity);
    END LOOP;
    IF record_found = FALSE THEN
          DBMS_output.put_line('No rides available as per requirement');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        ErrorCode := 0;
END;

/

-- start of member 4 procedures

CREATE OR REPLACE PROCEDURE RECORDTRIP (
    t_Customer_name customers.Customer_name%type,
    t_Owner_name vehicle_owners.name%type,
    t_Source_town distances.source_town%type,
    t_Source_state distances.source_state%type,
    t_Destination_Town distances.destination_town%type,
    t_Destination_State distances.destination_state%type,
    t_dateoftrip trips.dateoftrip%type,
    t_vehicle_id vehicles.vehicle_id%type,
    t_num_of_passengers trips.num_of_passengers%type,
    t_luggage_amount trips.luggage_amount%type,
    t_Paymentamount trips.paymentamount%type)
IS
BEGIN
    INSERT INTO Trips VALUES(
        Trips_Seq.NEXTVAL,(select Customer_id from customers where Customer_name=t_Customer_name),
        (select Owner_id from vehicle_owners where name=t_Owner_name),
        (select distance_id from distances where Source_Town=t_Source_Town and Source_State=t_Source_State and 
        Destination_Town=t_Destination_Town and Destination_State=t_Destination_State ),
        t_Source_Town, t_Source_State, 
        t_Destination_Town, t_Destination_State, t_DateofTrip,
		(select tag_number from vehicles where vehicle_id=t_vehicle_id),
		t_num_of_passengers, 
		t_luggage_amount,
        t_PaymentAmount  
    );
END;

/

Create or replace procedure return_trip_id (
    t_Customer_name customers.Customer_name%type,
    t_Owner_name vehicle_owners.name%type,
    t_Source_town distances.source_town%type,
    t_Source_state distances.source_state%type,
    t_Destination_Town distances.destination_town%type,
    t_Destination_State distances.destination_state%type,
    t_dateoftrip trips.dateoftrip%type)
IS
t_id trips.trip_id%type;
BEGIN
select trip_id into t_id from trips where customer_id=(select customer_id from customers where customer_name=t_customer_name) and owner_id=(select Owner_id from vehicle_owners where name=t_Owner_name) and 
Source_town=t_Source_town and Source_state=t_Source_state and Destination_Town=t_Destination_Town and Destination_State=t_Destination_State and
dateoftrip=t_dateoftrip;

dbms_output.put_line('TRIP_ID is: ' || t_id);

EXCEPTION

when no_data_found then
dbms_output.put_line('no such trip found');

end;

/
-- start of member 5 procedures

CREATE OR REPLACE PROCEDURE CalculatePayment(Distance IN float, Num_of_passengers IN int,
Luggage IN int, Car_value IN int, Tolls IN int, Total OUT float) IS
Tip_Amount decimal(19,4);
BEGIN
	Tip_Amount := .15 * ((distance*Car_value*Num_of_passengers) + (5*Luggage) + (20*Tolls));
	Total := (distance*Car_value*Num_of_passengers) + (5*Luggage) + (20*Tolls) + Tip_Amount;
END;

/

CREATE OR REPLACE PROCEDURE ChargeCustomer(t_TripID IN int, t_CustomerEmail IN varchar, t_OwnerEmail IN varchar,
ErrorCode OUT int) IS
	Amount int;
	CustPayment int;
	t_CustomerID int;
	t_OwnerID int;
	d_Distance float;
	d_Num_of_passengers int;
	d_Luggage int;
	d_Car_value int;
	Tolls int;
BEGIN
	ErrorCode := 1;
	
	SELECT T.Customer_ID,T.Owner_ID,Distance,Num_of_passengers,Luggage_amount,Rate_per_mile,States_crossed
	INTO t_CustomerID,t_OwnerID,d_Distance,d_Num_of_passengers,d_Luggage,d_Car_value,Tolls
	FROM Trips T, Customers C, Vehicle_Owners O, Distances D, Vehicles V, Vehicle_Types Z
	WHERE T.Trip_ID=t_TripID 
              AND C.Customer_email_ID=t_CustomerEmail 
              AND O.Email=t_OwnerEmail 
	      AND T.Customer_ID=C.Customer_ID 
              AND T.Owner_ID=O.Owner_ID 
              AND T.Distance_ID=D.Distance_ID 
              AND T.Vehicle_tag=V.Tag_number 
              AND V.Vehicle_type=Z.Vehicle_type;
	
	CalculatePayment(d_Distance,d_Num_of_passengers,d_Luggage,d_Car_value,Tolls,Amount);
	CustPayment := Amount * -1;
	
	INSERT INTO Payments(Payment_ID,PaymentSide,Trip_ID,Customer_ID,Owner_ID,PaymentAmount)
	VALUES (payment_seq.nextval,'Owner',t_TripID,t_CustomerID,t_OwnerID,Amount);
	INSERT INTO Payments(Payment_ID,PaymentSide,Trip_ID,Customer_ID,Owner_ID,PaymentAmount)
	VALUES (payment_seq.nextval,'Customer',t_TripID,t_CustomerID,t_OwnerID,CustPayment);
	
	UPDATE Trips SET PaymentAmount=Amount WHERE Trip_ID=t_TripID;
	
	EXCEPTION 
		WHEN others THEN
		ErrorCode := 0;
END;

/

CREATE OR REPLACE PROCEDURE FindTotalRevenue(TotalRevenue OUT float) IS
	CURSOR c1 IS SELECT PaymentAmount FROM Payments WHERE PaymentSide='Owner';
	d_PaymentAmount float;
BEGIN
	TotalRevenue := 0;
	
	OPEN c1;
	LOOP
		FETCH c1 INTO d_PaymentAmount;
		EXIT WHEN c1%NOTFOUND;
		TotalRevenue := TotalRevenue + d_PaymentAmount;
	END LOOP;
	CLOSE c1;
	
	DBMS_output.put_line('Total Revenue: ' || TotalRevenue);
END;

/

CREATE OR REPLACE PROCEDURE GenerateRevenueReportDest(ErrorCode OUT int) IS
	CURSOR c1 IS SELECT SUM(T.PaymentAmount), T.Destination_town FROM Payments P, Trips T 
	WHERE P.Trip_ID=T.Trip_ID GROUP BY T.Destination_Town;
	Total float;
	Town varchar(25);
BEGIN
	ErrorCode := 1;

	OPEN c1;
	LOOP
		FETCH c1 into Total,Town;
		EXIT WHEN c1%NOTFOUND;
		DBMS_output.put_line(Total || ' has been earned from trips to ' || Town);
	END LOOP;
	CLOSE c1;

	EXCEPTION 
		WHEN others THEN
		ErrorCode := 0;
END;

/

CREATE OR REPLACE PROCEDURE GenerateRevenueReportDept(ErrorCode OUT int) IS
	CURSOR c1 IS SELECT SUM(T.PaymentAmount), T.Source_town FROM Payments P, Trips T
	WHERE P.Trip_ID=T.Trip_ID AND PaymentSide='Owner'
	GROUP BY T.Source_town;
	Total float;
	Town varchar(25);
BEGIN
	ErrorCode := 1;

	-- print a list of source towns and the total amount of money earned from them as found in the cursor query
	OPEN c1;
	LOOP
		FETCH c1 into Total,Town;
		EXIT WHEN c1%NOTFOUND;
		DBMS_output.put_line('$' || Total || ' has been earned from trips from ' || Town);
	END LOOP;
	CLOSE c1;

	-- return an error code to indicate any exceptions
	EXCEPTION
		WHEN others THEN
		ErrorCode := 0;
END;

/

CREATE OR REPLACE PROCEDURE ViewCustomerPayments(CustomerName IN varchar, ErrorCode OUT int) IS
	CURSOR c1 is SELECT C.Customer_name, P.Trip_ID, P.PaymentAmount FROM Payments P, Customers C
	WHERE P.PaymentSide='Customer' AND C.Customer_name=CustomerName AND P.Customer_ID=C.Customer_ID;
	eCustomer_name varchar(25);
	eTrip_ID int;
	ePaymentAmount float;
BEGIN
	ErrorCode := 1;
	-- print out a list of payments made by a specific customer as retrieved by the cursor query
	OPEN c1;
	LOOP
		FETCH c1 into eCustomer_name, eTrip_ID, ePaymentAmount;
		EXIT WHEN c1%NOTFOUND;
		DBMS_output.put_line('Customer: ' || eCustomer_name || ' Trip ID: ' || eTrip_ID || ' Payment Amount: ' || '$' || ePaymentAmount);
	END LOOP;
	CLOSE c1;
	-- return an error code to indicate any exceptions
	EXCEPTION
		WHEN others THEN
		ErrorCode := 0;
END;

/

CREATE OR REPLACE PROCEDURE ViewOwnerPayments(OwnerName IN varchar, ErrorCode OUT int) IS
	CURSOR c1 is SELECT V.Name, P.Trip_ID, P.PaymentAmount FROM Payments P, Vehicle_Owners V
	WHERE P.PaymentSide='Owner' AND V.Name=OwnerName AND V.Owner_ID=P.Owner_ID;
	eOwner_name varchar(25);
	eTrip_ID int;
	ePaymentAmount float;
BEGIN
	ErrorCode := 1;
	-- print out a list of payments made to a specific owner as retrieved by the cursor query
	OPEN c1;
	LOOP
 		FETCH c1 into eOwner_name, eTrip_ID, ePaymentAmount;
 		EXIT WHEN c1%NOTFOUND;
 		DBMS_output.put_line('Owner: ' || eOwner_name || ' Trip ID: ' || eTrip_ID || ' Payment Amount: ' || '$' || ePaymentAmount);
 	END LOOP;
 	CLOSE c1;
 	-- return an error code to indicate any exceptions
 	EXCEPTION
 		WHEN others THEN
 	ErrorCode := 0;
END;

/

-- start of insert statements

INSERT INTO Customers(Customer_ID,Customer_name,Customer_email_ID,CreditCard) VALUES (1,'Nicholas','nick@gmail.com',8123456790871234);
INSERT INTO Customers(Customer_ID,Customer_name,Customer_email_ID,CreditCard) VALUES (2,'Mike','Mike@gmail.com',513345679057120);
INSERT INTO Customers(Customer_ID,Customer_name,Customer_email_ID,CreditCard) VALUES (3,'Sam','sam@gmail.com',7729856790871237);
INSERT INTO Customers(Customer_ID,Customer_name,Customer_email_ID,CreditCard) VALUES (4,'Michelle','Michelle@gmail.com',1972479057120876);

INSERT INTO Distances VALUES(Distance_Seq.nextval,'San Jose','California','San Francisco','California',48.4,0);
INSERT INTO Distances VALUES(Distance_Seq.nextval,'San Francisco','California','San Jose','California',48.4,0);
INSERT INTO Distances VALUES(Distance_Seq.nextval,'DC','Washington DC','Baltimore','Maryland',38.3,1);
INSERT INTO Distances VALUES(Distance_Seq.nextval,'Philadelphia','Pennsylvania','Baltimore','Maryland',106.1,1);
insert into distances values (distance_seq.nextval,'catonsville','maryland','chinatown','philadelphia',20.4,1);
insert into distances values (distance_seq.nextval,'catonsville','maryland','centercity','philadelphia',29.4,1);
insert into distances values (distance_seq.nextval,'catonsville','maryland','lowernorth','philadelphia',27.4,1);

insert into VEHICLE_TYPES values('SEDAN',1);
insert into VEHICLE_TYPES values('TRUCK',1);
insert into VEHICLE_TYPES values('SUV',2);
insert into VEHICLE_TYPES values('CROSSOVER',2);
insert into VEHICLE_TYPES values('MINIVAN',2);
insert into VEHICLE_TYPES values('BUS',5);

insert into VEHICLE_OWNERS values(VEHICLE_OWNERS_SEQ.NEXTVAL,'Tom','tom@umbc.edu',7535736295076583, 'Y');
insert into VEHICLE_OWNERS values(VEHICLE_OWNERS_SEQ.NEXTVAL,'Bob','bob@umbc.edu',4284742292376575, 'Y');
insert into VEHICLE_OWNERS values(VEHICLE_OWNERS_SEQ.NEXTVAL,'Rose','rose@umbc.edu',9859736295076999, 'Y');
insert into VEHICLE_OWNERS values(VEHICLE_OWNERS_SEQ.NEXTVAL,'David','david@umbc.edu',4288756295076584, 'Y');
insert into VEHICLE_OWNERS values(VEHICLE_OWNERS_SEQ.NEXTVAL,'Timber','timber@umbc.edu',4288756295076583, 'Y');

INSERT INTO VEHICLES VALUES(VEHICLES_SEQ.NEXTVAL, (SELECT OWNER_ID FROM VEHICLE_OWNERS WHERE EMAIL='tom@umbc.edu'), 'TRUCK', 'TRUCK', 2012, 4567, 'VA', 10, 15,'AUBURN', 'Y');
INSERT INTO VEHICLES VALUES(VEHICLES_SEQ.NEXTVAL, (SELECT OWNER_ID FROM VEHICLE_OWNERS WHERE EMAIL='bob@umbc.edu'), 'SUV', 'SUV', 2014, 8976, 'NY', 5, 4, 'ANNAPOLIS', 'Y');
INSERT INTO VEHICLES VALUES(VEHICLES_SEQ.NEXTVAL, (SELECT OWNER_ID FROM VEHICLE_OWNERS WHERE EMAIL='rose@umbc.edu'), 'CROSSOVER', 'CROSSOVER', 2011, 3456, 'VA', 6, 5, 'AUBURN', 'Y');
INSERT INTO VEHICLES VALUES(VEHICLES_SEQ.NEXTVAL, (SELECT OWNER_ID FROM VEHICLE_OWNERS WHERE EMAIL='rose@umbc.edu'), 'MINIVAN', 'MINIVAN', 2015, 8765, 'NY', 8, 7, 'AUBURN', 'Y');
INSERT INTO VEHICLES VALUES(VEHICLES_SEQ.NEXTVAL, (SELECT OWNER_ID FROM VEHICLE_OWNERS WHERE EMAIL='bob@umbc.edu'), 'BUS', 'BUS', 2018, 9273, 'MD', 10, 9, 'ANNAPOLIS', 'Y');
INSERT INTO VEHICLES VALUES(VEHICLES_SEQ.NEXTVAL, (SELECT OWNER_ID FROM VEHICLE_OWNERS WHERE EMAIL='rose@umbc.edu'), 'SEDAN', 'SEDAN', 2016, 6754, 'MD', 4, 2, 'RICHMOND', 'Y');
INSERT INTO VEHICLES VALUES(VEHICLES_SEQ.NEXTVAL, (SELECT OWNER_ID FROM VEHICLE_OWNERS WHERE EMAIL='timber@umbc.edu'), 'SUV', 'SUV', 2014, 9867, 'VA', 4, 2, 'ANNAPOLIS', 'Y');
INSERT INTO VEHICLES VALUES(VEHICLES_SEQ.NEXTVAL, (SELECT OWNER_ID FROM VEHICLE_OWNERS WHERE EMAIL='david@umbc.edu'), 'SUV', 'SEDAN', 2019,'1261', 'MD', 7, 6, 'ANNAPOLIS', 'Y');

INSERT INTO TRIPS VALUES(Trips_SEQ.nextval,3,1000,1,'San Jose','California','San Francisco','California',date '2021-11-8', 4567, 1, 0, 56);
INSERT INTO TRIPS VALUES(Trips_SEQ.nextval,4,1001,2,'San Francisco','California','San Jose','California',date '2021-11-8', 8976, 2, 2, 234);

INSERT INTO Payments VALUES(payment_seq.nextval,'Customer',5000,3,1000,-278.30);
INSERT INTO Payments VALUES(payment_seq.nextval,'Owner',5000,3,1000,278.30);
INSERT INTO Payments VALUES(payment_seq.nextval,'Customer',5001,4,1001,-456.78);
INSERT INTO Payments VALUES(payment_seq.nextval,'Owner',5001,4,1001,456.78);


-- start of anonymous programs
-- member 1 anonymous program

BEGIN
	add_owner('John', 'john@umbc.edu',123456,'y');
	add_owner('Lily', 'lily@umbc.com',234567,'y');
	add_owner('Patrick', 'patrick@yahoo.com',123234,'y');

	get_owner_id('lily@umbc.com');
	
	delete_vehicle('patrick@yahoo.com');

	displaystates();
	displayvehicles('SEDAN');
END;
/
-- member 2 anonymous program

Declare
ID number;
return_status_delete number;
return_status_add number;

Begin
return_status_add := AddACustomer('Jen','jen@gmail.com',456797520097614789);
if return_status_add > 0 then	
dbms_output.put_line('A new customer record has been added');
end if;


return_status_delete := DeleteACustomer('jen@gmail.com');
if return_status_delete > 0 then	
dbms_output.put_line('The customer detail has been deleted');
else
dbms_output.put_line('no such employee');
end if;	


ID := FindCustomerID('nick@gmail.com');
if ID > 0 then
	dbms_output.put_line('The customer ID is :' || ID);
    else
    dbms_output.put_line('no such employee');
end if;
End;

/

DECLARE
	ErrorCode int;
	return_status_update int;
BEGIN

	return_status_update := UpdateCreditCard(1,9912356790891274);                
	if return_status_update > 0 then	                                                            
	dbms_output.put_line('The creditcard number has been updated');
	else
	dbms_output.put_line('no such Customer');
	end if;

	WorstCustomer(ErrorCode);
	IF ErrorCode<1 THEN
		dbms_output.put_line('error in report generation for worst customer');
	END IF;
	
	BestCustomer(ErrorCode);
	IF ErrorCode<1 THEN
		dbms_output.put_line('error in report generation for best customer');
	END IF;
END;

/
-- member 3 anonymous program

DECLARE
    ErrorCode int;
BEGIN
    AddNewDistance('Baltimore', 'Maryland', 'DC', 'Washington DC', 38.3,1);
    AddNewDistance('Baltimore', 'Maryland', 'Philadelphia', 'Pennsylvania', 106.1, 1);
    AddNewDistance('New York', 'New York', 'Jeresy City', 'New Jeresy', 4.3, 1);
    ListOneLegDestinations('Baltimore', ErrorCode);
END;

/

DECLARE
    ErrorCode int;
BEGIN
    ListAvailableRides('Annapolis', 'Baltimore', 4, 2, ErrorCode);
END;

/
-- member 4 anonymous program

BEGIN
    Recordtrip('Mike','Bob','catonsville', 'maryland', 'chinatown', 'philadelphia', date '2021-11-7', 2000, 1, 1,  0);
    Recordtrip('Sam','Tom','catonsville', 'maryland', 'centercity', 'philadelphia', date '2021-11-8', 2001, 2, 0, 0);
    Recordtrip('Sam','Bob','catonsville', 'maryland', 'lowernorth', 'philadelphia', date '2021-11-9', 2000, 1, 2, 0);

    return_trip_id('Mike','Bob','catonsville', 'maryland', 'chinatown', 'philadelphia', date '2021-11-7');
    return_trip_id('Sam','Tom','catonsville', 'maryland', 'centercity', 'philadelphia', date '2021-11-8');
    return_trip_id('Sam','Bob','catonsville', 'maryland', 'lowernorth', 'philadelphia', date '2021-11-9');
END;

/
-- member 5 anonymous program
DECLARE
	ErrorCode int;
BEGIN
	ChargeCustomer(5002,'Mike@gmail.com','bob@umbc.edu',ErrorCode);
	ChargeCustomer(5003,'sam@gmail.com','tom@umbc.edu',ErrorCode);
	ChargeCustomer(5004,'sam@gmail.com','bob@umbc.edu',ErrorCode);
	IF ErrorCode<1 THEN
		dbms_output.put_line('customer charge has failed');
	END IF;
END;

/

DECLARE
	ErrorCode int;
	TotalRevenue int;
BEGIN
    FindTotalRevenue(TotalRevenue);
	dbms_output.put_line('The total revenue can also be retrieved and manipulated in a variable --> ' || TotalRevenue);
	GenerateRevenueReportDest(ErrorCode);
	IF ErrorCode<1 THEN
		dbms_output.put_line('error in report generation');
	END IF;
END;

/

DECLARE
 	cErrorCode int;
	oErrorCode int;
BEGIN
 	ViewCustomerPayments('Sam',cErrorCode);
 	ViewOwnerPayments('Tom',oErrorCode);
 	IF cErrorCode<1 THEN
 		dbms_output.put_line('Failed to pull customer information.');
 	END IF;
 	IF oErrorCode<1 THEN
 		dbms_output.put_line('Failed to pull owner information.');
 	END IF;
END;

/

DECLARE
	 ErrorCode int;
BEGIN
 	GenerateRevenueReportDept(ErrorCode);
 	IF ErrorCode<1 THEN
 		dbms_output.put_line('error in report generation');
 	END IF;
END;

/