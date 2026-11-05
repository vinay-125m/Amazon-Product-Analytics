CREATE DATABASE IF NOT EXISTS amazon_db
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
  
USE amazon_db;

Show databases;

CREATE TABLE amazon_product_data (
  product_id          VARCHAR(20),
  product_name        VARCHAR(600),
  main_category       VARCHAR(50),
  sub_category        VARCHAR(80),
  product_type        VARCHAR(80),
  discounted_price    DECIMAL(10,2),
  actual_price        DECIMAL(10,2),
  discount_percentage VARCHAR(10),
  calculated_discount VARCHAR(10),
  rating              DECIMAL(3,1),
  savings             DECIMAL(10,2),
  rating_count        VARCHAR(20),
  about_product       TEXT,
  user_id             MEDIUMTEXT,
  user_name           MEDIUMTEXT,
  review_id           MEDIUMTEXT,
  review_title        MEDIUMTEXT,
  review_content      MEDIUMTEXT,
  img_link            MEDIUMTEXT,
  product_link        MEDIUMTEXT
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE '/Users/mutyalavinay/Downloads/amazon_product_data.csv'
INTO TABLE amazon_product_data
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

describe amazon_product_data;

set sql_safe_updates = 1;

UPDATE amazon_product_data
SET
    discount_percentage =
        NULLIF(REGEXP_REPLACE(TRIM(discount_percentage), '[^0-9.-]', ''), ''),
    calculated_discount =
        NULLIF(REGEXP_REPLACE(TRIM(calculated_discount), '[^0-9.-]', ''), ''),
    rating_count =
        NULLIF(REPLACE(TRIM(rating_count), ',', ''),'');
        
Alter table amazon_product_data
Modify column discount_percentage decimal(5,2),
Modify column calculated_discount decimal(10,2),
Modify column rating_count Bigint;

SELECT count(*) from amazon_product_data;

Select count( Distinct product_id) as Total_products from amazon_product_data;

select round(avg(discounted_price),2) as avg_discounted_price from amazon_product_data;

select round(avg(discount_percentage),2) as avg_discount from amazon_product_data;

select round(avg(rating),2) as avg_rating from amazon_product_data;

select sum(rating_count) as Total_Ratings from amazon_product_data;

select main_category,count(distinct product_id) as Total_products 
from amazon_product_data
group by main_category
order by Total_products desc;

select main_category,round(avg(rating),2) as avg_rating
from amazon_product_data
group by main_category
order by avg_rating desc;

select product_name, main_category, rating, rating_count
from amazon_product_data
order by rating_count desc
limit 10;

select main_category,
	round(avg(actual_price),2) as avg_actual_price,
    round(avg(discounted_price),2) as avg_discounted_price,
    round(avg(actual_price-discounted_price),2) as avg_savings
from amazon_product_data
group by main_category
order by avg_savings desc;

select product_id, product_name, discount_percentage, rating, rating_count
from amazon_product_data
where discount_percentage is not null and rating is not null
order by discount_percentage desc;

select product_id, product_name, main_category, actual_price, discount_percentage
from amazon_product_data
order by discount_percentage desc
limit 10;

with category_performance as (
	select main_category,
		count(distinct product_id) as Total_products,
        round(avg(rating),2) as avg_rating
    from amazon_product_data
    group by main_category
)
select *, 
	case 
		when avg_rating>=4.0 then 'Excellent'
        when avg_rating >=3.5 then 'Good'
        when avg_rating >=3.0 then 'Average'
        else 'Below Average' end as Grade
from category_performance;

With ranked_products as (
	select product_id,
		product_name,
        main_category,
        rating,
        rating_count,
		rank() over(partition by main_category order by rating desc) as product_rank,
        dense_rank() over(partition by main_category order by rating desc) as product_dense_rank
	from amazon_product_data
)
select * 
from ranked_products where product_rank <= 5
order by main_category, product_rank 

