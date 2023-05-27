use Project;
CREATE TABLE driver(driver_id integer,reg_date date); 

INSERT INTO driver(driver_id,reg_date) 
 VALUES (1,'2021-01-01'),
(2,'2021-01-03'),
(3,'2021-01-08'),
(4,'2021-01-15');

CREATE TABLE ingredients(ingredients_id integer,ingredients_name varchar(60)); 

INSERT INTO ingredients(ingredients_id ,ingredients_name) 
 VALUES (1,'BBQ Chicken'),
(2,'Chilli Sauce'),
(3,'Chicken'),
(4,'Cheese'),
(5,'Kebab'),
(6,'Mushrooms'),
(7,'Onions'),
(8,'Egg'),
(9,'Peppers'),
(10,'schezwan sauce'),
(11,'Tomatoes'),
(12,'Tomato Sauce');

CREATE TABLE rolls(roll_id integer,roll_name varchar(30)); 

INSERT INTO rolls(roll_id ,roll_name) 
 VALUES (1	,'Non Veg Roll'),
(2	,'Veg Roll');

CREATE TABLE rolls_recipes(roll_id integer,ingredients varchar(24)); 

INSERT INTO rolls_recipes(roll_id ,ingredients) 
 VALUES (1,'1,2,3,4,5,6,8,10'),
(2,'4,6,7,9,11,12');

CREATE TABLE driver_order(order_id integer,driver_id integer,pickup_time datetime,distance VARCHAR(7),duration VARCHAR(10),cancellation VARCHAR(23));
INSERT INTO driver_order(order_id,driver_id,pickup_time,distance,duration,cancellation) 
 VALUES(1,1,'2021-01-01 18:15:34','20km','32 minutes',''),
(2,1,'2021-01-01 19:10:54','20km','27 minutes',''),
(3,1,'2021-01-03 00:12:37','13.4km','20 mins','NaN'),
(4,2,'2021-01-04 13:53:03','23.4','40','NaN'),
(5,3,'2021-01-08 21:10:57','10','15','NaN'),
(6,3,null,null,null,'Cancellation'),
(7,2,'2020-01-08 21:30:45','25km','25mins',null),
(8,2,'2020-01-10 00:15:02','23.4 km','15 minute',null),
(9,2,null,null,null,'Customer Cancellation'),
(10,1,'2020-01-11 18:50:20','10km','10minutes',null);

CREATE TABLE customer_orders(order_id integer,customer_id integer,roll_id integer,not_include_items VARCHAR(4),extra_items_included VARCHAR(4),order_date datetime);
INSERT INTO customer_orders(order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date)
values (1,101,1,'','','2021-01-01  18:05:02'),
(2,101,1,'','','2021-01-01 19:00:52'),
(3,102,1,'','','2021-01-02 23:51:23'),
(3,102,2,'','NaN','2021-01-02 23:51:23'),
(4,103,1,'4','','2021-01-04 13:23:46'),
(4,103,1,'4','','2021-01-04 13:23:46'),
(4,103,2,'4','','2021-01-04 13:23:46'),
(5,104,1,null,'1','2021-01-08 21:00:29'),
(6,101,2,null,null,'2021-01-08 21:03:13'),
(7,105,2,null,'1','2021-01-08 21:20:29'),
(8,102,1,null,null,'2021-01-09 23:54:33'),
(9,103,1,'4','1,5','2021-01-10 11:22:59'),
(10,104,1,null,null,'2021-01-11 18:34:49'),
(10,104,1,'2,6','1,4','2021-01-11 18:34:49');

select * from customer_orders;
select * from driver_order;
select * from ingredients;
select * from driver;
select * from rolls;
select * from rolls_recipes;

-- IN this Only 'Cancellation'  Represents that order cancel by Driver
-- And 'Customer Cancellation' Represents that order cancel by Customer

-- How many Roll were orderd ?
Select Count(*) as Total_Roll_Ordered from customer_orders;

-- How many unique customer ordered the roll ?
select Count(Distinct(Customer_id)) as Unique_order from customer_orders;

-- How many successful order delivered by Each Drivers ?
Select driver_id, count(distinct(order_id)) Total_orderd from driver_order where cancellation not in ('Cancellation','Customer Cancellation')
group by driver_id;

-- How many each type of roll was deliverd ?
select Roll_id,Count(Roll_id) As Total_Roll_Deliver
From (Select a.Order_id From(select *,
	     Case When cancellation in ('Cancellation','Customer Cancellation') then 'C' else 'NC' End as cancellation_Type
from driver_order) a 
Where cancellation_Type = 'NC')b Inner Join Customer_orders c on b.Order_id = c.Order_id
Group by Roll_id;

-- How Many Veg And Non_veg Roll Oreder By Customer ?
select R.Roll_Name,Count(C.Roll_id) as Total_Order from Customer_orders C inner Join Rolls R where C.Roll_id = R.Roll_id Group BY R.Roll_Name;

-- How Many Veg And Non_veg Roll Oreder By Each Customer ?
Select a.Customer_id,a.Total_Order,b.Roll_Name 
from (select Customer_id,Roll_Id,Count(Roll_id) Total_Order from Customer_orders Group BY Customer_id,Roll_Id)a inner join Rolls b 
on a.roll_id = b.roll_id order by Customer_id;

-- What was the maximum number of rolls deliverd in single order ?
select b.Order_id,Count(Roll_id) as Total From(Select a.Order_id From(select *,
	     Case When cancellation in ('Cancellation','Customer Cancellation') then 'C' else 'NC' End as cancellation_Type
from driver_order) a 
Where cancellation_Type = 'NC')a inner join Customer_orders b on a.Order_id = b.Order_id
Group by b.Order_id
Order By Total desc limit 1;

-- For Each Customer, How Many delivered rolls had at least 1 change abd how many have no change ?
with Customer_Orders1 (order_id,customer_id,roll_id,Not_Include_Extra_Items,Include_Extra_Items,order_date) As (
select order_id,customer_id,roll_id,
       Case when not_include_items is Null or not_include_items = '' Then '' else not_include_items End as Not_Include_Extra_Items,
       Case when extra_items_included is Null or extra_items_included = ''or extra_items_included = 'NaN' Then '' else extra_items_included 
       End as Include_Extra_Items,order_date
From Customer_Orders
)
,
 Driver_Order1 (order_id,driver_id,pickup_time,distance,duration,cancellation_Type) As(
Select order_id,driver_id,pickup_time,distance,duration,
       Case when cancellation in ('Cancellation','Customer Cancellation') Then '0' Else '1' End as cancellation_Type
From driver_order
)
select a.Customer_id,a.Change_In_Roll_Extra_Ingredient,count(Change_In_Roll_Extra_Ingredient) 
From (select *,case when Not_Include_Extra_Items = '' And Include_Extra_Items = '' then 'No Change' Else 'Change' End as Change_In_Roll_Extra_Ingredient
From Customer_Orders1 Where order_id in (
select order_id From Driver_Order1 where cancellation_Type!=0)) a 
Group by a.Customer_id,a.Change_In_Roll_Extra_Ingredient;

-- How many rolls were deliver both included or Not included extra ingredients ?
with Customer_Orders1 (order_id,customer_id,roll_id,Not_Include_Extra_Items,Include_Extra_Items,order_date) As (
select order_id,customer_id,roll_id,
       Case when not_include_items is Null or not_include_items = '' Then '' else not_include_items End as Not_Include_Extra_Items,
       Case when extra_items_included is Null or extra_items_included = ''or extra_items_included = 'NaN' Then '' else extra_items_included 
       End as Include_Extra_Items,order_date
From Customer_Orders
)
,
 Driver_Order1 (order_id,driver_id,pickup_time,distance,duration,cancellation_Type) As(
Select order_id,driver_id,pickup_time,distance,duration,
       Case when cancellation in ('Cancellation','Customer Cancellation') Then '0' Else '1' End as cancellation_Type
From driver_order
)
select a.Customer_id,a.Change_In_Roll_Extra_Ingredient,count(Change_In_Roll_Extra_Ingredient) 
From (select *,case when Not_Include_Extra_Items != '' And Include_Extra_Items != '' then 'Include or Exclude Both Chage' 
Else 'Only one chage or no chage' End as Change_In_Roll_Extra_Ingredient
From Customer_Orders1 Where order_id in (
select order_id From Driver_Order1 where cancellation_Type!=0)) a 
Group by a.Customer_id,a.Change_In_Roll_Extra_Ingredient;

-- What was the number of orders for each day of the week ?
select a.day_name,count(*) from(
select *,dayname(order_date) as day_name from customer_orders) a
group by a.day_name;



