-- IPL Bidding
use ipl;

-- Write a query to calculate the percentage of wins for each bidder, ordered from highest to lowest win percentage.
select b.bidder_name,
(select count(bd.bid_status) from ipl_bidding_details bd where bd.bid_status = 'Won' and bd.bidder_id = b.bidder_id) as won,
(select bp.no_of_bids from ipl_bidder_points bp where bp.bidder_id = b.bidder_id) as total, 
(select count(bd.bid_status) from ipl_bidding_details bd where bd.bid_status = 'Won' and bd.bidder_id = b.bidder_id)/
(select bp.no_of_bids from ipl_bidder_points bp where bp.bidder_id = b.bidder_id) *100 as win_percentage from ipl_bidder_details b order by win_percentage desc;


-- Write a query to display the number of matches conducted at each stadium, along with the stadium name and city.

select stadium_name, city, 
(select count(ms.stadium_id) from ipl_match_schedule ms where ms.stadium_id = s.stadium_id) as no_of_matches from ipl_stadium s;
with cte1 as
(select stadium_id, count(stadium_id) as count from ipl_match_schedule group by stadium_id)
select s.stadium_name, s.city, cte1.count from ipl_stadium s left join cte1
on s.stadium_id = cte1.stadium_id;

-- Write a query to display the total number of bids as "total_bids" made by each team, along with the team name.
SELECT 
    t.team_id,
    t.team_name,
    (SELECT 
            COUNT(bddt.bid_team)
        FROM
            ipl_bidding_details bddt
        WHERE
            bddt.bid_team = t.team_id) AS total_bids
FROM
    ipl_team t;

-- Write a query to retrieve the team ID of the winning team based on the win details.
with cte1 as(select WIN_DETAILS, case substring_index(substring_index(win_details, " ",2)," ",-1)
WHEN 'CSK' THEN 'CSK'
WHEN 'RCB' THEN 'RCB'
WHEN 'DD' THEN 'DD'
WHEN 'RR' THEN 'RR'
WHEN 'KKR' THEN 'KKR'
WHEN 'SRH' THEN 'SRH'
WHEN 'MI' THEN 'MI'
WHEN 'KXIP' THEN 'KXIP' END AS CODE FROM IPL_MATCH)
SELECT T.TEAM_ID, T.TEAM_NAME, CTE1.WIN_DETAILS FROM IPL_TEAM T RIGHT JOIN CTE1 ON T.REMARKS = CTE1.CODE;

-- Write a query to display the total matches played as "total", total matches won "won", and total matches lost as "lost" by each team along with its team name.
WITH CTE1 AS 
	(SELECT TEAM_ID, SUM(TS.MATCHES_PLAYED) AS PLAY, SUM(TS.MATCHES_WON) Won, SUM(TS.MATCHES_LOST) Lost 
			FROM IPL_TEAM_STANDINGS TS 
            GROUP BY TEAM_ID) 
	SELECT T.TEAM_ID, T.TEAM_NAME, CTE1.PLAY, CTE1.W, CTE1.L 
			FROM IPL_TEAM T 
            LEFT JOIN CTE1 
            ON T.TEAM_ID = CTE1.TEAM_ID; 
            
-- Write a query to display the bowlers for the Mumbai Indians team. The bowlers are the players who have the role 'Bowler' in the team.
SELECT 
    TEAM_ID,
    PLAYER_ID,
    (SELECT 
            PERFORMANCE_DTLS
        FROM
            IPL_PLAYER IP
        WHERE
            IP.PLAYER_ID = TP.PLAYER_ID) AS `Performance Details`
FROM
    IPL_TEAM_PLAYERS TP
WHERE
    PLAYER_ROLE LIKE 'Bowler'
        AND REMARKS LIKE 'TEAM - MI';  
        
-- Display the teams with more than 4 all-rounders in descending order.
SELECT 
    (SELECT 
            REMARKS
        FROM
            IPL_TEAM I
        WHERE
            I.TEAM_ID = IP.TEAM_ID) AS REMARKS,
    COUNT(PLAYER_ROLE) AS total
FROM
    IPL_TEAM_PLAYERS IP
WHERE
    PLAYER_ROLE = 'All-Rounder'
GROUP BY TEAM_ID
HAVING TOTAL > 4
ORDER BY total DESC;
