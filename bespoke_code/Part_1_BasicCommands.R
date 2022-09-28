library("DBI")
library("dplyr")
library("dbplyr")
library("CDMConnector")
library("duckdb")

con <- dbConnect(duckdb(), dbdir = eunomia_dir())
cdm <- cdm_from_con(con, cdm_schema = "main")

