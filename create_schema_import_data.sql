/*
    TechCrunch data import
    SQL DDL by Ryan B. Harvey (http://datascientist.guru)
    Created: 2014-12-01

    Data import script in PostgreSQL dialect for TechCrunch Continental USA dataset, found at:
    http://samplecsvs.s3.amazonaws.com/TechCrunchcontinentalUSA.csv

    This work was spurred by the manipulations described in this blog post at District Data Labs:
    http://districtdatalabs.silvrback.com/simple-csv-data-wrangling-with-python
 */

drop schema if exists techcrunch cascade;
create schema techcrunch;
grant all on schema techcrunch to ryan;

set search_path to techcrunch;

drop table if exists continental_usa_raw;
create temporary table continental_usa_raw (
  id bigserial primary key ,
  permalink text,
  company text,
  numEmps int,
  category text,
  city text,
  state char(2),
  fundedDate text,
  raisedAmt text,
  raisedCurrency char(3),
  round text
);

copy continental_usa_raw (
  permalink,
  company,
  numEmps,
  category,
  city,
  state,
  fundedDate,
  raisedAmt,
  raisedCurrency,
  round
)
from '/Users/ryan/Dropbox/code/SQL/techcrunch/TechCrunchcontinentalUSA.csv'
with csv header NULL as '';

drop table if exists continental_usa;
create table continental_usa as 
  select
    permalink,
    company,
    numEmps,
    category,
    city,
    state,
    to_date(fundedDate,'DD-Mon-YY') as fundedDate,
    cast(cast(raisedAmt as bigint) as money) as raisedAmt,
    raisedCurrency,
    round
  from continental_usa_raw
;
comment on table continental_usa
    is 'This import is data from TechCrunch extracted for the blog post at http://districtdatalabs.silvrback.com/simple-csv-data-wrangling-with-python.  The data file can be found at http://samplecsvs.s3.amazonaws.com/TechCrunchcontinentalUSA.csv.';

select * from continental_usa;

