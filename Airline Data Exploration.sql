--Airlines used to travel

select
distinct airlines 
from [airlines-data - Sheet1]

--Year used for maximum source cities

select
year, count(Source)
from [airlines-data - Sheet1]
group by Year 
order by count(Source) desc


--Most money spent on an airline

select
airlines, sum(Cost_in_rupees) as total
from [airlines-data - Sheet1]
group by airlines
order by total desc

--Year which had the highest % increase in number of flights

select 
Year,count(*) as NumberOfTrips
from [airlines-data - Sheet1]
group by year
order by NumberOfTrips desc;

--Maximum distance and trips covered by airline

WITH data AS (
    SELECT
        year,
        COUNT(*) AS numberofflights
    FROM [airlines-data - Sheet1]
    GROUP BY year
)
SELECT 
    year,
    numberofflights,
    LAG(numberofflights) OVER (ORDER BY year) AS previousyearflights,
    (numberofflights - LAG(numberofflights) OVER (ORDER BY year)) 
    / NULLIF(LAG(numberofflights) OVER (ORDER BY year), 0) AS growth_rate
FROM data
ORDER BY year;


--Which airline has been used the most

WITH data AS (
    SELECT
        airlines,
        SUM(distance_in_kms) AS totaldistance
    FROM [airlines-data - Sheet1]
    GROUP BY airlines
)
SELECT 
    airlines,
    totaldistance,
    RANK() OVER (ORDER BY totaldistance DESC) AS ranking
FROM data;
WITH data AS (
    SELECT
        airlines,
        count(*) as flights
    FROM [airlines-data - Sheet1]
    GROUP BY airlines
)
SELECT 
    airlines,
    flights,
    RANK() OVER (ORDER BY flights DESC) AS ranking
FROM data;
