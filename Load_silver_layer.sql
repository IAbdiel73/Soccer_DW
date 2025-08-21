CREATE OR REPLACE PROCEDURE load_silver()
LANGUAGE plpgsql
AS $$
DECLARE
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    batch_start_time TIMESTAMP;
    batch_end_time TIMESTAMP;
    error_message TEXT;
    error_sqlstate TEXT;
    error_context TEXT;
    error_detail TEXT;
BEGIN
    batch_start_time := NOW();
	RAISE INFO 'Loading Silver Layer';

	RAISE INFO 'Loading schedule Table';
	start_time := NOW();
	RAISE INFO '>> Truncating Table: silver.schedule';
	TRUNCATE TABLE silver.schedule;
	RAISE INFO '>> Inserting Data Into: silver.schedule';
	INSERT INTO silver.schedule 
	(
		gameid                   
	  , global_gameid          
	  , roundid                 
	  , season                 
	  , season_type             
	  , venueid                 
	  , venue_type                
	  , game_datetime           
	  , week                    
	  , global_home_teamid     
	  , home_teamid            
	  , home_team_key           
	  , home_team_country_code  
	  , home_team_name         
	  , global_away_teamid      
	  , away_teamid      
	  , away_team_key
	  , away_team_country_code
	  , away_team_name
	  , home_team_score
	  , away_team_score 
	  , winner
	  , status
	  , is_closed
	  , updated_utc
	)
	WITH match_result AS (
	WITH Goals_in_match AS 
	(
	SELECT g.goalid,g.name, g.gameid, ga.awayteamid, ga.hometeamid, g.teamid, g.type, 
		CASE 
			WHEN g.type = 'OwnGoal' THEN 
				CASE
					WHEN g.teamid = ga.awayteamid THEN ga.hometeamid
					WHEN g.teamid = ga.hometeamid THEN ga.awayteamid
				END 
			ELSE g.teamid	
		END AS goal_to_team		
	FROM staging.goals g
	JOIN staging.playerteams p ON g.name = p.name
	JOIN staging.games ga ON g.gameid = ga.gameid
	GROUP BY g.goalid, g.name, g.gameid, g.teamid, ga.awayteamid, ga.hometeamid, g.type
	)
	SELECT gameid, teamid, COUNT(goal_to_team) AS Goals FROM Goals_in_match GROUP BY gameid, teamid ORDER BY gameid ASC
	)
	SELECT 	g.gameid, 
			g.globalgameid AS global_gameid, 
			g.roundid, 
			g.season, 
			g.seasontype AS season_type, 
			g.venueid, 
			g.venuetype AS venue_type, 
			g.datetime AS game_datetime, 
			g.week, 
			g.globalhometeamid AS global_home_teamid, 
			g.hometeamid AS home_teamid, 
			g.hometeamkey AS home_team_key, 
			g.hometeamcountrycode AS home_team_country_code, 
			g.hometeamname AS home_team_name, 
			g.globalawayteamid AS global_away_teamid, 
			g.awayteamid AS away_teamid, 
			g.awayteamkey AS away_team_key, 
			g.awayteamcountrycode AS away_team_country_code, 
			g.awayteamname AS away_team_name,  
			COALESCE(mr.goals, 0) AS home_team_score , COALESCE(m.goals, 0) AS away_team_score, 
			CASE 
				WHEN COALESCE(m.goals, 0) > COALESCE(mr.goals, 0) THEN awayteamname 
	     		WHEN COALESCE(mr.goals, 0) > COALESCE(m.goals, 0) THEN hometeamname
			 	ELSE 'Draw' 
			END AS winner,
			g.status, 
			g.isclosed AS is_closed, 
			g.updatedutc AS updated_utc 
	FROM staging.games g
	LEFT JOIN match_result m ON g.awayteamid = m.teamid AND g.gameid = m.gameid
	LEFT JOIN match_result mr ON g.hometeamid = mr.teamid AND g.gameid = mr.gameid;	
	end_time := NOW();
	RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (end_time - start_time));

	--Loading silver.games
	RAISE INFO 'Loading games Table';
	start_time := NOW();
	RAISE INFO '>> Truncating Table: silver.games';
	TRUNCATE TABLE silver.games;
	RAISE INFO '>> Inserting Data Into: silver.games';
	INSERT INTO silver.games
	(
	    gameid  
	  , global_gameid
	  , roundid
	  , season
	  , season_type
	  , venueid
	  , attendance
	  , venue_type
	  , period 
	  , week
	  , game_datetime
	  , status
	  , main_referee
	  , assistant_referee_one
	  , assistant_referee_two
	  , fourth_referee
	  , video_assistant_referee
	  , winner
	  , global_away_teamid
	  , away_teamid
	  , away_team_key
	  , away_team_name
	  , away_team_country_code
	  , away_team_formation
	  , away_team_formation_tag
	  , away_team_coachid
	  , away_team_score
	  , away_team_money_line
	  , global_home_teamid
	  , home_teamid
	  , home_team_key
	  , home_team_name
	  , home_team_country_code
	  , home_team_formation
	  , home_team_formation_tag
	  , home_team_coachid
	  , home_team_score
	  , home_team_money_line
	  , draw_money_line
	  , point_spread
	  , home_team_points_spread_payout 
	  , away_team_points_spread_payout
	  , over_under
	  , over_payout 
	  , under_payout
	  , is_closed 
	  , updated_utc 
	)
	SELECT gameid, 
			globalgameid AS global_gameid, 
			roundid, 
			season, 
			seasontype AS season_type,  
			venueid, 
			attendance, 
			venuetype AS venue_type, 
			period, 
			week, 
			datetime AS game_datetime, 
			status,
			mainreferee AS main_referee, 
			assistantreferee1 AS assistant_referee_one, 
			assistantreferee2 AS assistant_referee_two, 
			fourthreferee AS fourth_referee, 
			videoassistantreferee AS video_assistant_referee,
			CASE 
				WHEN awayteamscore > hometeamscore THEN awayteamname 
	     		WHEN hometeamscore > awayteamscore THEN hometeamname
		 		ELSE 'Draw' 
			END AS winner,
			globalawayteamid AS global_away_teamid, 
			awayteamid AS away_teamid, 
			awayteamkey AS away_team_key, 
			awayteamname AS away_team_name, 
			awayteamcountrycode AS away_team_country_code, 
			string_to_array(regexp_replace(awayteamformation, '[^0-9\-]', '', 'g'), '-') AS away_team_formation,
	  		trim(both '-' from regexp_replace(awayteamformation, '^[0-9\- ]+', '', 'g')) AS away_team_formation_tag,
			awayteamcoachid AS away_team_coachid, 
			awayteamscore AS away_team_score, 
			awayteammoneyline AS away_team_money_line,
			globalhometeamid AS global_home_teamid, 
			hometeamid AS home_teamid, 
			hometeamkey AS home_team_key, 
			hometeamname AS home_team_name, 
			hometeamcountrycode AS home_team_country_code, 
			string_to_array(regexp_replace(hometeamformation, '[^0-9\-]', '', 'g'), '-') AS home_team_formation,
	  		trim(both '-' from regexp_replace(hometeamformation, '^[0-9\- ]+', '', 'g')) AS home_team_formation_tag,
			hometeamcoachid AS home_team_coachid, 
			hometeamscore AS home_team_score, 
			hometeammoneyline AS home_team_money_line,
			drawmoneyline AS draw_money_line, 
			pointspread AS points_spread, 
			hometeampointspreadpayout AS home_team_points_spread_payout,
			awayteampointspreadpayout AS away_team_points_spread_payout, 
			overunder AS over_under,
			overpayout AS over_payout, 
			underpayout AS under_payout,   
			isclosed AS is_closed, 
			updatedutc AS updated_utc
	FROM staging.games;
	UPDATE silver.games
	SET away_team_score = schedule.away_team_score,
	    home_team_score = schedule.home_team_score
	FROM silver.schedule
	WHERE games.gameid = schedule.gameid;
	end_time := NOW();
	RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (end_time - start_time));
	
	--Loading silver.referees
	RAISE INFO 'Loading referees Table';
	start_time := NOW();
	RAISE INFO '>> Truncating Table: silver.referees';
	TRUNCATE TABLE silver.referees;
	RAISE INFO '>> Inserting Data Into: silver.referees';
	INSERT INTO silver.referees
	(
	    refereeid
	  , first_name
	  , last_name
	  , short_name
	  , nationality
	)
	SELECT refereeid, 
			firstname AS first_name, 
			lastname AS last_name, 
			shortname AS short_name, 
			nationality 
	FROM (SELECT * , ROW_NUMBER() OVER(PARTITION BY refereeid ORDER BY refereeid) AS rn FROM staging.referees) 
	WHERE rn=1;
	end_time :=  NOW();
	RAISE INFO '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (end_time - start_time));
	
	--Loading silver.coaches
	RAISE INFO 'Loading games Table';
	start_time := NOW();
	RAISE INFO '>> Truncating Table: silver.coaches';
	TRUNCATE TABLE silver.coaches;
	RAISE INFO '>> Inserting Data Into: silver.coaches';
	INSERT INTO silver.coaches
	(                 
	    coachid      
	  , first_name 
	  , last_name
	  , short_name
	  , nationality
	)
	SELECT coachid, 
			firstname AS first_name, 
			lastname AS last_name, 
			shortname AS short_name, 
			nationality 
	FROM (SELECT * , ROW_NUMBER() OVER(PARTITION BY coachid ORDER BY coachid) AS rn FROM staging.coaches) 
	WHERE rn=1;
	end_time := NOW();
	RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (end_time - start_time));

	--Loading silver.goals
	RAISE INFO 'Loading games Table';
	start_time := NOW();
	RAISE INFO '>> Truncating Table: silver.goals';
	TRUNCATE TABLE silver.goals;
	RAISE INFO '>> Inserting Data Into: silver.goals';
	INSERT INTO silver.goals 
	(                 
	    goalid 
	  , gameid
	  , teamid
	  , playerid
	  , player_name
	  , goal_type 
	  , assisted_by_playerid
	  , assisted_by_player_name
	  , game_minute
	  , game_extra_minute
	)
	WITH players AS (
	  SELECT *
	  FROM (
	    SELECT playerid, name,
	           ROW_NUMBER() OVER (PARTITION BY playerid ORDER BY playerid) AS rn
	    FROM staging.playerteams
	  ) sub
	  WHERE rn = 1
	)
	SELECT 
	  g.goalid,
	  g.gameid,
	  g.teamid,
	  g.playerid,
	  g.name AS player_name,
	  g.type AS goal_type,
	  g.assistedbyplayerid1 AS assisted_by_playerid,
	  p.name AS assisted_by_player_name,
	  g.gameminute AS game_minute,
	  g.gameminuteextra AS extra_game_minute
	FROM staging.goals g
	JOIN players p ON g.assistedbyplayerid1 = p.playerid;
	end_time := NOW();
	RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (end_time - start_time));

	--Loading silver.bookings
	RAISE INFO 'Loading bookings Table';
	start_time := NOW();
	RAISE INFO '>> Truncating Table: silver.bookings';
	TRUNCATE TABLE silver.bookings;
	RAISE INFO '>> Inserting Data Into: silver.bookings';
	INSERT INTO silver.bookings
	(
	    gameid
	  , bookingid
	  , teamid
	  , playerid
	  , player_name
	  , booking_type
	  , booking_game_minute
	  , booking_game_extra_minute
	)
	SELECT gameid, 
			bookingid, 
			teamid, 
			playerid, 
			name AS player_name, 
			type AS booking_type, 
			gameminute AS booking_game_minute, 
			gameminuteextra::int AS booking_game_extra_minute 
	FROM staging.bookings;
	end_time := NOW();
	RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (end_time - start_time));

	--Loading silver.teamgames
	RAISE INFO 'Loading teamgames Table';
	start_time := NOW();
	RAISE INFO '>> Truncating Table: silver.teamgames';
	TRUNCATE TABLE silver.teamgames;
	RAISE INFO '>> Inserting Data Into: silver.teamgames';
	INSERT INTO silver.teamgames
	(
		statid 
	    , roundid
	    , gameid
	    , global_gameid
	    , season
	    , season_type
	    , game_datetime
	    , global_teamid
	    , teamid
	    , team_name
	    , possession
	    , global_opponentid
	    , opponentid
	    , opponent_name
	    , home_or_away
	    , is_game_over
	    , games
	    , fantasy_points
	    , fantasy_points_draft_kings
	    , fantasy_points_mondo_goal
	    , minutes
	    , goals
	    , assists
	    , shots
	    , shots_on_goal
	    , yellow_cards
	    , red_cards
	    , red_by_yellows_card
	    , crosses
	    , tackles_won
	    , interceptions
	    , own_goals
	    , fouls
	    , fouled
	    , offsides
	    , passes
	    , passes_completed
	    , last_man_tackle
	    , corners_won
	    , blocked_shots
	    , touches
	    , defender_clean_sheets
	    , goal_keeper_saves
	    , goal_keeper_goals_against
	    , goal_keeper_single_goal_against
	    , goal_keeper_clean_sheets
	    , goal_keeper_wins
	    , penalty_kick_goals
	    , penalty_kick_misses
	    , penalty_kick_saves
	    , penalties_won
	    , penalties_conceded
	    , score
	    , opponent_score
	    , tackles
	    , updated_utc      
	)
	WITH possessions AS 
	(
		WITH games_possession AS (
	  	SELECT gameid, SUM(possession) AS possession_total
	  	FROM staging.teamgames
	  	GROUP BY gameid
		),
		team_possession_with_extremes AS (
	  	SELECT 
	   	 	t.gameid,
	    	t.teamid,
	    	t.possession,
	    	gp.possession_total,
	    	MIN(t.possession) OVER (PARTITION BY t.gameid) AS min_possession,
	    	100 - MIN(t.possession) OVER (PARTITION BY t.gameid) AS max_possession
	  	FROM staging.teamgames t
	  	JOIN games_possession gp ON t.gameid = gp.gameid
		)
		SELECT gameid, teamid,
	  		CASE
	    		WHEN possession_total = 100 THEN possession
	    		WHEN possession = min_possession THEN min_possession
	    	ELSE max_possession
	  	END AS adjusted_possession
		FROM team_possession_with_extremes
	)
	SELECT tg.statid, 
			tg.roundid, 
			tg.gameid, 
			tg.globalgameid AS global_gameid, 
			tg.season, 
			tg.seasontype AS season_type, 
			tg.datetime AS game_datetime, 
			tg.globalteamid AS global_teamid, 
			tg.teamid, 
			tg.team AS team_name,  
			p.adjusted_possession AS possession,
			tg.globalopponentid AS global_opponentid, 
			tg.opponentid,
			tg.opponent AS opponent_name, 
			LOWER(tg.homeoraway) AS home_or_away, 
			tg.isgameover AS is_game_over, 
			tg.games,
			tg.fantasypoints AS fantasy_points, 
			tg.fantasypointsdraftkings AS fantasy_points_draft_kings, 
			tg.fantasypointsmondogoal AS fantasy_points_mondo_goal,
			tg.minutes, 
			tg.goals, 
			tg.assists, 
			tg.shots, 
			tg.shotsongoal AS shots_on_goal, 
			tg.yellowcards AS yellow_cards, 
			tg.redcards AS red_cards, 
			tg.yellowredcards AS red_by_yellows_card, 
			tg.crosses, 
			tg.tackleswon AS tackles_won,
			tg.interceptions, 
			tg.owngoals AS own_goals, 
			tg.fouls, 
			tg.fouled,
			tg.offsides, 
			tg.passes, 
			tg.passescompleted AS passes_completed,
			tg.lastmantackle AS last_man_tackle,
			tg.cornerswon AS corners_won,
			tg.blockedshots AS blocked_shots,
			tg.touches, 
			tg.defendercleansheets AS defender_clean_sheets,
			tg.goalkeepersaves AS goal_keeper_saves,
			tg.goalkeepergoalsagainst AS goal_keeper_goals_against, 
			tg.goalkeepersinglegoalagainst AS goal_keeper_single_goal_against, 
			tg.goalkeepercleansheets AS goal_keeper_clean_sheets,
			tg.goalkeeperwins AS goal_keeper_wins, 
			tg.penaltykickgoals AS penalty_kick_goals, 
			tg.penaltykickmisses AS penalty_kick_misses, 
			tg.penaltykicksaves AS penalty_kick_saves, 
			tg.penaltieswon AS penalties_won,
			tg.penaltiesconceded AS penalties_conceded, 
			tg.score, 
			tg.opponentscore AS opponent_score, 
			tg.tackles, 
			tg.updatedutc AS updated_utc 
	FROM staging.teamgames tg 
	JOIN possessions p ON tg.gameid = p.gameid AND tg.teamid = p.teamid;
	end_time := NOW();
	RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (end_time - start_time));

	--Loading silver.playerteams
	RAISE INFO 'Loading player Table';
	start_time := NOW();
	RAISE INFO '>> Truncating Table: silver.playerteams';
	TRUNCATE TABLE silver.playerteams;
	RAISE INFO '>> Inserting Data Into: silver.playerteams';
	INSERT INTO silver.playerteams
	(
	     statid
	    , roundid
	    , season
	    , season_type
	    , global_gameid
	    , gameid
	    , global_teamid
	    , teamid
	    , team_name
	    , home_or_away
	    , game_datetime
	    , playerid
	    , player_name
	    , player_short_name
	    , player_position
	    , jersey
	    , started
	    , captain
	    , suspension
	    , suspension_reason
	    , injury_start_date
	    , games
	    , fantasy_points
	    , fantasy_points_draft_kings
	    , fantasy_points_mondo_goal
	    , minutes
	    , goals
	    , assists
	    , shots
	    , shots_on_goal
	    , yellow_cards
	    , red_cards
	    , red_by_yellows_card
	    , crosses
	    , tackles_won
	    , interceptions
	    , own_goals
	    , fouls
	    , fouled
	    , offsides
	    , passes
	    , passes_completed
	    , last_man_tackle
	    , corners_won
	    , blocked_shots
	    , touches
	    , defender_clean_sheets
	    , goal_keeper_saves
	    , goal_keeper_goals_against
	    , goal_keeper_single_goal_against
	    , goal_keeper_clean_sheets
	    , goal_keeper_wins
	    , penalty_kick_goals
	    , penalty_kick_misses
	    , penalty_kick_saves
	    , penalties_won
	    , penalties_conceded
	    , tackles
	    , score
	    , opponent_score
	    , global_opponentid
	    , opponent_name
	    , is_game_over
	    , updated_utc
	)
	SELECT statid, 
		   roundid, 
		   season, 
		   seasontype AS season_type, 
		   globalgameid AS global_gameid, 
		   gameid, 
		   globalteamid AS global_teamid, 
		   teamid, 
		   team AS team_name, 
		   lower(homeoraway) AS home_or_away, 
		   datetime AS game_datetime,  
		   playerid, 
		   name AS player_name, 
		   shortname AS player_short_name,  
		   CASE 
		   		WHEN position = 'D' THEN 'Defense'
				WHEN position = 'A' THEN 'Attack'
				WHEN position = 'M' THEN 'Midfield'
				WHEN position = 'GK' THEN 'Goal Keep'
				ELSE 'N/A'
		   END AS player_position,
		   jersey, 
		   started, 
		   captain, 
		   suspension, 
		   suspensionreason AS suspension_reason, 
		   injurystartdate::date AS injury_start_date, 
		   games, 
		   fantasypoints AS fantasy_points,  
		   fantasypointsdraftkings AS fantasy_points_draft_kings, 
		   fantasypointsmondogoal AS fantasy_points_mondo_goal, 
		   minutes, 
		   goals, 
		   assists, 
		   shots, 
		   shotsongoal AS shots_on_goal, 
		   yellowcards AS yellow_cards, 
		   redcards AS red_cards,
		   yellowredcards AS red_by_yellows_card,
		   crosses, 
		   tackleswon AS tackles_won, 
		   interceptions, 
		   owngoals AS own_goals, 
		   fouls, 
		   fouled, 
		   offsides, 
		   passes, 
		   passescompleted AS passes_completed, 
		   lastmantackle AS last_man_tackle, 
		   cornerswon AS corners_won, 
		   blockedshots AS blocked_shots, 
		   touches,
		   defendercleansheets AS defender_clean_sheets, 
		   goalkeepersaves AS goal_keeper_saves, 
		   goalkeepergoalsagainst AS goal_keeper_goals_against, 
		   goalkeepersinglegoalagainst AS goal_keeper_single_goal_against, 
		   goalkeepercleansheets AS goal_keeper_clean_sheets, 
		   goalkeeperwins AS goal_keeper_wins, 
		   penaltykickgoals AS penalty_kick_goals, 
		   penaltykickmisses AS penalty_kick_misses, 
		   penaltykicksaves AS penalty_kick_saves, 
		   penaltieswon AS penalties_won, 
		   penaltiesconceded AS penalties_conceded, 
		   tackles,
		   score,
		   opponentscore AS opponent_score, 
		   globalopponentid AS global_opponentid, 
		   opponent AS opponent_name, 
		   isgameover AS is_game_over, 
		   updatedutc AS updated_utc 
	FROM staging.playerteams;
	end_time := NOW();
	RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (end_time - start_time));

	batch_end_time := NOW();
	RAISE NOTICE 'Loading Silver Layer is Completed';
	RAISE NOTICE 'Total Load Duration: % seconds', EXTRACT(EPOCH FROM (batch_end_time - batch_start_time));

	--Loading silver.lineups
	RAISE INFO 'Loading lineups Table';
	start_time := NOW();
	RAISE INFO '>> Truncating Table: silver.lineups';
	TRUNCATE TABLE silver.lineups;
	RAISE INFO '>> Inserting Data Into: silver.lineups';
	INSERT INTO silver.lineups
	(                 
		lineupid       
	  , gameid  
	  , teamid  
	  , playerid  
	  , lineup_type    
	  , player_name  
	  , pitch_position 
	  , pitch_position_horizontal 
	  , pitch_position_vertical
	  , replaced_playerid 
	  , replaced_player_name 
	  , replacement_game_minute 
	  , replacement_game_minute_extra 
	)
	SELECT lineupid, 
		   gameid, 
		   teamid, 
		   playerid::int,
		   type AS lineup_type, 
		   name AS player_name, 
		   CASE 
				WHEN position = 'D' THEN 'Defense'
				WHEN position = 'A' THEN 'Attack'
				WHEN position = 'M' THEN 'Midfield'
				WHEN position = 'GK' THEN 'Goal Keep'
				ELSE 'N/A'
			END AS pitch_position,
			pitchpositionhorizontal AS pitch_position_horizontal, 
			pitchpositionvertical AS pitch_position_vertical, 
			replacedplayerid AS replaced_playerid, 
			replacedplayername AS replaced_player_name, 
			gameminute::INT AS replacement_game_minute, 
			gameminuteextra AS replacement_game_extra_minute
	FROM staging.lineups;

	end_time := NOW();
	RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (end_time - start_time));

EXCEPTION 
    WHEN others THEN
        GET STACKED DIAGNOSTICS
            error_message = MESSAGE_TEXT,
            error_sqlstate = RETURNED_SQLSTATE,
            error_context = PG_EXCEPTION_CONTEXT,
            error_detail = PG_EXCEPTION_DETAIL;
            
        RAISE NOTICE 'Error Message: %', error_message;
        RAISE NOTICE 'Error Code: %', error_sqlstate;
        RAISE NOTICE 'Error Context: %', error_context;
        RAISE NOTICE 'Error Detail: %', error_detail;
END;
$$;