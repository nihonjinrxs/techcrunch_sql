drop schema if exists techcrunch;
create schema techcrunch;
grant all on schema techcrunch to ryan;

use techcrunch;

drop table if exists continental_usa_raw;
create temporary table continental_usa_raw (
  id bigserial primary key,
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
create table continental_usa as (
  select
    permalink,
    company,
    numEmps,
    category,
    city,
    state,
    to_date(fundedDate,'DD-Mon-YY') as fundedDate,
    bigint(raisedAmt),
    raisedCurrency,
    round
  from continental_usa_raw
);
