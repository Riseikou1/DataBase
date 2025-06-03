USE classicmodels;


-- Q1 : 대륙별 지점의 수를 검색.

SELECT 	territory, COUNT(*) 지점수
FROM 	offices 
GROUP 	BY territory;

-- Q2 : 직책이 'Sales Rep'가 아닌 직원의 성명과 직책을 검색.


SELECT 	CONCAT(firstName, ' ', lastName) AS 성명, jobTitle AS 직책
FROM 	employees
WHERE	jobTitle <> 'Sales Rep';


-- Q3 : 재고 개수가 9,000개 이상인 상품의 상품명, 재고 개수, 구매단가, 권장 소비자가를 검색.


SELECT 	name AS 상품명, quantityInStock AS '재고 개수', 
		CONCAT('USD ', buyPrice) AS 구매단가, 
		CONCAT('USD ', MSRP) AS '권장 소비자가'
FROM 	products
WHERE	quantityInStock >= 9000;

-- Q4 : 상품라인이 'Classic Cars' 혹은 'Vintage Cars'이고, 제조사가 'Studio M Art Models'이며, 
--		권장 소비자가가 50에서 100 사이인 상품을 검색.

SELECT 	productCode, name, vendor, MSRP, productLine
FROM 	products 
WHERE 	(productLine = 'Classic Cars' OR productLine = 'Vintage Cars') AND 
		vendor = 'Studio M Art Models' AND
		(MSRP >= 50 AND MSRP <= 100); 


-- Q5 : 상품라인별로 상품수와 최대, 최소, 평균 구매단가를 검색.

SELECT 	productLine, COUNT(*) 상품수,	
		MAX(buyPrice) '최대 구매단가', MIN(buyPrice) '최소 구매단가',
		ROUND(AVG(buyPrice),2) '평균 구매단가' 
FROM 	products 
GROUP 	BY productLine;

-- Q6 : 'Ships'와 'Trains' 상품라인의 상품수를 검색.


SELECT 	productLine 상품라인, COUNT(*) 상품수
FROM 	products 
GROUP 	BY productLine	HAVING productLine IN ('Ships', 'Trains');

-- Q7 : 2005년 5월의 주문 정보를 검색. 단, 상태(status)는 한글로 출력함.


SELECT	orderNo, orderDate,
		CASE
			WHEN status = 'In Process'	THEN '처리중'
			WHEN status = 'Shipped'		THEN '배송중'
			WHEN status = 'Resolved'		THEN '완료'
			WHEN status = 'Disputed'		THEN '문제해결중'
			WHEN status = 'On Hold'		THEN '보류'
			WHEN status = 'Cancelled'	THEN '취소' 
			ELSE '없음' 
		END AS status
FROM 	orders
WHERE	YEAR(orderDate) = 2005 AND MONTH(orderDate) = 5;

select * from orders;

-- Q8 : 가장 최근에 이뤄진 10개 주문을 검색. (10위까지가 아님)

WITH temp as(
	SELECT orderNo,orderDate,status,customerId,
	ROW_NUMBER() over(ORDER BY orderDate DESC) AS rn
    from orders
)
SELECT * FROM temp
WHERE rn <=10;

SELECT	orderNo, orderDate, status, customerId
FROM 	orders
ORDER 	BY orderDate DESC
LIMIT	10;	


-- Q9 : 주문번호 10,100에 포함된 각 상품의 상품코드, 개수, 주문단가를 검색.


SELECT	orderNo AS 주문번호, productCode AS 상품코드, 
		quantity AS 개수, priceEach AS 주문단가 
FROM 	orderDetails
WHERE	orderNo = 10100;



-- Q10 : 주문번호 10,100에서 주문액이 2,000불 이상인 상품을 검색.

SELECT	orderNo, productCode, quantity, priceEach, quantity * priceEach 주문액
FROM 	orderDetails
WHERE	orderNo = 10100 AND quantity * priceEach >= 2000;


-- Q11 : 국가별 고객수의 평균을 검색.

select * from customers;

WITH temp AS
(
		SELECT	country 국가, COUNT(*) 고객수
		FROM 	customers
		GROUP 	BY country
)
SELECT	ROUND(AVG(고객수),2) '평균 고객수'
FROM 	temp;


-- Q12 : 직책이 'Sales Manager'인 직원의 직원번호, 성명, 직책, 근무 지점명을 검색.
select employeeId, concat(firstName,' ' , lastName) name, jobTitle,city
from employees E join offices O using(officeCode)
where jobTitle like ('%Sales Manager%');

SELECT 	employeeId, CONCAT(firstName, ' ', lastName) name, jobTitle, city 
FROM 	employees E, offices O
WHERE 	E.officeCode = O.officeCode AND  
		jobTitle LIKE '%Sales Manager%';

-- Q13 : 'USA'에 있는 지점에서 근무하는 직원이 관리하는 고객을 검색
select * from customers;


SELECT 	customerId, name 고객, 
		employeeId, CONCAT(firstName, ' ', lastName) 직원,
		O.officeCode, O.city 지점
FROM 	customers C
		JOIN employees E ON C.salesRepId = E.employeeId
		JOIN offices O USING (officeCode)
WHERE 	O.country = 'USA'
ORDER 	BY O.officeCode, employeeId, customerId;

select * from products;
-- Q14 : 'USA'에 있는 지점에서 주문된 상품의 상품명과 주문개수를 검색. 

SELECT	productCode, P.name, SUM(quantity) AS CNT
FROM	offices O 
		JOIN employees USING (officeCode)
		JOIN customers ON employeeId = salesRepId
		JOIN orders USING (customerId)
		JOIN orderDetails USING (orderNo)
		JOIN products P USING (productCode)
WHERE	O.country = 'USA'
GROUP 	BY productCode
ORDER 	BY 3 DESC;



-- Q15 : 고객과 고객의 담당 직원을 검색. 단, 담당 직원이 없는 고객도 포함.

SELECT 	customerId, C.name, city, 
		employeeId, CONCAT(firstName, ' ', lastName) AS name 
FROM 	customers C LEFT JOIN employees E ON C.salesRepId = E.employeeId
ORDER 	BY name, C.name;


-- Q16 : 고객과 고객의 담당 직원을 검색. 단, 담당 직원이 없는 고객과 담당 고객이 없는 직원도 포함.

SELECT 	customerId, C.name, city, 
		employeeId, CONCAT(firstName, ' ', lastName) AS name 
FROM 	customers C LEFT JOIN employees E ON C.salesRepId = E.employeeId
UNION
SELECT 	customerId, C.name, city, 
		employeeId, CONCAT(firstName, ' ', lastName) AS name 
FROM 	customers C RIGHT JOIN employees E ON C.salesRepId = E.employeeId;

-- Q17 : 직원과 직원의 상급자를 검색, 단, 상급자가 없는 직원도 포함.

SELECT	emp.employeeId, 
		CONCAT(emp.firstName, ' ', emp.lastName) AS employee, emp.jobTitle, 
		mgr.employeeId AS managerId,
		CONCAT(mgr.firstName, ' ', mgr.lastName) AS manager
FROM  	employees emp LEFT JOIN employees mgr ON emp.managerId = mgr.employeeId;

-- Q18 : 권장 소비자 가격이 권장 소비자가격 평균의 2배 이상인 상품을 검색.


SELECT 	name 상품명, MSRP '권장 소비자가격'
FROM 	products
WHERE 	MSRP >=	(
					SELECT	AVG(MSRP) * 2
					FROM		products
				)
ORDER 	BY MSRP;  

-- Q19 : 성이 'Patterson'인 직원이 근무하는 지점을 검색.


SELECT 	officeCode, city 
FROM 	offices
WHERE 	officeCode = ANY	(
								SELECT	officeCode
 								FROM		employees
								WHERE	lastName = 'Patterson'
							)
ORDER 	BY officeCode;

-- Q20 : 각 상품라인에서 권장 소비자가격이 가장 저렴한 상품을 검색.

SELECT productLine, name, MSRP
FROM (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY productLine ORDER BY MSRP ASC) AS rn
  FROM products
) ranked
WHERE rn = 1;


SELECT	productLine 상품라인, name 상품명, MSRP 소비자가격
FROM 	products X
WHERE 	MSRP = (
						SELECT	MIN(MSRP)
						FROM		products Y
						WHERE	Y.productLine = X.productLine
				) 
ORDER 	BY productLine, name;

-- Q21 : 상태가 'Cancelled' 혹은 'On Hold'인 주문을 한 고객을 검색.

select customerId, name
from customers 
where customerId in 
(select customerId
	from orders
	where (status = 'Cancelled' or status = 'On hold')
);


SELECT	name
FROM	customers C
WHERE	customerId = ANY (
								SELECT	customerId	
								FROM	orders O
								WHERE	O.customerId = C.customerId AND
										O.status IN ('Cancelled', 'On Hold')
						  );

-- Q22 : 2003년 1월에 주문한 고객을 검색.

SELECT	name
FROM		customers C
WHERE	EXISTS	(
						SELECT	*
						FROM	orders O
						WHERE	O.customerId = C.customerId AND
								YEAR(orderDate)=2003 AND MONTH(orderDate)=1
				 );
                 


-- Q23 : 지점명과 지점에 근무하는 직원의 수를 검색. 


SELECT city, count(*)
FROM employees left JOIN offices using(officeCode)
group by offices.city;


SELECT 	city 지점,
		(
				SELECT	COUNT(*)
				FROM		employees Y
				WHERE	Y.officeCode = X.officeCode	
		) 직원수
FROM	offices X
ORDER	BY city;

-- Q24 : 직원들을 사장부터 하위 직급별로 순서대로 검색. 
-- 		 단, 출력에 직원의 레벨과 보고 라인(path)을 포함. 보고 라인은 직원 아이디를 사장부터 나열함.

WITH RECURSIVE employeeAnchor (id, name, title, level, path) AS
(
		SELECT	employeeId, CONCAT(firstName, ' ', lastName), jobTitle, 
				1, CAST(employeeId AS CHAR(50))
		FROM	employees
		WHERE	managerId IS NULL
			UNION ALL
		SELECT	employeeId, CONCAT(E.firstName, ' ', E.lastName), jobTitle, 
				level+1, CONCAT(A.path, ':', E.employeeId)
		FROM	employeeAnchor A JOIN employees E ON A.id = E.managerId
)
SELECT	*
FROM	employeeAnchor;	



-- Q25 : 2004년, 고객의 국가별/월별 주문횟수 검색. (세로축: 국가, 가로축: 월)

SELECT	country, 
		COALESCE(SUM(CASE MONTH(orderDate) WHEN 1 THEN 1 END),0) 1월,
		COALESCE(SUM(CASE MONTH(orderDate) WHEN 2 THEN 1 END),0) 2월,
		COALESCE(SUM(CASE MONTH(orderDate) WHEN 3 THEN 1 END),0) 3월,
		COALESCE(SUM(CASE MONTH(orderDate) WHEN 4 THEN 1 END),0) 4월,
		COALESCE(SUM(CASE MONTH(orderDate) WHEN 5 THEN 1 END),0) 5월,
		COALESCE(SUM(CASE MONTH(orderDate) WHEN 6 THEN 1 END),0) 6월,
		COALESCE(SUM(CASE MONTH(orderDate) WHEN 7 THEN 1 END),0) 7월,
		COALESCE(SUM(CASE MONTH(orderDate) WHEN 8 THEN 1 END),0) 8월,
		COALESCE(SUM(CASE MONTH(orderDate) WHEN 9 THEN 1 END),0) 9월,
		COALESCE(SUM(CASE MONTH(orderDate) WHEN 10 THEN 1 END),0) 10월,
		COALESCE(SUM(CASE MONTH(orderDate) WHEN 11 THEN 1 END),0) 11월,
		COALESCE(SUM(CASE MONTH(orderDate) WHEN 12 THEN 1 END),0) 12월,
		COUNT(orderNo) 주문회수
FROM 	customers LEFT JOIN orders USING (customerId)
WHERE	YEAR(orderDate) = 2004
GROUP 	BY country
ORDER 	BY country;

-- Q26 : 2004년, 상품의 상품라인별/주문상태별 주문횟수 그리고 상품라인별 총주문횟수를 검색. (세로축: 상품라인, 가로축: 주문상태)

SELECT	productLine,
		COALESCE(SUM(CASE status WHEN 'In Process'	THEN 1	END),0) AS 처리중,
		COALESCE(SUM(CASE status WHEN 'Shipped'		THEN 1	END),0) AS 배송중,
		COALESCE(SUM(CASE status WHEN 'Resolved'		THEN 1	END),0) AS 완료,
		COALESCE(SUM(CASE status WHEN 'Disputed'		THEN 1	END),0) AS 문제해결중,
		COALESCE(SUM(CASE status WHEN 'On Hold'		THEN 1	END),0) AS 보류,
		COALESCE(SUM(CASE status WHEN 'Cancelled'		THEN 1	END),0) AS 취소,
		COUNT(orderNo) AS 주문회수
FROM 	products 
		LEFT JOIN orderDetails USING (productCode)
		LEFT JOIN orders USING (orderNo)
WHERE	YEAR(orderDate) = 2004
GROUP 	BY productLine
ORDER 	BY productLine;


-- Q27 : 상품라인별로, 상품의 평균 재고개수, 평균 판매가격, 평균 권장소비자가격을 검색.
--       그리고 마지막 줄에 전체 상품라인의 평균 재고개수, 평균 판매가격, 평균 권장소비자가격을 추가.

SELECT	IF(productLine IS NULL, '평균', productLine) AS productLine, 
		FLOOR(AVG(quantityInStock)), FLOOR(AVG(buyPrice)), FLOOR(AVG(MSRP))
FROM	products
GROUP 	BY productLine WITH ROLLUP;




