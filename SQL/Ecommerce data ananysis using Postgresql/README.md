
# Ecommerce data analysis using Sql 

## Project Description
In this SQL project, I took on the role of an eCommerce Database Analyst for Maven Fuzzy Factory, a startup online retailer. Working with the CEO, Marketing Manager, and Website Manager, I analyzed marketing channels, measured website performance, and explored the product portfolio to help guide business decisions.


## Tech Stack Used 
**Postgresql**
![sql-server](https://github.com/user-attachments/assets/2a390e3d-c8d2-4642-a8ed-19deec734af8) 

------------------------------------------------------


![Green Clean Website traffic Analysis Graph](https://github.com/user-attachments/assets/1253d5a8-510d-45dc-af74-a3e93c35e0b0)


------------------------------------------------------

## Overview of the Maven Fuzzy Factory Database

![Maven FuzzyFactory Database Schema](https://github.com/user-attachments/assets/d342a5a4-ed70-44d1-b29f-92d33834681d)

The six tables listed above are essential and represent the core data an e-commerce database analyst would regularly work with. While slightly simplified, they still contain the most important information, such as website activity, products, orders, and refunds, which are fundamental to daily operations.

------------------------------------------------------                               

Before diving into the project, I’d like to quickly go over some common web and digital marketing terms.
## UTM (Urchin Tracking Module) Tracking Parameters

When businesses run paid marketing campaigns, they often obsess over performance and measure everything - how much they spend, how well traffic converts to sales, etc. Paid traffic is commonly tagged with tracking (UTM) parameters, which are appended to URLs. It allows us to tie website activity back to specific traffic sources and campaigns.

![Paid Marketing Campaign](https://github.com/user-attachments/assets/2874afa9-d526-41c1-9911-36bd1848cb29)

In the URL above, the “?” indicates that everything following it won’t affect the browser’s location for finding the page. Instead, it's used for tracking purposes. The parameter-value pairs (highlighted in yellow) are separated by ampersands (&).

In today's database:

- UTM sources: Include gsearch (Google) and bsearch (Bing).
- UTM campaigns: Include nonbrand and brand. The nonbrand group refers to people searching for a product category (e.g., "Teddy Bears," "Buy Toys Online"). The brand group includes users specifically searching for your company by name (e.g., "Maven," "Fuzzy Factory").
- UTM content: Includes g_ad_1, g_ad_2, b_ad_1, b_ad_2. Many companies use UTM content to track the names of specific ad units they're running.

------------------------------------------------------ 

## Situation and Objective
**The Situation**: Maven Fuzzy Factory has been operating for around eight months, and the CEO needs to present company performance metrics to the board next week. As the analyst, it's my responsibility to prepare the key metrics that highlight the company’s strong growth.

**The Objective**: Use SQL to extract and analyze website traffic and performance data from the Maven Fuzzy Factory database, demonstrating the company's growth and telling the story of how this success was achieved.

------------------------------------------------------ 

## Analyses Requests From the CEO

------------------------------------------------------ 
**Q**: Can you show me the average number of pageview per session?
```
-- average number of pageview per session
select
    count(distinct website_session_id) as total_sessions,
    count(website_pageview_id) as total_pageviews,
    round(count(website_pageview_id):: numeric / count(distinct website_session_id),4) as "average number of pageviews per session"
    	from website_pageviews;
```
**output:**
![1](https://github.com/user-attachments/assets/48238b03-f928-41c8-893d-ecfe62697086)

------------------------------------------------------ 

**Q**: Could you get the most-viewed website pages, ranked by session volume?
```
select pageview_url,count(distinct website_session_id) as total_pageview
		from website_pageviews
			group by pageview_url
				order by total_pageview desc;

```
**output:**
![4](https://github.com/user-attachments/assets/68118ef9-33c8-4098-9746-c8b82e944851)

------------------------------------------------------ 

**Q**: Identify the top entry pages and rank them on entry volume 	
```
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
```
**output:**
![5](https://github.com/user-attachments/assets/ef91c2c3-c8da-4d32-aaae-93079ad1eeac)

------------------------------------------------------ 

**Q**: Gsearch seems to be the biggest driver of our business. Could you pull monthly trends for gsearch sessions and orders so that we can showcase the growth there?
```
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
```
**output:**
![2](https://github.com/user-attachments/assets/0345470a-76e2-4f36-bbc3-02a7b58c190e)

[Results/Insights]: It's evident that session volume has been steadily increasing. In the first month, there were just 1,860 sessions, but that number has now grown to 8,889.

Order volume has also seen significant growth. Starting with 92 orders in March, or April as the first full month, we've now achieved about four times that amount.

The conversion rate has improved as well, rising from around 2.6% during the first three months to over 4% by the final month—a positive development for the business.

------------------------------------------------------ 

**Q**: Next, it would be great to see a similar monthly trend for Gsearch, but this time splitting out nonbrand and brand campaigns separately. I am wondering if brand is picking up at all? If so, this is a good story to tell.

```
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
```

**output:**
![3](https://github.com/user-attachments/assets/1b37e083-9a19-4c9d-b73a-9ddf44f16daa)

[Results/Insights]: Brand campaigns involve users actively searching for our business on search engines and clicking on our ads—companies often bid on their own brand terms to keep competitors at bay. The board is curious if the company will always depend on paid traffic or if the brand is growing organically. This is one indicator of whether the brand is gaining traction. The substantial increase in brand sessions is a very positive sign that investors will appreciate.

------------------------------------------------------ 

**Q**: While we are on Gsearch, could you dive into nonbrand, and pull monthly sessions and orders split by device type? I want to flex our analytical muscles a little and show the board we really know our traffic sources.

```
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
```

**output:**
![6](https://github.com/user-attachments/assets/9f1c4017-196c-4430-8c3a-6ab1b5de9ad1)

[Results/Insights]: We observe significantly more desktop sessions compared to mobile. Initially, the desktop-to-mobile ratio was just under 2:1, but by the end of the period, it’s grown to over 3:1. The difference in orders is even more pronounced, starting with a 5:1 ratio and nearly doubling to a 10:1 ratio by the end.

------------------------------------------------------

**Q**:I’m worried that one of our more pessimistic board members may be concerned about the large % of traffic from Gsearch. Can you pull monthly trends for Gsearch, alongside monthly trends for each of our other channels.

```
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
```

**output:**
![7](https://github.com/user-attachments/assets/6eda360d-3692-40c1-b64b-62a27e47f38f)
- We have UTM source values of Gsearch (Google) and Bsearch (Bing), with UTM campaign values for both brand and nonbrand categories. These represent our paid channels, but we also want to analyze other channels like direct type-in traffic and organic search.

- Direct type-in traffic occurs when UTM source and UTM campaign (our paid parameters) are both NULL, and the http referrer is also NULL—indicating no referring domain. When all three are NULL, we can attribute the traffic to direct type-in.

- Organic search traffic is identified when the UTM source and UTM campaign are NULL, but we have a search engine as the http referrer. This means the traffic is coming from a search engine but isn’t linked to our paid campaigns, classifying it as organic search traffic.

![8](https://github.com/user-attachments/assets/6685ee09-3eaf-48a1-a562-fa09d218b1cb)

[Results/Insights]: The board and CEO will be especially pleased with the growth in organic search and direct type-in sessions, as these represent traffic the company isn’t paying for. In contrast, sessions from Gsearch and Bsearch involve customer acquisition costs for any resulting orders, which reduce the profit margin due to marketing expenses. However, there are no additional variable costs associated with direct type-in and organic search traffic.

------------------------------------------------------

**Q**: I’d like to tell the story of our website performance improvements over the course of the first 8 months. Could you pull session to order conversion rates, by month?
```
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
```
**output:**
![9](https://github.com/user-attachments/assets/0f7d1d9e-324a-4712-9d4a-39915b4f7a96)

[Results/Insights]: The conversion rate began around 2.6%, increased to 3.5%, and continued to steadily climb into the 4% range.

------------------------------------------------------

**Q**: For the gsearch lander test, please estimate the revenue that test earned us.

The website manager conducted an A/B test from June 19 to July 28, comparing a new custom landing page (/lander-1) against the homepage (/home) for Gsearch nonbrand traffic, splitting the traffic 50/50.

Essentially, the goal is to determine which landing page generates more revenue and by how much, quantifying the difference in terms of monthly revenue.

```
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
```
**output:**
![10](https://github.com/user-attachments/assets/ecade108-ef14-43f3-98de-030bd574c467)

![11](https://github.com/user-attachments/assets/f1f10b7c-1c38-4026-8dbd-93209e045b19)

![12](https://github.com/user-attachments/assets/83628357-e270-4bee-95a1-e344eed5357f)

![13](https://github.com/user-attachments/assets/75617c52-b409-4fa2-9b02-18276da7c4d5)

![15](https://github.com/user-attachments/assets/3675c963-daec-4e78-b76c-67ea76df898b)

[Results/Insights]: The results table indicates that lander-1 has a slightly better conversion rate compared to the homepage. While it's not a full percentage point higher, it does result in about 0.88% more orders per session. After calculating this uplift, we need to identify the most recent pageview for Gsearch nonbrand traffic that was directed to '/home'.

***In marketing, “lift” represents an increase in sales in response to some form of advertising or promotion. Monitoring, measuring, and optimizing lift may help a business grow more quickly.***

![16](https://github.com/user-attachments/assets/713625d5-85e0-4bb4-adc3-40f947dce139)

The "most_recent_gsearch_nonbrand_home_session" is 17145, which represents the last session ID where Gsearch nonbrand traffic was directed to the '/home' page. After that, all the traffic has been redirected to '/lander-1'. Next, we can analyze how many sessions have occurred since this traffic shift.


![17](https://github.com/user-attachments/assets/5dac6c11-cf0d-47b4-83ad-5304fddbc3ea)

[Results/Insights]:Since rerouting all traffic to lander-1, we've had 22,977 sessions. With an incremental conversion rate of 0.88%, this translates to 202 additional orders after the home page A/B test concluded.

In terms of monthly performance, this generates about 50 extra orders per month over roughly 4 months (from 7/29 to 11/27), leading to a consistent increase of around 50 additional orders each month.

***Incremental Conversion: When we talk about “incremental conversion”, we are talking about how well a new version of something converts compared to the previous version. Conversion Rate B — Conversion Rate A = incremental conversion.***

------------------------------------------------------

**Q**:For the landing page test you analyzed previously, it would be great to show a full conversion funnel from each of the two pages to orders. You can use the same time period you analyzed last time (Jun 19 — Jul 28).

Here, I began by identifying which version of the pages users interacted with and tracking how far they progressed through the conversion funnel.


```
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
```

**output:**

![18](https://github.com/user-attachments/assets/6b5ab005-5eb3-482c-82c8-06464e6313b1)

In this step, we have the website session data along with every pageview URL for the specific session ID, and a flag (1/0) indicating whether the page was the homepage, lander-1, or another page. This will serve as a subquery in the analysis below.

![19](https://github.com/user-attachments/assets/430dbd93-8302-4e89-93fe-db36bd325622)

The results above show, for each session, whether users saw the homepage or the custom landing page ('/lander-1'). Additionally, we have the completion rates for different stages of the conversion funnel.

![20](https://github.com/user-attachments/assets/f4c0e3ed-96f0-49ed-a40c-c92b9bf6a54f)

The final table shows the percentage of users who clicked through from the landing page to products and other steps in the conversion process.

------------------------------------------------------

**Q**: I’d love for you to quantify the impact of our billing page AB test as well. Please analyze the lift generated from the test (Sep 10 — Nov 10), in terms of revenue per billing page session, and then pull the number of billing page sessions for the past month(10/27–11/27) to understand monthly impact.

The website manager conducted a 50/50 A/B test between a new custom billing page (/billing-2) and the original billing page (/billing) from June 19 to July 28.

```
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
```

**output:**

![21](https://github.com/user-attachments/assets/d9ea436e-aeec-4f70-ad75-caf68e84ff71)

![22](https://github.com/user-attachments/assets/680db4c3-8be2-4bcb-96f5-b8dd65c93649)

[Results/Insights]:The old billing page generated $22.83 in revenue per view, while the new version brings in $31.34. This change has resulted in a significant increase in revenue, with an uplift of $8.51 per billing page view. Each time a customer views the billing page, we’re now earning $8.51 more than before.

Lastly, we’re going to look at how many sessions we’ve had where somebody hit the billing page within the past month (10/27–11/27).

![23](https://github.com/user-attachments/assets/431adbf3-c0a3-44a5-93ab-9541c35efc1f)

[Results/Insights]:

There were 1,193 billing sessions in the past month, with a revenue lift of $8.51 per session. The impact of this billing test amounts to $10,152.43 in additional revenue over the past month (1,193 sessions * $8.51 per session).\

------------------------------------------------------

## Next, I'll leverage the database to analyze the channel mix in more detail, examining the balance between paid and organic traffic. I'll also conduct a time series analysis to explore product sales trends and seasonality, providing insights into the company’s growth trajectory.

### Situation and Objective
**The Situation**: Maven Fuzzy Factory has been in the market for three years, achieving significant growth that has positioned the company to raise a larger round of venture capital. The CEO is on the verge of securing this funding and needs assistance in presenting a compelling, data-driven growth story to investors.

**The Objective**: I will use SQL to extract and analyze website traffic and performance data, highlighting the marketing channels, website improvements, and sales activities that have fueled the company's success. This will demonstrate rapid growth and showcase my analytical skills to support the CEO's pitch to investors.

**Key Events**:

- January 2013: The second product, "Love Bear," was launched, aimed at couples for Valentine’s Day.
- December 12, 2013: The third product, "Birthday Bear," was introduced, targeting the birthday gift market.
- February 5, 2014: A fourth product, "Bear Accessory," was launched as a cross-sell item.
- December 5, 2014: The "Bear Accessory" became available as a standalone primary product, no longer just a cross-sell.

------------------------------------------------------

**Q**: First, I’d like to show our volume growth. Can you pull overall session and order volume, trended by quarter for the life of the business? Since the most recent quarter is incomplete, you can decide how to handle it.

```
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
```
**output:**
![24](https://github.com/user-attachments/assets/2c4d3f00-ed42-4503-a2c0-790d643bff14)

Now, as we wrap up three years of business, the growth has been remarkable. Initially, we had just 60 orders, and now we’re seeing around 100 times that number. Session volume has experienced similar significant growth, making the progress quite impressive.

------------------------------------------------------

**Q**: Next, let’s showcase all of our efficiency improvements. I would love to show quarterly figures since we launched, for session-to-order conversion rate, revenue per order, and revenue per session.

```
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
```

**output:**
![25](https://github.com/user-attachments/assets/cc0c2cf8-a2ae-4d00-94ee-782e498b9cf3)

We’ve seen a similar growth story in session-to-order conversion rates, which have risen from around 3% to over 8% in the latest quarter. Revenue per order, which started at a flat $49.99 when the company sold only one product, has now surpassed $60 due to cross-selling and optimization efforts. Revenue per session, initially around $1.60, has climbed to over $5 in the most recent quarter.

***This revenue-per-session metric is crucial, as it determines how much the marketing director can allocate to acquire traffic. The higher this figure, the more they can bid, increasing the likelihood of winning traffic, ranking higher in auctions, and gaining more visibility for your ads.***

------------------------------------------------------

**Q**: I’d like to show how we’ve grown specific channels. Could you pull a quarterly view of orders from Gsearch nonbrand, Bsearch nonbrand, brand search overall, organic search, and direct type-in?

```
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
```
**output:**
![27](https://github.com/user-attachments/assets/98b67b25-dc76-4873-a934-33e4d02932c5)

One key factor that will excite potential investors is the significant growth in brand search, organic search, and direct type-in traffic. In Q2 of 2012, the ratio of Google Search nonbrand to brand+free traffic was nearly 6:1. By Q1 of 2015, this ratio had dropped to about 2:1. The business has become much less reliant on paid nonbrand campaigns, showing strong progress in building its own brand, organic, and direct type-in traffic—channels with better margins that reduce dependency on search engines.

------------------------------------------------------

**Q**: Next, let’s show the overall session-to-order conversion rate trends for those same channels, by quarter. Please also make a note of any periods where we made major improvements or optimizations.

```
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
```
**output:**
![28](https://github.com/user-attachments/assets/c90c79a6-db21-452e-9405-e7b341a40970)

The Google Search non-brand campaign's conversion rate (CVR) has jumped from 3.2% to over 8% in the most recent quarter, more than doubling in performance. Similarly, with Bing Search, although we didn't initially run a non-brand campaign, we've since introduced it and seen growth.

What’s especially exciting is that our direct channels: Brand Search, Organic Search, and Direct Type_In_have all shown significant improvements from their starting points to where they are now. These efficiency gains will impress investors and demonstrate that we are consistently optimizing and improving the business.

------------------------------------------------------

**Q**: We’ve come a long way since the days of selling a single product. Let’s pull monthly trending for revenue and margin by product, along with total sales and revenue. Note anything you notice about seasonality.

```
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
```
**output:**

![29](https://github.com/user-attachments/assets/5f414afe-8213-4ca1-95f3-84653bc0bd78)

MrFuzzy’s revenue initially stood at around $3,000 per month, but by February 2015, it had increased to $55,000 (March data is only partial). We’ve also seen some standout months, like November and December, where revenue reached $72,000 and $79,000 due to the holiday season, which tends to drive a yearly sales surge.

For the Love Bear, there’s a significant spike in February each year, which aligns with its target as a Valentine’s Day gift for couples.

While we anticipate similar year-end trends for the Birthday Bear and Mini Bear, it’s a bit harder to confirm due to limited data, making seasonality patterns less clear.

------------------------------------------------------

**Q**:Let’s dive deeper into the impact of introducing new products. Please pull monthly sessions to the /products page, and show how the % of those sessions clicking through another page has changed over time, along with a view of how conversion from /products to placing an order has improved.

```
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

```

**output:**

![30](https://github.com/user-attachments/assets/6e155214-55a9-48e7-b7fc-9dad22cc5c88)

![31](https://github.com/user-attachments/assets/e59fbb75-5c07-4b24-92bf-c36211b4c0d2)

The key point to highlight, beyond the overall growth in sessions reaching the product page, is the increase in the clickthrough rate from 71% at the start of the business to 85% in the most recent month. Similarly, the conversion rate—people moving from the product page to making a full purchase has risen from 7% to 14% over the same period.

These improvements, such as adding products that appeal to a wider audience and introducing lower-priced options, have significantly contributed to the overall health and success of the business.

------------------------------------------------------

**Q**:We made our 4th product available as a primary product on December 05, 2014 ( it was previously only a cross-sell item). Could you please pull sales data since then, and show how well each product cross-sells from one another?

```
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
```

**output:**

![32](https://github.com/user-attachments/assets/e447ec74-f288-49e3-baf8-1fce73629b53)

![33](https://github.com/user-attachments/assets/192ad3be-c9ff-4485-b38a-fe10f50b1d16)

![34](https://github.com/user-attachments/assets/5664adc5-543d-4a42-9ce5-8d8eb8eacb6e)

Product 1 remains the top performer, followed by products 2 and 3, with product 4 being the least likely to be a primary purchase. However, product 4 cross-sells effectively with products 1, 2, and 3, likely because of its lower price point, making it an easy add-on for customers. Over 20% of orders for primary products 1, 2, and 3 also include product 4. Notably, product 3 cross-sells particularly well with product 1.

### Conclution

As an analyst, witnessing the business's evolution and how it adapted based on analytical insights has given me a clear understanding of the value an analyst brings. Not only did I enhance my SQL skills, but I also gained valuable eCommerce business knowledge. By optimizing the business, everything becomes more competitive our website improves, we sell products more effectively, and we can better compete in ad auctions, ultimately driving higher traffic volumes.
