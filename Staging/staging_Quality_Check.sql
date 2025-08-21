------------------------------------------------------------------------------
---------------------------QC staging.schedule--------------------------------
------------------------------------------------------------------------------
SELECT g.gameid, g.awayteamscore, s.awayteamscore, g.awayteamscoreperiod1, s.awayteamscoreperiod1, g.awayteamscoreperiod2, s.awayteamscoreperiod2, 
		g.hometeamscore, s.hometeamscore, g.hometeamscoreperiod1, s.hometeamscoreperiod1, g.hometeamscoreperiod2, s.hometeamscoreperiod2
FROM staging.games g
JOIN staging.schedule s ON g.gameid = s.gameid 
WHERE g.awayteamscore != s.awayteamscore OR g.awayteamscoreperiod1 != s.awayteamscoreperiod1 OR g.awayteamscoreperiod2 != s.awayteamscoreperiod2 OR 
		g.hometeamscore != s.hometeamscore OR g.hometeamscoreperiod1 != s.hometeamscoreperiod1 OR g.hometeamscoreperiod2 != s.hometeamscoreperiod2;

SELECT DISTINCT venuetype FROM staging.schedule; -- Only one value for all rows
SELECT DISTINCT awayteamkey FROM staging.schedule; -- 20, equal to the number of teams
SELECT DISTINCT hometeamkey FROM staging.schedule WHERE hometeamkey NOT IN(SELECT DISTINCT awayteamkey FROM staging.schedule); --no additional team keys
SELECT venueid, count(venueid) FROM staging.schedule GROUP BY venueid; --venues appear 19 times, equal to the games in each venue 
SELECT day FROM staging.schedule ORDER BY day;
SELECT day FROM staging.schedule WHERE day NOT IN (datetime::date);
SELECT DISTINCT status FROM staging.schedule; -- Only one value for all rows
SELECT DISTINCT week FROM staging.schedule ORDER BY week;
SELECT venueid, count(venueid) FROM staging.schedule GROUP BY venueid;
SELECT day FROM staging.schedule ORDER BY day;
SELECT day FROM staging.schedule WHERE day NOT IN (datetime::date);
SELECT DISTINCT status FROM staging.schedule;
SELECT DISTINCT week FROM staging.schedule ORDER BY week;
SELECT gameid, count(gameid) OVER(PARTITION BY gameid) FROM staging.games;
SELECT awayteamid, count(awayteamid) FROM staging.schedule WHERE awayteamid IN(SELECT DISTINCT hometeamid FROM staging.games)GROUP BY awayteamid;
------------------------------------------------------------------------------
---------------------------QC staging.games------------------------------------
------------------------------------------------------------------------------
SELECT SUBSTRING(globalgameid::TEXT,4) FROM staging.games WHERE SUBSTRING(globalgameid::TEXT,4) != gameid::TEXT;
SELECT DISTINCT roundid FROM staging.games;
SELECT DISTINCT season FROM staging.games;
SELECT DISTINCT seasontype FROM staging.games;
SELECT DISTINCT group_num FROM staging.games;
SELECT DISTINCT venueid FROM staging.games;
SELECT DISTINCT venuetype FROM staging.games;
SELECT DISTINCT period FROM staging.games;
SELECT COUNT(DISTINCT week) FROM staging.games;
SELECT DATE(day) FROM staging.games WHERE DATE(day) != datetime::DATE;
SELECT DISTINCT status FROM staging.games;

SELECT mainreferee FROM staging.games WHERE mainreferee NOT IN (SELECT DISTINCT refereeid FROM staging.referees);
SELECT assistantreferee1 FROM staging.games WHERE assistantreferee1 NOT IN (SELECT DISTINCT refereeid FROM staging.referees);
SELECT assistantreferee2 FROM staging.games WHERE assistantreferee2 NOT IN (SELECT DISTINCT refereeid FROM staging.referees);
SELECT fourthreferee FROM staging.games WHERE fourthreferee NOT IN (SELECT DISTINCT refereeid FROM staging.referees);
SELECT videoassistantreferee FROM staging.games WHERE videoassistantreferee NOT IN (SELECT DISTINCT refereeid FROM staging.referees);

SELECT globalawayteamid, awayteamid + 90000000 FROM staging.games WHERE globalawayteamid != awayteamid + 90000000;
SELECT COUNT(DISTINCT awayteamkey) FROM staging.games;
SELECT awayteamcoachid FROM staging.games WHERE awayteamcoachid NOT IN (SELECT DISTINCT coachid FROM staging.coaches);
SELECT DISTINCT awayteamscorepenalty FROM staging.games;
SELECT DISTINCT awayteamscoreextratime FROM staging.games;
SELECT DISTINCT awayteamcountrycode FROM staging.games;
SELECT awayteamname FROM staging.games WHERE awayteamname NOT IN(SELECT DISTINCT hometeamname FROM staging.games);


SELECT globalhometeamid, hometeamid + 90000000 FROM staging.games WHERE globalhometeamid != hometeamid + 90000000;
SELECT COUNT(DISTINCT hometeamkey) FROM staging.games;
SELECT hometeamkey FROM staging.games WHERE hometeamkey NOT IN(SELECT DISTINCT awayteamkey FROM staging.games);
SELECT hometeamcoachid FROM staging.games WHERE hometeamcoachid NOT IN (SELECT DISTINCT coachid FROM staging.coaches);
SELECT DISTINCT hometeamscorepenalty FROM staging.games;
SELECT DISTINCT hometeamscoreextratime FROM staging.games;
SELECT DISTINCT hometeamcountrycode FROM staging.games;

SELECT * FROM 
	(SELECT hometeamname, hometeamscore, (hometeamscoreperiod1 + hometeamscoreperiod2 + COALESCE(hometeamscoreextratime::text, '0')::int + COALESCE(hometeamscorepenalty::text, '0')::int) AS home_goals_sum,
			awayteamname, awayteamscore, (awayteamscoreperiod1 + awayteamscoreperiod2 + COALESCE(awayteamscoreextratime::text, '0')::int + COALESCE(awayteamscorepenalty::text, '0')::int) AS away_goals_sum FROM staging.games)
WHERE hometeamscore != home_goals_sum OR awayteamscore != away_goals_sum;
SELECT clockextra FROM staging.games WHERE clockextra IS NOT NULL;
SELECT clockdisplay FROM staging.games WHERE clockdisplay IS NOT NULL;
SELECT DISTINCT clock FROM staging.games;
SELECT DISTINCT playoffaggregatescore FROM staging.games;
SELECT DISTINCT isclosed FROM staging.games;
SELECT DATE(updated) FROM staging.games WHERE DATE(updated) != updatedutc::DATE;
SELECT DATE(updated) FROM staging.games WHERE EXTRACT(YEAR FROM updated) > 2025;
------------------------------------------------------------------------------
---------------------------QC staging.referees--------------------------------
------------------------------------------------------------------------------
SELECT DISTINCT refereeid FROM staging.referees;

------------------------------------------------------------------------------
---------------------------QC staging.coaches---------------------------------
------------------------------------------------------------------------------

SELECT DISTINCT coachid FROM staging.coaches;

------------------------------------------------------------------------------
---------------------------QC staging.goals-----------------------------------
------------------------------------------------------------------------------
SELECT teamid FROM staging.goals WHERE teamid NOT IN (SELECT DISTINCT hometeamid FROM staging.schedule);
SELECT playerid FROM staging.goals WHERE playerid NOT IN (SELECT DISTINCT playerid FROM staging.playerteams);
SELECT DISTINCT type FROM staging.goals;
SELECT playerid FROM staging.goals WHERE assistedbyplayerid1 NOT IN (SELECT DISTINCT playerid FROM staging.playerteams);
SELECT DISTINCT assistedbyplayername1 FROM staging.goals;
SELECT DISTINCT assistedbyplayerid2 FROM staging.goals;
SELECT DISTINCT assistedbyplayername2 FROM staging.goals;

------------------------------------------------------------------------------
---------------------------QC staging.lineups---------------------------------
------------------------------------------------------------------------------
SELECT * FROM (SELECT lineupid, ROW_NUMBER() OVER(PARTITION BY lineupid) AS rn FROM staging.lineups) WHERE rn != 1;

SELECT count(DISTINCT gameid) AS games FROM staging.games
UNION ALL
SELECT count(DISTINCT gameid) AS lineups FROM staging.lineups;

SELECT count(DISTINCT teamid) AS games FROM staging.teamgames
UNION ALL
SELECT count(DISTINCT teamid) AS lineups FROM staging.lineups;

SELECT * FROM staging.lineups WHERE playerid::INT NOT IN(SELECT DISTINCT playerid FROM staging.playerteams);
SELECT DISTINCT type FROM staging.lineups;
SELECT DISTINCT position FROM staging.lineups;
SELECT * FROM staging.lineups WHERE replacedplayerid NOT IN(SELECT DISTINCT playerid FROM staging.playerteams);
SELECT gameminute::int from staging.lineups WHERE gameminute::int > 90;

------------------------------------------------------------------------------
---------------------------QC staging.bookings--------------------------------
------------------------------------------------------------------------------

SELECT count(*) FROM staging.bookings;
SELECT DISTINCT bookingid FROM staging.bookings;
SELECT gameid FROM staging.bookings WHERE gameid NOT IN (SELECT gameid FROM staging.games);
SELECT DISTINCT type FROM staging.bookings;
SELECT teamid FROM staging.bookings WHERE teamid NOT IN (SELECT DISTINCT hometeamid FROM staging.schedule);
SELECT playerid::int FROM staging.bookings WHERE playerid::int NOT IN (SELECT DISTINCT playerid FROM staging.playerteams);
------------------------------------------------------------------------------
---------------------------QC staging.teamgames-------------------------------
------------------------------------------------------------------------------
SELECT * FROM (SELECT statid, ROW_NUMBER() OVER(PARTITION BY statid) AS rn FROM staging.teamgames) WHERE rn != 1;
SELECT DISTINCT roundid FROM staging.teamgames;
SELECT gameid FROM staging.teamgames WHERE gameid NOT IN(SELECT DISTINCT gameid FROM staging.games);
SELECT globalgameid FROM staging.teamgames WHERE globalgameid NOT IN(SELECT DISTINCT globalgameid FROM staging.games);
SELECT DISTINCT season FROM staging.teamgames;
SELECT DISTINCT seasontype FROM staging.teamgames;
SELECT t.gameid, t.datetime, s.datetime FROM staging.teamgames t
JOIN staging.schedule s ON t.gameid = s.gameid
WHERE t.datetime != s.datetime; 
SELECT globalteamid, teamid + 90000000 FROM staging.teamgames WHERE globalteamid != teamid + 90000000;
SELECT team, name FROM staging.teamgames WHERE team != name;

WITH teams AS (SELECT DISTINCT hometeamid AS teamid, hometeamname AS team FROM staging.schedule)
SELECT t.teamid, t.team, tg.team FROM staging.teamgames tg
JOIN teams t ON tg.teamid = t.teamid
WHERE tg.team != t.team;
SELECT teamid, COUNT(teamid) FROM staging.teamgames GROUP BY teamid, teamid HAVING COUNT(teamid) != 38;

SELECT DISTINCT opponent FROM staging.teamgames WHERE opponent NOT IN(SELECT DISTINCT name FROM staging.teamgames);
SELECT t1.statid, t1.team, t1.opponent,t2.team, t2.opponent FROM staging.teamgames t1 JOIN staging.teamgames t2 ON t1.team = t2.opponent WHERE  t1.gameid = t2.gameid AND t1.team != t2.opponent AND t2.team != t1.opponent;
SELECT DISTINCT LOWER(homeoraway) FROM staging.teamgames;
SELECT DISTINCT isgameover FROM staging.teamgames;
SELECT DISTINCT games FROM staging.teamgames;
SELECT DISTINCT fantasypointsfanduel FROM staging.teamgames;
SELECT DISTINCT fantasypointsyahoo FROM staging.teamgames;

------------------------------------------------------------------------------
---------------------------QC staging.playerteams-----------------------------
------------------------------------------------------------------------------
SELECT * FROM (SELECT statid, ROW_NUMBER() OVER (PARTITION BY statid) AS rn FROM staging.playerteams) WHERE rn != 1;
SELECT DISTINCT roundid FROM staging.playerteams;
SELECT DISTINCT season FROM staging.playerteams;
SELECT DISTINCT seasontype FROM staging.playerteams;
SELECT globalgameid FROM staging.playerteams WHERE globalgameid NOT IN (SELECT DISTINCT globalgameid FROM staging.games);
SELECT gameid FROM staging.playerteams WHERE gameid NOT IN (SELECT DISTINCT gameid FROM staging.games);
SELECT globalteamid FROM staging.playerteams WHERE globalteamid NOT IN (SELECT DISTINCT globalteamid FROM staging.teamgames);
SELECT teamid FROM staging.playerteams WHERE teamid NOT IN (SELECT DISTINCT teamid FROM staging.teamgames);
SELECT team FROM staging.playerteams WHERE team NOT IN (SELECT DISTINCT team FROM staging.teamgames);
SELECT DISTINCT homeoraway FROM staging.playerteams;
SELECT DATE_PART('year',datetime) FROM staging.teamgames WHERE DATE_PART('year',datetime) > 2025 OR DATE_PART('year',datetime) < 2024;
SELECT playerid FROM staging.playerteams WHERE playerid NOT IN (SELECT playerid::int FROM staging.lineups) AND minutes != 0;
SELECT LENGTH(playerid::TEXT) FROM staging.playerteams WHERE LENGTH(playerid::TEXT) != 8;
SELECT DISTINCT position FROM staging.playerteams;
SELECT position FROM staging.playerteams WHERE position !=positioncategory;
SELECT * FROM(SELECT teamid, gameid, playerid, jersey, ROW_NUMBER() OVER (PARTITION BY teamid, gameid, playerid, jersey) AS rn FROM staging.playerteams) WHERE rn != 1 AND jersey IS NOT NULL;
SELECT DISTINCT started FROM staging.playerteams;
SELECT DISTINCT captain FROM staging.playerteams;
SELECT DISTINCT suspension FROM staging.playerteams;
SELECT DISTINCT suspensionreason FROM staging.playerteams;
SELECT DISTINCT injurystartdate FROM staging.playerteams;
SELECT DISTINCT games FROM staging.playerteams;
SELECT distinct(fantasypointsfanduel) FROM  staging.playerteams; 
SELECT DISTINCT fanduelsalary FROM staging.playerteams;
SELECT DISTINCT draftkingssalary FROM staging.playerteams; 
SELECT DISTINCT yahoosalary FROM staging.playerteams;
SELECT DISTINCT mondogoalsalary FROM staging.playerteams; --only nulls
SELECT DISTINCT fanduelposition FROM staging.playerteams; --only scrambled
SELECT DISTINCT draftkingsposition FROM staging.playerteams; --only scrambled
SELECT DISTINCT yahooposition FROM staging.playerteams; --only scrambled
SELECT DISTINCT mondogoalposition FROM staging.playerteams; --only scrambled
SELECT DISTINCT injurystatus FROM staging.playerteams; --solo scrambled
SELECT DISTINCT injurybodypart FROM staging.playerteams; --solo scrambled
SELECT DISTINCT injurynotes FROM staging.playerteams; --solo scrambled
SELECT LENGTH(globalopponentid::TEXT) FROM staging.playerteams WHERE LENGTH(globalopponentid::TEXT) != 8;
SELECT globalopponentid FROM staging.playerteams WHERE globalopponentid NOT IN (SELECT DISTINCT globalteamid FROM staging.teamgames);
SELECT COUNT(DISTINCT opponent) FROM staging.playerteams;
SELECT DATE_PART('year',updatedutc) FROM staging.playerteams WHERE DATE_PART('year',updatedutc) > 2025 AND DATE_PART('year',updatedutc) < 2024;
