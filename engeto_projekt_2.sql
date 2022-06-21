CREATE OR REPLACE TABLE t_Pepa_Poskocil_project_SQL_secondary_final AS	
	SELECT
		e.country,
		e.`year`,
		e.GDP,
		e.population,
		e.gini
	FROM economies e
	JOIN countries c 
	ON e.country = c.country
	WHERE `year` >= 2006
		AND continent = 'Europe'
		AND GDP IS NOT NULL;