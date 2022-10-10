-- What are the top 5 brands by receipts scanned for most recent month?
SELECT brandCode, COUNT(DISTINCT receiptId) AS brand_cnt
FROM receipts A
JOIN items B
ON A._id = B.receiptId
WHERE EXTRACT(YEAR_MONTH FROM dateScanned) = (SELECT EXTRACT(YEAR_MONTH FROM MAX(dateScanned)) FROM receipts)
GROUP BY brandCode
HAVING brandCode IS NOT NULL
ORDER BY brand_cnt DESC
LIMIT 5;

-- How does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking for the previous month?
WITH ranking_most_recent_month AS (
SELECT brandCode, COUNT(DISTINCT receiptId) AS brand_cnt
FROM receipts A
JOIN items B
ON A._id = B.receiptId
WHERE EXTRACT(YEAR_MONTH FROM dateScanned) = (SELECT EXTRACT(YEAR_MONTH FROM MAX(dateScanned)) FROM receipts)
GROUP BY brandCode
HAVING brandCode IS NOT NULL
ORDER BY brand_cnt DESC
LIMIT 5),
previous_month AS (SELECT brandCode, COUNT(DISTINCT receiptId) AS brand_cnt
FROM receipts A
JOIN items B
ON A._id = B.receiptId
WHERE EXTRACT(YEAR_MONTH FROM dateScanned) = (SELECT EXTRACT(YEAR_MONTH FROM MAX(dateScanned)) - '1 month' FROM receipts)
GROUP BY brandCode
HAVING brandCode IS NOT NULL
ORDER BY brand_cnt DESC
)
SELECT A.brandCode, RANK() OVER (ORDER BY A.brand_cnt DESC) AS rank_recent_month, RANK() OVER (ORDER BY B.brand_cnt DESC) AS rank_previous_month
FROM ranking_most_recent_month A
LEFT JOIN previous_month B
ON A.brandCode = B.brandCode;

-- When considering average spend from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
SELECT rewardsReceiptStatus, AVG(totalSpent) AS avg_spend
FROM receipts
GROUP BY 1
ORDER BY 2 DESC;

-- When considering total number of items purchased from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
SELECT rewardsReceiptStatus, AVG(purchasedItemCount) AS avg_spend
FROM receipts
GROUP BY 1
ORDER BY 2 DESC;

-- Which brand has the most spend among users who were created within the past 6 months?
SELECT B.brandCode, SUM(B.finalPrice) AS Totalspend
FROM receipts A
JOIN items B ON A._id = B.receiptId
JOIN users C ON A.userId = C._id
WHERE C.createdDate >= NOW() - '6 months'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- Which brand has the most transactions among users who were created within the past 6 months?
SELECT B.brandCode, COUNT(DISTINCT B.receiptId) AS transaction_cnt
FROM receipts A
JOIN items B ON A._id = B.receiptId
JOIN users C ON A.userId = C._id
WHERE C.createdDate >= NOW() - '6 months'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;
