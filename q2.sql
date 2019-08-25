-- Winners

SET SEARCH_PATH TO parlgov;
drop table if exists q2 cascade;

-- You must not change this table definition.

create table q2(
countryName VARCHaR(100),
partyName VARCHaR(100),
partyFamily VARCHaR(100),
wonElections INT,
mostRecentlyWonElectionId INT,
mostRecentlyWonElectionYear INT
);


-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;
DROP VIEW IF EXISTS combinecountryname CASCADE;
DROP VIEW IF EXISTS combinepartyname CASCADE;
DROP VIEW IF EXISTS combinepartyfamily CASCADE;
DROP VIEW IF EXISTS wholetable CASCADE;
DROP VIEW IF EXISTS winnervotes CASCADE;
DROP VIEW IF EXISTS wonparty CASCADE;
DROP VIEW IF EXISTS countwoneachparty CASCADE;
DROP VIEW IF EXISTS countwoneachcountry CASCADE;
DROP VIEW IF EXISTS countparties CASCADE;
DROP VIEW IF EXISTS countavg CASCADE;
DROP VIEW IF EXISTS recentwonyear CASCADE;
DROP VIEW IF EXISTS recentwoneid CASCADE;
-- Define views for your intermediate steps here.

CREATE VIEW wholetable AS
SELECT election_id, country_id, EXTRACT(year FROM e_date) AS year, party_id, votes
FROM election JOIN election_result ON election.id = election_id;

CREATE VIEW winnervotes AS
SELECT election_id, MAX(votes) as maxVotes
FROM wholetable
GROUP BY election_id;

CREATE VIEW wonparty AS
SELECT wholetable.election_id, country_id, party_id
FROM winnervotes JOIN wholetable ON winnervotes.election_id = wholetable.election_id
WHERE maxVotes = votes
ORDER BY winnervotes.election_id;

CREATE VIEW countwoneachparty AS
SELECT country_id, party_id, count(*) as wonElections
FROM wonparty
GROUP BY country_id, party_id
ORDER BY country_id;

CREATE VIEW countwoneachcountry AS
SELECT country_id, SUM(wonElections) AS wonByCountry
FROM countwoneachparty
GROUP BY country_id;

CREATE VIEW countparties AS
SELECT country_id, count(party.id) AS numOfParties
FROM party
GROUP BY country_id;

CREATE VIEW countavg AS
SELECT cc.country_id, CAST(wonByCountry AS FLOAT) / numOfParties AS avgWonElections
FROM countwoneachcountry cc JOIN countparties cp ON cc.country_id = cp.country_id;

CREATE VIEW thricemorewon AS
SELECT c.country_id, c.party_id, wonElections
FROM countwoneachparty c NATURAL JOIN countavg
WHERE wonElections > (3 * avgWonElections);

CREATE VIEW recentwonyear AS
SELECT t.country_id, t.party_id, wonElections, MAX(year) as year
FROM thricemorewon t NATURAL JOIN wholetable w
GROUP BY country_id, party_id, wonElections;

CREATE VIEW recentwoneid AS
SELECT t.country_id, t.party_id, wonElections, year, election_id
FROM recentwonyear t NATURAL JOIN wholetable w;

CREATE VIEW combinecountryname AS
SELECT name AS countryName, party_id, wonElections, year, election_id
FROM country JOIN recentwoneid ON country.id = country_id;

CREATE VIEW combinepartyname AS
SELECT party.name AS partyName, countryName, wonElections, year, election_id, id
FROM party JOIN combinecountryname ON party.id = combinecountryname.party_id;

CREATE VIEW combinepartyfamily AS
SELECT partyName, countryName, wonElections, year, election_id, party_family.family AS partyFamily
FROM party_family RIGHT JOIN combinepartyname ON party_id = id;

-- the answer to the query
insert into q2

SELECT countryName, partyName, partyFamily, wonElections, election_id AS mostRecentlyWonElectionId, year AS mostRecentlyWonElectionYear
FROM combinepartyfamily;