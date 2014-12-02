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

drop table if exists continental_usa cascade;
create table continental_usa (
  id bigserial primary key ,
  permalink text,
  company text,
  numEmps int,
  category text,
  city text,
  state char(2),
  fundedDate date,
  raisedAmt bigint,
  raisedCurrency char(3),
  round text
);
insert into continental_usa (
  permalink, company, numEmps, category, city, state, fundedDate, raisedAmt, raisedCurrency, round
)
select
  permalink, company, numEmps, category, city, state,
  to_date(fundedDate,'DD-Mon-YY') as fundedDate,
  cast(raisedAmt as bigint) as raisedAmt,
  raisedCurrency, round
from continental_usa_raw
;
comment on table continental_usa
    is 'This import is data from TechCrunch extracted for the blog post at http://districtdatalabs.silvrback.com/simple-csv-data-wrangling-with-python.  The data file can be found at http://samplecsvs.s3.amazonaws.com/TechCrunchcontinentalUSA.csv.';

select * from continental_usa;

/* Create indices */
create index idx_company on continental_usa (company);
create index idx_category on continental_usa (category);
create index idx_round on continental_usa (round);
create index idx_raisedAmt on continental_usa (raisedAmt);
create index idx_state on continental_usa (state);
vacuum analyze;

/* Create view to capture aggregated data by company */
drop view if exists continental_usa_companies;
create view continental_usa_companies as
  select
    company,
    count(*) as numFundingRecords,
    count(distinct round) as numFundingRounds,
    sum(raisedAmt) as totalRaised,
    max(numEmps) as maxEmployees
  from continental_usa
  group by company
;

select * from continental_usa_companies;

/* Create view to capture aggregated data by category */
drop view if exists continental_usa_categories;
create view continental_usa_categories as
  select
    category,
    count(*) as numFundingRecords,
    count(distinct round) as numFundingRounds,
    sum(raisedAmt) as totalRaised
  from continental_usa
  group by category
;

select * from continental_usa_categories;

/* Create function to get funding records for a specific company */
drop function if exists continental_usa_funding_records_for(text);
create function continental_usa_funding_records_for (in param_company text) 
returns table (
  id bigint,
  permalink text,
  company text,
  numEmps int,
  category text,
  city text,
  state char(2),
  fundedDate date,
  raisedAmt bigint,
  raisedCurrency char(3),
  round text
)
as $body$
  select 
    id,
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
  from continental_usa
  where company = param_company
  order by fundedDate
$body$ language sql;

select * from continental_usa_funding_records_for('Facebook');

