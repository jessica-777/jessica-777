-- Total number of Listings
select COUNT(listing_id) AS Number_of_listings from listing;

-- Total Number of Hosts
select count(distinct(host_id)) AS Number_of_hosts from listing;

-- Total number of visitors 
select count(distinct(reviewer_id)) AS Number_of_Visitors from reviews;

-- Number of Reviews 
select count(distinct(review_id)) AS Number_of_Reviews from reviews;

-- Number of Superhosts
select count(host_is_superhost) AS Number_of_SuperHosts from listing where host_is_superhost = 't' ;

-- Count of different property type sorted in decending order 
select property_type,count(property_type) from listing group by property_type order by count(property_type) desc;

-- Count of  different room type sorted in decending order  
select room_type,count(room_type) from listing group by room_type order by count(room_type) desc;

-- Number of properties that can be instantly booked 
select count(instant_bookable) AS Number_of_InstantBookable_properties from listing where instant_bookable = 't' ;

-- Average of accomodates 
select avg(accommodates) AS Average_number_of_Accommodates from listing;

-- Average overall Rating 
select avg(scores_rating) AS Avg_Overall_Rating  from listing;

-- Average Easy checkin Rating
select avg(review_checkin) AS Avg_Easy_Checkin_Rating  from listing;

-- Average cleanliness Ratings
select avg(review_cleanliness) AS Avg_Cleanliness_Rating  from listing;

-- Average value for money Rating
select avg(review_value_for_money) AS Avg_ValueForMoney_Rating  from listing;

-- Average Location Rating 
select avg(review_location) AS Avg_Location_Rating  from listing;

-- Average number of listings per Host
SELECT 
    AVG(host_total_listings_count) AS Average_Listings_Per_Host
FROM
    (SELECT 
        COUNT(*) AS host_total_listings_count
    FROM
        listing
    GROUP BY host_id) AS listing_counts;
    
    
--  Creating Conversion Rate Table 
create table conversion_rates (city varchar (20), conversion_rate float);

insert into conversion_rates values('Paris',1.08), ('New York',1), ('Bangkok' ,0.027), ('Rio de Janeiro' ,0.20), 
(' Rome' ,1.08), ('Hong Kong',0.13), ('Mexico City' ,0.061), ('Cape Town' ,0.053) ;
select* from conversion_rates;

-- Converting all the prices into a common currency (USD)
UPDATE listing l 
JOIN conversion_rates cr ON l.city = cr.city 
SET l.price = l.price * cr.conversion_rate;
    
   -- Average Price (USD) of an Airbnb 
   select avg(price) from listing;
    
-- Sum of Revenue earned by all Airbnbs 
SELECT SUM(l.price * r.num_reviews) AS total_revenue
FROM listing l
JOIN (
    SELECT listing_id, COUNT(*) AS num_reviews
    FROM reviews
    GROUP BY listing_id
) r ON l.listing_id = r.listing_id;





select property_type,count(property_type) as Number_of_prop from listing group by property_type 
order by Number_of_prop desc limit 5;
select room_type,count(room_type) as Number_of_rooms from listing group by room_type 
order by Number_of_rooms desc;

-- Top 5 cities on the basis of Revenue 
SELECT 
    l.city,
    SUM(l.price * r.num_reviews) AS total_revenue
FROM listing l
JOIN (SELECT listing_id, COUNT(*) AS num_reviews FROM reviews
        GROUP BY listing_id
		) r ON l.listing_id = r.listing_id
GROUP BY l.city order by total_revenue desc limit 5;

-- Number of new listings per Year (Date Function)
select year(str_to_date(listing_date,'%d-%m-%Y')) 
as LYear,count(listing_id) as No_of_listings 
from listing group by LYear order by No_of_listings desc ;

-- Percentage change in revenue from last year (Window Function)
SELECT listing_year,total_revenue,
    LAG(total_revenue) OVER (ORDER BY listing_year) AS previous_year_revenue,
    ((total_revenue - LAG(total_revenue) OVER (ORDER BY listing_year)) / LAG(total_revenue) OVER 
    (ORDER BY listing_year)) * 100 AS revenue_change_percentage
FROM (SELECT YEAR(STR_TO_DATE(l.listing_date, '%d-%m-%Y')) AS listing_year, SUM(l.price * r.num_reviews) AS total_revenue
    FROM listing l JOIN ( SELECT listing_id, COUNT(*) AS num_reviews
	FROM reviews GROUP BY listing_id) r ON l.listing_id = r.listing_id
    GROUP BY listing_year) AS revenue_data;
