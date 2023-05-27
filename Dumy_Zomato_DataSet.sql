use project;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date VARCHAR(10)); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');

CREATE TABLE users(userid integer,signup_date VARCHAR(10)); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');

CREATE TABLE sales(userid integer,created_date VARCHAR(10),product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);

CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

-- What is the total amount each customer spent on Zomato ? 

select Userid,sum(Price) Total_spend_amount
from sales inner join product on sales.product_id = product.product_id
group by userid;

-- How many days has each customer visit the Zomato store ?
select Userid,count(*) total_visited_days
from sales
group by userid;

-- What was the first product purchased by each customer ?
select userid,product_id from(select userid,created_date,product_id,
       rank() over(partition by userid order by created_date) as Ranks
from sales)a  where a.ranks = 1;

-- what is the most purchased item from the menu and how many times it purchased by each customer ?
select userid,count(product_id) from sales 
where product_id=(select product_id
from sales
group by product_id order by count(*) desc limit 1)
group by userid;

-- Which item is most popular for each customer ?
select * from(select a.* , rank() over(partition by userid order by Total_order_each_product desc)as Ranks from(select userid,product_id,count(*) Total_order_each_product
from sales
group by userid,product_id) as a) as b
where b.Ranks=1;

-- Update the date columns
update sales
set created_date = str_to_date(created_date,'%m-%d-%Y');

update goldusers_signup
set  gold_signup_date= str_to_date(gold_signup_date,'%m-%d-%Y');

update users
set signup_date = str_to_date(signup_date,'%m-%d-%Y');

-- Which item purchased first by the customer after they become a member ?
select b.* from(select a.*, rank() over(Partition by userid order by created_date) Ranks
from(select a.userid,a.created_date,a.product_id,b.gold_signup_date 
from sales a inner join goldusers_signup b on a.userid = b.userid And a.created_date>b.gold_signup_date) a) b
where b.Ranks = 1;

-- Which items is purchased just before the customer become a gold member ?
select b.userid,b.product_id from(select a.*, rank() over(Partition by userid order by created_date desc) Ranks 
from (select a.userid,a.created_date,a.product_id,b.gold_signup_date 
from sales a inner join goldusers_signup b on a.userid = b.userid And a.created_date<b.gold_signup_date) a) b
where b.ranks = 1;

-- What is the total order and amount spent for each member before they become a member ?
select b.userid,count(*) item_purchased,sum(price) total_amount from (select a.userid,a.product_id,p.price from (select a.userid,a.created_date,a.product_id,b.gold_signup_date 
from sales a inner join goldusers_signup b on a.userid = b.userid And a.created_date<b.gold_signup_date) a inner join
Product P on a.product_id = p.product_id) b
group by userid
order by userid;

/* For buy any product from zomato we get some zomato points in this case if we buy
   Product p1 then 5₹ = 1 zomato point ,
   Product p2 then 10₹ = 5 zomato point,
   Product p3 then 5₹ = 1 zomato point
   
   1. Calculate point earn by each customer  
   2. which product highest point given till now.
*/

select userid,sum(Total_Point) Point_Earn_By_Each_customer
from (select d.*, Round(amount/Product_Cost_Per_Point) as Total_Point 
from (select c.*, case when product_id = 1 then 5
                 when product_id = 2 then 2
                 when product_id = 3 then 5
                 end as Product_Cost_Per_Point
from (select a.userid,a.product_id,sum(price) as amount from sales a inner join product b on a.product_id = b.product_id
group by userid,product_id) c ) d ) e
group by userid;

select e.product_id,sum(total_point)TP
from(select d.*, Round(amount/Product_Cost_Per_Point) as Total_Point 
from (select c.*, case when product_id = 1 then 5
                 when product_id = 2 then 2
                 when product_id = 3 then 5
                 end as Product_Cost_Per_Point
from (select a.userid,a.product_id,sum(price) as amount from sales a inner join product b on a.product_id = b.product_id
group by userid,product_id) c ) d) e
group by product_id
order by 2 desc limit 1;

/*  
    In the first one year after customer join the gold program (including the join date) irrespective what the customer has purchased
    they earn 5 zomato point for every 10₨ spent who earned more 1 or 3 and what was their point earning in their first year
*/

Alter table  goldusers_signup
modify column gold_signup_date date;

select c.*, price*0.5 Total_Point_Earn from(
select a.userid,a.created_date,a.product_id,b.gold_signup_date 
from sales a inner join goldusers_signup b on a.userid = b.userid And a.created_date>=b.gold_signup_date And created_date<=adddate(gold_signup_date,Interval 1 Year)) c
inner join product p on p.product_id = c.product_id;

-- Rank all the tranctions of the customer

select * , Rank() Over(order by created_date)Ranks
from sales;

-- Rank all the tranctions for each member whenever they are the gold member of zomato and for every non-gold-member as NA
select *,
       Case when a.userid = b.userid then rank() over(partition by a.userid order by created_date)
		    else 'NA'
	   End as Ranks 
From sales a left join goldusers_signup b on a.userid = b.userid;