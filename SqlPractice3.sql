name	continent	area	population	gdp
Afghanistan	Asia	652230	25500100	20343000000
Albania	Europe	28748	2831741	12960000000
Algeria	Africa	2381741	37100000	188681000000
Andorra	Europe	468	78115	3712000000
Angola	Africa	1246700	20609294	100990000000
...

world(name, continent, area, population, gdp)


List each country name where the population is larger than that of 'Russia'.

SELECT name FROM world
  WHERE population >
     (SELECT population FROM world
      WHERE name='Russia');
	  

Show the countries in Europe with a per capita GDP greater than 'United Kingdom'.

SELECT name FROM world WHERE continent = 'Europe' and gdp/population > (SELECT gdp/population FROM world WHERE name = 'United Kingdom');


List the name and continent of countries in the continents containing either Argentina or Australia. Order by name of the country.

SELECT name, continent FROM world WHERE continent IN (SELECT continent FROM world WHERE name = 'Argentina' or name = 'Australia') order by name;


Which country has a population that is more than Canada but less than Poland? Show the name and the population.

SELECT name, population FROM world WHERE population > (SELECT population FROM world WHERE name = 'Canada') and population < (SELECT population FROM world WHERE name = 'Poland');


Germany (population 80 million) has the largest population of the countries in Europe. Austria (population 8.5 million) has 11% of the population of Germany.
Show the name and the population of each country in Europe. Show the population as a percentage of the population of Germany.
Decimal places
You can use the function ROUND to remove the decimal places.
Percent symbol %
You can use the function CONCAT to add the percentage symbol.

SELECT 
  name, 
  CONCAT(ROUND((population*100)/(SELECT population 
                                 FROM world WHERE name='Germany'), 0), '%')
FROM world
WHERE population IN (SELECT population
                     FROM world
                     WHERE continent='Europe');
					 
SELECT name,CONCAT(ROUND(population/80000000,-2),'%')
FROM world
WHERE population IN (SELECT population
FROM world
WHERE continent='Europe');


you can find the largest country in the world, by population with this query:

SELECT name
  FROM world
 WHERE population >= ALL(SELECT population
                           FROM world
                          WHERE population>0);
						  
						  
Which countries have a GDP greater than every country in Europe? [Give the name only.] (Some countries may have NULL gdp values)

SELECT name
  FROM world
 WHERE gdp > All(SELECT gdp
                           FROM world
                          WHERE continent = 'Europe' and gdp > 0);
						  

Find the largest country (by area) in each continent, show the continent, the name and the area:

SELECT continent, name, area FROM world x
  WHERE area >= ALL
    (SELECT area FROM world y
        WHERE y.continent=x.continent
          AND area>0);


We can refer to values in the outer SELECT within the inner SELECT. We can name the tables so that we can tell the difference between the inner and outer versions.


List each continent and the name of the country that comes first alphabetically.

SELECT continent, name FROM world GROUP BY continent ORDER BY name ASC;


Find the continents where all countries have a population <= 25000000. Then find the names of the countries associated with these continents. Show name, continent and population.

SELECT name, continent, population 
FROM world w
WHERE NOT EXISTS (                  -- there are no countries
   SELECT *
   FROM world nx
   WHERE nx.continent = w.continent -- on the same continent
   AND nx.population > 25000000     -- with more than 25M population 
   );


You have to divide the work. Step one, find the neighbours for a country. This have to be an auto join :

SELECT *
FROM bbc country
    INNER JOIN bbc neighbours
        ON country.region = neighbours.region
        AND country.name != neighbours.name
Don't forget to exclude self country from the neighbours !

Second, you can count how much neighbours for a country have the right population :

sum(CASE WHEN country.population > neighbours.population * 3 THEN 1 ELSE 0 END)
(Group by country !)
Compare with the total and you are done !

SELECT countryName 
FROM
(
    SELECT sum(CASE WHEN country.population > neighbours.population * 3 THEN 1 ELSE 0 END) as okNeighbours,
           count(*) as totalNeighbours
           country.name as countryName
    FROM bbc country
        INNER JOIN bbc neighbours
            ON country.region = neighbours.region
            AND country.name != neighbours.name
    GROUP BY country.name
)
WHERE totalNeighbours = okNeighbours
For the second :

SELECT name, region, population
FROM bbc
WHERE region IN (
    SELECT region
    FROM bbc
    GROUP BY region
    HAVING SUM(CASE WHEN population >= 25000000 THEN 1 ELSE 0 END) = 0
)   