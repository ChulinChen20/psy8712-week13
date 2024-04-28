library(keyring)
library(RMariaDB)
library(tidyverse)

##### Script Settings and Resources #####
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

##### Data Import and cleaning #####
conn <- dbConnect(MariaDB(),
                  user="chen6496",
                  password=key_get("latis-mysql","chen6496"),
                  host="mysql-prod5.oit.umn.edu",
                  port=3306,
                  ssl.ca = 'mysql_hotel_umn_20220728_interm.cer'
)

databases_df <- dbGetQuery(conn, "SHOW DATABASES;")
dbExecute(conn, "USE cla_tntlab;")
dbGetQuery(conn, "SHOW TABLES")

employees_tbl = dbGetQuery(conn, 
                                    "SELECT * FROM datascience_employees") 
write_csv(employees_tbl, "../data/employees.csv")

testscores_tbl = dbGetQuery(conn, 
                           "SELECT * FROM datascience_testscores") 
write_csv(testscores_tbl, "../data/testscores.csv")

offices_tbl = dbGetQuery(conn, 
                           "SELECT * FROM datascience_offices") 
write_csv(offices_tbl, "../data/offices.csv")

# combine dataset an remove employees without test scores 
week13_tbl = inner_join(employees_tbl,testscores_tbl,by="employee_id")
write_csv(week13_tbl, "../data/week13.csv")

##### Analysis #####

# Display the total number of managers.
week13_tbl %>%
  summarize(total_rows = n())

# Display the total number of unique managers.
week13_tbl %>%
  distinct(employee_id) %>%  
  summarize(total_unique_rows = n())

# Display a summary of the number of managers split by location, 
#but only include those who were not originally hired as managers.
week13_tbl %>%
  filter(manager_hire == "N") %>%
  group_by(city) %>%
    count()

# Display the average and standard deviation of number of years of employment 
#split by performance level (bottom, middle, and top).
week13_tbl %>% 
  group_by(performance_group) %>%
  summarise(avg_yrs = mean(yrs_employed), sd_yrs = sd(yrs_employed))

# Display the location and ID numbers of each manager from each location, 
# in alphabetical order by location and then descending order of test score. 

week13_tbl %>% 
  select(city,employee_id, test_score) %>%
  group_by(city) %>%
  mutate(ranking = dense_rank(desc(test_score))) %>%
  arrange(city, desc(test_score))
