library(keyring)
library(RMariaDB)

##### Script Settings and Resources #####
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

##### Data Import and cleaning #####
## Run in Console ##
key_set_with_value(service="latis-mysql", username="chen6496",
                   password="Timeandspace1918")

conn <- dbConnect(MariaDB(),
                  user="chen6496",
                  password=key_get("latis-mysql","chen6496"),
                  host="mysql-prod5.oit.umn.edu",
                  port=3306,
                  ssl.ca = 'mysql_hotel_umn_20220728_interm.cer'
)

# show information about database 
dbGetQuery(conn, "SHOW DATABASES;")
# pick tables in cla_tntlab for further operations
dbExecute(conn, "USE cla_tntlab;")
dbGetQuery(conn, "SHOW TABLES")

# Display the total number of managers
dbGetQuery(conn, "SELECT COUNT(*) 
           FROM datascience_employees 
           INNER JOIN datascience_testscores 
           ON datascience_employees.employee_id = datascience_testscores.employee_id;")

# Display the total number of unique managers (i.e., unique by id number).
dbGetQuery(conn, "SELECT COUNT(DISTINCT(datascience_employees.employee_id)) 
           FROM datascience_employees 
           INNER JOIN datascience_testscores 
           ON datascience_employees.employee_id = datascience_testscores.employee_id;")

# Display a summary of the number of managers split by location, 
#but only include those who were not originally hired as managers.
dbGetQuery(conn, "SELECT COUNT(DISTINCT(datascience_employees.employee_id)) AS num_managers, city
           FROM datascience_employees 
           INNER JOIN datascience_testscores 
           ON datascience_employees.employee_id = datascience_testscores.employee_id 
           WHERE manager_hire = 'N'
           GROUP BY city;")

# Display the average and standard deviation of number of years of employment 
#split by performance level (bottom, middle, and top).

dbGetQuery(conn, "SELECT performance_group, AVG(yrs_employed) AS avg_yrs, 
           STDDEV(yrs_employed) AS sd_yrs 
           FROM datascience_employees 
           INNER JOIN datascience_testscores 
           ON datascience_employees.employee_id = datascience_testscores.employee_id  
           GROUP BY performance_group;")

# Display the location and ID numbers of all managers from each location, 
# in alphabetical order by location and then descending order of test score. 

dbGetQuery(conn, "
           SELECT datascience_employees.employee_id, city, test_score,
           DENSE_RANK() OVER(PARTITION BY city ORDER BY city ASC, test_score DESC) 
           AS ranking
           FROM datascience_employees 
           INNER JOIN datascience_testscores 
           ON datascience_employees.employee_id = datascience_testscores.employee_id 
           ")
