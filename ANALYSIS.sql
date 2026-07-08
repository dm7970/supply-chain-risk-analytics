 # Identifying which regions face the highest delivery delays to optimize logistics.
SELECT Order_Region,Category_Name,COUNT(*) as Total_Orders,
SUM(CASE WHEN 'Late_delivery_risk' = 1 THEN 1 ELSE 0 END) as Late_Orders,
ROUND(AVG('Days_for_shipping_real' - 'Days_for_shipment_scheduled'), 2) as Avg_Delay_Days,
RANK() 
OVER (PARTITION BY `Order_Region` ORDER BY COUNT(*) DESC) as Category_Rank
FROM supply_chain_data
GROUP BY 'Order_Region', 'Category_Name';


# Calculating when to reorder stock to avoid going out-of-stock
 
SELECT Product_Name,category_Name,
ROUND(AVG(`Order_Item_Quantity`), 2) as Avg_Daily_Sales,
ROUND(AVG(`Days_for_shipping_real`), 2) as Avg_Lead_Time,
ROUND((AVG(`Order_Item_Quantity`) * AVG(`Days_for_shipping_real`)) + 5, 0) as Reorder_Per_Units
FROM supply_chain_data
GROUP BY `Product_Name`, `Category_Name`
ORDER BY Reorder_Per_Units DESC;


#High-Risk & Fraud Analytics 
# Tracking down 'SUSPECTED_FRAUD' orders to minimize money leakag

SELECT Order_Country,Department_Name,COUNT(*) as Fraud_Order_Count,
SUM(`Sales`) as Total_Fraud_Amount
FROM supply_chain_data
WHERE `Order_Status` = 'SUSPECTED_FRAUD'
GROUP BY `Order_Country`, `Department_Name`
ORDER BY Total_Fraud_Amount DESC;


# Checking which shipping methods (like First Class) fail delivery deadlines most often.



# High-Risk Sales Regions (Revenue Leakage)
# Business Impact: Tracking where order cancellations or returns ('ON_HOLD', 'CANCELED') are blocking money.

SELECT Order_Region,Order_Status,
COUNT(*) as Total_Orders,
SUM(`Sales`) as Revenue_At_Risk
FROM supply_chain_data
WHERE `Order_Status` IN ('ON_HOLD', 'CANCELED')
GROUP BY `Order_Region`, `Order_Status`;

# Top 3 Performing Products per Department
# Business Impact: Extracting the top 3 best-selling products in each department for warehouse management.
SELECT *
FROM (
SELECT
Department_Name,
Product_Name,
sum(Sales) AS Total_Product_Sales,
DENSE_RANK() OVER (
PARTITION BY Department_Name
ORDER BY SUM(Sales) DESC
) AS Sales_Rank
FROM supply_chain_data
GROUP BY Department_Name, Product_Name
) AS Ranked_Products
WHERE Sales_Rank <= 3;