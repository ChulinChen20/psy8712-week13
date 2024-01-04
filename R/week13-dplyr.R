library(keyring)
library(RMariaDB)
library(tidyverse)
library(psych)

# Script Settings and Resources
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

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

## Reading in created dataset 
week13_tbl = read_csv("../data/week13.csv", show_col_types = FALSE)

# Analysis

# Display the total number of managers.
week13_tbl %>% nrow()

# Display the total number of unique managers.
week13_tbl %>% nrow()
