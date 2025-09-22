/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/


------------------------------------------------------------------------------
---------------------------CREATE gold.fact_games-----------------------------
------------------------------------------------------------------------------


DROP VIEW IF EXISTS gold.fact_games;
CREATE OR REPLACE VIEW gold.fact_games AS
SELECT  g.gameid
	  , g.home_teamid
	  , g.home_team_score
	  , g.home_team_formation
	  , g.home_team_formation_tag
	  , g.away_teamid
	  , g.away_team_score
	  , g.away_team_formation
	  , g.away_team_formation_tag
	  , s.winner
	  , g.away_team_money_line
	  , g.home_team_money_line
	  , g.draw_money_line
	  , g.point_spread
	  , g.home_team_points_spread_payout 
	  , g.away_team_points_spread_payout
	  , g.over_under
	  , g.over_payout 
	  , g.under_payout
FROM silver.schedule s 
JOIN silver.games g ON s.gameid = g.gameid;


------------------------------------------------------------------------------
---------------------------CREATE gold.fact_playerteams-----------------------
------------------------------------------------------------------------------

DROP VIEW IF EXISTS gold.fact_playerteams;
CREATE OR REPLACE VIEW gold.fact_playerteams AS
SELECT    pt.statid
	    , pt.gameid
	    , pt.teamid
	    , pt.playerid
	    , pt.games
	    , pt.fantasy_points
	    , pt.fantasy_points_draft_kings
	    , pt.fantasy_points_mondo_goal
	    , pt.minutes
	    , pt.goals
	    , pt.assists
	    , pt.shots
	    , pt.shots_on_goal
	    , pt.yellow_cards
	    , pt.red_cards
	    , pt.red_by_yellows_card
	    , pt.crosses
	    , pt.tackles_won
	    , pt.interceptions
	    , pt.own_goals
	    , pt.fouls
	    , pt.fouled
	    , pt.offsides
	    , pt.passes
	    , pt.passes_completed
	    , pt.last_man_tackle
	    , pt.corners_won
	    , pt.blocked_shots
	    , pt.touches
	    , pt.defender_clean_sheets
	    , pt.goal_keeper_saves
	    , pt.goal_keeper_goals_against
	    , pt.goal_keeper_single_goal_against
	    , pt.goal_keeper_clean_sheets
	    , pt.goal_keeper_wins
	    , pt.penalty_kick_goals
	    , pt.penalty_kick_misses
	    , pt.penalty_kick_saves
	    , pt.penalties_won
	    , pt.penalties_conceded
	    , pt.tackles
	    , pt.score
	    , pt.opponent_score
FROM silver.playerteams pt
JOIN silver.lineups l ON pt.gameid = l.gameid AND pt.playerid = l.playerid;

------------------------------------------------------------------------------
---------------------------CREATE gold.fact_teamgames-------------------------
------------------------------------------------------------------------------

DROP VIEW IF EXISTS gold.fact_teamgames;
CREATE OR REPLACE VIEW gold.fact_teamgames AS
SELECT
		  ROW_NUMBER() OVER() AS tg_statid
	    , t.gameid
	    , t.teamid
		, t.home_or_away
	    , t.possession
	    , t.opponentid 
	    , t.fantasy_points
	    , t.fantasy_points_draft_kings
	    , t.fantasy_points_mondo_goal
	    , t.minutes
	    , t.goals
	    , t.assists
	    , t.shots
	    , t.shots_on_goal
	    , t.yellow_cards
	    , t.red_cards
	    , t.red_by_yellows_card
	    , t.crosses
	    , t.tackles_won
	    , t.interceptions
		, own_goals
	    , t.fouls
	    , t.fouled
	    , t.offsides
	    , t.passes
	    , t.passes_completed
	    , t.last_man_tackle
	    , t.corners_won
	    , t.blocked_shots
	    , t.touches
	    , t.defender_clean_sheets
	    , t.goal_keeper_saves
	    , t.goal_keeper_goals_against
	    , t.goal_keeper_single_goal_against
	    , t.goal_keeper_clean_sheets
	    , t.goal_keeper_wins
	    , t.penalty_kick_goals
	    , t.penalty_kick_misses
	    , t.penalty_kick_saves
	    , t.penalties_won
	    , t.penalties_conceded
	    , t.score
	    , t.opponent_score
	    , t.tackles
FROM silver.teamgames t
JOIN silver.games g ON t.gameid = g.gameid;


------------------------------------------------------------------------------
---------------------------CREATE gold.dim_schedules--------------------------
------------------------------------------------------------------------------

DROP VIEW IF EXISTS gold.dim_schedule;
CREATE OR REPLACE VIEW gold.dim_schedule AS
SELECT 
		s.gameid
	  , s.roundid
	  , s.season                 
	  , s.season_type   
	  , s.venueid
	  , s.venue_type
	  , g.attendance
	  , s.game_datetime
	  , s.week
	  , g.period 
 	  , s.home_teamid
	  , s.home_team_country_code  
	  , s.home_team_key           
	  , s.home_team_name
	  , g.home_team_coachid	  
	  , s.away_teamid  
	  , s.away_team_country_code
	  , s.away_team_key
	  , s.away_team_name
	  , g.away_team_coachid
	  , g.main_referee
	  , g.assistant_referee_one
	  , g.assistant_referee_two
	  , g.fourth_referee
	  , g.video_assistant_referee
FROM silver.schedule s 
JOIN silver.games g ON s.gameid = g.gameid;

------------------------------------------------------------------------------
---------------------------CREATE gold.dim_lineups----------------------------
------------------------------------------------------------------------------

DROP VIEW IF EXISTS gold.dim_lineups;
CREATE OR REPLACE VIEW gold.dim_lineups AS
SELECT 
		l.lineupid       
	  , l.gameid  
	  , l.teamid  
	  , l.playerid
	  , pt.home_or_away	  
	  , l.lineup_type    
	  , l.player_name  
	  , pt.jersey
	  , pt.captain
	  , l.pitch_position 
	  , l.pitch_position_horizontal 
	  , l.pitch_position_vertical
	  , l.replaced_playerid 
	  , l.replaced_player_name 
	  , l.replacement_game_minute 
	  , l.replacement_game_minute_extra
	  , pt.suspension
	  , pt.suspension_reason
	  , pt.injury_start_date
FROM silver.lineups l
JOIN silver.playerteams pt ON l.gameid = pt.gameid AND l.playerid = pt.playerid;

------------------------------------------------------------------------------
---------------------------CREATE gold.dim_booking----------------------------
------------------------------------------------------------------------------

DROP VIEW IF EXISTS gold.dim_bookings;
CREATE OR REPLACE VIEW gold.dim_bookings AS
SELECT 
		bookingid
	  , gameid
	  , teamid
	  , playerid
	  , booking_type
	  , booking_game_minute
	  , booking_game_extra_minute
FROM silver.bookings;

------------------------------------------------------------------------------
---------------------------CREATE gold.dim_coaches----------------------------
------------------------------------------------------------------------------

DROP VIEW IF EXISTS gold.dim_coaches;
CREATE OR REPLACE VIEW gold.dim_coaches AS
SELECT 
	    coachid      
	  , short_name
	  , nationality
FROM silver.coaches;

------------------------------------------------------------------------------
---------------------------CREATE gold.dim_referees---------------------------
------------------------------------------------------------------------------

DROP VIEW IF EXISTS gold.dim_referees;
CREATE OR REPLACE VIEW gold.dim_referees AS
SELECT 
	    refereeid
	  , short_name
	  , nationality
FROM silver.referees;

------------------------------------------------------------------------------
---------------------------CREATE gold.dim_goals------------------------------
------------------------------------------------------------------------------

DROP VIEW IF EXISTS gold.dim_goals;
CREATE OR REPLACE VIEW gold.dim_goals AS
SELECT
	    goalid 
	  , gameid
	  , teamid
	  , playerid
	  , goal_type 
	  , assisted_by_playerid
	  , game_minute
	  , game_extra_minute
FROM silver.goals;


