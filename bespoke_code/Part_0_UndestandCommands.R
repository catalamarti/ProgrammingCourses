library("here")
library("DatabaseConnector")
library("duckdb")
library("dplyr")
library("dbplyr")

#### Connections ####

drv <- duckdb(dbdir = here("Duckdb_Eunomia/eunomia.duckdb"))
con <- dbConnect(drv)

condition_occurrence_db <- tbl(con, "CONDITION_OCCURRENCE")
condition_occurrence_db
person_db <- tbl(con, "PERSON")
person_db

#### filter, select & %>% ####

older80 <- filter(person_db,YEAR_OF_BIRTH<=1942)
older80

older80 <- select(filter(person_db,YEAR_OF_BIRTH<=1942),PERSON_ID,YEAR_OF_BIRTH)
older80

older80 <- person_db %>% filter(YEAR_OF_BIRTH<=1942) %>% select(PERSON_ID,YEAR_OF_BIRTH)
older80

#### Mutate, rename, group_by, tally & distinct ####

# See the different race concepts included in person_db:
Race <- person_db %>% select(RACE_CONCEPT_ID  )
Race

# Obtain the unique values for identifiers
Race <- person_db %>% select(RACE_CONCEPT_ID  ) %>% distinct()
Race

# Create variable age (mutate) and rename the variable race
tab <- person_db %>% mutate(AGE = 2022 - year_of_birth) %>% rename(RACE = RACE_CONCEPT_ID)

# Count the elements with different groups
tab %>% tally()
tab %>% group_by(RACE) %>% tally()
tab %>% group_by(AGE) %>% tally()
tab %>% group_by(RACE,AGE) %>% tally()

# Save this table for later
compute_table <- tab %>% group_by(RACE,AGE) %>% tally()

#### show_querry() ####
older80 %>% show_query()
Race %>% show_query()
tab %>% show_query()
compute_table %>% show_query()

#### Compute, collect & pull ####

library(tictoc)
tab

tic()
tab
toc()

tic()
tab_saved <- tab %>% compute()
toc()

tic()
tab_saved
toc()

nrow(tab_saved)

tab_collected <- tab %>% collect()
tab_collected
nrow(tab_collected)

genders1 <- tab_collected %>% select(GENDER_CONCEPT_ID) %>% pull()
genders2 <- tab_saved %>% select(GENDER_CONCEPT_ID) %>% pull()
genders3 <- tab %>% select(GENDER_CONCEPT_ID) %>% pull()
identical(genders1,genders2)
identical(genders1,genders3)
identical(genders2,genders3)

#### Inner_join, full_join, left_join, right_join & anti_join ####

# Table 1: people_db with only the people aged 80
table1 <- person_db %>%
  filter(YEAR_OF_BIRTH == 1942) %>%
  select(PERSON_ID,GENDER_CONCEPT_ID,YEAR_OF_BIRTH) %>%
  compute()
table1

# Table 2: the first event (condition_occurrence) of: "Sprain of ankle":
table2 <- condition_occurrence_db %>%
  filter(CONDITION_CONCEPT_ID == 81151) %>%
  select(PERSON_ID,CONDITION_START_DATE) %>%
  group_by(PERSON_ID) %>%
  filter(CONDITION_START_DATE == min(CONDITION_START_DATE, na.rm = TRUE)) %>%
  ungroup() %>%
  compute()
table2

# Number of elements in each table
table1 %>% tally() %>% pull()
table2 %>% tally() %>% pull()

# Individuals who are in any both tables
table1_and_2 <- table1 %>% full_join(table2)
table1_and_2 <- table1 %>% full_join(table2,by="PERSON_ID")
table1 %>% full_join(table2,by="PERSON_ID") %>% tally() %>% pull()
table2 %>% full_join(table1,by="PERSON_ID") %>% tally() %>% pull()

# Individuals in both tables
table1 %>% inner_join(table2,by="PERSON_ID") %>% tally() %>% pull()
table2 %>% inner_join(table1,by="PERSON_ID") %>% tally() %>% pull()

# Left join, we can see that the final table has the size of the initial one (first to appear)
table1 %>% left_join(table2,by="PERSON_ID")
table1 %>% left_join(table2,by="PERSON_ID") %>% tally() %>% pull() 
table2 %>% left_join(table1,by="PERSON_ID")
table2 %>% left_join(table1,by="PERSON_ID") %>% tally() %>% pull()
tail(table2 %>% left_join(table1,by="PERSON_ID") %>% collect(),10)

# Right join, we can see that the final table has the size of the joined table (second to appear)
table1 %>% right_join(table2,by="PERSON_ID")
table1 %>% right_join(table2,by="PERSON_ID") %>% tally() %>% pull() 
table2 %>% right_join(table1,by="PERSON_ID")
table2 %>% right_join(table1,by="PERSON_ID") %>% tally() %>% pull()

# Anti_join, eliminate from the first table the individuals that appear in the second table
table1 %>% anti_join(table2,by="PERSON_ID")
table1 %>% anti_join(table2,by="PERSON_ID") %>% tally() %>% pull()
table2 %>% anti_join(table1,by="PERSON_ID")
table2 %>% anti_join(table1,by="PERSON_ID") %>% tally() %>% pull()

