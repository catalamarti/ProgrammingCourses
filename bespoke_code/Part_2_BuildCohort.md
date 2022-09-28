## Introduction

This R markdown document is the guideline for the second part of the
practicum.

In this part we are going to:

1.  Generate a cohort using the commands explained in the previous
    session.

2.  Generate a cohort from a .json definition generated in ATLAS

3.  Check that both cohorts are the same.

The database that we are are going to use is a modified version of
[Eunomia](https://github.com/OHDSI/Eunomia) using
[duckdb](https://cran.r-project.org/web/packages/duckdb/duckdb.pdf) and
[CDMConnector](https://odyosg.github.io/CDMConnector/).

This document contain the tasks that we must try to complete during this
session. If at some point we are not able to proceed, ask help to any of
the nice and ready to help guys from the summer school. Also, the .Rmd
file contains the solutions, although it is not recommended to use.

### Cohort definition

Individuals included in our cohort must fulfill the following criteria:

-   They are aged between 20 and 60 years old at 2000-01-01
-   Had a condition occurrence of “Viral sinusitis” between 2000-01-01
    and 2004-12-31.
-   They were used to “Doxylamine” in the next 3 months (90 days) after
    the occurrence.
-   They were in continuous observation since 365 days previous the
    condition occurrence.

We are going to define the cohort of a data.frame or tibble with 4
columns (OHDSI format):

-   COL 1 \[cohort\_definition\_id\]: is the identifier of the cohort.
    In our case, we just have one cohort, so all individuals will be
    identified with the same number (1).
-   COL 2 \[subject\_id\]: is the identifier of each individual. In our
    cohort we are going to use the given PERSON\_ID given by the
    database.
-   COL 3 \[cohort\_start\_date\]: is the start date of the cohort. In
    our case, the date of the condition occurrence.
-   COL 4 \[cohort\_end\_date\]: is the end date of the cohort. In our
    case, the end of the continuous observation.

### Tips

It is important to remember that:

1.  Year, month and day of birth are contained in PERSON\_ID table.
2.  To obtain the CONCEPT\_ID of a desired measurement / condition /
    observation / drug era … we can use CONCEPT table.
3.  Conditions occurrence can be found in CONDITION\_OCCURRENCE table.
4.  We use DRUG\_ERA table to find Exposures to drugs.
5.  Periods of observation are seen in OBSERVATION\_PERIOD table
6.  Measurements are found in MEASUREMENT table.
7.  To merge different tables we have the functions: inner\_join,
    full\_join, left\_join, right\_join …

If you don’t know to start follow the next steps:

1.  Use person table to compute the age of individuals (difftime is a
    common function to compute the difference between two dates).
    Important difftime dos not work in databse side.
2.  Select only the individuals who fulfill the age criteria.
3.  Use concept table to find the concept\_id for “Viral sinusitis”.
    ATLAS and ATHENA can also be used.
4.  Use condition\_occurrence table to find only the condition
    occurrences of “Viral sinusitis”.
5.  Filter this table to find the
6.  Use inner\_join to merge both tables and obtain only individuals
    that fulfill both conditions.
7.  If you arrived at this point you can continue alone…

### EXPECTED RESULT

The result for Eunomia database should be a total of 3 individuals and a
cohort like this:

<details>
<summary>
SOLUTION
</summary>

    ## # A tibble: 3 × 4
    ##   cohort_definition_id subject_id cohort_start_date cohort_end_date
    ##                  <dbl>      <dbl> <date>            <date>         
    ## 1                    1        160 2003-05-23        2019-04-11     
    ## 2                    1       3159 2002-07-04        2018-10-18     
    ## 3                    1       3841 2002-08-15        2018-09-26

</details>
