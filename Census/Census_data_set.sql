Create database if not exists Project;
use project;
show tables in project;
desc dataset1;

select * from dataset1;
select * from dataset2;

-- Total No. of rows
Select Count(*) from dataset1;
Select Count(*) from dataset2;

-- Take Avg Literacy result on basis of State
Select State,Round(Avg(Literacy),2) As Literary_Rate from dataset1 group by State;

-- Take Out the result for particular state
Select * from dataset1 where state in ('Maharashtra','Rajasthan');

-- I Have Integer value seprated with comma and datatype is text  
Update dataset2
set Population = Replace(Population,',','');
Update dataset2
set Area_km2 = Replace(Area_km2,',','');

-- Now Updating datatype to int
Alter Table dataset2
Modify Population Double,
Modify Area_km2 Int;

-- Total Population of India
select Sum(Population) As Total_Population from dataset2;

-- Total population By State
select state,Sum(Population) As Total_Population from dataset2 group by state;

-- Change The col name
Alter Table dataset1
Rename Column Growth to Growth_In_Percentage;

-- Remove the Percentage sign
Update dataset1
set Growth_In_Percentage = Replace(Growth_In_Percentage,'%','');

-- Change the Type 
Alter Table dataset1
modify Growth_In_Percentage int;

-- Avg Growth of india Population
select Avg(Growth_In_Percentage) Population_Growth_India From Dataset1;

-- Avg Growth by state
Select State, Avg(Growth_In_Percentage) Population_Growth_State From Dataset1 Group By State;

-- Avg Sex Ratio By State Having sex_ration more than 950
Select State, Round(Avg(Sex_Ratio),2) as sex_ratio From Dataset1 Group By State having sex_ratio > 950 Order By sex_ratio;

-- If I want to take out The Top three state on the basis of some condition like Growth, Sex Ratio, Literacy 
Select State, Avg(Growth_In_Percentage) Population_Growth_State 
From Dataset1 
Group By State 
Order By Population_Growth_State Desc limit 3;

-- If I want to take out The Least three state on the basis of some condition like Growth, Sex Ratio, Literacy 
Select State, Avg(Growth_In_Percentage) Population_Growth_State 
From Dataset1 
Group By State 
Order By Population_Growth_State limit 3;

-- If I want to showcase Result Of Top and Least State
    -- It's give me error on using order by clause 
Select State, Avg(Growth_In_Percentage) Population_Growth_State 
From Dataset1 
Group By State 
Order By Population_Growth_State Desc limit 3
union all
Select State, Avg(Growth_In_Percentage) Population_Growth_State 
From Dataset1 
Group By State 
Order By Population_Growth_State limit 3;

      -- To Handle this, I used a sub-query 
select * from (Select State, Avg(Growth_In_Percentage) Population_Growth_State 
From Dataset1 
Group By State 
Order By Population_Growth_State Desc limit 3) A
union all
select * From(Select State, Avg(Growth_In_Percentage) Population_Growth_State 
From Dataset1 
Group By State 
Order By Population_Growth_State limit 3) B ;

-- How Many district data of a state I have
Select state,count(distinct(district)) As Total_district from dataset1 group by state order by state;


-- Task 1. Take Out the Males And Female Population

 -- Join The Table On District Basis
Create View Dataset3 as (
select  D2.District, D2.state, D1.sex_ratio, D2.population
From Dataset1 D1 inner join Dataset2 D2 on D1.District = D2.District);

select * from Dataset3;

/*    F = Females , M = Males , P = Populations, sex Ratio = SR
      sex_ration = F*1000/M
      Population = F + M
      M = (P*1000)/(SR+1000)
      F = P - M
*/

create view population_data_Gender AS(
select District,State,Floor((Population *1000)/(Sex_Ratio+1000)) as Males,Floor(Population-((Population *1000)/(Sex_Ratio+1000))) as Females
From Dataset3);

select * from population_data_Gender;

-- Get The total no. of male and females
select Sum(males) as Total_males ,sum(Females) As Total_Females from population_data_Gender;

-- Get total no. males and female state wise
select state, Sum(males) as Total_males ,sum(Females) As Total_Females from population_data_Gender group by state;


-- Task 2. Take Out the Population of literate or illiterate population

Create View Dataset4 as (
select  D2.District, D2.state, D1.literacy, D2.population
From Dataset1 D1 inner join Dataset2 D2 on D1.District = D2.District);

select * from Dataset4;

create view litracy_data AS(
select District,State,Round((population*literacy)) AS literate_population, Round((population*(100-literacy))) As illiterate_population
From Dataset4);

-- Get total no.  literate_population and illiterate_population state wise
select state, Sum( literate_population) as Total_literate_population ,sum(illiterate_population) As Total_illiterate_population 
from litracy_data group by state;


-- Task 3. Get the top three district from each state that have highest literacy 
select * from(select *, Dense_Rank() Over(Partition by state order by literacy desc) as Ranks from dataset1)as WF
where WF.Ranks in (1,2,3);

-- Task 4. Previous Population Census  data

Select D1.district,d1.state,d2.population as Current_Population, round(population/(1+Growth_In_Percentage),0) as previous_population
From dataset1 D1 inner join dataset2 D2 on D1.district = D2.district;