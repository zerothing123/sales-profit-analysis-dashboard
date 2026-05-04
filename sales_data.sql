select * from sales_data
--Calculate total sales, total profit, and profit margin for the entire dataset
create view overall_performance as
select sum(sales) as total_sales ,sum(profit) as total_profit ,sum(profit)*100.00/sum(sales) as profit_margin from sales_data

SELECT * FROM overall_performance
--Identify which regions generate high sales but low profit
create view region_analysis as
SELECT 
    region,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit
FROM sales_data
GROUP BY region
ORDER BY total_sales DESC, total_profit ASC;

SELECT * FROM region_analysis

--Find which categories and sub-categories are loss-making or low margin

create view category_subcategory_analysis as
select Category, sub_Category, sum(profit) as total_profit, sum(profit)*100.00/sum(sales) as margin from sales_data
group by Category, sub_Category 
having sum(profit) <0
and sum(profit)*100.00/sum(sales)  <10
order by total_profit Asc,  margin asc

SELECT * FROM category_subcategory_analysis

--Analyze how discount levels affect profit across categorie
create view discount_impact_analysis as
SELECT 
    Category,
    AVG(discount) AS avg_discount,
    AVG(profit) AS avg_profit
FROM sales_data
GROUP BY Category order by avg_discount, avg_profit

SELECT * FROM discount_impact_analysis

--Identify top 10 profitable products and bottom 10 loss-making products
create view product_performance as
with prod as (
select product_name, AVG(profit) AS avg_profit from sales_data group by product_name 
)
select * from (select *, row_number() over (order by avg_profit desc) as Rnk
from prod) where Rnk<=10
union all 
select * from(select *, row_number() over (order by avg_profit asc) as Rnk from prod) where Rnk <=10

SELECT * FROM product_performance

--Find top customers contributing to revenue and profit

create view customer_analysis as
select * from (select customer_name, 
sum(sales) as total_sales , 
sum(profit) as sum_profit ,
row_number() over(order by sum(sales) desc) as rnk
from sales_data group by customer_name) where rnk<=10
SELECT * FROM customer_analysis

--Compare shipping modes based on profit and delivery patterns
create view shipping_mode_analysis as
select ship_mode , avg(profit) as avg_profit , avg(order_date - ship_date) as dilivery_time from sales_data group by ship_mode
order by avg_profit desc, dilivery_time asc
SELECT * FROM shipping_mode_analysis


--Analyze monthly sales and profit trends over time
create view time_trend_analysis as
select date_trunc('month',order_date) as month, 
avg(sales) as avg_sales, 
avg(profit) as profit 
from sales_data 
group by date_trunc('month',order_date) order by month
SELECT * FROM time_trend_analysis

--Identify combinations of region + category where profit is negative
create view profit_leakage_analysis as
select region, category, sum(profit) as total_profit from sales_data  group by region, category having sum(profit)<0
SELECT * FROM profit_leakage_analysis


--Find orders where high sales resulted in low or negative profit
create view order_efficiency_analysis as
select * from sales_data where sales > (select avg(sales) from sales_data)
and profit <(select avg(profit) from sales_data)
SELECT * FROM order_efficiency_analysis