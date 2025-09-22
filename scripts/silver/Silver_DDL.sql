/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'silver' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'staging' Tables
===============================================================================
*/

------------------------------------------------------------------------------
---------------------------CREATE silver.schedule-----------------------------
------------------------------------------------------------------------------
DROP TABLE IF EXISTS silver.schedule;
CREATE TABLE IF NOT EXISTS silver.schedule 
(                 
   gameid                   INT
  , global_gameid           INT
  , roundid                 INT
  , season                  INT
  , season_type             INT
  , venueid                 INT
  , venue_type              VARCHAR(50)  
  , game_datetime           TIMESTAMP
  , week                    INT
  , global_home_teamid      INT
  , home_teamid             INT
  , home_team_key           VARCHAR(50)
  , home_team_country_code  VARCHAR(50)
  , home_team_name          VARCHAR(50)
  , global_away_teamid      INT
  , away_teamid             INT
  , away_team_key           VARCHAR(50)
  , away_team_country_code  VARCHAR(50)
  , away_team_name          VARCHAR(50)
  , home_team_score         INT
  , away_team_score         INT  
  , winner                  VARCHAR(50)
  , status                  VARCHAR(50)
  , is_closed               BOOLEAN
  , updated_utc             TIMESTAMP
  , dwh_created_date        TIMESTAMPTZ DEFAULT NOW()
);
------------------------------------------------------------------------------
---------------------------CREATE silver.games--------------------------------
------------------------------------------------------------------------------
DROP TABLE IF EXISTS silver.games;
 CREATE TABLE IF NOT EXISTS silver.games 
(                 
    gameid                    INT
  , global_gameid             INT  
  , roundid                   INT
  , season                    INT
  , season_type               INT
  , venueid                   INT
  , attendance                INT
  , venue_type                VARCHAR(50)
  , period                    VARCHAR(50)
  , week                      INT
  , game_datetime             TIMESTAMP
  , status                    VARCHAR(255)
  , main_referee               INT  
  , assistant_referee_one         INT
  , assistant_referee_two         INT
  , fourth_referee             INT
  , video_assistant_referee     INT     
  , winner                    VARCHAR(255)
  , global_away_teamid      INT
  , away_teamid             INT
  , away_team_key           VARCHAR(50)
  , away_team_name          VARCHAR(255)  
  , away_team_country_code  VARCHAR(50)
  , away_team_formation     VARCHAR(50)
  , away_team_formation_tag VARCHAR(50)
  , away_team_coachid       INT  
  , away_team_score         INT
  , away_team_money_line      INT
  , global_home_teamid        INT
  , home_teamid               INT
  , home_team_key             VARCHAR(255)
  , home_team_name            VARCHAR(255)
  , home_team_country_code    VARCHAR(255)
  , home_team_formation       VARCHAR(255)
  , home_team_formation_tag   VARCHAR(255)
  , home_team_coachid           INT
  , home_team_score             INT
  , home_team_money_line        INT
  , draw_money_line             INT
  , point_spread               FLOAT
  , home_team_points_spread_payout INT
  , away_team_points_spread_payout INT
  , over_under                 FLOAT
  , over_payout                INT
  , under_payout               INT
  , is_closed                  BOOLEAN
  , updated_utc                TIMESTAMP
  , dwh_created_date TIMESTAMPTZ DEFAULT NOW()
);
------------------------------------------------------------------------------
---------------------------CREATE silver.referees-----------------------------
------------------------------------------------------------------------------
DROP TABLE IF EXISTS silver.referees;
 CREATE TABLE IF NOT EXISTS silver.referees 
(                 
    refereeid        INT
  , first_name       VARCHAR(50)
  , last_name        VARCHAR(50)
  , short_name       VARCHAR(50)
  , nationality      VARCHAR(50)
  , dwh_created_date TIMESTAMPTZ DEFAULT NOW()
);

------------------------------------------------------------------------------
---------------------------CREATE silver.coahes-------------------------------
------------------------------------------------------------------------------
DROP TABLE IF EXISTS silver.coaches;
 CREATE TABLE IF NOT EXISTS silver.coaches
(                 
    coachid       INT
  , first_name    VARCHAR(50)
  , last_name     VARCHAR(50)
  , short_name    VARCHAR(50)
  , nationality   VARCHAR(50)
);

------------------------------------------------------------------------------
---------------------------CREATE silver.goals-----------------------------
------------------------------------------------------------------------------
DROP TABLE IF EXISTS silver.goals;
 CREATE TABLE IF NOT EXISTS silver.goals 
(                 
    goalid                  INT
  , gameid                  INT
  , teamid                  INT
  , playerid                INT
  , player_name             VARCHAR(50)
  , goal_type               VARCHAR(50)
  , assisted_by_playerid    INT
  , assisted_by_player_name VARCHAR(50)
  , game_minute             INT
  , game_extra_minute       INT
);

------------------------------------------------------------------------------
---------------------------CREATE silver.lineups------------------------------
------------------------------------------------------------------------------
DROP TABLE IF EXISTS silver.lineups;
CREATE TABLE IF NOT EXISTS silver.lineups 
(                 
    lineupid                    INT
  , gameid                      INT
  , teamid                      INT  
  , lineup_type                 VARCHAR(50)
  , playerid                    INT
  , player_name                 VARCHAR(255)
  , pitch_position              VARCHAR(50)
  , pitch_position_horizontal   FLOAT
  , pitch_position_vertical     FLOAT
  , replaced_playerid           INT
  , replaced_player_name        VARCHAR(50)
  , replacement_game_minute       INT
  , replacement_game_minute_extra INT
  , dwh_created_date TIMESTAMPTZ DEFAULT NOW()
);

------------------------------------------------------------------------------
---------------------------CREATE silver.bookings-----------------------------
------------------------------------------------------------------------------
DROP TABLE IF EXISTS silver.bookings;
 CREATE TABLE IF NOT EXISTS silver.bookings
(                 
    gameid            INT
  , bookingid         INT
  , teamid            INT
  , playerid          INT
  , player_name                VARCHAR(50)
  , booking_type               VARCHAR(50)
  , booking_game_minute        INT
  , booking_game_extra_minute  INT
  , dwh_created_date           TIMESTAMPTZ DEFAULT NOW()
);

------------------------------------------------------------------------------
---------------------------CREATE silver.teamgames----------------------------
------------------------------------------------------------------------------
DROP TABLE IF EXISTS silver.teamgames;
CREATE TABLE IF NOT EXISTS silver.teamgames 
(
    statid                          INT
    , roundid                       INT
    , gameid                        INT
    , global_gameid                 INT
    , season                        INT
    , season_type                   INT
    , game_datetime                 TIMESTAMP
    , global_teamid                 INT
    , teamid                        INT
    , team_name                     VARCHAR(255)
    , possession                    FLOAT
    , global_opponentid             INT
    , opponentid                    INT    
    , opponent_name                 VARCHAR(255)
    , home_or_away                  VARCHAR(255)
    , is_game_over                  BOOLEAN
    , games                         INT
    , fantasy_points                FLOAT
    , fantasy_points_draft_kings    FLOAT
    , fantasy_points_mondo_goal     FLOAT
    , minutes                       FLOAT
    , goals                         FLOAT
    , assists                       FLOAT
    , shots                         FLOAT
    , shots_on_goal                 FLOAT
    , yellow_cards                  FLOAT
    , red_cards                     FLOAT
    , red_by_yellows_card           FLOAT
    , crosses                       FLOAT
    , tackles_won                   FLOAT
    , interceptions                 FLOAT
    , own_goals                     FLOAT
    , fouls                         FLOAT
    , fouled                        FLOAT
    , offsides                      FLOAT
    , passes                        FLOAT
    , passes_completed              FLOAT
    , last_man_tackle               FLOAT
    , corners_won                   FLOAT
    , blocked_shots                 FLOAT
    , touches                       FLOAT
    , defender_clean_sheets         FLOAT
    , goal_keeper_saves             FLOAT
    , goal_keeper_goals_against         FLOAT
    , goal_keeper_single_goal_against   FLOAT
    , goal_keeper_clean_sheets          FLOAT
    , goal_keeper_wins                  FLOAT
    , penalty_kick_goals                FLOAT
    , penalty_kick_misses               FLOAT
    , penalty_kick_saves                FLOAT
    , penalties_won                     FLOAT
    , penalties_conceded                FLOAT
    , score                             FLOAT
    , opponent_score                    FLOAT
    , tackles                           FLOAT
    , updated_utc                       TIMESTAMP
    , dwh_created_date                  TIMESTAMPTZ DEFAULT NOW()	
);

------------------------------------------------------------------------------
---------------------------CREATE silver.playerteams--------------------------
------------------------------------------------------------------------------
DROP TABLE IF EXISTS silver.playerteams;
 CREATE TABLE IF NOT EXISTS silver.playerteams 
( 
     statid                         INT
    , roundid                       INT
    , season                        INT
    , season_type                   INT
    , global_gameid                 INT
    , gameid                        INT
    , global_teamid                 INT
    , teamid                        INT
    , team_name                     VARCHAR(255)
    , home_or_away                  VARCHAR(255)
    , game_datetime                 TIMESTAMP
    , playerid                      INT
    , player_name                   VARCHAR(150)
    , player_short_name             VARCHAR(50)
    , player_position               VARCHAR(10)
    , jersey                        INT
    , started                       BOOLEAN
    , captain                       BOOLEAN
    , suspension                    BOOLEAN
    , suspension_reason             VARCHAR(255)
    , injury_start_date             TIMESTAMP
    , games                         INT
    , fantasy_points                FLOAT
    , fantasy_points_draft_kings    FLOAT
    , fantasy_points_mondo_goal     FLOAT
    , minutes                       FLOAT
    , goals                         FLOAT
    , assists                       FLOAT
    , shots                         FLOAT
    , shots_on_goal                 FLOAT
    , yellow_cards                  FLOAT
    , red_cards                     FLOAT
    , red_by_yellows_card           FLOAT
    , crosses                       FLOAT
    , tackles_won                   FLOAT
    , interceptions                 FLOAT
    , own_goals                     FLOAT
    , fouls                         FLOAT
    , fouled                        FLOAT
    , offsides                      FLOAT
    , passes                        FLOAT
    , passes_completed              FLOAT
    , last_man_tackle               FLOAT
    , corners_won                   FLOAT
    , blocked_shots                 FLOAT
    , touches                       FLOAT
    , defender_clean_sheets         FLOAT
    , goal_keeper_saves                FLOAT
    , goal_keeper_goals_against        FLOAT
    , goal_keeper_single_goal_against  FLOAT
    , goal_keeper_clean_sheets         FLOAT
    , goal_keeper_wins                 FLOAT
    , penalty_kick_goals               FLOAT
    , penalty_kick_misses              FLOAT
    , penalty_kick_saves               FLOAT
    , penalties_won                    FLOAT
    , penalties_conceded               FLOAT
    , tackles                          FLOAT
    , score                            FLOAT
    , opponent_score                   FLOAT
    , global_opponentid                INT
    , opponent_name                    VARCHAR(255)
    , is_game_over                     BOOLEAN
    , updated_utc                      TIMESTAMP
    , dwh_created_date                 TIMESTAMPTZ DEFAULT NOW()
);




