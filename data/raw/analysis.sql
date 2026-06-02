SELECT *
FROM monthly_revenue;

SELECT *
FROM subscriptions;

SELECT
	plan,
    COUNT(*) AS total_customers,
    SUM(CASE
		WHEN churned = "Yes" THEN 1
        ELSE 0
	END) AS churned_customers,
    ROUND(100 * SUM(CASE
		WHEN churned = "Yes" THEN 1
        ELSE 0
	END) / COUNT(*), 2) AS churn_rate
FROM subscriptions
GROUP by plan
ORDER BY churn_rate DESC;
    
SELECT
	billing_cycle,
    COUNT(*) AS total_customers,
    SUM(CASE
		WHEN churned = "Yes" THEN 1
        ELSE 0
	END) AS churned_customers,
    ROUND(100 * SUM(CASE
		WHEN churned = "Yes" THEN 1
        ELSE 0
	END) / COUNT(*), 2) AS churn_rate
FROM subscriptions
GROUP by billing_cycle
ORDER BY churn_rate DESC;

SELECT
	company_size,
    COUNT(*) AS total_customers,
    SUM(CASE
		WHEN churned = "Yes" THEN 1
        ELSE 0
	END) AS churned_customers,
    ROUND(100 * SUM(CASE
		WHEN churned = "Yes" THEN 1
        ELSE 0
	END) / COUNT(*), 2) AS churn_rate
FROM subscriptions
GROUP by company_size
ORDER BY churn_rate DESC;

SELECT
	acquisition_channel,
    COUNT(*) AS total_customers,
    SUM(CASE
		WHEN churned = "Yes" THEN 1
        ELSE 0
	END) AS churned_customers,
    ROUND(100 * SUM(CASE
		WHEN churned = "Yes" THEN 1
        ELSE 0
	END) / COUNT(*), 2) AS churn_rate
FROM subscriptions
GROUP by acquisition_channel
ORDER BY churn_rate DESC;

SELECT
	plan,
    billing_cycle,
    COUNT(*) AS total_customers,
    SUM(CASE
		WHEN churned = "Yes" THEN 1
        ELSE 0
	END) AS churned_customers,
    ROUND(100 * SUM(CASE
		WHEN churned = "Yes" THEN 1
        ELSE 0
	END) / COUNT(*), 2) AS churn_rate
FROM subscriptions
GROUP by plan, billing_cycle
ORDER BY churn_rate DESC;

## Which subscription plan (Starter, Professional, Business, Enterprise) has the highest churn rate? Does billing cycle (monthly vs. annual) significantly impact retention?

## Starter has the highest churn rate at 70.51%. Nearly half of the churned customers are from the starter plan. Enterprise has the smallest churn rate at 22.00%. However, only 50 of 600 customers are on the enterprise plan. This may indicate that the customers on the higher-tier plan receive more value from the platform and are less likely to cancel their plan.

## Monthly cycle has a churn rate of 60.51%. The annual cycle has a churn rate of 40.32%. The 20% gap is significant enough to warrant consideration of its impact on retention. Customers who commit to annual plans may be more invested in the platform and less likely to leave.

## Regarding company size, there seems to be no consistent pattern. However, a larger company (500+) has the highest churn rate at 63.16%, while a smaller company (51-200) has the lowest at 42.55%. Additional analysis may be required to determine whether company size is a meaningful predictor of churn.

## For the acquisition channel, referral has the highest churn rate at 61.29%, and direct sales has the lowest churn rate at 39.29%.

## The Starter plan with a monthly billing cycle had the highest churn rate at 76.87%, substantially higher than any other segment. The next highest churn rates were Starter Annual (60.24%), Professional Monthly (57.58%), and Business Monthly (52.87%). Most annual subscription segments had churn rates below 36%, while Enterprise customers maintained relatively low churn rates across billing cycles.

## The results suggest that both subscription tier and billing cycle influence retention. Customers on the Starter plan may be using the product as a low-commitment trial before deciding whether to continue. Additionally, monthly subscriptions provide greater flexibility to cancel, which may contribute to higher churn rates across multiple plan types.

SELECT
	churn_reason,
    COUNT(*) AS churn_count
FROM subscriptions
WHERE churned = "Yes"
GROUP BY churn_reason
ORDER BY churn_count DESC
LIMIT 3;

SELECT
    plan,
    churn_reason,
    COUNT(*) AS churn_count
FROM subscriptions
WHERE churned = 'Yes'
GROUP BY plan, churn_reason
ORDER BY plan, churn_count DESC;

SELECT
    company_size,
    churn_reason,
    COUNT(*) AS churn_count
FROM subscriptions
WHERE churned = 'Yes'
GROUP BY company_size, churn_reason
ORDER BY company_size, churn_count DESC;

## Top 3 churn reasons are 1. budget cuts, 2. price too high, and 3. company closed.

## For the starter plan, the top 2 churn reasons are price too high and budget cuts, with 29 each. This suggests that many companies can't afford these plans with what they are looking for.
## For a business plan, among the top churn reasons are missing features, no longer needed, and poor support. This indicates the current plan isn't meeting expectations so that an improved plan would be helpful.

## For a company size of 1-10, the two top churn reasons are budget cuts and price too high. This makes sense given that it is a very small company that is looking to grow revenue. The same goes for companies with 51-200 and 201-500 employees.

## Overall, it is likely that plans, especially starter plans, are pricey for many smaller companies. The company may consider evaluating pricing strategies, discounts, or promotional offers for smaller businesses, as pricing-related concerns are among the most common churn drivers.

SELECT
	plan,
    ROUND(AVG(monthly_revenue), 2) AS avg_monthly_revneue,
    ROUND(AVG(lifespan_months), 2) AS avg_lifespan_months,
    ROUND(AVG(monthly_revenue) * AVG(lifespan_months), 2) AS customer_lifetime_value, 
    ROUND(AVG(monthly_revenue) * AVG(lifespan_months) / AVG(avg_cac), 2) AS clv_cac_ratio
FROM (
	SELECT *,
	CASE
		WHEN churned = "Yes"
			THEN TIMESTAMPDIFF(MONTH, signup_date, churn_date)
		ELSE TIMESTAMPDIFF(MONTH, signup_date, '2025-12-31')
	END AS lifespan_months
	FROM subscriptions
	) lifespan_table
CROSS JOIN (
	SELECT AVG(customer_acquisition_cost) AS avg_cac
	FROM monthly_revenue
    ) cac_table
GROUP BY plan;

## Which plans are the most and least profitable?

## Enterprise customers provide the highest customer lifetime value and CLV:CAC ratio, making them the most valuable customer segment in the dataset.

## Starter customers generate the lowest average monthly revenue and have the shortest average customer lifespan. As a result, the Starter plan produces the lowest customer lifetime value and CLV:CAC ratio among all plans.

SELECT month, monthly_churn_rate_pct, total_active_customers, churned_customers
FROM monthly_revenue;

SELECT
	churned,
    AVG(feature_usage_pct) AS avg_feature_usage_pct,
    AVG(nps_score) AS avg_nps_score,
    AVG(support_tickets_12mo) AS avg_support_tickets_12mo
FROM subscriptions
GROUP BY churned;