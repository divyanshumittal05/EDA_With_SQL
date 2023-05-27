                            
Create database automobile;
use automobile;
show tables;

-- !csvsql --dialect mysql --snifflimit 250 file_name.extension > output_name.extension 
-- By using this script table created

create table cars_data(
		symboling DECIMAL(38, 0) NOT NULL, 
		normalized_losses DECIMAL(38, 0), 
		make VARCHAR(13) NOT NULL, 
		fuel_type VARCHAR(6) NOT NULL, 
		aspiration VARCHAR(5) NOT NULL, 
		num_of_doors VARCHAR(4), 
		body_style VARCHAR(11) NOT NULL, 
		drive_wheels VARCHAR(3) NOT NULL, 
		engine_location VARCHAR(5) NOT NULL, 
		wheel_base DECIMAL(38, 1) NOT NULL, 
		length DECIMAL(38, 1) NOT NULL, 
		width DECIMAL(38, 1) NOT NULL, 
		height DECIMAL(38, 1) NOT NULL, 
		curb_weight DECIMAL(38, 0) NOT NULL, 
		engine_type VARCHAR(5) NOT NULL, 
		num_of_cylinders VARCHAR(6) NOT NULL, 
		engine_size DECIMAL(38, 0) NOT NULL, 
		fuel_system VARCHAR(4) NOT NULL, 
		bore DECIMAL(38, 2), 		
        stroke DECIMAL(38, 2), 
		compression_ration DECIMAL(38, 2) NOT NULL, 
		horsepower DECIMAL(38, 0), 
		peak_rpm DECIMAL(38, 0), 
		city_mpg DECIMAL(38, 0) NOT NULL, 
    	highway_mpg DECIMAL(38, 0) NOT NULL, 
		price DECIMAL(38, 0)
);

load data local infile '/Users/divyanshumittal/Downloads/SQL DATASET PRACTICE/automobile dataset/clean_dataset.csv'
into table cars_data
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

set global local_infile = 1; 

select * from cars_data;
desc table cars_data;
desc cars_data;

select count(*) as Num_of_col  from information_schema.columns where table_name = 'Cars_data';
select count(*) as Num_of_records from Cars_data;     -- 195 records

/* By seeking the table we can say there some col that have null or blank values that are: 
   
  Categorical data fields --
        num_of_doors 
    
  Countinous data fields -- 
    normalized_losses 
    bore
    stroke
    horsepower
    peak_rpm
    price
*/

-- Check For any other error like meaning mistake
select distinct(make) from Cars_data;
select distinct(fuel_type) from Cars_data;
select distinct(aspiration) from Cars_data;
select distinct(num_of_doors) from Cars_data;
select distinct(body_style) from Cars_data;
select distinct(drive_wheels) from Cars_data;
select distinct(Engine_location) from Cars_data;
select distinct(engine_type) from Cars_data;
select distinct(num_of_cylinders) from Cars_data;
select distinct(Fuel_system) from Cars_data;


-- Check the balnks values rows to identify on which basis value can be fillup
select * from cars_data where num_of_doors = '';

-- Update the balnk values on basis of make,fuel_type,body_style 
select * from cars_data where (make = 'dodge' and body_style = 'sedan' and fuel_type = 'gas' ) 
                        or (make = 'mazda' and body_style = 'sedan' and fuel_type = 'diesel');
                        
update cars_data
set num_of_doors = 'Four'
where (make = 'dodge' and body_style = 'sedan' and fuel_type = 'gas' ) 
                        or (make = 'mazda' and body_style = 'sedan' and fuel_type = 'diesel');
                        
-- Check the blank values in normalized_losses 
select * from cars_data where normalized_losses = '';   -- 35 cols 

-- I think it's depend so many factors like make,fuel_type,num_of_doors,body_style by using we can fill out the avg value 
-- which seems difficult to fill


-- Update the values for bore
select * from cars_data where bore = '';

select round(avg(bore),2) 
from cars_data 
where make='mazda' and fuel_type = 'gas' and num_of_doors = 'two' and body_style = 'hatchback' and bore != 0;

update cars_data 
set bore = 3.17
where bore = 0;

-- update the value for stroke
select * from cars_data where stroke = '';

select round(avg(stroke),2) as avg_value 
from cars_data 
where make='mazda' and fuel_type = 'gas' and num_of_doors = 'two' and body_style = 'hatchback' and stroke != 0;

update cars_data 
set stroke = 3.25
where stroke = 0;

-- update the value for horsepower
select * from cars_data where horsepower = '';

select round(avg(horsepower),2) as avg_value 
from cars_data 
where make='renault' and fuel_type = 'gas' and num_of_doors = 'two' and body_style = 'hatchback' and horsepower != 0;

select round(avg(horsepower),2) as avg_value 
from cars_data 
where make='renault' and fuel_type = 'gas' and num_of_doors = 'four' and body_style = 'wagon' and horsepower != 0;

-- For both col horsepower and peak_rpm no common value is present

-- update the value of price
select * from cars_data where price = '';

select Round(avg(price)) from cars_data where make = 'audi' and price!=0;
update cars_data 
set price = 17859
where make = 'audi' and price=0;

select round(avg(price),0) from cars_data where make = 'isuzu' and price!=0;
update cars_data 
set price = 8917
where make = 'isuzu' and price=0;

select * from cars_data where make = 'porsche' and price!=0;
update cars_data 
set price = 22000
where make = 'porsche' and price=0;


-- Task 1: To find the top 5 cars customers bought based on make.

select make, count(make) as car_bought
from cars_data
group by 1
order by 2 desc
limit 5;

-- Task 2: To find the top 5 cars based on body_style.

select make, body_style ,count(make) as car_bought
from cars_data
group by 1,2
order by 3 desc
limit 5;

-- Task 3: Which body style pattern purchase mostly and how many car bought by customer

select body_style, count(body_style) as car_bought
from cars_data
group by 1
order by 2 desc
limit 1;

-- Task 3: Find out the 2nd highest body style pattern purchase mostly and how many car bought by customer

select body_style, count(body_style) as car_bought
from cars_data
group by 1
order by 2 desc
limit 1,1;

-- Task 4: Total sales from each cars based on their body-style and how many cars are sold ?

select make,body_style,sum(price) as Total, count(body_style) as cars_sold
from cars_data
group by 1,2
order by 3 desc;

-- Task 5 : Find out on fuel basis how many cars sold ?

select fuel_type, count(fuel_type) total_cars
From cars_data
group by 1;

-- Task 6: Find Out the Highest Price of car

select * from cars_data where price = (select max(price) from cars_data);

-- Task 7: How many cars are sold that have highest price
   
   select count(*) total_cars from cars_data where price = (select max(price) from cars_data);
