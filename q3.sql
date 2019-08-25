-- Participate

SET SEARCH_PATH TO parlgov;
drop table if exists q3 cascade;

-- You must not change this table definition.

create table q3(
        countryName varchar(50),
        year int,
        participationRatio real
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;
DROP VIEW IF EXISTS participationratio CASCADE;
DROP VIEW IF EXISTS avgpartratio CASCADE;
DROP VIEW IF EXISTS invalidcountries CASCADE;
DROP VIEW IF EXISTS validcountries CASCADE;
DROP VIEW IF EXISTS combinecountryname CASCADE;
-- Define views for your intermediate steps here.
CREATE VIEW participationratio AS
SELECT id as election_id, country_id, EXTRACT(year FROM e_date) AS year, CAST(votes_cast AS FLOAT) / electorate AS pRatio
FROM election
WHERE votes_cast > 0;

CREATE VIEW avgpartratio AS
SELECT country_id, year, AVG(pRatio) AS avgratio
FROM participationratio
WHERE year >= 2001 AND year <= 2016
GROUP BY country_id, year
HAVING AVG(pRatio) > 0;

CREATE VIEW invalidcountries AS
SELECT DISTINCT y1.country_id
FROM avgpartratio y1, avgpartratio y2
WHERE y1.country_id = y2.country_id AND y1.year < y2.year AND y1.avgratio > y2.avgratio;

CREATE VIEW validcountries AS
SELECT DISTINCT a.country_id, year, avgratio
FROM avgpartratio a
WHERE NOT EXISTS(
        SELECT i.country_id
        FROM invalidcountries i
        WHERE i.country_id = a.country_id);

CREATE VIEW combinecountryname AS
SELECT country.name AS countryName, year, avgratio
FROM country JOIN validcountries ON country.id = country_id;

-- the answer to the query
insert into q3

SELECT countryName, year, avgratio AS participationRatio
FROM combinecountryname;