library(keyring)
library(RMariaDB)
library(tidyverse)

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

databases_df <- dbGetQuery(conn, "SHOW DATABASES;")
dbExecute(conn, "USE cla_tntlab;")
dbGetQuery(conn, "SHOW TABLES")

datascience_8960_table = dbGetQuery(conn, 
                                    "SELECT * FROM datascience_8960_table")
write_csv(datascience_8960_table, "../data/week13.csv")

# Open saved dataset 
week13_tbl = read_csv("../data/week13.csv", show_col_types = FALSE)

##### Analysis #####

# Display the total number of managers.
nrow(week13_tbl)

# Display the total number of unique managers.
length(unique(week13_tbl$employee_id))

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

# Display the location and ID numbers of the top 3 managers from each location, 
# in alphabetical order by location and then descending order of test score. 
# If there are ties, include everyone reaching rank 3. 
week13_tbl %>% 
  select(city,employee_id, test_score) %>%
  group_by(city) %>%
  mutate(ranking = dense_rank(desc(test_score))) %>%
  filter(ranking<=3) %>%
  arrange(city, desc(test_score))
