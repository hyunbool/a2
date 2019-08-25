-- VoteRange

SET SEARCH_PATH TO parlgov;
drop table if exists q1 cascade;

-- You must not change this table definition.

create table q1(
year INT,
countryName VARCHAR(50),
voteRange VARCHAR(20),
partyName VARCHAR(100)
);


-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;
DROP VIEW IF EXISTS combinecountryName CASCADE;
DROP VIEW IF EXISTS combinepartyName CASCADE;
DROP VIEW IF EXISTS wholetable CASCADE;
DROP VIEW IF EXISTS calpercentage CASCADE;
DROP VIEW IF EXISTS avgpercentage CASCADE;
DROP VIEW IF EXISTS percentagernge CASCADE;

-- Define views for your intermediate steps here.
CREATE VIEW combinecountryName AS
SELECT election.id AS election_id, name AS countryName, EXTRACT(year FROM e_date) AS year, votes_valid
FROM election, country
WHERE country_id = country.id;

CREATE VIEW combinepartyName AS
SELECT election_id, name_short AS partyName, votes
FROM election_result, party
WHERE party_id = party.id;

CREATE VIEW wholetable AS
SELECT combinecountryName.election_id,  countryName, year, votes_valid, partyName, votes
FROM combinecountryName, combinepartyName
WHERE combinecountryName.election_id = combinepartyName.election_id;

CREATE VIEW calpercentage AS
SELECT election_id, countryName, year, partyName, CAST(SUM(votes) AS FLOAT) / CAST(SUM(votes_valid) AS FLOAT) AS percentage
FROM wholetable
GROUP BY election_id, year, countryName, partyName;

CREATE VIEW avgpercentage AS
SELECT countryName, year, partyName, AVG(percentage) AS percentage_avg
FROM calpercentage
GROUP BY election_id, year, countryName, partyName
HAVING AVG(percentage) > 0;

CREATE VIEW percentagerange AS
SELECT countryName, year, partyName,
        (Case
        WHEN (percentage_avg <= 0.05) THEN '(0-5]'
        WHEN (percentage_avg > 0.05 AND percentage_avg <= 0.10) THEN '(5-10]'
        WHEN (percentage_avg > 0.10 AND percentage_avg <= 0.20) THEN '(10-20]'
        WHEN (percentage_avg > 0.20 AND percentage_avg <= 0.30) THEN '(20-30]'
        WHEN (percentage_avg > 0.30 AND percentage_avg <= 0.40) THEN '(30-40]'
        WHEN (percentage_avg > 0.40) THEN '(40-100]'
        END) AS voteRange
FROM avgpercentage;

-- the answer to the query
insert into q1

SELECT year, countryName, voteRange, partyName
FROM percentagerange
WHERE year >= 1996 and year <= 2016;

