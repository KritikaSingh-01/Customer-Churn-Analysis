-- Step 1:
-- CREATE DATABASE customer_churned;
-- use customer_churned;

-- step 2:
-- then IMPORTING CSV FILE

-- step 3: verify
SELECT *
FROM customer_churned_cleaned
LIMIT 5;

SELECT COUNT(*) as Total_Customers
FROM customer_churned_cleaned;
# The dataset contains info for 7043 customers

SELECT Churn,COUNT(*) AS Customers
FROM customer_churned_cleaned
GROUP BY Churn;
# INSIGHT: 1869 customers left the company and 5174 customers stayed.

-----------------------------------------------------------------------------
# Step 4 : calculating churn rate
SELECT ROUND(
SUM(CASE
        WHEN Churn='Yes' THEN 1
        ELSE 0
    END) * 100.0 / COUNT(*), 2) AS Churn_Rate
FROM customer_churned_cleaned;

-- Convert 'Yes' to 1 and 'No' to 0
-- Sum the 1's to get total churned customers
-- Divide by total customers and multiply by 100
-- Round the result to 2 decimal places


---------------------------------------------------------------------------
# Step 5 : Churn by gender
SELECT gender, Churn, COUNT(*) AS Customers
FROM customer_churned_cleaned
GROUP BY gender, Churn
ORDER BY gender;

# INSIGHT:
-- Male and female customers have nearly the same churn count.
-- Gender does not significantly influence customer churn.


------------------------------------------------------------------------------
# Step 6 : Contract vs Churn
SELECT Contract, Churn, COUNT(*) AS Customers
FROM customer_churned_cleaned
GROUP BY Contract, Churn
ORDER BY Contract;

# INSIGHT:
-- Customers with month-to-month contracts have the highest churn count,
-- whereas customers with two-year contracts have the lowest churn count.
-- This indicates that churn decreases as contract duration increases.


-------------------------------------------------------------------------------------
# Step 7 : Payment method vs churn
SELECT PaymentMethod,  Churn, COUNT(*) AS Customers
FROM customer_churned_cleaned
GROUP BY PaymentMethod, Churn
ORDER BY PaymentMethod; 

# INSIGHT:
-- Customers using Electronic Check have the highest churn count,
-- whereas customers using automatic payment methods have lower churn.
-- This indicates that payment method is associated with customer retention.


-------------------------------------------------------------------------------------------
# Step 8 : Internet service vs churn
SELECT InternetService,  Churn, COUNT(*) AS Customers
FROM customer_churned_cleaned
GROUP BY InternetService, Churn
ORDER BY InternetService; 

# INSIGHT:
-- Customers using Fiber Optic internet service have the highest churn count,
-- whereas customers with no internet service have the lowest churn count.
-- This suggests that factors such as pricing, service quality, or customer
-- expectations may be contributing to higher churn among Fiber Optic users.


------------------------------------------------------------------------------------
# Step 9 : AVG Monthly Charges by Churn
SELECT Churn,  ROUND(AVG(MonthlyCharges),2) AS Avg_Monthly_Charges
FROM customer_churned_cleaned
GROUP BY Churn;

# INSIGHT:
-- Customers who churned have higher average monthly charges
-- than customers who stayed. This suggests that higher monthly
-- fees may be a contributing factor to customer churn.


-----------------------------------------------------------------------------------------
# Step 10 : AVG Total Charges by Churn
SELECT Churn,  ROUND(AVG(TotalCharges),2) AS Avg_Total_Charges
FROM customer_churned_cleaned
GROUP BY Churn;

# INSIGHT:
-- Customers who stayed have significantly higher average total charges
-- than customers who churned. Long-term customers contribute more
-- revenue to the company.


-----------------------------------------------------------------------------------------
# Step 11 : AVG Tenure by Churn 
SELECT Churn,  ROUND(AVG(tenure),2) AS Avg_Tenure
FROM customer_churned_cleaned
GROUP BY Churn;                                    

# INSIGHT:
-- Customers who churned have a much lower average tenure than
-- customers who stayed. New customers are more likely to leave
-- the company than long-term customers.


----------------------------------------------------------------------------------------
# Step 12 : Senior Citizen VS Churn
SELECT SeniorCitizen,Churn,COUNT(*) AS Customers
FROM customer_churned_cleaned
GROUP BY SeniorCitizen, Churn
ORDER BY SeniorCitizen;

# INSIGHT:
-- Senior citizens have a higher churn count compared to
-- non-senior customers, indicating that this segment is
-- more likely to leave the company.

-------------------------------------------------------------------------
# "ADVANCED SQL ANALYSIS"
----------------------------------------------------------------------------------
# Step 13 :
# "ADVANCED ANALYSIS USING WINDOW FUNCTIONS"

# 1.Rank contract Types by churn count (using window fun)
SELECT Contract, COUNT(*) AS Churned_Customers,
RANK() OVER (
	   ORDER BY COUNT(*) DESC) AS Churn_Rank
FROM customer_churned_cleaned
WHERE Churn = 'Yes'
GROUP BY Contract;

# INSIGHT :
-- By ranking contract types based on churn count, it is evident that Month-to-Month customers contribute the most to overall churn, while
-- Two-Year contract customers have the lowest churn. 
-- This suggests that longer contract commitments significantly improve customer retention.



# 2. Rank Payment Methods by churn count (using window fun)
SELECT PaymentMethod, COUNT(*) AS Churned_Customers,
DENSE_RANK() OVER (
		ORDER BY COUNT(*) DESC) AS Payment_Rank
FROM customer_churned_cleaned
WHERE Churn = 'Yes'
GROUP BY PaymentMethod;

# INSIGHT:
-- The ranking analysis indicates that Electronic Check has the highest number
-- of churned customers and is ranked first in customer attrition. 
-- This suggests that customers using Electronic Check are more likely to leave the company
-- compared to customers using automatic payment methods.

----------------------------------------------------------------------------------
# Step 14: Tenure Bucket vs Churn
SELECT 
    CASE 
        WHEN tenure <= 12 THEN '0-1 Year'
        WHEN tenure <= 24 THEN '1-2 Years'
        ELSE '2+ Years'
    END AS Tenure_Group,
    Churn,
    COUNT(*) AS Customers
FROM customer_churned_cleaned
GROUP BY Tenure_Group, Churn
ORDER BY Tenure_Group;

# INSIGHT:
-- New customers (0-1 year) have the highest churn count,
-- while long-term customers (2+ years) are more likely to stay.
-- This suggests early retention efforts are critical.

-------------------------------------------------------------------------------
# Step 15 : Churn Rate % by Contract Type
SELECT Contract,
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS Churned,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) 
        * 100.0 / COUNT(*), 2) AS Churn_Rate_Pct
FROM customer_churned_cleaned
GROUP BY Contract
ORDER BY Churn_Rate_Pct DESC;

# INSIGHT:
-- Month-to-month customers have the highest churn rate %,
-- confirming they are the most at-risk segment.

---------------------------------------------------------------------------
# Step 16 : Monthly Revenue Lost Due to Churn
SELECT 
    ROUND(SUM(MonthlyCharges), 2) AS Revenue_Lost_Monthly,
    ROUND(AVG(MonthlyCharges), 2) AS Avg_Lost_Per_Customer
FROM customer_churned_cleaned
WHERE Churn = 'Yes';

# INSIGHT:
-- Shows the total monthly revenue lost due to churned customers.
-- Helps business understand the financial impact of attrition.

--------------------------------------------------------------------------
# Step 17 : CTE Summary - Key Churn Metrics
WITH churn_summary AS (
    SELECT 
        Contract, 
        InternetService, 
        PaymentMethod,
        COUNT(*) AS Total,
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) 
		AS Churned,
        ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
            * 100.0 / COUNT(*), 2) AS Churn_Pct
    FROM customer_churned_cleaned
    GROUP BY Contract, InternetService, PaymentMethod
)
SELECT * FROM churn_summary
WHERE Churned > 50
ORDER BY Churn_Pct DESC;

# INSIGHT:
-- This CTE combines contract, internet service and payment method
-- to identify the highest risk customer combinations.
-- Segments with Churn_Pct above 50% need immediate attention.

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
# SQL CONCEPTS USED :
-- 1. SELECT, FROM and LIMIT for data retrieval and verification.
-- 2. COUNT(), AVG(), SUM() and ROUND() for aggregation and calculations.
-- 3. GROUP BY and ORDER BY for data segmentation and sorting.
-- 4. CASE WHEN for conditional logic and churn rate calculation.
-- 5. Window Functions (RANK(), DENSE_RANK()) for ranking high-churn customer segments.
-- 6. CTE (Common Table Expressions) for multi-dimension churn analysis.
-- 7. WHERE clause for filtering specific segments like churned customers.
-- 8. Subgroup analysis across Contract, Payment Method, Internet Service,
--    Gender, Senior Citizen, and Tenure for business insight generation.

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
# Final Business Findings

-- • Month-to-month customers have the highest churn risk.
-- • Fiber optic customers show the highest churn percentage.
-- • Electronic Check users churn more frequently.
-- • Customers with tenure below one year are the most vulnerable.
-- • Long-term contracts significantly improve retention.
-- • Churn leads to considerable monthly revenue loss.