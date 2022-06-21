CREATE OR REPLACE TABLE t_Pepa_Poskocil_project_SQL_primary_final AS
	WITH category_price_per_year AS (
		SELECT
			YEAR(cp.date_from) AS date_year,
			cp.category_code,
			cpc.name,
			cp.value AS avg_value
		FROM czechia_price cp
		JOIN czechia_price_category cpc
		  ON cp.category_code = cpc.code
		GROUP BY 
			YEAR(date_from), 
			category_code
		ORDER BY 
			cpc.name, 
			YEAR(cp.date_from)
	),
		payroll_avg_per_year AS (
		SELECT
			cp.payroll_year,
			industry_branch_code,
			cpib.name AS industry_name,
			avg(value) AS payroll
		FROM czechia_payroll cp
		JOIN czechia_payroll_industry_branch cpib
	  	  ON cp.industry_branch_code = cpib.code
		WHERE TRUE 
		  AND value_type_code = '5958'
		  AND calculation_code = '200'
		GROUP BY payroll_year, industry_branch_code
	),
		base AS (
		SELECT
			*
		FROM payroll_avg_per_year papy
		JOIN category_price_per_year cppy
		  ON papy.payroll_year = cppy.date_year
		ORDER BY 
			papy.payroll_year,
			papy.industry_branch_code
	)
		SELECT
			payroll_year AS 'Year',
			industry_branch_code,
			industry_name,
			payroll,
			name,
			avg_value AS goods_price
		FROM base;


