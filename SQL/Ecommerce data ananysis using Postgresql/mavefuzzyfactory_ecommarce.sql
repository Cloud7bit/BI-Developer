--creating database in postgresql

-- set the schema to create the tables
drop schema mavenfuzzyfactory;
create schema if not exists mavenfuzzyfactory;
set search_path to mavenfuzzyfactory;


--creating website_sessions table:

drop table if exists website_sessions;
create table website_sessions (
  website_session_id bigserial primary key,
  created_at timestamptz not null,
  user_id bigint not null,
  is_repeat_session smallint not null, 
  utm_source varchar(12), 
  utm_campaign varchar(20),
  utm_content varchar(15), 
  device_type varchar(15), 
  http_referer varchar(30)
);

-- creating website_pageviews table:

drop table if exists website_pageviews;
create table website_pageviews (
  website_pageview_id bigserial primary key,
  created_at timestamptz not null,
  website_session_id bigint not null references website_sessions (website_session_id),
  pageview_url varchar(50) not null
);


-- creating products table:
drop table if exists products;
create table products (
  product_id bigserial primary key,
  created_at timestamptz not null,
  product_name varchar(50) not null
);

-- Creating an empty shell for the table 'orders'. We will populate it later. 

drop table if exists orders;
create table orders (
  order_id bigserial primary key,
  created_at timestamptz not null,
  website_session_id bigint not null references website_sessions (website_session_id),
  user_id bigint not null, -- assuming there is a foreign key reference needed here
  primary_product_id smallint not null,
  items_purchased smallint not null,
  price_usd numeric(6,2) not null,
  cogs_usd numeric(6,2) not null
);

-- Creating order_items table 
drop table if exists order_items;
create table order_items (
  order_item_id bigserial primary key,
  created_at timestamptz not null,
  order_id bigint not null references orders (order_id),
  product_id smallint not null references products (product_id),
  is_primary_item smallint not null,
  price_usd numeric(6,2) not null,
  cogs_usd numeric(6,2) not null
);

-- Creating order_item_refunds table
drop table if exists order_item_refunds;
create table order_item_refunds (
  order_item_refund_id bigserial primary key,
  created_at timestamptz not null,
  order_item_id bigint not null references order_items (order_item_id),
  order_id bigint not null references orders (order_id),
  refund_amount_usd numeric(6,2) not null
);

--exploring the e-commerce database

select *
	from orders 
		limit 10;

select * 
	from website_pageviews
		where website_session_id = 20
			order by created_at;		

select count(website_session_id)
		from website_sessions; --4,72,871
		
select count(website_pageview_id)
		  from website_pageviews; --11,88,124
		  
select count(order_id)
		from orders; --32,313

-- average number of pageview per session
select
    count(distinct website_session_id) as total_sessions,
    count(website_pageview_id) as total_pageviews,
    round(count(website_pageview_id):: numeric / count(distinct website_session_id),4) as "average number of pageviews per session"
    	from website_pageviews; --2.5126
		
-- Conversion Rate (CVR): TOTAL ORDERS/TOTAL SESSIONS

select 
	min(created_at), -- 2012-03-19
	max(created_at) -- 2015-03-19
from website_sessions;

-- overall
select
    count(distinct w.website_session_id) as total_sessions, -- 472871
    count(distinct o.order_id) as total_orders, -- 32313
    to_char(round((count(distinct o.order_id)::numeric / count(distinct w.website_session_id)) * 100, 2), 'fm999990.00') || '%' as cvr -- 6.83%
		from website_sessions w
			left join orders o
    			on o.website_session_id = w.website_session_id;

				
-- by year and month
select
    extract(year from w.created_at) as session_year,
    extract(month from w.created_at) as session_month,
    to_char(round((count(distinct o.order_id)::numeric / count(distinct w.website_session_id)) * 100, 2), 'fm999990.00') || '%' as cvr  
		from website_sessions w
			left join orders o
    			on o.website_session_id = w.website_session_id
						group by 1, 2
							order by 1, 2;
							

-- by week 
select
    -- extract(year from w.created_at) as session_year,
    -- extract(week from w.created_at) as session_week,
    min((w.created_at::date - (extract(dow from w.created_at)::integer % 7) * interval '1 day')::date) as week_start_date,
    to_char(round((count(distinct o.order_id)::numeric / count(distinct w.website_session_id)) * 100, 2), 'fm999990.00') || '%' as cvr  
    	from website_sessions w
     		 left join orders o
    			on o.website_session_id = w.website_session_id
				  where w.created_at between '2012-04-01' and '2013-03-31'
					group by extract(year from w.created_at), date_trunc('week', w.created_at - (extract(dow from w.created_at)::integer % 7) * interval '1 day')::date;
						-- order by session_year, session_week;

-- by device type
select
    w.device_type,
    to_char(round((count(distinct o.order_id)::numeric / count(distinct w.website_session_id)) * 100, 2), 'fm999990.00') || '%' as cvr 
		from website_sessions w
			left join orders o
    			on o.website_session_id = w.website_session_id
						group by w.device_type
							order by w.device_type;

-- by device and week

select
    min((w.created_at::date - (extract(dow from w.created_at)::integer % 7) * interval '1 day')::date) as week_start_date,
    to_char(round((count(distinct case when w.device_type = 'desktop' then o.order_id else null end)::numeric / 
          nullif(count(distinct case when w.device_type = 'desktop' then w.website_session_id else null end), 0)) * 100, 2), 'fm999990.00') || '%' as desktop_cvr,
    to_char(round((count(distinct case when w.device_type = 'mobile' then o.order_id else null end)::numeric / 
          nullif(count(distinct case when w.device_type = 'mobile' then w.website_session_id else null end), 0)) * 100, 2), 'fm999990.00') || '%' as mobile_cvr
				from website_sessions w
					left join orders o
					    on o.website_session_id = w.website_session_id
							group by extract(year from w.created_at), date_trunc('week', w.created_at - (extract(dow from w.created_at)::integer % 7) * interval '1 day')::date
								order by extract(year from w.created_at), week_start_date;


select
	utm_source,
	utm_campaign,
	http_referer,
    count(distinct website_session_id) as total_sessions
		from website_sessions
			where website_sessions.created_at < '2013-06-30'
				group by 1, 2, 3;

-- site traffic breakdown by utm_source, utm_campaign, htttp_referer
-- gsearch_paid_sessions, bsearch_paid_sessions, organic_search_sessions, direct_type_in_session
-- gsearch_paid_orders, bsearch_paid_orders, organic_search_orders, direct_type_in_orders
-- gsearch_paid_cvr, bsearch_paid_cvr, organic_search_cvr, direct_type_in_cvr

select
    extract(year from w.created_at) as year,
    extract(month from w.created_at) as month,
    count(distinct case when w.utm_source = 'gsearch' then w.website_session_id else null end) as gsearch_paid_sessions,
    count(distinct case when w.utm_source = 'bsearch' then w.website_session_id else null end) as bsearch_paid_sessions,
    count(distinct case when w.utm_source = 'NULL' and w.http_referer != 'NULL' then w.website_session_id else null end) as organic_search_sessions,
    count(distinct case when w.utm_source = 'NULL' and w.http_referer = 'NULL' then w.website_session_id else null end) as direct_type_in_sessions,
    count(distinct case when w.utm_source = 'gsearch' then o.order_id else null end) as gsearch_paid_orders,
    count(distinct case when w.utm_source = 'bsearch' then o.order_id else null end) as bsearch_paid_orders,
    count(distinct case when w.utm_source = 'NULL' and w.http_referer != 'NULL' then o.order_id else null end) as organic_search_orders,
    count(distinct case when w.utm_source = 'NULL' and w.http_referer = 'NULL' then o.order_id else null end) as direct_type_in_orders,
    -- cvr calculations with nullif() to avoid division by zero
    to_char((count(distinct case when w.utm_source = 'gsearch' then o.order_id else null end) * 100.0) / nullif(count(distinct case when w.utm_source = 'gsearch' then w.website_session_id else null end), 0), 'fm999990.00') || '%' as gsearch_paid_cvr,
	to_char((count(distinct case when w.utm_source = 'bsearch' then o.order_id else null end) * 100.0) / nullif(count(distinct case when w.utm_source = 'bsearch' then w.website_session_id else null end), 0), 'fm999990.00') || '%' as bsearch_paid_cvr,
    to_char((count(distinct case when w.utm_source = 'NULL' and w.http_referer != 'NULL' then o.order_id else null end) * 100.0) / nullif(count(distinct case when w.utm_source = 'NULL' and w.http_referer != 'NULL' then w.website_session_id else null end), 0), 'fm999990.00') || '%' as organic_search_cvr,
    to_char((count(distinct case when w.utm_source = 'NULL' and w.http_referer = 'NULL' then o.order_id else null end) * 100.0) / nullif(count(distinct case when w.utm_source = 'NULL' and w.http_referer = 'NULL' then w.website_session_id else null end), 0), 'fm999990.00') || '%' as direct_type_in_cvr
			from website_sessions w
				left join orders o
			    	on o.website_session_id = w.website_session_id
						where w.created_at < '2013-06-30'
							group by 1, 2
								order by 1, 2;


-- 1. Gsearch seems to be the biggest driver of our business. 
-- Could you pull monthly trends for gsearch sessions and orders 
-- so that we can showcase the growth there?

select
    extract(year from w.created_at) as year,
    extract(month from w.created_at) as month,
    count(w.website_session_id) as gsearch_sessions,
    count(o.order_id) as gsearch_orders,
    to_char(round((count(distinct o.order_id)::numeric / count(distinct w.website_session_id)) * 100, 2), 'fm999990.00') || '%' as gsearch_cvr
		from website_sessions w
			left join orders o
   				 on w.website_session_id = o.website_session_id
					where w.utm_source = 'gsearch' 
  						and w.created_at < '2012-11-27'
							group by 1, 2;

-- 2. Next, it would be great to see a similar monthly trend for Gsearch, 
-- but this time splitting out nonbrand and brand campaigns separately. 
-- I am wondering if brand is picking up at all. If so, this is a good story to tell.

select
    extract(year from website_sessions.created_at) as year,
    extract(month from website_sessions.created_at) as month,
    count(distinct case when utm_campaign = 'nonbrand' then website_sessions.website_session_id end) as nonbrand_sessions,
    count(distinct case when utm_campaign = 'nonbrand' then orders.order_id end) as nonbrand_orders,
    count(distinct case when utm_campaign = 'brand' then website_sessions.website_session_id end) as brand_sessions,
    count(distinct case when utm_campaign = 'brand' then orders.order_id end) as brand_orders
		from website_sessions
			left join orders
			    on website_sessions.website_session_id = orders.website_session_id
					where utm_source = 'gsearch' and website_sessions.created_at < '2012-11-27'
						group by year, month
							order by year, month;


-- 3. Could you get the most-viewed website pages, ranked by session volume?
select pageview_url,count(distinct website_session_id) as total_pageview
		from website_pageviews
			group by pageview_url
				order by total_pageview desc;
				
-- 4. Identify the top entry pages and rank them on entry volume 				
with first_pageview as
(select
	website_session_id,min(website_pageview_id) as starting_pageview_id
		from website_pageviews
			group by website_session_id)
select
	wp.pageview_url as landing_page,
    count(fp.website_session_id) as number_of_sessions
		from first_pageview fp
			left join website_pageviews wp
				on wp.website_pageview_id = fp.starting_pageview_id
					group by landing_page
						order by number_of_sessions desc;

-- 5. while we're on Gsearch, could you dive into nonbrand, 
-- and pull sessions and orders split by device type? 
-- I want to flex our analytical muscles a little and show the board we really know 
-- our traffic sources.		

select
	extract(year from ws.created_at) as year,
    extract(month from ws.created_at) as month,
	count(case when device_type = 'desktop' then ws.website_session_id else null end) as desktop_sessions,
    count(case when device_type = 'desktop' then o.order_id else null end) as desktop_orders,
    count(case when device_type = 'mobile' then ws.website_session_id else null end) as mobile_sessions,
    count(case when device_type = 'mobile' then o.order_id else null end) as mobile_orders
		from website_sessions ws
			left join orders o
				on ws.website_session_id = o.website_session_id
					where utm_source = 'gsearch' 
							and utm_campaign = 'nonbrand' 
							and ws.created_at < '2012-11-27'
								group by 1,2
								order by 2;

-- 6. I'm worried that one of our more pessimistic board members may be concerned about 
-- the large % of traffic from Gsearch. Can you pull monthly trends for Gsearch,
-- alongside monthly trends for each of our other channels.

select
	distinct utm_source,utm_campaign,http_referer
		from website_sessions
		  where created_at < '2012-11-27';
-- first, finding the various utm sources and referers to see the traffic we're getting.
-- pulling the distinct combinations of utm source, utm campaign and http referrer.

select 
    extract(year from w.created_at) as year,
    extract(month from w.created_at) as month,
    count(distinct case when utm_source = 'gsearch' then w.website_session_id end) as gsearch_paid_sessions,
    count(distinct case when utm_source = 'bsearch' then w.website_session_id end) as bsearch_paid_sessions,
    count(distinct case when utm_source = 'NULL' and http_referer != 'NULL' then w.website_session_id end) as organic_search_sessions,
    -- it doesn't have paid tracking but it does have a referring domain from the search engine -> organic search
    count(distinct case when utm_source ='NULL' and http_referer ='NULL' then w.website_session_id end) as direct_type_in_sessions
			from website_sessions w
				left join orders o 
			    	on w.website_session_id = o.website_session_id
						where w.created_at < '2012-11-27'
							group by 1,2
								order by 1,2;



-- 7. I'd like to tell the story of our website performance improvements 
-- over the course of the first 8 months. Could you pull session to order conversion rates, 
-- by month?
select
	extract(year from w.created_at) as year,
    extract(month from w.created_at) as month,
    count(distinct w.website_session_id) as sessions,
    count(distinct o.order_id) as ordrs,
	to_char(round((count(distinct o.order_id)::numeric / count(distinct w.website_session_id)) * 100, 2), 'fm999990.00') || '%' as cvr
		from website_sessions w
			left join orders o
				on w.website_session_id = o.website_session_id
					where w.created_at < '2012-11-27'
						group by 1,2
							order by 1,2;

-- 8. For the gsearch lander test, please estimate the revenue that test earned us.
select min(website_pageview_id) as first_test_pv
	from website_pageviews
		where pageview_url = '/lander-1';
-- min pageview id -> find when the test started. first_test_pv: 23504
DROP TABLE IF EXISTS first_test_pageview;
create temporary table first_test_pageview as
select
    ws.website_session_id,
    min(wp.website_pageview_id) as min_pageview_id
		from website_pageviews wp
			join website_sessions ws
    			on wp.website_session_id = ws.website_session_id
					where wp.website_pageview_id >= '23504'
					    and ws.created_at < '2012-07-28'
					    and utm_source = 'gsearch'
					    and utm_campaign = 'nonbrand'
							group by ws.website_session_id;
select * from first_test_pageview;							
-- session level table. session id, first pageview id of that session.

drop table if exists nonbrand_test_sessions_landing_pages;
create temporary table nonbrand_test_sessions_landing_pages as
select
    wp.website_session_id,
    wp.pageview_url as landing_page
		from first_test_pageview fp
			left join website_pageviews wp
		    	on fp.min_pageview_id =wp.website_pageview_id
					where wp.pageview_url in ('/home', '/lander-1');
					
select * from nonbrand_test_sessions_landing_pages;	
-- bring in the landing page for each session but restricting to home/lander-1

drop table if exists nonbrand_test_session_orders;
create temporary table nonbrand_test_session_orders as
select
    np.website_session_id,
    np.landing_page,
    o.order_id
		from nonbrand_test_sessions_landing_pages np
			left join orders o
		    	on np.website_session_id = o.website_session_id;

select * from  nonbrand_test_session_orders;
-- bring in orders

select
    landing_page,
    count(distinct website_session_id) as sessions,
    count(distinct order_id) as orders,
    to_char(round((count(distinct order_id)::numeric / count(distinct website_session_id)) * 100, 2), 'fm999990.00') || '%' as cvr
		from nonbrand_test_session_orders
			group by landing_page;


select 
    max(ws.website_session_id) as most_recent_gsearch_nonbrand_home_session
		from website_sessions ws
			left join website_pageviews wp
    			on ws.website_session_id = wp.website_session_id
					where utm_source = 'gsearch'
					    and utm_campaign = 'nonbrand'
					    and wp.pageview_url = '/home'
					    and ws.created_at < '2012-11-27';
-- find the last home lander traffic so that we can find when all traffic is rerouted to lander-1

select count(website_session_id) as sessions_since_test
		from website_sessions
			where created_at < '2012-11-27'
				and website_session_id > 17145
			    and utm_source = 'gsearch'
			    and utm_campaign = 'nonbrand';

-- 9. For the landing page test you analyzed previously, it would be great to show a 
-- full conversion funnel from each of the two pages to orders. 
-- You can use the same time period you analyzed last time (Jun 19 - Jul 28).
drop table if exists session_level_made_it_flagged;

create temporary table session_level_made_it_flagged as
select
    website_session_id,
    max(homepage) as saw_homepage,
    max(custom_lander) as saw_custom_lander,
    max(products_page) as product_made_it,
    max(mrfuzzy_page) as mrfuzzy_made_it,
    max(cart_page) as cart_made_it,
    max(shipping_page) as shipping_made_it,
    max(billing_page) as billing_made_it,
    max(thankyou_page) as thankyou_made_it
from (
    select
        ws.website_session_id,
        wp.pageview_url,
        case when pageview_url = '/home' then 1 else 0 end as homepage,
        case when pageview_url = '/lander-1' then 1 else 0 end as custom_lander,
        case when pageview_url = '/products' then 1 else 0 end as products_page,
        case when pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
        case when pageview_url = '/cart' then 1 else 0 end as cart_page,
        case when pageview_url = '/shipping' then 1 else 0 end as shipping_page,
        case when pageview_url = '/billing' then 1 else 0 end as billing_page,
        case when pageview_url = '/thank-you-for-your-order' then 1 else 0 end as thankyou_page
    from website_sessions ws
    left join website_pageviews wp
        on ws.website_session_id = wp.website_session_id
    where ws.utm_source = 'gsearch'
        and ws.utm_campaign = 'nonbrand'
        and ws.created_at > '2012-06-19'
        and ws.created_at < '2012-07-28'
    order by ws.website_session_id, ws.created_at
		) as pageview_level
			group by website_session_id;

select * from session_level_made_it_flagged;			

select
    case
        when saw_homepage = 1 then 'saw_homepage'
        when saw_custom_lander = 1 then 'saw_custom_lander'
        else 'uh oh ... check logic'
    end as segment,
    to_char((count(distinct case when product_made_it = 1 then website_session_id else null end) * 100.0 / count(distinct website_session_id)), 'fm999990.00') || '%' as lander_click_rt,
    to_char((count(distinct case when mrfuzzy_made_it = 1 then website_session_id else null end) * 100.0 / count(distinct case when product_made_it = 1 then website_session_id else null end)),'fm999990.00') || '%' as products_click_rt,
    to_char((count(distinct case when cart_made_it = 1 then website_session_id else null end) * 100.0 / count(distinct case when mrfuzzy_made_it = 1 then website_session_id else null end)),'fm999990.00') || '%' as mrfuzzy_click_rt,
    to_char((count(distinct case when shipping_made_it = 1 then website_session_id else null end) * 100.0 / count(distinct case when cart_made_it = 1 then website_session_id else null end)),'fm999990.00') || '%' as cart_click_rt,
    to_char((count(distinct case when billing_made_it = 1 then website_session_id else null end) * 100.0 / count(distinct case when shipping_made_it = 1 then website_session_id else null end)),'fm999990.00') || '%' as shipping_click_rt,
    to_char((count(distinct case when thankyou_made_it = 1 then website_session_id else null end) * 100.0 / count(distinct case when billing_made_it = 1 then website_session_id else null end)),'fm999990.00') || '%' as billing_click_rt
		from session_level_made_it_flagged
			group by segment;

-- 10. I'd love for you to quantify the impact of our billing test, as well. 
-- Please analyze the lift generated from the test (Sep 10 - Nov 10), 
-- in terms of revenue per billing page session, and then 
-- pull the number of billing page sessions for the past month(10/27-11/27) 
-- to understand monthly impact.			
select
    billing_version_seen,
    count(distinct website_session_id) as sessions,
    round(sum(price_usd) / count(distinct website_session_id),2) as revenue_per_billing_page_seen
from (
    select
        wp.website_session_id, 
        wp.pageview_url as billing_version_seen, 
        o.order_id, 
        o.price_usd
    		from website_pageviews wp
			    left join orders o
			        on wp.website_session_id = o.website_session_id
			    		where wp.created_at > '2012-09-10'
				        and wp.created_at < '2012-11-10'
				        and wp.pageview_url in ('/billing', '/billing-2')
							) as billing_version_revenue
							group by billing_version_seen;

select count(website_session_id) as billing_sessions_last_month
		from website_pageviews
			where pageview_url in ('/billing', '/billing-2')
			    and created_at > '2012-10-27'
			    and created_at < '2012-11-27';  -- past month

-----------------------------------------------------------------------------------------------------

-- 1. First, I'd like to show our volume growth. Can you pull overall session and 
-- order volume, trended by quarter for the life of the business? 
-- Since the most recent quarter is incomplete, you can decide how to handle it.

select
    extract(year from ws.created_at) as yr,
    extract(quarter from ws.created_at) as qtr,
    count(distinct ws.website_session_id) as sessions,
    count(distinct order_id) as orders
		from website_sessions ws
		    left join orders o
		        on ws.website_session_id = o.website_session_id
					group by 1, 2
					order by 1, 2;


-- 2. Next, let's showcase all of our efficiency improvements. I would love to show 
-- quarterly figures since we launched, for session-to-order conversion rate, 
-- revenue per order, and revenue per session.
select
    extract(year from website_sessions.created_at) as yr,
    extract(quarter from website_sessions.created_at) as qrt,
    to_char((count(distinct orders.order_id) * 1.0 / count(distinct website_sessions.website_session_id)) * 100, 'fm999990.00') || '%' as session_to_order_conv_rate,
    to_char(round(sum(orders.price_usd) / count(distinct orders.order_id),2), 'fm$999990.00') as revenue_per_order,
	to_char(round(sum(orders.price_usd) / count(distinct website_sessions.website_session_id), 2), 'fm$999990.00') as revenue_per_session
		from website_sessions
		    left join orders
		        on website_sessions.website_session_id = orders.website_session_id
					group by 1, 2
					order by 1, 2;


-- 3. I'd like to show how we've grown specific channels. Could you pull a quarterly view 
-- of orders from Gsearch nonbrand, Bsearch nonbrand, brand search overall, organic search, 
-- and direct type-in?

select
    extract(year from ws.created_at) as yr,
    extract(quarter from ws.created_at) as qrt,
    count(distinct case when utm_source = 'gsearch' and utm_campaign = 'nonbrand' then o.order_id else null end) as gsearch_nonbrand_orders,
    count(distinct case when utm_source = 'bsearch' and utm_campaign = 'nonbrand' then o.order_id else null end) as bsearch_nonbrand_orders,
    count(distinct case when utm_campaign = 'brand' then o.order_id else null end) as brand_search_orders,
    count(distinct case when utm_source = 'NULL' and http_referer != 'NULL' then o.order_id else null end) as organic_search_orders,
    count(distinct case when utm_source  = 'NULL' and http_referer  = 'NULL' then o.order_id else null end) as direct_orders
		from website_sessions ws
		    left join orders o
		        on ws.website_session_id = o.website_session_id
					group by 1, 2
					order by 1, 2;

-- 4. Next, let's show the overall session-to-order conversion rate trends for those 
-- same channels, by quarter. Please also make a note of any periods where we made major 
-- improvements or optimizations.
select
    extract(year from ws.created_at) as yr,
    extract(quarter from ws.created_at) as qrt,
    round(count(distinct case when utm_source = 'gsearch' and utm_campaign = 'nonbrand' then o.order_id else null end) * 100.0 / 
            nullif(count(distinct case when utm_source = 'gsearch' and utm_campaign = 'nonbrand' then ws.website_session_id else null end), 0), 2) || '%' as gsearch_nonbrand_conv_rt,
    round(count(distinct case when utm_source = 'bsearch' and utm_campaign = 'nonbrand' then o.order_id else null end) * 100.0 /
            nullif(count(distinct case when utm_source = 'bsearch' and utm_campaign = 'nonbrand' then ws.website_session_id else null end), 0), 2) || '%' as bsearch_nonbrand_conv_rt,
    round(count(distinct case when utm_campaign = 'brand' then o.order_id else null end) * 100.0 /
            nullif(count(distinct case when utm_campaign = 'brand' then ws.website_session_id else null end), 0), 2) || '%' as brand_search_conv_rt,
    round(count(distinct case when utm_source = 'NULL' and http_referer != 'NULL' then o.order_id else null end) * 100.0 /
            nullif(count(distinct case when utm_source = 'NULL' and http_referer != 'NULL' then ws.website_session_id else null end), 0), 2) || '%' as organic_search_conv_rt,
    round(count(distinct case when utm_source = 'NULL' and http_referer = 'NULL' then o.order_id else null end) * 100.0 /
            nullif(count(distinct case when utm_source = 'NULL' and http_referer = 'NULL' then ws.website_session_id else null end), 0), 2) || '%' as direct_type_in_conv_rt
				from website_sessions ws
				    left join orders o 
				        on ws.website_session_id = o.website_session_id
							group by 1, 2
							order by 1, 2;

--- 5. We've come a long way since the days of selling a single product. 
-- Let's pull monthly trending for revenue and margin by product, 
-- along with total sales and revenue. Note anything you notice about seasonality.
select
    extract(year from created_at) as yr,
    extract(month from created_at) as mo,
    to_char(sum(case when product_id = 1 then price_usd else null end), '$fm999,999,999.00') as mrfuzzy_rev,
    to_char(sum(case when product_id = 1 then price_usd - cogs_usd else null end), '$fm999,999,999.00') as mrfuzzy_marg,
    to_char(sum(case when product_id = 2 then price_usd else null end), '$fm999,999,999.00') as lovebear_rev,
    to_char(sum(case when product_id = 2 then price_usd - cogs_usd else null end), '$fm999,999,999.00') as lovebear_marg,
    to_char(sum(case when product_id = 3 then price_usd else null end), '$fm999,999,999.00') as birthdaybear_rev,
    to_char(sum(case when product_id = 3 then price_usd - cogs_usd else null end), '$fm999,999,999.00') as birthdaybear_marg,
    to_char(sum(case when product_id = 4 then price_usd else null end), '$fm999,999,999.00') as minibear_rev,
    to_char(sum(case when product_id = 4 then price_usd - cogs_usd else null end), '$fm999,999,999.00') as minibear_marg
			from order_items
				group by 1, 2
				order by 1, 2;


-- 6. Let's dive deeper into the impact of introducing new products. 
-- Please pull monthly sessions to the /products page, and show how the % of those sessions 
-- clicking through another page has changed over time, along with a view of how conversion 
-- from /products to placing an order has improved.
-- first, identifying all the views of the /products page

with products_pageviews as (
    select
        website_session_id,
        website_pageview_id,
        created_at as saw_product_page_at
		    from website_pageviews
		    	where pageview_url = '/products'
)
select
    extract(year from pp.saw_product_page_at) as yr,
    extract(month from pp.saw_product_page_at) as mo,
    count(distinct pp.website_session_id) as sessions_to_product_page,
    count(distinct wp.website_session_id) as click_to_next_page,
    to_char(round(
            count(distinct wp.website_session_id) * 100.0 / 
            nullif(count(distinct pp.website_session_id), 0), 2), 'fm999.00') || '%' as clickthrough_rt,
    count(distinct orders.order_id) as orders,
    to_char(round(count(distinct orders.order_id) * 100.0 /
			nullif(count(distinct pp.website_session_id), 0), 2), 'fm999.00') || '%' as products_to_order_rt
			from products_pageviews pp
			    left join website_pageviews wp
			        on pp.website_session_id = wp.website_session_id
			        and wp.website_pageview_id > pp.website_pageview_id
					    left join orders
					        on orders.website_session_id = pp.website_session_id
								group by 1, 2
								order by 1, 2;


-- 7. We made our 4th product available as a primary product on 
-- December 05, 2014 (it was previously only a cross-sell item). 
-- Could you please pull sales data since then, and show how well each product cross-sells 
-- from one another?
drop table if exists primary_products;
create temporary table primary_products as
select
    order_id,
    primary_product_id,
    created_at as ordered_at
		from orders
			where created_at > '2014-12-05';

-- use the temporary table in the next query
select
    pp.*,
    oi.product_id as cross_sell_product_id
		from primary_products pp
		    left join order_items oi
		        on pp.order_id = oi.order_id
		        and oi.is_primary_item = 0;  -- only bringing in cross-sells

select 
    primary_product_id,
    count(distinct order_id) as total_orders,
    count(distinct case when cross_sell_product_id = 1 then order_id else null end) as _xsold_p1,
    count(distinct case when cross_sell_product_id = 2 then order_id else null end) as _xsold_p2,
    count(distinct case when cross_sell_product_id = 3 then order_id else null end) as _xsold_p3,
    count(distinct case when cross_sell_product_id = 4 then order_id else null end) as _xsold_p4,
        to_char(round(count(distinct case when cross_sell_product_id = 1 then order_id else null end) * 100.0 / count(distinct order_id), 2),
        'fm999990.00') || '%' as p1_xsold_rt,
        to_char(round(count(distinct case when cross_sell_product_id = 2 then order_id else null end) * 100.0 / count(distinct order_id), 2),
        'fm999990.00') || '%' as p2_xsold_rt,
        to_char(round(count(distinct case when cross_sell_product_id = 3 then order_id else null end) * 100.0 / count(distinct order_id), 2),
        'fm999990.00') || '%' as p3_xsold_rt,
        to_char(round(count(distinct case when cross_sell_product_id = 4 then order_id else null end) * 100.0 / count(distinct order_id), 2),
        'fm999990.00') || '%' as p4_xsold_rt
				from (
				    select
				        pp.*,
				        oi.product_id as cross_sell_product_id
				    from primary_products pp
				    left join order_items oi
				        on pp.order_id = oi.order_id
				        and oi.is_primary_item = 0
				) as primary_w_cross_sell
				group by 1;


		
							