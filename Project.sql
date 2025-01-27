-- To know how many products are stored in each warehouses and which have higher number inventory levels
select w.warehouseCode, Count(p.productCode) as totalProducts, Sum(p.quantityInStock) as totalstock
from products p join warehouses w on p.warehouseCode = w.warehouseCode
group by w.warehouseCode
order by totalstock desc;

-- To see which product is getting sold frequently, added '$' and formatted total sales as currency
select p.productCode, p.productName, sum(o.quantityOrdered) as TotalQuantitySold, Concat('$ ',format(sum(o.quantityOrdered * priceEach),0)) as TotalSales
from products p join orderdetails o on p.productCode = o.productCode
group by  p.productCode, p.productName
order by TotalQuantitySold desc;

-- Checks the distribution of products across warehouses by productline
select productLine, warehouseCode, count(productCode) as TotalProducts, Sum(quantityInStock) as TotalStock
from products
group by productLine, warehouseCode
order by TotalStock desc;

-- Checking for products with low sales.
select p.productCode, p.productName, Sum(o.quantityOrdered) as TotalQuantitySold
from products p join orderdetails o on p.productCode = o.productCode
group by p.productCode, p.productName
having TotalQuantitySold < 900
order by TotalQuantitySold asc;

-- Evaluating the sales and profitability of each product line.
select p.productLine, sum(o.quantityOrdered * priceEach) as TotalSales, format(avg(o.priceEach),2) as AvgPrice, Count( distinct p.productCode) as ProductCount
from products p join orderdetails o on p.productCode = o.productCode
group by productLine
order by TotalSales desc;

-- Orders and Delivery performance  by warehouse
select w.warehouseCode, count(distinct o1.orderNumber) as TotalOrders, sum(o2.quantityOrdered) as TotalQuantityDelivered
from orders o1 
join  orderdetails o2 on o1.orderNumber = o2.orderNumber
join products p on o2.productCode = p.productCode
join warehouses w on p.warehouseCode = w.warehouseCode
group by w.warehouseCode
order by TotalOrders desc
limit 0, 1000;

-- Most Profitable Product Lines
select p.productLine, sum(o.quantityOrdered * priceEach) as TotalSales, format(avg(o.priceEach),2) as AvgSellingPrice, 
format(Max(o.priceEach),2) as MaxPrice, format(Min(o.priceEach),2) as MinPrice
from products p
join orderdetails o on p.productCode = o.productCode
group by p.productLine
order by TotalSales desc;

-- Top 5 Customers by Total Purchases
select c.customerName, sum(o2.quantityOrdered * priceEach) as TotalSpent, Count(distinct o1.orderNumber) as TotalOrders
from customers c join orders o1 on c.customerNumber = o1.customerNumber
join orderdetails o2 on o1.orderNumber = o2.orderNumber
group by c.customerName
order by TotalSpent desc
limit 5;

-- This query calculates the delivery status of orders by comparing the shippedDate with the requiredDate.
select orderNumber, datediff(shippedDate, requiredDate) as DeliveryTime,
Case when datediff(shippedDate, requiredDate) < 0 then 'Before Time'
when datediff(shippedDate, requiredDate) = 0  then 'On Time'
when datediff(shippedDate, requiredDate) <=3   then 'Slight Delay'
else 'Delayed'
end as DeliveryStatus
from orders
where shippedDate is not null
order by DeliveryTime asc;

-- This query categorizes products based on sales velocity
select p.productCode, p.productName, sum(o.quantityOrdered) as TotalQuantitySold,
case when sum(o.quantityOrdered) > 1000 then 'Fast Moving'
when sum(o.quantityOrdered) between 700 and 1000 then 'Moderate'
else 'slow moving'
end as productCategory
from products p 
left join orderdetails o on p.productCode = o.productCode
group by p.productCode, p.productName
order by TotalQuantitySold desc;

-- To check for products stored in more than one warehouse which could indicate redundant storage
select productCode, count(distinct warehouseCode) as WarehouseCount
from products
group by productCode
having warehouseCount > 1
order by warehouseCount desc; -- no they are not stored more than 1 warehouse

-- This query relates to if situation for 5% across all vehicle types and calculate the total impact
select productLine, sum(quantityInStock) as TotalStock, sum(quantityInStock) * 0.95 as ReducedStock, sum(quantityInStock) - sum(quantityInStock) * 0.95 as ReductionImpact 
from products
group by productLine
order by ReductionImpact desc;