### 3298 unique user_ids
### 189 unique player names
### 'entry_data' table only contains data from September, 2020. Still used date functions to simulate proper use for an expanded dataset.


--- Q1: What is the total entry amount for all members who signed up in September 2020?
### Joined tables based on related column 'user_id', filtered for signups in September 2020.

SELECT SUM(entry_data.entry_amount) AS total_entry_amount
FROM `PrizePicks_DB.entry_data` AS entry_data
JOIN `PrizePicks_DB.signup_data` AS signup_data
  ON  entry_data.user_id = signup_data.user_id
WHERE DATE_TRUNC(signup_data.reg_date, month) = DATE '2020-09-01';


--- Q2: What is the average entry amount per member for each day of the week (Monday-Sunday) in the month of September
2020?
### Assumed it's asking for average entry per unique member.
### Used CTE to average entry amounts by user and FORMAT_DATE to extract day of week from entry_date field.
### Used main query to average entry amounts per day across all users.
### Used CASE statement in ORDER BY to sort days of the week in order.

WITH daily_user_avg AS(
  SELECT user_id,
    FORMAT_DATE('%A', entry_date) AS day_of_week,
    AVG(entry_amount) AS avg_entry_amount_per_user
  FROM `PrizePicks_DB.entry_data`
  WHERE DATE_TRUNC(entry_date, month) = DATE '2020-09-01'
  GROUP BY user_id, day_of_week
)

SELECT day_of_week,
  AVG(avg_entry_amount_per_user) AS avg_entry_amount_per_day
FROM daily_user_avg
GROUP BY day_of_week
ORDER BY   
  CASE 
    WHEN day_of_week = 'Monday' THEN 1
    WHEN day_of_week = 'Tuesday' THEN 2
    WHEN day_of_week = 'Wednesday' THEN 3
    WHEN day_of_week = 'Thursday' THEN 4
    WHEN day_of_week = 'Friday' THEN 5
    WHEN day_of_week = 'Saturday' THEN 6
    WHEN day_of_week = 'Sunday' THEN 7 END;

---Q3: Create an ordered list of the top 5 most popular players (by total entry amount) and their league in the month of September
2020
### Ordered total entry amount in descending order, limited results to only query top 5.

SELECT player,
  league
FROM `PrizePicks_DB.entry_data`
WHERE DATE_TRUNC(entry_date, month) = DATE '2020-09-01'
GROUP BY player, league
ORDER BY sum(entry_amount) DESC
LIMIT 5;


---Q4: Determine each user's contribution (by percentage) to the total entry amount for each player
---Note: The final output should include 3 columns: player_name, user_id, and share.
---Note: You do not need to format the final column with a percentage sign
### Used PARTITION BY window function to sum entry amounts by player across users.
### Divided total of each user's contribution to a player by total user contributions to a player to calculate share.

SELECT player AS player_name,
  user_id,
  ROUND((SUM(entry_amount) / SUM(entry_amount) OVER (PARTITION BY player)) * 100, 2) AS share
FROM `PrizePicks_DB.entry_data`
GROUP BY player, user_id
ORDER BY player_name, user_id;
