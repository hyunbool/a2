-- Left-right

SET SEARCH_PATH TO parlgov;
drop table if exists q4 cascade;

-- You must not change this table definition.


CREATE TABLE q4(
        countryName VARCHAR(50),
        r0_2 INT,
        r2_4 INT,
        r4_6 INT,
        r6_8 INT,
        r8_10 INT
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;
DROP VIEW IF EXISTS intermediate_step CASCADE;
DROP VIEW IF EXISTS partyleftright CASCADE;
DROP VIEW IF EXISTS countrypartyleftright CASCADE;
DROP VIEW IF EXISTS range0_2 CASCADE;
DROP VIEW IF EXISTS range2_4 CASCADE;
DROP VIEW IF EXISTS range4_6 CASCADE;
DROP VIEW IF EXISTS range6_8 CASCADE;
DROP VIEW IF EXISTS range8_10 CASCADE;
DROP VIEW IF EXISTS combineallrange CASCADE;
DROP VIEW IF EXISTS combinecountryname CASCADE;
-- Define views for your intermediate steps here.

CREATE VIEW partyleftright AS
SELECT party_id, left_right, country_id
FROM party p JOIN party_position pp ON p.id = pp.party_id;

CREATE VIEW range0_2 AS
SELECT country_id, count(*) AS r0_2
FROM partyleftright
WHERE left_right < 2
GROUP BY country_id;

CREATE VIEW range2_4 AS
SELECT country_id, count(*) AS r2_4
FROM partyleftright
WHERE left_right >= 2 AND left_right < 4
GROUP BY country_id;

CREATE VIEW range4_6 AS
SELECT country_id, count(*) AS r4_6
FROM partyleftright
WHERE left_right >= 4 AND left_right < 6
GROUP BY country_id;

CREATE VIEW range6_8 AS
SELECT country_id, count(*) AS r6_8
FROM partyleftright
WHERE left_right >= 6 AND left_right < 8
GROUP BY country_id;

CREATE VIEW range8_10 AS
SELECT country_id, count(*) AS r8_10
FROM partyleftright
WHERE left_right >= 8
GROUP BY country_id;

CREATE VIEW combineallrange AS
SELECT country_id, r0_2, r2_4, r4_6, r6_8, r8_10
FROM range0_2 NATURAL JOIN range2_4 NATURAL JOIN range4_6 NATURAL JOIN range6_8 NATURAL JOIN range8_10;

CREATE VIEW combinecountryname AS
SELECT name AS countryName, r0_2, r2_4, r4_6, r6_8, r8_10
FROM country JOIN combineallrange ON id = country_id;

-- the answer to the query
INSERT INTO q4
SELECT countryName, r0_2, r2_4, r4_6, r6_8, r8_10
FROM combinecountryname;