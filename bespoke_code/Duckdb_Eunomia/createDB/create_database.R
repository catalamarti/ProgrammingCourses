library("dbplyr")
library("RSQLite")
library("here")
library("dplyr")
library("DatabaseConnector")
library("duckdb")

db <- dbConnect(drv=RSQLite::SQLite(), dbname=here("eunomia.sqlite"))

cdm_database_schema <- "main"
names <- dbListTables(db)
ConvertDates <- NULL
for (k in 1:length(names)){
  DataDb <- tbl(db, sql(paste0("SELECT * FROM ",cdm_database_schema,".",names[k])))
  ColumNames <- colnames(DataDb)
  ColumNames <- ColumNames[grep("DATE",ColumNames)]
  if (length(ColumNames)>0){
    if (is.null(ConvertDates)){
      ConvertDates <- tibble(TableName = names[k], VariableName = ColumNames)
    } else {
      ConvertDates <- rbind(ConvertDates,tibble(TableName = names[k], VariableName = ColumNames))
    }
  }
}

drv <- duckdb(dbdir = here("Duckdb_Eunomia/eunomia.duckdb"))
con <- dbConnect(drv)

for (k in 1:length(names)){
  DataDb <- tbl(db, sql(paste0("SELECT * FROM ",cdm_database_schema,".",names[k]))) %>% collect()
  VariablesConvert <- ConvertDates %>% filter(TableName == names[k]) 
  if (nrow(VariablesConvert)>0){
    VariablesConvert <- VariablesConvert %>% select(VariableName) %>% pull()
    for (i in 1:length(VariablesConvert)){
      VariableName.i <- VariablesConvert[i]
      DataDb <- DataDb %>% 
        rename("DaysAdd" = VariableName.i) %>%
        mutate(DaysAdd = DaysAdd/3600/24) %>%
        mutate(DaysAdd = as.Date("1970-01-01") + DaysAdd) %>%
        rename(!!VariableName.i := "DaysAdd")
    }
  }
  DBI::dbWithTransaction(con,{DBI::dbWriteTable(con, names[k], DataDb,overwrite = TRUE)})
}

observation_period_db <- tbl(con, "observation_period")

dbDisconnect(con)