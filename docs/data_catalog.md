# Data Catalog for Gold Layer

## Overview
The Gold Layer is structured to support analytical and reporting use cases. It consists of **dimension tables** and **fact tables** for specific game metrics.

---

### 1. **gold.dim_bookings**

- **Purpose:** Stores booking data specific to each game.
- **Columns:**

| Column Name      | Data Type     | Description                                                                                   |
|------------------|---------------|-----------------------------------------------------------------------------------------------|
| booking_type     | VARCHAR           | The type of booking. Possible values: Yellow Card; Red Card; Yellow Red Card.               |
| bookingid        | INT           | The unique ID of the booking.                                       |
| game_minute           | INT  | The minute in the game in which the booking occurred.         |
| game_minute_extra     | INT  | The extra minute in the game in which the booking occurred.                                         |
| gameid                | INT  | The unique ID of the game.                                                     |
| playerid              | INT  | The player's unique PlayerID as assigned by SportsDataIO. Note: this ID stays with the player their entire career.                               |
| teamid   | INT  | The unique ID of the team.                              |


---

### 2. **gold.dim_coach**

- **Purpose:** Stores team coaches data.
- **Columns:**

| Column Name      | Data Type     | Description                                                                                   |
|------------------|---------------|-----------------------------------------------------------------------------------------------|
| coachid     | INT           | The unique ID of the coach.               |
| nationality        | VARCHAR           | Coach's nationality.                                       |
| short_name           | VARCHAR  | The short name of the coach.         |

---

### 3. **gold.dim_goals**

- **Purpose:** Provides information about the goals scored in each game.
- **Columns:**

| Column Name         | Data Type     | Description                                                                                   |
|---------------------|---------------|-----------------------------------------------------------------------------------------------|
| assisted_by_playerid         | INT           | Surrogate key uniquely identifying each product record in the product dimension table.         |
| gameid          | INT           | A unique identifier assigned to the product for internal tracking and referencing.            |
| game_minute      | INT  | A structured alphanumeric code representing the product, often used for categorization or inventory. |
| game_minute_extra        | INT  | Descriptive name of the product, including key details such as type, color, and size.         |
| goal_type         | VARCHAR  | A unique identifier for the product's category, linking to its high-level classification.     |
| goalid            | INT  | The broader classification of the product (e.g., Bikes, Components) to group related items.  |
| playerid         | INT  | A more detailed classification of the product within the category, such as product type.      |
| teamid| INT  | Indicates whether the product requires maintenance (e.g., 'Yes', 'No').                       |

---

### 4. **gold.dim_lineups**

- **Purpose:** Stores player data about their lineup in each game.
- **Columns:**

| Column Name     | Data Type     | Description                                                                                   |
|-----------------|---------------|-----------------------------------------------------------------------------------------------|
| captain    | BOOLEAN  | Whether the player is a captain (true/false).                      |
| gameid     | INT           | The unique ID of the game.                               |
| replacement_game_minute    | INT           | The minute of the game.                              |
| replacement_game_minute_extra      | INT          | The extra minute of the game.                                                           |
| home_or_away   | VARCHAR          | Whether the team is home or away.                                          |
| injury_start_date        | TIMESTAMP          | The date that the injury started or was first discovered.                                                      |
| jersey    | INT           | The player's jersey number.   |
| lineupid        | INT           | The unique ID of this lineup.                       |
| name           | VARCHAR           | The player's full name.      |
| pitch_position_horizontal | DOUBLE | The pitch position of where this player lined up on the field. Note: This is used for rendering an image of a soccer/football field with the players marked as such. This will be a number between 0 and 50. |
| pitch_position_vertical | DOUBLE | The pitch position of where this player lined up on the field. Note: This is used for rendering an image of a soccer/football field with the players marked as such. This will be a number between 0 and 50. |
| playerid | VARCHAR | The player's unique PlayerID as assigned by SportsDataIO. Note: this ID stays with the player their entire career |
| position | INT | The position of the player. Possible values include: Attacker; Midfielder; Defender; Goalkeeper. |
| replaced_playerid | INT | The unique ID of the replaced player |
| replaced_player_name | VARCHAR | The name of the replaced player |
| suspension | BOOLEAN | Whether the player is suspended or not (true/false) |
| suspension_reason | VARCHAR | The reason given for the player's suspension |
| teamid| INT | The unique ID of the team |
| lineup_type | VARCHAR | The player's status in the lineup. Possible values: Substitute In; Starter; Bench. |

---

### 5. **gold.dim_referee**

- **Purpose:** Stores identification data about the referees in the league.
- **Columns:**

| Column Name      | Data Type     | Description                                                                                   |
|------------------|---------------|-----------------------------------------------------------------------------------------------|
| nationality     | VARCHAR           | The nationality of the referee.               |
| refereeid        | INT           | The unique ID of the  referee.                                       |
| short_name           | VARCHAR  | The short name of the referee.         |

---

### 6. **gold.dim_schedule**

- **Purpose:** Stores game level data for context.
- **Columns:**

| Column Name     | Data Type     | Description                                                                                   |
|-----------------|---------------|-----------------------------------------------------------------------------------------------|
| assistant_referee_one | INT | The refereeid of the assistant referee one of the game. |
| assistant_referee_two | INT | The refereeid of the assistant referee two of the game. |
| attendance            | INT  | The attendance for the game.                           |
| away_team_coachid     | INT  | The couchid of the away team coach for this game.  | 
| away_team_country_code | VARCHAR | The country code of the away team. |
| away_team_key         | VARCHAR | The abbreviation [Key] of the away team. |
| away_team_name        | VARCHAR | The name of the away team. |
| away_teamid           | INT | The unique ID of the away team. |
| fourth_referee        | INT | The refereeid of the fourth referee of the game. |
| game_datetime         | DATETIME     | The date and time of the game.                              |
| gameid                | INT   | The unique ID of the game.     
| home_team_couachid    | INT | The couchid of the home team coach for this game.  |
| home_team_country_code   | VARCHAR     | The country code of the home team.                                                           |
| home_team_key        | VARCHAR          | The abbreviation [Key] of the home team.       |
| home_team_name    | VARCHAR           | The name of the home team.   |
| home_teamid        | INT           | The unique ID of the home team.                       |
| main_referee           | INT           | The refereeid of the main referee of the game.      |
| period | VARCHAR | The final period of the game. Possible values: Regular = Game ended in 90 minutes of regular time; ExtraTime = Game ended in extra time / overtime; PenaltyShootout = Game finished in penalty shootout time. |
| roundid | INT | The unique ID of the round that this team is associated with. |
| season | INT | The soccer regular season for which these totals apply. |
| season_type | INT | The type of season that this record corresponds to (1=Regular Season; 2=Preseason; 3=Postseason; 4=Offseason; 5=AllStar). |
| venue_type | VARCHAR | Shows which team has home field advantage. Possible values: Home; Away; Neutral |
| venueid | INT | The unique ID of the venue |
| video_assistant_referee | INT | The refereeid of the video assistant referee two of the game |
| week | INT | The week during the season/round in which this game occurs |

---

### 7. **gold.fact_games**

- **Purpose:** Stores game level data for analytical purposes.
- **Columns:**

| Column Name     | Data Type     | Description                                                                                   |
|-----------------|---------------|-----------------------------------------------------------------------------------------------|
| away_team_money_line | INT | The sportsbook's money line for the away team |
| away_team_formation | VARCHAR | The formation for the away team (4-4-2; 4-3-3; etc.) |
| away_team_formation_tag | VARCHAR | The formation description, a tag to describe some formations |
| away_teamid | INT | The unique ID of the away team |
| away_team_point_spread_payout | INT | Payout if the away team covers the spread |
| away_team_score | INT | The final score of the away team |
| draw_money_line | INT | The sportsbook's money line for a draw |
| gameid | INT | The unique ID of the game |
| home_money_line | INT | The sportsbook's moneyline for the home team |
| home_team_formation | VARCHAR | The formation for the home team (4-4-2; 4-3-3; etc.) |
| home_team_formation_tag | VARCHAR | The formation description, a tag to describe some formations |
| home_teamid | INT | The unique ID of the home team |
| home_team_point_spread_payout | INT | Payout if the home team covers the spread |
| home_team_score | INT | The final score of the home team |
| over_payout | INT | The sportsbook's payout for the over bet on the total goals line |
| over_under | DOUBLE | The sportsbook's total goals line (over/under) for the game |
| point_spread | DOUBLE | Point spread for the home team |
| under_payout | INT | The sportsbook's payout for the under |
| winner | VARCHAR | The winner of the game. Possible values: AwayTeam; HomeTeam; Draw |

---

### 8. **gold.fact_playerteams**

- **Purpose:** Stores player performance data for analytical purposes.
- **Columns:**

| Column Name     | Data Type     | Description                                                                                   |
|-----------------|---------------|-----------------------------------------------------------------------------------------------|
| assists | DOUBLE | Total assists scored |
| blocked_shots | DOUBLE | Total shots blocked |
| corners_won | DOUBLE | Total corner kicks awarded |
| crosses | DOUBLE | Total passes from a wide area of the field towards the center of the field near the opponent's goal |
| defender_clean_sheets | DOUBLE | Total defender clean sheets (awarded when zero goals were allowed to the opponent and the player played at least 60 minutes) |
| fantasy_points | DOUBLE | Total fantasy points |
| fantasy_points_draft_kings | DOUBLE | Total Draft Kings daily fantasy points scored |
| fantasy_points_mondo_goal | DOUBLE | Total Mondogoal fantasy points scored |
| fouled | DOUBLE | Total times fouled |
| fouls | DOUBLE | Total fouls made |
| gameid | INT | The unique ID of the game |
| games | INT | The number of games played |
| goal_keeper_clean_sheets | DOUBLE | Total goalkeeper clean sheets (awarded when zero goals were allowed to the opponent and the player played at least 60 minutes) |
| goal_keeper_goals_against | DOUBLE | Total goals allowed by goalkeeper |
| goal_keeper_saves | DOUBLE | Total saves made by goalkeeper |
| goal_keeper_single_goal_against | DOUBLE | Total games where this goalkeeper allowed exactly one goal |
| goal_keeper_wins | DOUBLE | Total goalkeeper wins (awarded when zero goals were allowed to the opponent and the player played at least 45 minutes) |
| goals | DOUBLE | Total goals scored |
| interceptions | DOUBLE | Total interceptions made |
| last_man_tackle | DOUBLE | Total tackles made when there is no one else available to stop the opponent from scoring (this can be the goalkeeper) |
| minutes | DOUBLE | Total minutes played |
| offsides | DOUBLE | Total offsides against |
| opponent_score | DOUBLE | Goals allowed to opponent |
| own_goals | DOUBLE | Total goals scored against own team (accidentally) |
| passes | DOUBLE | Total passes attempted |
| passes_completed | DOUBLE | Total passes completed successfully to teammate |
| penalties_conceded | DOUBLE | Total penalties conceded |
| penalties_won | DOUBLE | Total penalties won |
| penalty_kick_goals | DOUBLE | Total penalty kick goals |
| penalty_kick_misses | DOUBLE | Total penalty kick misses |
| penalty_kick_saves | DOUBLE | Total penalty kick saves |
| playerid | DOUBLE | The player's unique PlayerID as assigned by SportsDataIO. Note: this ID stays with the player their entire career |
| red_cards | DOUBLE | Total red cards against |
| score | DOUBLE | Goals scored by entire team |
| shots | DOUBLE | Total shots attempted |
| shots_on_goal | DOUBLE | Total shots on goal attempted |
| statid | DOUBLE | The unique ID of the stat associated with this player |
| tackles | DOUBLE | Total Tackles |
| tackles_won | DOUBLE | Total tackles won |
| teamid | DOUBLE | The unique ID of the team |
| touches | DOUBLE | Total times this player touched the ball |
| yellow_cards | DOUBLE | Total yellow cards against |
| red_by_yellow_cards | DOUBLE | Total double yellow cards against (which result in a red card) |

---

### 9. **gold.fact_teamgames**

- **Purpose:** Stores team performance data for analytical purposes.
- **Columns:**

| Column Name     | Data Type     | Description                                                                                   |
|-----------------|---------------|-----------------------------------------------------------------------------------------------|
| assists | DOUBLE | Total assists scored |
| blocked_shots | DOUBLE | Total shots blocked |
| corners_won | DOUBLE | Total corner kicks awarded |
| crosses | DOUBLE | Total passes from a wide area of the field towards the center of the field near the opponent's goal |
| defender_clean_sheets | DOUBLE | Total defender clean sheets (awarded when zero goals were allowed to the opponent and the player played at least 60 minutes) |
| fantasy_points | DOUBLE | Total fantasy points |
| fantasy_points_draft_kings | DOUBLE | Total Draft Kings daily fantasy points scored |
| fantasy_points_mondo_goal | DOUBLE | Total Mondogoal fantasy points scored |
| fouled | DOUBLE | Total times fouled |
| fouls | DOUBLE | Total fouls made |
| gameid | INT | The unique ID of the game |
| goal_keeper_clean_sheets | DOUBLE | Total goalkeeper clean sheets (awarded when zero goals were allowed to the opponent and the player played at least 60 minutes) |
| goal_keeper_goals_against | DOUBLE | Total goals allowed by goalkeeper |
| goal_keeper_saves | DOUBLE | Total saves made by goalkeeper |
| goal_keeper_single_goal_against | DOUBLE | Total games where this goalkeeper allowed exactly one goal |
| goal_keeper_wins | DOUBLE | Total goalkeeper wins (awarded when zero goals were allowed to the opponent and the player played at least 45 minutes) |
| goals | DOUBLE | Total goals scored |
| home_or_away | VARCHAR | Whether the team is home or away |
| interceptions | DOUBLE | Total interceptions made |
| last_man_tackle | DOUBLE | Total tackles made when there is no one else available to stop the opponent from scoring (this can be the goalkeeper) |
| minutes | DOUBLE | Total minutes played |
| offsides | DOUBLE | Total offsides against |
| opponent_score | DOUBLE | Goals allowed to opponent |
| own_goals | DOUBLE | Total goals scored against own team (accidentally) |
| passes | DOUBLE | Total passes attempted |
| passes_completed | DOUBLE | Total passes completed successfully to teammate |
| penalties_conceded | DOUBLE | Total penalties conceded |
| penalties_won | DOUBLE | Total penalties won |
| penalty_kick_goals | DOUBLE | Total penalty kick goals |
| penalty_kick_misses | DOUBLE | Total penalty kick misses |
| penalty_kick_saves | DOUBLE | Total penalty kick saves |
| possession | DOUBLE | Percentage of ball possession by the team in the game |
| red_cards | DOUBLE | Total red cards against |
| score | DOUBLE | Goals scored by entire team |
| shots | DOUBLE | Total shots attempted |
| shots_on_goal | DOUBLE | Total shots on goal attempted |
| tackles | DOUBLE | Total Tackles |
| tackles_won | DOUBLE | Total tackles won |
| teamid | INT | The unique ID of the team |
| tg_statid | INT | The unique ID of the stat associated with this player |
| touches | DOUBLE | Total times this player touched the ball |
| yellow_cards | DOUBLE | Total yellow cards against |
| red_by_yellow_cards | DOUBLE | Total double yellow cards against (which result in a red card) |

---
