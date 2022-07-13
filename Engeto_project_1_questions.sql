/* 1) Rostou v prùbìhu let mzdy ve všech odvìtvích, nebo v nìkterých klesají? */
SELECT 
	`Year`,
	industry_name,
	payroll
FROM t_Pepa_Poskocil_project_SQL_primary_final ppp
GROUP BY `Year`, industry_name;


/* 2) Kolik je možné si koupit litrù mléka a kilogramù chleba za první a poslední srovnatelné období v dostupných datech cen a mezd? */
SELECT
	`Year`,
	industry_name,
	payroll,
	name,
	goods_price,
	ROUND(payroll/goods_price, 0) AS value
FROM t_Pepa_Poskocil_project_SQL_primary_final ppp
WHERE TRUE
	AND name IN ('Mléko polotuèné pasterované', 'Chléb konzumní kmínový')
	AND `Year` IN ('2006', '2018');


/* 3) Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroèní nárùst)? */
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

/* 4) Existuje rok, ve kterém byl meziroèní nárùst cen potravin výraznì vyšší než rùst mezd (vìtší než 10 %)?
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


/* 5) Má výška HDP vliv na zmìny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výraznìji v jednom roce, 
 * projeví se to na cenách potravin èi mzdách ve stejném nebo násdujícím roce výraznìjším rùstem? */
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








