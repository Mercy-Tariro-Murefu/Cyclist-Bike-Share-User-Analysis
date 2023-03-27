--Creating a table to combine the data from the 12 months

--starting by creating a table

DROP TABLE IF EXISTS merged_data
CREATE TABLE merged_data (
ride_id nvarchar(255),
customer_type nvarchar(50),
bike_type nvarchar(50),
started_at datetime2,
ended_at datetime2,
start_station_name nvarchar(100),
end_staion_name nvarchar(100)
)
 --Inserting data into the table 

INSERT INTO merged_data
SELECT ride_id, customer_type,bike_type,started_at,ended_at,start_station_name,end_station_name FROM Cyclist_data_2022.dbo.January$
UNION
SELECT ride_id, customer_type,bike_type,started_at,ended_at,start_station_name,end_station_name FROM Cyclist_data_2022.dbo.february$
UNION
SELECT ride_id, customer_type,bike_type,started_at,ended_at,start_station_name,end_station_name FROM Cyclist_data_2022.dbo.march$
UNION
SELECT ride_id, customer_type,bike_type,started_at,ended_at,start_station_name,end_station_name FROM Cyclist_data_2022.dbo.april$
UNION
SELECT ride_id, customer_type,bike_type,started_at,ended_at,start_station_name,end_station_name FROM Cyclist_data_2022.dbo.may$
UNION
SELECT ride_id, customer_type,bike_type,started_at,ended_at,start_station_name,end_station_name FROM Cyclist_data_2022.dbo.june$
UNION
SELECT ride_id, customer_type,bike_type,started_at,ended_at,start_station_name,end_station_name FROM Cyclist_data_2022.dbo.july$
UNION
SELECT ride_id, customer_type,bike_type,started_at,ended_at,start_station_name,end_station_name FROM Cyclist_data_2022.dbo.august$
UNION
SELECT ride_id, customer_type,bike_type,started_at,ended_at,start_station_name,end_station_name FROM Cyclist_data_2022.dbo.sept$
UNION
SELECT ride_id, customer_type,bike_type,started_at,ended_at,start_station_name,end_station_name FROM Cyclist_data_2022.dbo.october$
UNION
SELECT ride_id, customer_type,bike_type,started_at,ended_at,start_station_name,end_station_name FROM Cyclist_data_2022.dbo.november$
UNION
SELECT ride_id, customer_type,bike_type,started_at,ended_at,start_station_name,end_station_name FROM Cyclist_data_2022.dbo.december$


--Cleaning and organizing the combined data, and creating a table to store it

DROP TABLE IF EXISTS cleaned_data
CREATE TABLE cleaned_data (
ride_id nvarchar(255),
customer_type nvarchar(50),
bike_type nvarchar(50),
start_station_name nvarchar(100),
started_at datetime2,
day_of_week nvarchar(50),
month_of_year nvarchar(50),
hour_of_day int,
ride_duration_in_minutes int
)

INSERT INTO cleaned_data
SELECT
 ride_id,
 customer_type,
 bike_type,
 TRIM (start_station_name) AS start_station_name,
 started_at,
 DATENAME(WEEKDAY,started_at) AS day_of_week,
 DATENAME(MONTH,started_at) AS month_of_year,
 DATENAME(HOUR,started_at) AS hour_of_day,
 DATEDIFF(MINUTE,started_at,ended_at) AS ride_duration_in_minutes
FROM merged_data
WHERE  ride_id IS NOT NULL
        AND started_at IS NOT NULL
        AND start_station_name IS NOT NULL 
        AND DATEDIFF(MINUTE,started_at,ended_at) BETWEEN 1 AND 1440
		AND DATEDIFF(MINUTE,started_at,ended_at) IS NOT NULL

	
 --ANALYSIS


--Calculations and creating views for visualizations


--Total number of rides for the year 2022


CREATE VIEW  year_total_rides AS
SELECT 
    COUNT(ride_id) AS total_year_rides
FROM tempdb.dbo.cleaned_data


CREATE VIEW  year_total_rides_by_customer_type AS
SELECT CASE WHEN customer_type ='member' THEN 'member' ELSE 'casual' END AS customer_type,
       COUNT (*) AS rides_by_customer_type
FROM tempdb.dbo.cleaned_data
 GROUP BY customer_type 


 --Number of rides per week day;


  CREATE VIEW rides_by_day_of_week AS
 SELECT day_of_week,
        COUNT(ride_id) AS total_rides,
		COUNT(CASE WHEN customer_type ='member' THEN 1 ELSE NULL END) AS num_of_member_rides,
		COUNT(CASE WHEN customer_type ='casual' THEN 1 ELSE NULL END) AS num_of_casual_rides
 FROM tempdb.dbo.cleaned_data
 GROUP BY day_of_week


 ---Number of rides by month of year;


  CREATE VIEW rides_by_month_of_year AS
 SELECT month_of_year,
        COUNT(ride_id) AS total_rides,
		COUNT(CASE WHEN customer_type ='member' THEN 1 ELSE NULL END) AS num_of_member_rides,
		COUNT(CASE WHEN customer_type ='casual' THEN 1 ELSE NULL END) AS num_of_casual_rides 
 FROM tempdb.dbo.cleaned_data
 GROUP BY month_of_year


 --Number of rides per hour of the day;


  CREATE VIEW rides_by_hour_of_day AS
 SELECT hour_of_day,
        COUNT(ride_id) AS total_rides,
		COUNT(CASE WHEN customer_type ='member' THEN 1 ELSE NULL END) AS num_of_member_rides,
		COUNT(CASE WHEN customer_type ='casual' THEN 1 ELSE NULL END) AS num_of_casual_rides  
 FROM tempdb.dbo.cleaned_data
 GROUP BY hour_of_day


 --Number of rides per hour of on weekdays vs weekends

 
 CREATE VIEW weekday_vs_weekends_combined AS

SELECT 
CASE WHEN day_of_week ='monday' THEN 'weekday'
            WHEN day_of_week ='tuesday' THEN 'weekday'
			WHEN day_of_week ='wednesday' THEN 'weekday'
			WHEN day_of_week ='thursday' THEN 'weekday'
			WHEN day_of_week ='friday' THEN 'weekday'
			WHEN day_of_week ='saturday' THEN 'weekend'
			WHEN day_of_week ='sunday' THEN 'weekend'
			ELSE 'null' END AS day_of_week,
            hour_of_day,
	   COUNT(ride_id) AS total_of_rides ,
	   COUNT(CASE WHEN customer_type ='member' THEN 1 ELSE NULL END) AS num_of_member_rides,
		COUNT(CASE WHEN customer_type ='casual' THEN 1 ELSE NULL END) AS num_of_casual_rides 
FROM tempdb.dbo.cleaned_data
GROUP BY day_of_week, hour_of_day,customer_type


 --Number of rides per bike type;


 CREATE VIEW  num_of_rides_by_bike_type  AS
  SELECT
    CASE
		WHEN bike_type= 'electric_bike' THEN 'electric_bike'
		WHEN bike_type=  'classic_bike' THEN 'classic_bike'
	    ELSE 'docked_bike' END AS bike_type,  
        COUNT(bike_type) AS total_rides,
		COUNT(CASE WHEN customer_type ='member' THEN 1 ELSE NULL END) AS num_of_member_rides,
		COUNT(CASE WHEN customer_type ='casual' THEN 1 ELSE NULL END) AS num_of_casual_rides  	  
 FROM tempdb.dbo.cleaned_data
 GROUP BY bike_type
 
 --The average, minimum and maximum;

 --By customer_type

 CREATE VIEW  avg_min_max_by_customer_type AS
SELECT 
CASE WHEN customer_type ='member' THEN 'member' ELSE 'casual' END AS customer_type,
	 AVG(ride_duration_in_minutes) AS avg_ride_duration,
	 MAX(ride_duration_in_minutes) AS max_ride_duration,
	 MIN(ride_duration_in_minutes) AS min_ride_duration
	 FROM tempdb.dbo.cleaned_data
GROUP BY CASE WHEN customer_type ='member' THEN 'member' ELSE 'casual' END
		
--Looking at all customers

CREATE VIEW  avg_min_max_for_all AS
SELECT AVG(ride_duration_in_minutes) AS avg_ride_duration,
       MAX(ride_duration_in_minutes) AS max_ride_duration,
	   MIN(ride_duration_in_minutes) AS min_ride_duration
FROM tempdb.dbo.cleaned_data


--Number of rides starting at each station;

--For all customers

CREATE VIEW rides_starting_at_each_station_for_all_customers AS
 SELECT start_station_name,
       COUNT(*) AS total_rides,
		COUNT(CASE WHEN customer_type ='member' THEN 1 ELSE NULL END) AS num_of_member_rides,
		COUNT(CASE WHEN customer_type ='casual' THEN 1 ELSE NULL END) AS num_of_casual_rides  
FROM tempdb.dbo.cleaned_data
GROUP BY start_station_name

--Looking at Top 50 stations breaking down by customer_type

--FOR MEMBERS ONLY

 CREATE VIEW  top_50_stations_for_members AS
 SELECT start_station_name,
       COUNT(*) AS num_of_rides
FROM tempdb.dbo.cleaned_data
GROUP BY start_station_name,customer_type
HAVING customer_type = 'member'
ORDER BY COUNT(*) DESC
OFFSET 0 ROWS  
    FETCH NEXT 50 ROWS ONLY

-- FOR CASUAL RIDERS ONLY

CREATE VIEW  top_50_stations_for_casual_riders AS
 SELECT start_station_name,
       COUNT(*) AS num_of_rides
FROM tempdb.dbo.cleaned_data
GROUP BY start_station_name,customer_type
HAVING customer_type = 'casual'
ORDER BY COUNT(*) DESC
OFFSET 0 ROWS  
    FETCH NEXT 50 ROWS ONLY
