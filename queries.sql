
/* ANALİZ-1 GENEL BAKIŞ (OVERVIEW)
1. Net satışlar nedir?
2. Kaç sipariş alındı?
3. Kaç çeşit ürün satıldı?
4. Toplam indirim miktarı nedir?
5. Aylar boyunca satış eğilimi nedir? 
6. Kategori bazında satılan ürün sayıları ve her bir kategori için net satışlar nedir?*/

--1. Net satışlar nedir?

SELECT 
    ROUND(SUM((UNIT_PRICE * QUANTITY) * (1 - DISCOUNT))::NUMERIC, 2) AS NET_SALES
FROM ORDER_DETAILS;

-- 2. Kaç sipariş alındı?
SELECT
	COUNT(DISTINCT ORDER_ID) AS ORDER_COUNT
FROM
	ORDERS


--3. Kaç çeşit ürün toplamda kaç kez satıldı?

SELECT COUNT(DISTINCT PRODUCT_ID) AS DIFFERENT_PRODUCT_COUNT,
COUNT(PRODUCT_ID) AS  TOTAL_SOLD_PRODUCT
FROM ORDER_DETAILS

-- 4. Toplam indirim miktarı nedir? 

SELECT 
    SUM((UNIT_PRICE * QUANTITY) * DISCOUNT) AS TOTAL_DISCOUNT
FROM ORDER_DETAILS

-- 5. Aylar boyunca satış eğilimi nedir? */
SELECT 
    DATE_TRUNC('year', O.ORDER_DATE) AS YEAR_,
    DATE_TRUNC('month', O.ORDER_DATE) AS MONTH_,
    ROUND(SUM((OD.UNIT_PRICE * OD.QUANTITY) * (1 - OD.DISCOUNT))::NUMERIC, 2) AS NET_SALES
FROM ORDERS O 
JOIN ORDER_DETAILS OD ON O.ORDER_ID = OD.ORDER_ID
GROUP BY 1, 2 
ORDER BY 1, 2 ASC


-- 6. Kategori bazında satılan ürün sayıları ve her bir kategori için net satışlar nedir?*/

-- Kategori bazında ürün sayıları
SELECT C.CATEGORY_NAME AS CATEGORY,
	COUNT(OD.QUANTITY) AS TOTAL_AMOUNT
FROM CATEGORIES C
JOIN PRODUCTS P ON C.CATEGORY_ID = P.CATEGORY_ID
JOIN ORDER_DETAILS OD ON P.PRODUCT_ID = OD.PRODUCT_ID
GROUP BY 1


-- her bir kategori için net satışlar
SELECT C.CATEGORY_NAME AS CATEGORY,
	ROUND(SUM((OD.UNIT_PRICE * OD.QUANTITY) * (1 - OD.DISCOUNT))::NUMERIC, 2) AS NET_SALES
FROM CATEGORIES C
JOIN PRODUCTS P ON C.CATEGORY_ID = P.CATEGORY_ID
JOIN ORDER_DETAILS OD ON P.PRODUCT_ID = OD.PRODUCT_ID
GROUP BY 1


/* Ürün Analizi;
1. Katalogda kaç ürün var?
2. En çok satan 5 ürün hangileridir?
3. En çok hangi kategoride, hangi ürün satın alınıyor? Discount miktarları nedir? */



--1. Katalogda kaç ürün var?
SELECT COUNT(DISTINCT PRODUCT_ID) AS DIFFERENT_PRODUCT_COUNT
FROM ORDER_DETAILS

-- 2. En çok satan 5 ürün hangileridir?

SELECT P.PRODUCT_NAME,
	ROUND(SUM((OD.UNIT_PRICE * OD.QUANTITY) * (1 - OD.DISCOUNT))::NUMERIC, 2) AS TOP_SELLING_PRODUCTS
FROM PRODUCTS P
JOIN ORDER_DETAILS OD ON P.PRODUCT_ID = OD.PRODUCT_ID
GROUP BY 1 
ORDER BY 2 DESC
LIMIT 5

-- 3. Satışı durdurulan ürün var mı? Varsa kaç tane?

	SELECT SUM(DISCONTINUED) FROM PRODUCTS 

-- 3. En çok hangi kategoride, hangi ürün satın alınıyor? Discount miktarları nedir?
SELECT 
    C.CATEGORY_NAME,
    P.PRODUCT_NAME,
    COUNT(OD.QUANTITY) AS PRODUCTS_SOLD,
    SUM((OD.UNIT_PRICE * OD.QUANTITY) * OD.DISCOUNT) AS DISCOUNT,
    SUM(OD.UNIT_PRICE * OD.QUANTITY * (1 - OD.DISCOUNT)) AS NET_SALES
FROM 
    CATEGORIES C
JOIN 
    PRODUCTS P ON C.CATEGORY_ID = P.CATEGORY_ID
JOIN 
    ORDER_DETAILS OD ON OD.PRODUCT_ID = P.PRODUCT_ID
GROUP BY 
    C.CATEGORY_NAME, P.PRODUCT_NAME
ORDER BY 
    NET_SALES DESC;

-- aylara göre satılan ürün sayısı
SELECT 
    DATE_TRUNC('year', O.ORDER_DATE) AS YEAR_,
    DATE_TRUNC('month', O.ORDER_DATE) AS MONTH_,
	COUNT(OD.QUANTITY) AS PRODUCTS_SOLD
FROM ORDERS O 
JOIN ORDER_DETAILS OD ON OD.ORDER_ID = O.ORDER_ID
GROUP BY 1,2
ORDER BY 1,2 ASC


/* ANALİZ-3 MÜŞTERİ ANALİZİ
1. Kaç müşteriye hizmet verildi?
2. Bu müşteriler hangi ülkelerde bulunmaktadır?
3. Net satışlara göre ilk 5 müşteri kimlerdir?
4. Satın alınan ürünlere ve siparişlere göre ilk 5 müşteri kimlerdir?
5. En çok satış yapılan 5 ülke hangisidir?
6. Müşterileri Recency, Frequency ve Monetary değerlerine göre segmente ediniz. 
 */

-- 1. Kaç müşteriye hizmet verildi?
SELECT COUNT(DISTINCT COMPANY_NAME)  AS CUSTOMER_COUNT FROM CUSTOMERS

-- 2. Bu müşteriler kaç farklı ülkede bulunmaktadır?
SELECT COUNT(DISTINCT COUNTRY) AS COUNTRY_COUNT FROM CUSTOMERS

-- 3. Net satışlara göre ilk 5 müşteri kimlerdir?
SELECT C.COMPANY_NAME,
	ROUND(SUM((OD.UNIT_PRICE * OD.QUANTITY) * (1 - OD.DISCOUNT))::NUMERIC, 2) AS NET_SALES
FROM CUSTOMERS C
JOIN ORDERS O ON C.CUSTOMER_ID = O.CUSTOMER_ID
JOIN ORDER_DETAILS OD ON O.ORDER_ID = OD.ORDER_ID
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5


--4. Satın alınan ürünlere ve siparişlere göre ilk 5 müşteri kimlerdir?

SELECT 
    C.COMPANY_NAME,
	COUNT(DISTINCT OD.PRODUCT_ID) AS PRODUCT_COUNT,
    COUNT(DISTINCT O.ORDER_ID) AS ORDER_COUNT
FROM  CUSTOMERS C
JOIN ORDERS O ON C.CUSTOMER_ID = O.CUSTOMER_ID
JOIN ORDER_DETAILS OD ON O.ORDER_ID = OD.ORDER_ID
GROUP BY C.CUSTOMER_ID, C.COMPANY_NAME
ORDER BY ORDER_COUNT DESC
LIMIT 5;

-- 5. En çok satış yapılan 5 ülke hangisidir?
SELECT C.COUNTRY,
	ROUND(SUM((OD.UNIT_PRICE * OD.QUANTITY) * (1 - OD.DISCOUNT))::NUMERIC, 2) AS NET_SALES
FROM CUSTOMERS C
JOIN ORDERS O ON C.CUSTOMER_ID = O.CUSTOMER_ID
JOIN ORDER_DETAILS OD ON O.ORDER_ID = OD.ORDER_ID
GROUP BY 1
ORDER BY 2 DESC



-- 6. Müşterileri Recency, Frequency ve Monetary değerlerine göre segmente ediniz. 
WITH RFM AS (
    SELECT 
        C.COMPANY_NAME,
        C.COUNTRY,
        (SELECT MAX(ORDER_DATE) FROM ORDERS) - MAX(O.ORDER_DATE) AS RECENCY,
        COUNT(DISTINCT O.ORDER_ID) AS FREQUENCY,
        SUM(OD.UNIT_PRICE * OD.QUANTITY * (1 - OD.DISCOUNT)) AS MONETARY
    FROM CUSTOMERS C
    JOIN ORDERS O ON C.CUSTOMER_ID = O.CUSTOMER_ID
    JOIN ORDER_DETAILS OD ON O.ORDER_ID = OD.ORDER_ID
    GROUP BY C.COMPANY_NAME, C.COUNTRY
),
RFM_SCORES AS (
    SELECT 
        COMPANY_NAME,
        COUNTRY,
        RECENCY,
        FREQUENCY,
        MONETARY,
        NTILE(5) OVER (ORDER BY RECENCY DESC) AS RECENCY_SCORE,
        NTILE(5) OVER (ORDER BY FREQUENCY) AS FREQUENCY_SCORE,
        NTILE(5) OVER (ORDER BY MONETARY) AS MONETARY_SCORE
    FROM RFM
)
SELECT 
    COMPANY_NAME AS CUSTOMER_COMPANY,
    COUNTRY,
    RECENCY,
    FREQUENCY,
    MONETARY,
    RECENCY_SCORE,
    FREQUENCY_SCORE,
    MONETARY_SCORE,
    CONCAT(RECENCY_SCORE, FREQUENCY_SCORE) AS RFM_SCORE,
    CASE
        WHEN CONCAT(RECENCY_SCORE, FREQUENCY_SCORE) IN ('11', '12', '21', '22') THEN 'HIBERNATING'
        WHEN CONCAT(RECENCY_SCORE, FREQUENCY_SCORE) IN ('13', '14', '23', '24') THEN 'AT RISK'
        WHEN CONCAT(RECENCY_SCORE, FREQUENCY_SCORE) IN ('15', '25') THEN 'CANT LOSE'
        WHEN CONCAT(RECENCY_SCORE, FREQUENCY_SCORE) IN ('31', '32') THEN 'ABOUT TO SLEEP'
        WHEN CONCAT(RECENCY_SCORE, FREQUENCY_SCORE) = '33' THEN 'NEED ATTENTION'
        WHEN CONCAT(RECENCY_SCORE, FREQUENCY_SCORE) IN ('34', '35', '44', '45') THEN 'LOYAL CUSTOMERS'
        WHEN CONCAT(RECENCY_SCORE, FREQUENCY_SCORE) = '41' THEN 'PROMISING'
        WHEN CONCAT(RECENCY_SCORE, FREQUENCY_SCORE) IN ('42', '43', '52', '53') THEN 'POTENTIAL LOYALISTS'
        WHEN CONCAT(RECENCY_SCORE, FREQUENCY_SCORE) = '51' THEN 'NEW CUSTOMERS'
        WHEN CONCAT(RECENCY_SCORE, FREQUENCY_SCORE) IN ('54', '55') THEN 'CHAMPIONS'
    END AS RFM_CATEGORY
FROM RFM_SCORES
ORDER BY FREQUENCY DESC;


/* ANALİZ-4
	LOJISTIK ANALIZ Lojistik ekibi aşağıdaki sorulara cevap bulmak istiyor.
	1. En çok hangi nakliye şirketi kullanılıyor?
	2. Kaç sipariş gönderildi, kaç sipariş geç gönderildi, kaç sipariş gönderilmedi gönderilmedi?
	3. Nakliyecilere ne kadar navlun ödendi?
	4. Zamanında teslimat oranı nedir?
	5. Ülkelere göre ortalama teslimat sürelerini hesaplayınız. En hızlı ve en yavaş teslimat yapılan 5 ülkeyi
		belirleyiniz.*/

	-- 1. En çok hangi nakliye şirketi kullanılıyor?
SELECT S.COMPANY_NAME,
	COUNT(DISTINCT O.ORDER_ID) AS ORDER_COUNT
FROM SHIPPERS S
JOIN ORDERS O ON S.SHIPPER_ID = O.SHIP_VIA
GROUP BY 1
ORDER BY ORDER_COUNT DESC

--2. Toplam sipariş sayısı nedir?Kaç sipariş gönderildi, kaç sipariş geç gönderildi, kaç sipariş gönderilmedi gönderilmedi? --

-- Toplam sipariş sayısı
SELECT
	COUNT(DISTINCT ORDER_ID) AS ORDER_COUNT
FROM
	ORDERS
	
-- Gönderilen sipariş sayısı
SELECT
	COUNT(DISTINCT ORDER_ID) AS SHIPPED_ORDER_COUNT
FROM
	ORDERS
WHERE
	SHIPPED_DATE IS NOT NULL

-- Gönderilmeyen sipariş sayısı
SELECT
	COUNT(DISTINCT ORDER_ID) AS NON_SHIPPED_ORDER_COUNT
FROM
	ORDERS
WHERE
	SHIPPED_DATE IS NULL


-- Geç Gönderilen sipariş sayısı
SELECT
	COUNT(DISTINCT ORDER_ID) LATE_ORDER_COUNT
FROM
	ORDERS
WHERE
	SHIPPED_DATE > REQUIRED_DATE

--3. Nakliyecilere ne kadar navlun ödendi?

SELECT S.COMPANY_NAME,
ROUND(SUM(O.FREIGHT)::NUMERIC,2) AS FREIGHT_TOTAL
FROM SHIPPERS S 
JOIN ORDERS O ON O.SHIP_VIA = S.SHIPPER_ID
GROUP BY 1
ORDER BY 2 DESC

-- 4. Zamanında shippment oranı nedir?*/

SELECT 
    ROUND((COUNT(DISTINCT CASE WHEN REQUIRED_DATE >= SHIPPED_DATE THEN ORDER_ID END) * 100.0) / 
        COUNT(DISTINCT ORDER_ID), 2) AS ON_TIME_SHIPMENT_RATIO
FROM ORDERS;


/*5. Ülkelere göre ortalama teslimat sürelerini hesaplayınız. En hızlı ve en yavaş teslimat yapılan 5 ülkeyi
	  ve toplam sipariş sayılarını belirleyiniz.*/

SELECT SHIP_COUNTRY,
	ROUND(AVG(EXTRACT(DAY FROM (SHIPPED_DATE - ORDER_DATE) * INTERVAL '1 DAY'))::NUMERIC,2) AS AVG_SHIPPING_TIME,
	COUNT(*) AS TOTAL_ORDERS
FROM ORDERS
GROUP BY SHIP_COUNTRY
ORDER BY 2 ASC



/* ANALİZ-5 ÇALIŞAN ANALİZİ
Aşağıdaki sorulara cevap bulunmak isteniyor.
1. Ofislerde kaç çalışan çalışıyor?
2. Yapılan satışlar açısından en aktif çalışan kimdir?
3. Sipariş sayıların göre çalışanları getiriniz.
4. Ofislerin sipariş ve satış performansı nedir?
*/

--1. Ofislerde kaç çalışan çalışıyor?
SELECT COUNTRY AS OFFICE,
	COUNT(DISTINCT EMPLOYEE_ID) AS EMPLOYEE_COUNT
FROM EMPLOYEES 
GROUP BY 1
ORDER BY 2 DESC

-- 2. Yapılan satışlar açısından en aktif çalışan kimdir? Net satış miktarlarına göre performansları getiriniz.pie chart ekle
SELECT 
    E.FIRST_NAME || ' ' || E.LAST_NAME AS EMPLOYEE,
    ROUND(SUM(OD.UNIT_PRICE * OD.QUANTITY * (1 - OD.DISCOUNT))::NUMERIC, 2) AS TOTAL_SALES
FROM 
    EMPLOYEES E
JOIN 
    ORDERS O ON E.EMPLOYEE_ID = O.EMPLOYEE_ID
JOIN 
    ORDER_DETAILS OD ON O.ORDER_ID = OD.ORDER_ID
GROUP BY 
    E.EMPLOYEE_ID, E.FIRST_NAME, E.LAST_NAME
ORDER BY 
    TOTAL_SALES DESC

-- 3. Sipariş sayıların göre çalışanları getiriniz.
SELECT E.FIRST_NAME || ' ' || E.LAST_NAME AS EMPLOYEE, COUNT(O.ORDER_ID) AS NUMBEROFORDERS
FROM EMPLOYEES E
JOIN ORDERS O ON E.EMPLOYEE_ID = O.EMPLOYEE_ID
GROUP BY  E.FIRST_NAME, E.LAST_NAME
ORDER BY NUMBEROFORDERS DESC

--4. Ofislerin sipariş ve satış performansı nedir?
SELECT E.COUNTRY,
	E.TITLE,
	COUNT(DISTINCT E.EMPLOYEE_ID) AS EMPLOYEE_NUMBER,
	COUNT(DISTINCT OD.ORDER_ID) AS TOTAL_ORDER,
	ROUND(SUM(OD.UNIT_PRICE * OD.QUANTITY)::NUMERIC, 2) AS NET_SALES
FROM EMPLOYEES E 
JOIN ORDERS O ON E.EMPLOYEE_ID = O.EMPLOYEE_ID
JOIN ORDER_DETAILS OD ON O.ORDER_ID = OD.ORDER_ID
GROUP BY 1,2
ORDER BY 1,5 DESC
	


/* ANALİZ-6 TEDARİKÇİ ANALİZİ
1. Tedarikçiler hangi ülkelerden ve her ülkeden kaç tedarikçi var.
2. Hangi tedarikçiden kaç ürün satın alınıyor? En fazla ürün sağlayan tedarikçiler
3. En yüksek toplam satışa katkıda bulunan ilk 5  tedarikçi kimdir?
4. Tedarikçilerin sağladığı ürünlerin satış performansı nedir? */

--1. Tedarikçiler hangi ülkelerden ve her ülkeden kaç tedarikçi var.

SELECT S.COUNTRY,
    COUNT(S.SUPPLIER_ID) AS SUPPLIER_COUNT
FROM SUPPLIERS S
GROUP BY 1
ORDER BY 2 DESC

-- 2. Hangi tedarikçiden kaç ürün satın alınıyor? En fazla ürün sağlayan tedarikçiler
SELECT 
    S.COMPANY_NAME,
    COUNT(DISTINCT P.PRODUCT_ID) AS PRODUCT_COUNT
FROM SUPPLIERS S
JOIN PRODUCTS P ON S.SUPPLIER_ID = P.SUPPLIER_ID
GROUP BY 1
ORDER BY 2 DESC

-- 3. En yüksek toplam satışa katkıda bulunan ilk 5  tedarikçi kimdir?

SELECT 
    S.COMPANY_NAME,
    ROUND(SUM(OD.UNIT_PRICE * OD.QUANTITY * (1 - OD.DISCOUNT))::NUMERIC, 2) AS TOTAL_SALES
FROM SUPPLIERS S
JOIN PRODUCTS P ON S.SUPPLIER_ID = P.SUPPLIER_ID
JOIN ORDER_DETAILS OD ON P.PRODUCT_ID = OD.PRODUCT_ID
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 4. Tedarikçilerin sağladığı ürünlerin satış performansı nedir?
SELECT 
    S.COMPANY_NAME,
	P.PRODUCT_NAME,
    ROUND(SUM(OD.UNIT_PRICE * OD.QUANTITY * (1 - OD.DISCOUNT))::NUMERIC, 2) AS TOTAL_SALES,
    COUNT(DISTINCT P.PRODUCT_ID) AS PRODUCT_COUNT,
    ROUND(SUM(OD.UNIT_PRICE * OD.QUANTITY * (1 - OD.DISCOUNT))::NUMERIC / NULLIF(COUNT(DISTINCT P.PRODUCT_ID), 0)::NUMERIC, 2)AS SALES_PER_PRODUCT
FROM SUPPLIERS S
JOIN PRODUCTS P ON S.SUPPLIER_ID = P.SUPPLIER_ID
JOIN ORDER_DETAILS OD ON P.PRODUCT_ID = OD.PRODUCT_ID
GROUP BY 1,2
ORDER BY 5 DESC
LIMIT 5




