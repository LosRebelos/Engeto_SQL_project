/* 1) Rostou v pr�b�hu let mzdy ve v�ech odv�tv�ch, nebo v n�kter�ch klesaj�? */
SELECT 
	`Year`,
	industry_name,
	payroll
FROM t_Pepa_Poskocil_project_SQL_primary_final ppp
GROUP BY `Year`, industry_name;


/* 2) Kolik je mo�n� si koupit litr� ml�ka a kilogram� chleba za prvn� a posledn� srovnateln� obdob� v dostupn�ch datech cen a mezd? */
SELECT
	`Year`,
	industry_name,
	payroll,
	name,
	goods_price,
	ROUND(payroll/goods_price, 0) AS value
FROM t_Pepa_Poskocil_project_SQL_primary_final ppp
WHERE TRUE
	AND name IN ('Ml�ko polotu�n� pasterovan�', 'Chl�b konzumn� km�nov�')
	AND `Year` IN ('2006', '2018');


/* 3) Kter� kategorie potravin zdra�uje nejpomaleji (je u n� nejni��� percentu�ln� meziro�n� n�r�st)? */
WITH percentage_change AS (	
	SELECT
		`Year`,
		name,
		goods_price,
		ROUND(goods_price * 100 / LAG(goods_price) OVER (PARTITION BY name ORDER BY `Year`
								ROWS BETWEEN UNBOUNDED PRECEDING
										AND CURRENT ROW)-100, 2) AS percentage_year_change
	FROM t_Pepa_Poskocil_project_SQL_primary_final ppp
	GROUP BY `Year`, name
	ORDER BY name, `Year`
)
SELECT
	name,
	ROUND(AVG(percentage_year_change), 2)
FROM percentage_change
GROUP BY name;	

/* 4) Existuje rok, ve kter�m byl meziro�n� n�r�st cen potravin v�razn� vy��� ne� r�st mezd (v�t�� ne� 10 %)?
--> 2007 */
WITH avg_payroll_and_price AS (
	SELECT 
		ppp.`Year`,
		AVG(payroll) AS avg_payroll,
		lead(avg(payroll)) OVER (ORDER BY `year` DESC) AS payroll_before,
		AVG(goods_price) AS avg_goods_price,
		lead(avg(goods_price)) OVER (ORDER BY `year` DESC) AS goods_price_before
	FROM t_Pepa_Poskocil_project_SQL_primary_final ppp
	GROUP BY `Year` DESC
)
SELECT
	`year`,
	ROUND((avg_payroll - payroll_before)/payroll_before*100, 2) AS payroll_growth, 
	ROUND((avg_goods_price - goods_price_before)/goods_price_before*100, 2) AS goods_price_growth,
	ROUND((avg_payroll - payroll_before)/payroll_before*100, 2) - ROUND((avg_goods_price - goods_price_before)/goods_price_before*100, 2) AS difference
FROM avg_payroll_and_price;


/* 5) M� v��ka HDP vliv na zm�ny ve mzd�ch a cen�ch potravin? Neboli, pokud HDP vzroste v�razn�ji v jednom roce, 
 * projev� se to na cen�ch potravin �i mzd�ch ve stejn�m nebo n�sduj�c�m roce v�razn�j��m r�stem? */
WITH gdp_czech AS (
	SELECT 
	ppps.`year`,
	GDP
	FROM t_Pepa_Poskocil_project_SQL_secondary_final ppps
	WHERE country = "Czech Republic"
		AND `year` >= 2006 
		AND `year` <= 2018
),
gdp_czech_and_avg_price AS (
	SELECT 
		ppp.`Year`,
		AVG(payroll) AS avg_payroll,
		lead(avg(payroll)) OVER (ORDER BY `year` DESC) AS payroll_before,
		AVG(goods_price) AS avg_goods_price,
		lead(avg(goods_price)) OVER (ORDER BY `year` DESC) AS goods_price_before,
		lead(GDP) OVER (ORDER BY `year` DESC) AS GDP_before,
		GDP 
	FROM t_Pepa_Poskocil_project_SQL_primary_final ppp
	JOIN gdp_czech
	ON ppp.`Year` = gdp_czech.`Year`
	GROUP BY `Year` DESC
)
SELECT
	`year`,
	ROUND((avg_payroll - payroll_before)/payroll_before*100, 2) AS payroll_growth, 
	ROUND((avg_goods_price - goods_price_before)/goods_price_before*100, 2) AS goods_price_growth,
	ROUND((GDP - GDP_before)/GDP_before*100, 2) AS GDP_growth 
FROM gdp_czech_and_avg_price;








