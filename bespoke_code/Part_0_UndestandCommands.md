## Connect to a database

In general we would write the following commands to connect to a
database:

    library("DBI")

    server_dbi <- "..."
    user       <- "..."
    password   <- "..."
    port       <- "..."
    host       <- "..." 

    db <- dbConnect(RPostgreSQL::PostgreSQL(),
                    dbname = server_dbi,
                    port = port,
                    host = host, 
                    user = user, 
                    password = password)

OHDSI packages use their own database connector:

    library("DatabaseConnector")
    library("here")

    server   <- "..."
    user     <- "..."
    password <- "..."
    port     <- "..."
    host     <- "..." 

    connectionDetails <- DatabaseConnector::downloadJdbcDrivers("postgresql", here::here())
    connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "postgresql",
                                                                   server = server,
                                                                   user = user,
                                                                   password = password,
                                                                   port = port ,
                                                                   pathToDriver = here::here())

In this example we are going to use a synthetic database called
[Eunomia](https://github.com/OHDSI/Eunomia) modified using
[duckdb](https://cran.r-project.org/web/packages/duckdb/duckdb.pdf). To
connect this database we are going to use the “standard” way:

    library("here")
    library("DatabaseConnector")
    library("duckdb")
    library("dplyr")
    library("dbplyr")

    drv <- duckdb(dbdir = here("Duckdb_Eunomia/eunomia.duckdb"))
    con <- dbConnect(drv)

For example, to read ‘person’ and ‘condition\_occurrence’ tables we can
use the following commands:

    condition_occurrence_db <- tbl(con, "CONDITION_OCCURRENCE")
    condition_occurrence_db

    ## # Source:   table<CONDITION_OCCURRENCE> [?? x 16]
    ## # Database: DuckDB 0.3.5-dev1410 [martics@Windows 10 x64:R 4.2.1/C:/Users/martics/Documents/GitHub/RWE_summer_school_2022/practicals/4_bespoke_code/Duckdb_Eunomia/eunomia.duckdb]
    ##    CONDITION_OCCUR… PERSON_ID CONDITION_CONCE… CONDITION_START… CONDITION_START…
    ##               <dbl>     <dbl>            <dbl> <date>           <date>          
    ##  1             4483       263          4112343 2015-10-02       2015-10-02      
    ##  2             4657       273           192671 2011-10-10       2011-10-10      
    ##  3             4815       283            28060 1984-02-15       1984-02-15      
    ##  4             4981       293           378001 2005-11-07       2005-11-07      
    ##  5             5153       304           257012 1974-07-30       1974-07-30      
    ##  6             5313       312          4134304 1991-05-14       1991-05-14      
    ##  7             5513       326            28060 1979-09-23       1979-09-23      
    ##  8             5655       334         40481087 1999-07-12       1999-07-12      
    ##  9             5811       341         40481087 1990-09-14       1990-09-14      
    ## 10             5977       351         40481087 1986-02-24       1986-02-24      
    ## # … with more rows, and 11 more variables: CONDITION_END_DATE <date>,
    ## #   CONDITION_END_DATETIME <date>, CONDITION_TYPE_CONCEPT_ID <dbl>,
    ## #   STOP_REASON <chr>, PROVIDER_ID <dbl>, VISIT_OCCURRENCE_ID <dbl>,
    ## #   VISIT_DETAIL_ID <dbl>, CONDITION_SOURCE_VALUE <chr>,
    ## #   CONDITION_SOURCE_CONCEPT_ID <dbl>, CONDITION_STATUS_SOURCE_VALUE <chr>,
    ## #   CONDITION_STATUS_CONCEPT_ID <dbl>

    person_db <- tbl(con, "PERSON")
    person_db

    ## # Source:   table<PERSON> [?? x 18]
    ## # Database: DuckDB 0.3.5-dev1410 [martics@Windows 10 x64:R 4.2.1/C:/Users/martics/Documents/GitHub/RWE_summer_school_2022/practicals/4_bespoke_code/Duckdb_Eunomia/eunomia.duckdb]
    ##    PERSON_ID GENDER_CONCEPT_ID YEAR_OF_BIRTH MONTH_OF_BIRTH DAY_OF_BIRTH
    ##        <dbl>             <dbl>         <dbl>          <dbl>        <dbl>
    ##  1         6              8532          1963             12           31
    ##  2       123              8507          1950              4           12
    ##  3       129              8507          1974             10            7
    ##  4        16              8532          1971             10           13
    ##  5        65              8532          1967              3           31
    ##  6        74              8532          1972              1            5
    ##  7        42              8532          1909             11            2
    ##  8       187              8507          1945              7           23
    ##  9        18              8532          1965             11           17
    ## 10       111              8532          1975              5            2
    ## # … with more rows, and 13 more variables: BIRTH_DATETIME <date>,
    ## #   RACE_CONCEPT_ID <dbl>, ETHNICITY_CONCEPT_ID <dbl>, LOCATION_ID <dbl>,
    ## #   PROVIDER_ID <dbl>, CARE_SITE_ID <dbl>, PERSON_SOURCE_VALUE <chr>,
    ## #   GENDER_SOURCE_VALUE <chr>, GENDER_SOURCE_CONCEPT_ID <dbl>,
    ## #   RACE_SOURCE_VALUE <chr>, RACE_SOURCE_CONCEPT_ID <dbl>,
    ## #   ETHNICITY_SOURCE_VALUE <chr>, ETHNICITY_SOURCE_CONCEPT_ID <dbl>

### Filter, select & %&gt;%

[Filter](https://www.rdocumentation.org/packages/dplyr/versions/0.7.8/topics/filter)
function is used to obtain the rows (in our db patients) that have a
desired condition.

[Select](https://www.rdocumentation.org/packages/dplyr/versions/0.7.8/topics/select)
function is used to obtain only the desired columns.

[%&gt;%](https://cran.r-project.org/web/packages/dplyr/vignettes/dplyr.html)
operator is used to chain operators one after the other

Lets filter people older than 80 (that were born before 1942)

    older80 <- filter(person_db,YEAR_OF_BIRTH<=1942)
    older80

    ## # Source:   SQL [?? x 18]
    ## # Database: DuckDB 0.3.5-dev1410 [martics@Windows 10 x64:R 4.2.1/C:/Users/martics/Documents/GitHub/RWE_summer_school_2022/practicals/4_bespoke_code/Duckdb_Eunomia/eunomia.duckdb]
    ##    PERSON_ID GENDER_CONCEPT_ID YEAR_OF_BIRTH MONTH_OF_BIRTH DAY_OF_BIRTH
    ##        <dbl>             <dbl>         <dbl>          <dbl>        <dbl>
    ##  1        42              8532          1909             11            2
    ##  2       149              8532          1941              8           19
    ##  3       191              8532          1920              6            1
    ##  4         2              8532          1920              6            1
    ##  5        96              8507          1924             12           27
    ##  6         3              8507          1916              1            3
    ##  7       286              8532          1928              5            5
    ##  8       245              8507          1916              6           18
    ##  9       162              8532          1938             11           22
    ## 10       116              8532          1926             11            7
    ## # … with more rows, and 13 more variables: BIRTH_DATETIME <date>,
    ## #   RACE_CONCEPT_ID <dbl>, ETHNICITY_CONCEPT_ID <dbl>, LOCATION_ID <dbl>,
    ## #   PROVIDER_ID <dbl>, CARE_SITE_ID <dbl>, PERSON_SOURCE_VALUE <chr>,
    ## #   GENDER_SOURCE_VALUE <chr>, GENDER_SOURCE_CONCEPT_ID <dbl>,
    ## #   RACE_SOURCE_VALUE <chr>, RACE_SOURCE_CONCEPT_ID <dbl>,
    ## #   ETHNICITY_SOURCE_VALUE <chr>, ETHNICITY_SOURCE_CONCEPT_ID <dbl>

Lets select year of birth and person\_id

    older80 <- select(filter(person_db,YEAR_OF_BIRTH<=1942),PERSON_ID,YEAR_OF_BIRTH)
    older80

    ## # Source:   SQL [?? x 2]
    ## # Database: DuckDB 0.3.5-dev1410 [martics@Windows 10 x64:R 4.2.1/C:/Users/martics/Documents/GitHub/RWE_summer_school_2022/practicals/4_bespoke_code/Duckdb_Eunomia/eunomia.duckdb]
    ##    PERSON_ID YEAR_OF_BIRTH
    ##        <dbl>         <dbl>
    ##  1        42          1909
    ##  2       149          1941
    ##  3       191          1920
    ##  4         2          1920
    ##  5        96          1924
    ##  6         3          1916
    ##  7       286          1928
    ##  8       245          1916
    ##  9       162          1938
    ## 10       116          1926
    ## # … with more rows

Combine them in an easy code (%&gt;%)

    older80 <- person_db %>% filter(YEAR_OF_BIRTH<=1942) %>% select(PERSON_ID,YEAR_OF_BIRTH)
    older80

    ## # Source:   SQL [?? x 2]
    ## # Database: DuckDB 0.3.5-dev1410 [martics@Windows 10 x64:R 4.2.1/C:/Users/martics/Documents/GitHub/RWE_summer_school_2022/practicals/4_bespoke_code/Duckdb_Eunomia/eunomia.duckdb]
    ##    PERSON_ID YEAR_OF_BIRTH
    ##        <dbl>         <dbl>
    ##  1        42          1909
    ##  2       149          1941
    ##  3       191          1920
    ##  4         2          1920
    ##  5        96          1924
    ##  6         3          1916
    ##  7       286          1928
    ##  8       245          1916
    ##  9       162          1938
    ## 10       116          1926
    ## # … with more rows

### Mutate, rename, group\_by, tally & distinct

[Mutate](https://www.rdocumentation.org/packages/dplyr/versions/0.5.0/topics/mutate)
is used to create new variables (columns) in the database. They can be
completely new variables or variables computed from the previous ones.

[Rename](https://www.rdocumentation.org/packages/plyr/versions/1.8.7/topics/rename)
is used to change the name of a column.

[Group\_by](https://www.rdocumentation.org/packages/dplyr/versions/0.7.8/topics/group_by)
is used to create groups in the data (functions then are applied into
this groups).

[Tally](https://www.rdocumentation.org/packages/dplyr/versions/0.5.0/topics/tally)
is used to count the number of elements (rows).

[Distinct](https://www.rdocumentation.org/packages/dplyr/versions/0.7.8/topics/distinct)
is used to ensure that all the rows are different.

See the different race concepts included in person\_db:

    Race <- person_db %>% select(RACE_CONCEPT_ID  )
    Race

    ## # Source:   SQL [?? x 1]
    ## # Database: DuckDB 0.3.5-dev1410 [martics@Windows 10 x64:R 4.2.1/C:/Users/martics/Documents/GitHub/RWE_summer_school_2022/practicals/4_bespoke_code/Duckdb_Eunomia/eunomia.duckdb]
    ##    RACE_CONCEPT_ID
    ##              <dbl>
    ##  1            8516
    ##  2            8527
    ##  3            8527
    ##  4            8527
    ##  5            8516
    ##  6            8527
    ##  7            8527
    ##  8            8527
    ##  9            8527
    ## 10            8527
    ## # … with more rows

Obtain the unique values for identifiers

    Race <- person_db %>% select(RACE_CONCEPT_ID  ) %>% distinct()
    Race

    ## # Source:   SQL [4 x 1]
    ## # Database: DuckDB 0.3.5-dev1410 [martics@Windows 10 x64:R 4.2.1/C:/Users/martics/Documents/GitHub/RWE_summer_school_2022/practicals/4_bespoke_code/Duckdb_Eunomia/eunomia.duckdb]
    ##   RACE_CONCEPT_ID
    ##             <dbl>
    ## 1            8516
    ## 2            8527
    ## 3            8515
    ## 4               0

Create variable age (mutate) and rename the variable race

    tab <- person_db %>% mutate(AGE = 2022 - year_of_birth) %>% rename(RACE = RACE_CONCEPT_ID)

Count the elements with different groups

    tab %>% tally()

    ## # Source:   SQL [1 x 1]
    ## # Database: DuckDB 0.3.5-dev1410 [martics@Windows 10 x64:R 4.2.1/C:/Users/martics/Documents/GitHub/RWE_summer_school_2022/practicals/4_bespoke_code/Duckdb_Eunomia/eunomia.duckdb]
    ##       n
    ##   <dbl>
    ## 1  2694

    tab %>% group_by(RACE) %>% tally()

    ## # Source:   SQL [4 x 2]
    ## # Database: DuckDB 0.3.5-dev1410 [martics@Windows 10 x64:R 4.2.1/C:/Users/martics/Documents/GitHub/RWE_summer_school_2022/practicals/4_bespoke_code/Duckdb_Eunomia/eunomia.duckdb]
    ##    RACE     n
    ##   <dbl> <dbl>
    ## 1  8516   338
    ## 2  8527  1693
    ## 3  8515   212
    ## 4     0   451

    tab %>% group_by(AGE) %>% tally()

    ## # Source:   SQL [?? x 2]
    ## # Database: DuckDB 0.3.5-dev1410 [martics@Windows 10 x64:R 4.2.1/C:/Users/martics/Documents/GitHub/RWE_summer_school_2022/practicals/4_bespoke_code/Duckdb_Eunomia/eunomia.duckdb]
    ##      AGE     n
    ##    <dbl> <dbl>
    ##  1    59    84
    ##  2    72    55
    ##  3    48    61
    ##  4    51    79
    ##  5    55    70
    ##  6    50    88
    ##  7   113    19
    ##  8    77    37
    ##  9    57    67
    ## 10    47    46
    ## # … with more rows

    tab %>% group_by(RACE,AGE) %>% tally()

    ## # Source:   SQL [?? x 3]
    ## # Database: DuckDB 0.3.5-dev1410 [martics@Windows 10 x64:R 4.2.1/C:/Users/martics/Documents/GitHub/RWE_summer_school_2022/practicals/4_bespoke_code/Duckdb_Eunomia/eunomia.duckdb]
    ## # Groups:   RACE
    ##     RACE   AGE     n
    ##    <dbl> <dbl> <dbl>
    ##  1  8516    59    12
    ##  2  8527    72    41
    ##  3  8527    48    42
    ##  4  8527    51    48
    ##  5  8516    55     9
    ##  6  8527    50    62
    ##  7  8527   113    16
    ##  8  8527    77    25
    ##  9  8527    57    42
    ## 10  8527    47    30
    ## # … with more rows

Save this table for later

    compute_table <- tab %>% group_by(RACE,AGE) %>% tally()

### show\_querry()

-   What
    [dbplyr](https://cran.r-project.org/web/packages/dplyr/dplyr.pdf)
    package is doing is to transform our R commands to SQL.
-   They are executed in the “DB side” and we see the output.
-   With this command we can see which are the sql commands that are
    being executed
-   Let’s see what our previous codes where doing…

<!-- -->

    older80 %>% show_query()

    ## <SQL>
    ## SELECT "PERSON_ID", "YEAR_OF_BIRTH"
    ## FROM "PERSON"
    ## WHERE ("YEAR_OF_BIRTH" <= 1942.0)

    Race %>% show_query()

    ## <SQL>
    ## SELECT DISTINCT "RACE_CONCEPT_ID"
    ## FROM "PERSON"

    tab %>% show_query()

    ## <SQL>
    ## SELECT
    ##   "PERSON_ID",
    ##   "GENDER_CONCEPT_ID",
    ##   "YEAR_OF_BIRTH",
    ##   "MONTH_OF_BIRTH",
    ##   "DAY_OF_BIRTH",
    ##   "BIRTH_DATETIME",
    ##   "RACE_CONCEPT_ID" AS "RACE",
    ##   "ETHNICITY_CONCEPT_ID",
    ##   "LOCATION_ID",
    ##   "PROVIDER_ID",
    ##   "CARE_SITE_ID",
    ##   "PERSON_SOURCE_VALUE",
    ##   "GENDER_SOURCE_VALUE",
    ##   "GENDER_SOURCE_CONCEPT_ID",
    ##   "RACE_SOURCE_VALUE",
    ##   "RACE_SOURCE_CONCEPT_ID",
    ##   "ETHNICITY_SOURCE_VALUE",
    ##   "ETHNICITY_SOURCE_CONCEPT_ID",
    ##   2022.0 - "year_of_birth" AS "AGE"
    ## FROM "PERSON"

    compute_table %>% show_query()

    ## <SQL>
    ## SELECT "RACE", "AGE", COUNT(*) AS "n"
    ## FROM (
    ##   SELECT
    ##     "PERSON_ID",
    ##     "GENDER_CONCEPT_ID",
    ##     "YEAR_OF_BIRTH",
    ##     "MONTH_OF_BIRTH",
    ##     "DAY_OF_BIRTH",
    ##     "BIRTH_DATETIME",
    ##     "RACE_CONCEPT_ID" AS "RACE",
    ##     "ETHNICITY_CONCEPT_ID",
    ##     "LOCATION_ID",
    ##     "PROVIDER_ID",
    ##     "CARE_SITE_ID",
    ##     "PERSON_SOURCE_VALUE",
    ##     "GENDER_SOURCE_VALUE",
    ##     "GENDER_SOURCE_CONCEPT_ID",
    ##     "RACE_SOURCE_VALUE",
    ##     "RACE_SOURCE_CONCEPT_ID",
    ##     "ETHNICITY_SOURCE_VALUE",
    ##     "ETHNICITY_SOURCE_CONCEPT_ID",
    ##     2022.0 - "year_of_birth" AS "AGE"
    ##   FROM "PERSON"
    ## ) "q01"
    ## GROUP BY "RACE", "AGE"

### Compute, collect & pull

In fact, all this operations are carried out in the “database side” so
how we can connect our environment of R with the variables that we want
to obtain:

[Compute](https://www.rdocumentation.org/packages/dplyr/versions/0.5.0/topics/compute)
is used to force the computation of a set of commands, if compute is not
used our variable only contains the set of commands and not the result.

[Collect](https://www.rdocumentation.org/packages/memisc/versions/0.99.30.7/topics/collect)
is used to move one data set to our R environment

[Pull](https://www.rdocumentation.org/packages/lplyr/versions/0.1.6/topics/pull)
is used to obtain an array of the table (moving the data set to our
environment, if necessary)

    library(tictoc)
    tab

    ## # Source:   SQL [?? x 19]
    ## # Database: DuckDB 0.3.5-dev1410 [martics@Windows 10 x64:R 4.2.1/C:/Users/martics/Documents/GitHub/RWE_summer_school_2022/practicals/4_bespoke_code/Duckdb_Eunomia/eunomia.duckdb]
    ##    PERSON_ID GENDER_CONCEPT_ID YEAR_OF_BIRTH MONTH_OF_BIRTH DAY_OF_BIRTH
    ##        <dbl>             <dbl>         <dbl>          <dbl>        <dbl>
    ##  1         6              8532          1963             12           31
    ##  2       123              8507          1950              4           12
    ##  3       129              8507          1974             10            7
    ##  4        16              8532          1971             10           13
    ##  5        65              8532          1967              3           31
    ##  6        74              8532          1972              1            5
    ##  7        42              8532          1909             11            2
    ##  8       187              8507          1945              7           23
    ##  9        18              8532          1965             11           17
    ## 10       111              8532          1975              5            2
    ## # … with more rows, and 14 more variables: BIRTH_DATETIME <date>, RACE <dbl>,
    ## #   ETHNICITY_CONCEPT_ID <dbl>, LOCATION_ID <dbl>, PROVIDER_ID <dbl>,
    ## #   CARE_SITE_ID <dbl>, PERSON_SOURCE_VALUE <chr>, GENDER_SOURCE_VALUE <chr>,
    ## #   GENDER_SOURCE_CONCEPT_ID <dbl>, RACE_SOURCE_VALUE <chr>,
    ## #   RACE_SOURCE_CONCEPT_ID <dbl>, ETHNICITY_SOURCE_VALUE <chr>,
    ## #   ETHNICITY_SOURCE_CONCEPT_ID <dbl>, AGE <dbl>

    tic()
    tab

    ## # Source:   SQL [?? x 19]
    ## # Database: DuckDB 0.3.5-dev1410 [martics@Windows 10 x64:R 4.2.1/C:/Users/martics/Documents/GitHub/RWE_summer_school_2022/practicals/4_bespoke_code/Duckdb_Eunomia/eunomia.duckdb]
    ##    PERSON_ID GENDER_CONCEPT_ID YEAR_OF_BIRTH MONTH_OF_BIRTH DAY_OF_BIRTH
    ##        <dbl>             <dbl>         <dbl>          <dbl>        <dbl>
    ##  1         6              8532          1963             12           31
    ##  2       123              8507          1950              4           12
    ##  3       129              8507          1974             10            7
    ##  4        16              8532          1971             10           13
    ##  5        65              8532          1967              3           31
    ##  6        74              8532          1972              1            5
    ##  7        42              8532          1909             11            2
    ##  8       187              8507          1945              7           23
    ##  9        18              8532          1965             11           17
    ## 10       111              8532          1975              5            2
    ## # … with more rows, and 14 more variables: BIRTH_DATETIME <date>, RACE <dbl>,
    ## #   ETHNICITY_CONCEPT_ID <dbl>, LOCATION_ID <dbl>, PROVIDER_ID <dbl>,
    ## #   CARE_SITE_ID <dbl>, PERSON_SOURCE_VALUE <chr>, GENDER_SOURCE_VALUE <chr>,
    ## #   GENDER_SOURCE_CONCEPT_ID <dbl>, RACE_SOURCE_VALUE <chr>,
    ## #   RACE_SOURCE_CONCEPT_ID <dbl>, ETHNICITY_SOURCE_VALUE <chr>,
    ## #   ETHNICITY_SOURCE_CONCEPT_ID <dbl>, AGE <dbl>

    toc()

    ## 0.11 sec elapsed

    tic()
    tab_saved <- tab %>% compute()
    toc()

    ## 0.05 sec elapsed

    tic()
    tab_saved

    ## # Source:   table<dbplyr_001> [?? x 19]
    ## # Database: DuckDB 0.3.5-dev1410 [martics@Windows 10 x64:R 4.2.1/C:/Users/martics/Documents/GitHub/RWE_summer_school_2022/practicals/4_bespoke_code/Duckdb_Eunomia/eunomia.duckdb]
    ##    PERSON_ID GENDER_CONCEPT_ID YEAR_OF_BIRTH MONTH_OF_BIRTH DAY_OF_BIRTH
    ##        <dbl>             <dbl>         <dbl>          <dbl>        <dbl>
    ##  1         6              8532          1963             12           31
    ##  2       123              8507          1950              4           12
    ##  3       129              8507          1974             10            7
    ##  4        16              8532          1971             10           13
    ##  5        65              8532          1967              3           31
    ##  6        74              8532          1972              1            5
    ##  7        42              8532          1909             11            2
    ##  8       187              8507          1945              7           23
    ##  9        18              8532          1965             11           17
    ## 10       111              8532          1975              5            2
    ## # … with more rows, and 14 more variables: BIRTH_DATETIME <date>, RACE <dbl>,
    ## #   ETHNICITY_CONCEPT_ID <dbl>, LOCATION_ID <dbl>, PROVIDER_ID <dbl>,
    ## #   CARE_SITE_ID <dbl>, PERSON_SOURCE_VALUE <chr>, GENDER_SOURCE_VALUE <chr>,
    ## #   GENDER_SOURCE_CONCEPT_ID <dbl>, RACE_SOURCE_VALUE <chr>,
    ## #   RACE_SOURCE_CONCEPT_ID <dbl>, ETHNICITY_SOURCE_VALUE <chr>,
    ## #   ETHNICITY_SOURCE_CONCEPT_ID <dbl>, AGE <dbl>

    toc()

    ## 0.07 sec elapsed

    nrow(tab_saved)

    ## [1] NA

    tab_collected <- tab %>% collect()
    tab_collected

    ## # A tibble: 2,694 × 19
    ##    PERSON_ID GENDER_CONCEPT_ID YEAR_OF_BIRTH MONTH_OF_BIRTH DAY_OF_BIRTH
    ##        <dbl>             <dbl>         <dbl>          <dbl>        <dbl>
    ##  1         6              8532          1963             12           31
    ##  2       123              8507          1950              4           12
    ##  3       129              8507          1974             10            7
    ##  4        16              8532          1971             10           13
    ##  5        65              8532          1967              3           31
    ##  6        74              8532          1972              1            5
    ##  7        42              8532          1909             11            2
    ##  8       187              8507          1945              7           23
    ##  9        18              8532          1965             11           17
    ## 10       111              8532          1975              5            2
    ## # … with 2,684 more rows, and 14 more variables: BIRTH_DATETIME <date>,
    ## #   RACE <dbl>, ETHNICITY_CONCEPT_ID <dbl>, LOCATION_ID <dbl>,
    ## #   PROVIDER_ID <dbl>, CARE_SITE_ID <dbl>, PERSON_SOURCE_VALUE <chr>,
    ## #   GENDER_SOURCE_VALUE <chr>, GENDER_SOURCE_CONCEPT_ID <dbl>,
    ## #   RACE_SOURCE_VALUE <chr>, RACE_SOURCE_CONCEPT_ID <dbl>,
    ## #   ETHNICITY_SOURCE_VALUE <chr>, ETHNICITY_SOURCE_CONCEPT_ID <dbl>, AGE <dbl>

    nrow(tab_collected)

    ## [1] 2694

    genders1 <- tab_collected %>% select(GENDER_CONCEPT_ID) %>% pull()
    genders2 <- tab_saved %>% select(GENDER_CONCEPT_ID) %>% pull()
    genders3 <- tab %>% select(GENDER_CONCEPT_ID) %>% pull()
    identical(genders1,genders2)

    ## [1] TRUE

    identical(genders1,genders3)

    ## [1] TRUE

    identical(genders2,genders3)

    ## [1] TRUE

### Inner\_join, full\_join, left\_join, right\_join & anti\_join

Join tables is a very powerful tool that allow us to merge two different
tables into just one. We are going to show five ways to join two tables.

[Inner\_join](https://www.rdocumentation.org/packages/tidyft/versions/0.4.5/topics/inner_join):
only elements contained in both tables.

[Full\_join](https://www.rdocumentation.org/packages/tidylog/versions/1.0.2/topics/full_join):
all element (even if they are not contained in one of the tables). NAs
are introduced for absences.

[Left\_join](https://www.rdocumentation.org/packages/tidytable/versions/0.8.0/topics/left_join.):
only elements in the first table are included. NAs are introduced for
absences.

[Right\_join](https://www.rdocumentation.org/packages/sparklyr/versions/1.7.5/topics/right_join):
only elements in the second table are included. NAs are introduced for
absences.

[Anti\_join](https://www.rdocumentation.org/packages/tidylog/versions/1.0.2/topics/anti_join):
only elements that are in the first table but not in the second are
included.

Tables are joined using the variable specified (by=“variable”), if it is
not specified all common variables are used.

Lets define two tables we are going to work with:

Table 1: people\_db with only the people aged 80

    table1 <- person_db %>%
      filter(YEAR_OF_BIRTH == 1942) %>%
      select(PERSON_ID,GENDER_CONCEPT_ID,YEAR_OF_BIRTH) %>%
      compute()
    table1

    ## # Source:   table<dbplyr_002> [?? x 3]
    ## # Database: DuckDB 0.3.5-dev1410 [martics@Windows 10 x64:R 4.2.1/C:/Users/martics/Documents/GitHub/RWE_summer_school_2022/practicals/4_bespoke_code/Duckdb_Eunomia/eunomia.duckdb]
    ##    PERSON_ID GENDER_CONCEPT_ID YEAR_OF_BIRTH
    ##        <dbl>             <dbl>         <dbl>
    ##  1       224              8532          1942
    ##  2       940              8507          1942
    ##  3      1459              8507          1942
    ##  4      1219              8507          1942
    ##  5      2260              8507          1942
    ##  6      1779              8507          1942
    ##  7      2082              8532          1942
    ##  8      2427              8532          1942
    ##  9      2220              8507          1942
    ## 10      2226              8507          1942
    ## # … with more rows

Table 2: the first event (condition\_occurrence) of: “Sprain of ankle”:

    table2 <- condition_occurrence_db %>%
      filter(CONDITION_CONCEPT_ID == 81151) %>%
      select(PERSON_ID,CONDITION_START_DATE) %>%
      group_by(PERSON_ID) %>%
      filter(CONDITION_START_DATE == min(CONDITION_START_DATE)) %>%
      ungroup() %>%
      compute()

    ## Warning: Missing values are always removed in SQL aggregation functions.
    ## Use `na.rm = TRUE` to silence this warning
    ## This warning is displayed once every 8 hours.

    table2

    ## # Source:   table<dbplyr_003> [?? x 2]
    ## # Database: DuckDB 0.3.5-dev1410 [martics@Windows 10 x64:R 4.2.1/C:/Users/martics/Documents/GitHub/RWE_summer_school_2022/practicals/4_bespoke_code/Duckdb_Eunomia/eunomia.duckdb]
    ##    PERSON_ID CONDITION_START_DATE
    ##        <dbl> <date>              
    ##  1      1328 1980-12-31          
    ##  2      2790 1984-12-01          
    ##  3      1145 1961-10-22          
    ##  4      4709 2008-06-08          
    ##  5      3315 1968-06-28          
    ##  6      1217 1988-10-20          
    ##  7      1751 1980-09-12          
    ##  8      4418 1952-07-21          
    ##  9      5215 1982-08-20          
    ## 10       487 2015-02-24          
    ## # … with more rows

Number of elements in each table

    table1 %>% tally() %>% pull()

    ## [1] 26

    table2 %>% tally() %>% pull()

    ## [1] 1357

Individuals who are in any both tables

    table1_and_2 <- table1 %>% full_join(table2)

    ## Joining, by = "PERSON_ID"

    table1_and_2 <- table1 %>% full_join(table2,by="PERSON_ID")
    table1 %>% full_join(table2,by="PERSON_ID") %>% tally() %>% pull()

    ## [1] 1364

    table2 %>% full_join(table1,by="PERSON_ID") %>% tally() %>% pull()

    ## [1] 1364

Individuals in both tables

    table1 %>% inner_join(table2,by="PERSON_ID") %>% tally() %>% pull()

    ## [1] 19

    table2 %>% inner_join(table1,by="PERSON_ID") %>% tally() %>% pull()

    ## [1] 19

Left join, we can see that the final table has the size of the initial
one (first to appear)

    table1 %>% left_join(table2,by="PERSON_ID")

    ## # Source:   SQL [?? x 4]
    ## # Database: DuckDB 0.3.5-dev1410 [martics@Windows 10 x64:R 4.2.1/C:/Users/martics/Documents/GitHub/RWE_summer_school_2022/practicals/4_bespoke_code/Duckdb_Eunomia/eunomia.duckdb]
    ##    PERSON_ID GENDER_CONCEPT_ID YEAR_OF_BIRTH CONDITION_START_DATE
    ##        <dbl>             <dbl>         <dbl> <date>              
    ##  1      2406              8507          1942 1958-01-20          
    ##  2      3295              8532          1942 1957-12-18          
    ##  3      2927              8507          1942 1954-05-21          
    ##  4      2226              8507          1942 2008-11-23          
    ##  5      1219              8507          1942 1978-08-11          
    ##  6      2685              8507          1942 1992-04-12          
    ##  7      3509              8532          1942 1943-01-11          
    ##  8      2705              8507          1942 1966-09-20          
    ##  9      3456              8507          1942 1978-10-07          
    ## 10      2220              8507          1942 1949-07-07          
    ## # … with more rows

    table1 %>% left_join(table2,by="PERSON_ID") %>% tally() %>% pull() 

    ## [1] 26

    table2 %>% left_join(table1,by="PERSON_ID")

    ## # Source:   SQL [?? x 4]
    ## # Database: DuckDB 0.3.5-dev1410 [martics@Windows 10 x64:R 4.2.1/C:/Users/martics/Documents/GitHub/RWE_summer_school_2022/practicals/4_bespoke_code/Duckdb_Eunomia/eunomia.duckdb]
    ##    PERSON_ID CONDITION_START_DATE GENDER_CONCEPT_ID YEAR_OF_BIRTH
    ##        <dbl> <date>                           <dbl>         <dbl>
    ##  1      2406 1958-01-20                        8507          1942
    ##  2      3295 1957-12-18                        8532          1942
    ##  3      2927 1954-05-21                        8507          1942
    ##  4      2226 2008-11-23                        8507          1942
    ##  5      1219 1978-08-11                        8507          1942
    ##  6      2685 1992-04-12                        8507          1942
    ##  7      3509 1943-01-11                        8532          1942
    ##  8      2705 1966-09-20                        8507          1942
    ##  9      3456 1978-10-07                        8507          1942
    ## 10      2220 1949-07-07                        8507          1942
    ## # … with more rows

    table2 %>% left_join(table1,by="PERSON_ID") %>% tally() %>% pull()

    ## [1] 1357

Right join, we can see that the final table has the size of the joined
table (second to appear)

    table1 %>% right_join(table2,by="PERSON_ID")

    ## # Source:   SQL [?? x 4]
    ## # Database: DuckDB 0.3.5-dev1410 [martics@Windows 10 x64:R 4.2.1/C:/Users/martics/Documents/GitHub/RWE_summer_school_2022/practicals/4_bespoke_code/Duckdb_Eunomia/eunomia.duckdb]
    ##    PERSON_ID GENDER_CONCEPT_ID YEAR_OF_BIRTH CONDITION_START_DATE
    ##        <dbl>             <dbl>         <dbl> <date>              
    ##  1      2406              8507          1942 1958-01-20          
    ##  2      3295              8532          1942 1957-12-18          
    ##  3      2927              8507          1942 1954-05-21          
    ##  4      2226              8507          1942 2008-11-23          
    ##  5      1219              8507          1942 1978-08-11          
    ##  6      2685              8507          1942 1992-04-12          
    ##  7      3509              8532          1942 1943-01-11          
    ##  8      2705              8507          1942 1966-09-20          
    ##  9      3456              8507          1942 1978-10-07          
    ## 10      2220              8507          1942 1949-07-07          
    ## # … with more rows

    table1 %>% right_join(table2,by="PERSON_ID") %>% tally() %>% pull() 

    ## [1] 1357

    table2 %>% right_join(table1,by="PERSON_ID")

    ## # Source:   SQL [?? x 4]
    ## # Database: DuckDB 0.3.5-dev1410 [martics@Windows 10 x64:R 4.2.1/C:/Users/martics/Documents/GitHub/RWE_summer_school_2022/practicals/4_bespoke_code/Duckdb_Eunomia/eunomia.duckdb]
    ##    PERSON_ID CONDITION_START_DATE GENDER_CONCEPT_ID YEAR_OF_BIRTH
    ##        <dbl> <date>                           <dbl>         <dbl>
    ##  1      2406 1958-01-20                        8507          1942
    ##  2      3295 1957-12-18                        8532          1942
    ##  3      2927 1954-05-21                        8507          1942
    ##  4      2226 2008-11-23                        8507          1942
    ##  5      1219 1978-08-11                        8507          1942
    ##  6      2685 1992-04-12                        8507          1942
    ##  7      3509 1943-01-11                        8532          1942
    ##  8      2705 1966-09-20                        8507          1942
    ##  9      3456 1978-10-07                        8507          1942
    ## 10      2220 1949-07-07                        8507          1942
    ## # … with more rows

    table2 %>% right_join(table1,by="PERSON_ID") %>% tally() %>% pull()

    ## [1] 26

Anti\_join, eliminate from the first table the individuals that appear
in the second table

    table1 %>% anti_join(table2,by="PERSON_ID")

    ## # Source:   SQL [7 x 3]
    ## # Database: DuckDB 0.3.5-dev1410 [martics@Windows 10 x64:R 4.2.1/C:/Users/martics/Documents/GitHub/RWE_summer_school_2022/practicals/4_bespoke_code/Duckdb_Eunomia/eunomia.duckdb]
    ##   PERSON_ID GENDER_CONCEPT_ID YEAR_OF_BIRTH
    ##       <dbl>             <dbl>         <dbl>
    ## 1      2260              8507          1942
    ## 2      2427              8532          1942
    ## 3      3194              8532          1942
    ## 4      2859              8532          1942
    ## 5      3906              8507          1942
    ## 6      4284              8532          1942
    ## 7      5285              8532          1942

    table1 %>% anti_join(table2,by="PERSON_ID") %>% tally() %>% pull()

    ## [1] 7

    table2 %>% anti_join(table1,by="PERSON_ID")

    ## # Source:   SQL [?? x 2]
    ## # Database: DuckDB 0.3.5-dev1410 [martics@Windows 10 x64:R 4.2.1/C:/Users/martics/Documents/GitHub/RWE_summer_school_2022/practicals/4_bespoke_code/Duckdb_Eunomia/eunomia.duckdb]
    ##    PERSON_ID CONDITION_START_DATE
    ##        <dbl> <date>              
    ##  1      1328 1980-12-31          
    ##  2      2790 1984-12-01          
    ##  3      1145 1961-10-22          
    ##  4      4709 2008-06-08          
    ##  5      3315 1968-06-28          
    ##  6      1217 1988-10-20          
    ##  7      1751 1980-09-12          
    ##  8      4418 1952-07-21          
    ##  9      5215 1982-08-20          
    ## 10       487 2015-02-24          
    ## # … with more rows

    table2 %>% anti_join(table1,by="PERSON_ID") %>% tally() %>% pull()

    ## [1] 1338
