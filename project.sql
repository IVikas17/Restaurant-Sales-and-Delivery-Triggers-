create database miniproject;
use miniproject;

select str_to_date(order_date,'%d-%m-%Y') from orders_dimen;
set sql_safe_updates = 0;
alter table orders_dimen modify order_date date;
update  orders_dimen set order_date = str_to_date(order_Date,'%d-%m-%Y');



select str_to_date(ship_date,'%d-%m-%Y') from shipping_dimen;
set sql_safe_updates = 0;
alter table shipping_dimen modify ship_date date;
update  shipping_dimen set ship_date = str_to_date(ship_date,'%d-%m-%Y');








# Question 1: Find the top 3 customers who have the maximum number of orders
select cd.customer_name,cd.cust_id,count(od.ord_id) no_of_orders 
from orders_dimen od join market_fact mf using (ord_id) join cust_dimen cd using (cust_id)
group by cd.customer_name,cd.cust_id order by no_of_orders desc limit 3 ;


#Question 2: Create a new column DaysTakenForDelivery that contains the date difference between Order_Date and Ship_Date.
select *,datediff(ship_date,order_date) DaysTakenforDelivery from orders_dimen join shipping_dimen using(order_id);


#Question 3: Find the customer whose order took the maximum time to get delivered.
select cust_id,customer_name,order_date,ship_date, datediff(sd.ship_Date,order_date) daystakenfordelivery
from market_fact mf join orders_dimen od using (ord_id) join shipping_dimen sd using (order_id) join cust_dimen  cd using (cust_id)
order by daystakenfordelivery desc limit 1;


#Question 4: Retrieve total sales made by each product from the data (use Windows function)
select * from shipping_dimen  ;
select * from cust_dimen;
select * from orders_dimen ;
select distinct prod_id,sum(mf.sales) over (partition by pd.prod_id )  total_sales 
from market_fact mf join prod_dimen pd using(prod_id);


# Question 5: Retrieve the total profit made from each product from the data (use windows function)
select distinct prod_id,sum(mf.profit) over (partition by pd.prod_id ) from market_fact mf join prod_dimen pd using(prod_id);



#Question 6: Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011

# in january month of 2011
select   count( distinct c.cust_id) ,monthname( order_date), year(order_date )
from cust_dimen c
join
market_fact m
using (cust_id)
join 
orders_dimen o
using (ord_id)
where year( order_date )= 2011 and  monthname( order_date)="january";

#to find how many of them came back every month over the entire year in 2011 

select t.cust_id ,count(t.cust_id)over() from (
(select distinct cust_id from market_fact m join orders_dimen o  using(ord_id)
where year(order_date)=2011 and  month(order_date)= 1)t
join 
(select distinct cust_id from market_fact m join orders_dimen o  using(ord_id)
where year(order_date)=2011 and  month(order_date)!= 1 )t1
on t.cust_id=t1.cust_id);





#PART2
#Question 1: - We need to find out the total visits to all restaurants under all alcohol categories available.        

SELECT 
    alcohol, COUNT(userID)
FROM
    geoplaces2
        JOIN
    rating_final USING (placeid)
GROUP BY alcohol;

#Question 2: -Let's find out the average rating according to alcohol and price so that we can understand the rating in respective price categories as well.

SELECT 
    alcohol, price, round(avg(rating),2)
FROM
    rating_final
        JOIN
    geoplaces2 USING (placeid)
GROUP BY alcohol , price;


#Question 3:  Let’s write a query to quantify that what are the parking availability as well in different alcohol categories along with the total number of restaurants.

SELECT 
    alcohol, parking_lot,COUNT(placeid) no_of_restaurants 
FROM
    geoplaces2
        JOIN
    chefmozparking USING (placeid)
GROUP BY alcohol , parking_lot;	


#Question 4: -Also take out the percentage of different cuisine in each alcohol type.     


select *, cuisine_no/alcohol_no*100 percentage_cuisine from (
select distinct alcohol,rcuisine,count(rcuisine) over (partition by alcohol,rcuisine) cuisine_no,count(alcohol) over (partition by alcohol) alcohol_no  
from geoplaces2 join chefmozcuisine using (placeid))t ;



#Questions 5: - let’s take out the average rating of each state.

SELECT 
    state, AVG(rating)
FROM
    geoplaces2
        JOIN
    rating_final USING (placeid)
GROUP BY state;



#Questions 6: -' Tamaulipas' Is the lowest average rated state. Quantify the reason why it is the lowest rated by providing the summary on the basis of State, alcohol, and Cuisine.

select  placeid,name,alcohol,price,smoking_area,rcuisine,rating 
from geoplaces2 join rating_final  using(placeid) join chefmozcuisine 
using(placeid) where state = 'tamaulipas'
order by  rating desc;



# the state 'tamaulipas' has lowest ratings because of following reasons:-
# almost no restaurant serves Alcohol this is the main reason for the lower ratings
# there are limited varieties of cuisines provided in the state


#Question 7:  - Find the average weight, food rating, and service rating of the customers who have visited KFC and tried Mexican or Italian types of cuisine, and also their budget level is low.
#We encourage you to give it a try by not using joins.


select up.userid ,name,avg(weight)over(), food_rating, service_rating ,uc.rcuisine from 
rating_final rf
join
userprofile up
on rf.userid = up.userid
join  
geoplaces2 g
on rf.placeid = g.placeid
join 
usercuisine uc
on up.userid = uc.userid
where name='kfc' and rcuisine in ('italian', 'mexican') and budget ="low";



#Part 3:  Triggers
#Question 1

#Create two called Student_details and Student_details_backup.

/*You have the above two tables Students Details and Student Details Backup. Insert some records into Student details. 

Problem:

Let’s say you are studying SQL for two weeks. In your institute, there is an employee who has been maintaining the student’s details and Student Details Backup tables. 
He / She is deleting the records from the Student details after the students completed the course and keeping the backup in the student details backup table
by inserting the records every time. 
You are noticing this daily and now you want to help him/her by not inserting the records for backup purpose when he/she delete the records.
write a trigger that should be capable enough to insert the student details in the backup table whenever the employee deletes records from the student details table.

Note: Your query should insert the rows in the backup table before deleting the records from student details.
*/

CREATE TABLE  student_details(
student_id int ,
student_name varchar(50),
mail_id varchar(50),
mobile bigint
); 

insert into student_details values
(1,'radha','radha@gmail.com',988666666),
(2,'raghu','raghu@gmail.com',9883435455),
(3,'shravan','shravan@gmail.com',7237123446),
(4,'ramesh','ramesh@gmail.com',996767896),
(5,'tarun','tarun@gmail.com',726789666);

select * from student_details;

create table student_details_backup(  
student_id int ,
student_name varchar(50),
mail_id varchar(50),
mobile bigint
); 


create trigger backup1
before delete on student_details
for each row
insert into student_details_backup values (old.student_id,old.student_name,old.mail_id,old.mobile);



