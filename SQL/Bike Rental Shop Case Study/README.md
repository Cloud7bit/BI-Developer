
# Bike Rental Shop Case Study Using Postgresql

In this project, I worked as a Data Analyst for Emily, the owner of a bike shop. I utilized SQL to analyze and extract key insights from the shop's database, addressing business questions like the total number of bikes owned by category and the monthly rental revenue. This data-driven approach provided Emily with valuable insights to support her business growth strategies.

## Tech Stack Used 

Postgresql

![sql-server](https://github.com/user-attachments/assets/459cb5aa-236a-4aaa-b29a-41b648e446fa)

## Data Source
The dataset can be accessed on learnsql via this [link](https://learnsql.com/log-in/?redirect=/course/2023-advanced-sql-practice-challenges/november-challenge/introduction/introduction/)

## Database Structure:
The Shop’s database consists of 5 tables :
- Customer
- Bike
- Rental
- Membership_type
- Membership

## Following are the business questions that Emily wants answers to. 
- Emily would like to know how many bikes the shop owns by category. 
```
select category, count(*)	as number_of_bikes
	from bike 
		group by category;

```
**Output:**

![1](https://github.com/user-attachments/assets/ea6e5e97-eadf-45ab-8c97-3bab89155424)

------------------------------------------------------ 

- Emily needs a list of customer names with the total number of memberships purchased by each.

```
select c.name , count(m.id) as membership_count
	from membership m 
	 right join customer c on m.customer_id=c.id
	 	group by 1
		 order by 2 desc;
```
**Output:**
![2](https://github.com/user-attachments/assets/ca84e559-62d1-4a28-9892-2a679a019c11)

------------------------------------------------------ 

- Emily is working on a special offer for the winter months. She needs help to prepare a list of new rental prices?
Electric bikes should have a 10% discount for hourly rentals and a 20% discount for daily rentals. Mountain bikes should have a 20% discount for hourly rentals and a 
50% discount for daily rentals. All other bikes should have a 50% discount for all types of rentals.


```
select id,category,price_per_hour as old_price_per_hour,
	   case when  category = 'electric' then round(price_per_hour - (price_per_hour*0.1) ,2)
	   		when category = 'mountain bike' then round(price_per_hour - (price_per_hour*0.5) ,2)
			   else round(price_per_hour - (price_per_hour*0.5) ,2)
			   	end as new_price_per_hour,
				   price_per_day as old_price_per_day,
				   case when  category = 'electric' then round(price_per_day - (price_per_day*0.1) ,2)
	   					when category = 'mountain bike' then round(price_per_day - (price_per_day*0.5) ,2)
			   			else round(price_per_day - (price_per_day*0.5) ,2)
						 end as new_price_per_day  
						 	from bike;
```            
**Output:**
![3](https://github.com/user-attachments/assets/649eab7d-d147-4963-9fa2-6a61c0af7b3d)

------------------------------------------------------ 

- Emily is looking for counts of the rented bikes and of the available bikes in each category.


```  
select category
	, count(case when status ='available' then 1 end) as available_bikes_count
	, count(case when status ='rented' then 1 end) as rented_bikes_count
		from bike
			group by category;
```  
**Output:**
![4](https://github.com/user-attachments/assets/9f3041d4-c916-4525-9fa0-14cb74eaca95)

------------------------------------------------------ 
- Emily is preparing a sales report. She needs to know the total revenue from rentals by month, the total by year, and the all-time across all the years. 
``` 
select extract(year from start_timestamp) as year
		, extract(month from start_timestamp) as month
			, sum(total_paid) as revenue
				from rental
					group by grouping sets ( (year, month), (year), () )
						order by year, month;
```
**Output:**
![5](https://github.com/user-attachments/assets/96e3ad3a-603f-4a91-bae5-9b6285747d4f)

------------------------------------------------------ 

-  Emily has asked me to get the total revenue from memberships for each combination of year, month, and membership type.


```
select extract(year from start_date) as year
	, extract(month from start_date) as month
	, mt.name as membership_type_name
	, sum(total_paid) as total_revenue
		from membership m
			left join membership_type mt on m.membership_type_id = mt.id
				group by year, month, mt.name
					order by year, month, mt.name;
```
**Output:**
![6](https://github.com/user-attachments/assets/2bcf675b-f7dd-4104-b480-a74bd3d8ddf5)

------------------------------------------------------ 

- Next, Emily would like data about memberships purchased in 2023, with subtotals and grand totals for all the different combinations of membership types and months


```
select mt.name as membership_type_name
	, extract(month from start_date) as month
	, sum(total_paid) as total_revenue
		from membership m
		 join membership_type mt on m.membership_type_id = mt.id
		  where extract(year from start_date) = 2023
		   group by cube(membership_type_name, month)
		    order by membership_type_name, month;
        
```
**Output:**

![7](https://github.com/user-attachments/assets/595630f6-9182-43db-a4f3-ac5987b53be2)
------------------------------------------------------ 

- Now it's time for the final task.
Emily wants to segment customers based on the number of rentals and see the count of customers in 
each segment

```
with cte as (
	select customer_id,count(*),
	case when count(*)>10 then 'more than 10' 
		 when count(*) between 5 and 10 then 'between 5 and 10'
		 else 'fewer than 5' 
		 end as category
		 	from rental 
			 group by customer_id
)
select category as rental_count_category ,count(*) as customer_count 
	from cte 
	  group by category
	   order by customer_count;

```
**Output:**
![8](https://github.com/user-attachments/assets/ae7a4d15-6f02-449b-a8cd-2062251d6800)

------------------------------------------------------

