create database tournament
use tournament

CREATE TABLE Teams (
    team_id INT AUTO_INCREMENT PRIMARY KEY,
    team_name VARCHAR(100) NOT NULL
);
INSERT INTO Teams (team_id,team_name) VALUES (1,'India'), (2,'England'), (3,'Australia'),(4,'West Indians');
CREATE TABLE Players (
    player_id INT AUTO_INCREMENT PRIMARY KEY,
    player_name VARCHAR(100),
    team_id INT,
    FOREIGN KEY (team_id) REFERENCES Teams(team_id)
);
INSERT INTO Players (player_name, team_id) VALUES
('Virat Kohli', 1),
('Rohit Sharma', 1),
('Jasprit Bumrah',1),
('MS Dhoni',1);
INSERT INTO Players (player_name, team_id) VALUES
('Joe Root', 2),
('Ben Stokes', 2),
('Dawid Malan',2),
('Jofra Archer',2);
INSERT INTO Players (player_name, team_id) VALUES
('David Warner', 3),
('Pat Cummins', 3),
('Travis Head',3),
('Alex Carey',3);
INSERT INTO Players (player_name, team_id) VALUES
('Chris Gayle', 4),
('Andre Russell', 4),
('Jason Holder', 4),
('Sunil Narine', 4);
CREATE TABLE Matches (
    match_id INT AUTO_INCREMENT PRIMARY KEY,
    match_date DATE,
    team1_id INT,
    team2_id INT,
    winner_team_id INT,
    FOREIGN KEY (team1_id) REFERENCES Teams(team_id),
    FOREIGN KEY (team2_id) REFERENCES Teams(team_id),
    FOREIGN KEY (winner_team_id) REFERENCES Teams(team_id)
);
INSERT INTO Matches (match_date, team1_id, team2_id, winner_team_id) VALUES ('2025-10-01', 1, 2, 1),('2023-08-12',3,4,4),('2024-09-14',2,4,4),('2022-11-08',2,3,2);

CREATE TABLE Stats (
    stat_id INT AUTO_INCREMENT PRIMARY KEY,
    match_id INT,
    player_id INT,
    runs_scored INT,
    wickets_taken INT,
    FOREIGN KEY (match_id) REFERENCES Matches(match_id),
    FOREIGN KEY (player_id) REFERENCES Players(player_id)
);
INSERT INTO Stats (stat_id,match_id, player_id, runs_scored, wickets_taken) VALUES
(101,1, 1, 45, 0),  
(102,1, 2, 10, 3),  
(103,1, 4, 5, 2);
INSERT INTO Stats (stat_id,match_id, player_id, runs_scored, wickets_taken) VALUES
(104,3,6,35,1);
INSERT INTO Stats (stat_id,match_id, player_id, runs_scored, wickets_taken) VALUES
(105, 3, 1, 0, 0),
(106, 4, 5, 1, 1),
(107, 5, 6, 1, 0);
set sql_safe_updates=0
select * from Teams;
select * from Players;
select * from Matches;
select * from Stats;
-- Match Results
SELECT 
    m.match_id,
    m.match_date,
    t1.team_name AS team1,
    t2.team_name AS team2,
    tw.team_name AS winner
FROM Matches m
JOIN Teams t1 ON m.team1_id = t1.team_id
JOIN Teams t2 ON m.team2_id = t2.team_id
JOIN Teams tw ON m.winner_team_id = tw.team_id;



SELECT 
    p.player_name,
    t.team_name,
    SUM(s.runs_scored) AS total_runs_scored,
    SUM(s.wickets_taken) AS total_wickets_taken
FROM Stats s
JOIN Players p ON s.player_id = p.player_id
JOIN Teams t ON p.team_id = t.team_id
GROUP BY p.player_name, t.team_name
ORDER BY total_runs_scored DESC;
drop table Stats
drop table Matches
drop table Players
drop table Teams
-- Sports Tournament Tracker (MySQL)
-- Deliverables: Schema, sample data, queries, leaderboards, summary views, CTEs, export examples

-- =========================
-- 1) SCHEMA: Teams, Players, Matches, Stats
-- =========================
DROP TABLE IF EXISTS Stats;
DROP TABLE IF EXISTS Matches;
DROP TABLE IF EXISTS Players;
DROP TABLE IF EXISTS Teams;

CREATE TABLE Teams (
    team_id INT AUTO_INCREMENT PRIMARY KEY,
    team_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ;

CREATE TABLE Players (
    player_id INT AUTO_INCREMENT PRIMARY KEY,
    player_name VARCHAR(100) NOT NULL,
    team_id INT NOT NULL,
    role VARCHAR(50) DEFAULT NULL, -- e.g., Batsman, Bowler, Allrounder
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (team_id) REFERENCES Teams(team_id) ON DELETE CASCADE
);

CREATE TABLE Matches (
    match_id INT AUTO_INCREMENT PRIMARY KEY,
    match_date DATE NOT NULL,
    venue VARCHAR(150) DEFAULT NULL,
    team1_id INT NOT NULL,
    team2_id INT NOT NULL,
    winner_team_id INT DEFAULT NULL,
    match_type VARCHAR(50) DEFAULT 'ODI', -- e.g., ODI/T20/Test
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (team1_id) REFERENCES Teams(team_id) ON DELETE RESTRICT,
    FOREIGN KEY (team2_id) REFERENCES Teams(team_id) ON DELETE RESTRICT,
    FOREIGN KEY (winner_team_id) REFERENCES Teams(team_id) ON DELETE SET NULL
);

CREATE TABLE Stats (
    stat_id INT AUTO_INCREMENT PRIMARY KEY,
    match_id INT NOT NULL,
    player_id INT NOT NULL,
    runs_scored INT DEFAULT 0,
    balls_faced INT DEFAULT 0,
    fours INT DEFAULT 0,
    sixes INT DEFAULT 0,
    wickets_taken INT DEFAULT 0,
    overs_bowled DECIMAL(4,1) DEFAULT 0.0,
    maidens INT DEFAULT 0,
    runs_conceded INT DEFAULT 0,
    catches INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (match_id) REFERENCES Matches(match_id) ON DELETE CASCADE,
    FOREIGN KEY (player_id) REFERENCES Players(player_id) ON DELETE CASCADE
);

-- =========================
-- 2) SAMPLE DATA
-- =========================
-- Teams
INSERT INTO Teams (team_name) VALUES
('India'), ('England'), ('Australia'), ('West Indies');

-- Players (sample)
INSERT INTO Players (player_name, team_id, role) VALUES
('Virat Kohli', 1, 'Batsman'),
('Rohit Sharma', 1, 'Batsman'),
('Jasprit Bumrah', 1, 'Bowler'),
('MS Dhoni', 1, 'Wicketkeeper'),

('Joe Root', 2, 'Batsman'),
('Ben Stokes', 2, 'Allrounder'),
('Dawid Malan', 2, 'Batsman'),
('Jofra Archer', 2, 'Bowler'),

('David Warner', 3, 'Batsman'),
('Pat Cummins', 3, 'Bowler'),
('Travis Head', 3, 'Batsman'),
('Alex Carey', 3, 'Wicketkeeper'),

('Chris Gayle', 4, 'Batsman'),
('Andre Russell', 4, 'Allrounder'),
('Jason Holder', 4, 'Allrounder'),
('Sunil Narine', 4, 'Bowler');

-- Matches
INSERT INTO Matches (match_date, venue, team1_id, team2_id, winner_team_id, match_type) VALUES
('2025-10-01', 'Mumbai', 1, 2, 1, 'ODI'),
('2023-08-12', 'Brisbane', 3, 4, 4, 'T20'),
('2024-09-14', 'London', 2, 4, 4, 'ODI'),
('2022-11-08', 'Sydney', 2, 3, 2, 'Test');

-- Stats (example performance entries)
INSERT INTO Stats (match_id, player_id, runs_scored, balls_faced, fours, sixes, wickets_taken, overs_bowled, runs_conceded, catches) VALUES
(1, 1, 45, 50, 5, 1, 0, 0.0, 0, 1),  -- Virat
(1, 2, 10, 8, 1, 1, 3, 0.0, 0, 0),    -- Rohit
(1, 4, 5, 4, 0, 0, 2, 0.0, 0, 0),     -- Dhoni
(3, 6, 35, 40, 3, 0, 1, 0.0, 0, 0),   -- Ben Stokes
(3, 1, 0, 1, 0, 0, 0, 0.0, 0, 0),     -- Virat
(4, 5, 1, 2, 0, 0, 1, 0.0, 0, 0);

-- =========================
-- 3) QUERIES: Match results and player scores
-- =========================
SELECT 
    m.match_id,
    m.match_date,
    COALESCE(t1.team_name, 'Unknown') AS team1,
    COALESCE(t2.team_name, 'Unknown') AS team2,
    COALESCE(tw.team_name, 'No result') AS winner,
    m.venue,
    m.match_type
FROM Matches m
JOIN Teams t1 ON m.team1_id = t1.team_id
JOIN Teams t2 ON m.team2_id = t2.team_id
LEFT JOIN Teams tw ON m.winner_team_id = tw.team_id
ORDER BY m.match_date DESC;

SELECT
    s.match_id,
    p.player_id,
    p.player_name,
    t.team_name,
    s.runs_scored,
    s.balls_faced,
    s.fours,
    s.sixes,
    s.wickets_taken,
    s.overs_bowled,
    s.runs_conceded,
    s.catches
FROM Stats s
JOIN Players p ON s.player_id = p.player_id
JOIN Teams t ON p.team_id = t.team_id
WHERE s.match_id = 1
ORDER BY s.runs_scored DESC, s.wickets_taken DESC;

SELECT
    p.player_id,
    p.player_name,
    t.team_name,
    SUM(s.runs_scored) AS total_runs,
    SUM(s.balls_faced) AS total_balls,
    SUM(s.fours) AS total_fours,
    SUM(s.sixes) AS total_sixes,
    SUM(s.wickets_taken) AS total_wickets,
    SUM(s.overs_bowled) AS total_overs,
    SUM(s.runs_conceded) AS total_runs_conceded,
    SUM(s.catches) AS total_catches
FROM Players p
LEFT JOIN Stats s ON p.player_id = s.player_id
LEFT JOIN Teams t ON p.team_id = t.team_id
GROUP BY p.player_id, p.player_name, t.team_name
ORDER BY total_runs DESC;

-- =========================
-- 4) VIEWS: Leaderboards and points tables
-- =========================
CREATE OR REPLACE VIEW vw_player_leaderboard AS
SELECT
    p.player_id,
    p.player_name,
    t.team_name,
    COALESCE(SUM(s.runs_scored),0) AS total_runs,
    COALESCE(SUM(s.wickets_taken),0) AS total_wickets,
    COALESCE(SUM(s.catches),0) AS total_catches
FROM Players p
LEFT JOIN Stats s ON p.player_id = s.player_id
LEFT JOIN Teams t ON p.team_id = t.team_id
GROUP BY p.player_id, p.player_name, t.team_name
ORDER BY total_runs DESC;

CREATE OR REPLACE VIEW vw_team_results AS
SELECT m.match_id, m.match_date, m.team1_id AS team_id, m.winner_team_id,
       CASE
         WHEN m.winner_team_id = m.team1_id THEN 'W'
         WHEN m.winner_team_id IS NULL THEN 'NR'
         ELSE 'L'
       END AS result
FROM Matches m
UNION ALL
SELECT m.match_id, m.match_date, m.team2_id AS team_id, m.winner_team_id,
       CASE
         WHEN m.winner_team_id = m.team2_id THEN 'W'
         WHEN m.winner_team_id IS NULL THEN 'NR'
         ELSE 'L'
       END AS result
FROM Matches m;

CREATE OR REPLACE VIEW vw_team_points AS
SELECT
    t.team_id,
    t.team_name,
    COUNT(r.match_id) AS matches_played,
    SUM(CASE WHEN r.result = 'W' THEN 1 ELSE 0 END) AS wins,
    SUM(CASE WHEN r.result = 'L' THEN 1 ELSE 0 END) AS losses,
    SUM(CASE WHEN r.result = 'NR' THEN 1 ELSE 0 END) AS no_results,
    (SUM(CASE WHEN r.result = 'W' THEN 2 ELSE 0 END) + SUM(CASE WHEN r.result = 'NR' THEN 1 ELSE 0 END)) AS points
FROM Teams t
LEFT JOIN vw_team_results r ON t.team_id = r.team_id
GROUP BY t.team_id, t.team_name
ORDER BY points DESC, wins DESC;

-- =========================
-- 5) CTEs for average player performance
-- =========================
WITH player_averages AS (
    SELECT
        p.player_id,
        p.player_name,
        t.team_name,
        COUNT(DISTINCT s.match_id) AS matches_played,
        ROUND(AVG(NULLIF(s.runs_scored,0)),2) AS avg_runs_if_batted,
        ROUND(AVG(s.runs_scored),2) AS avg_runs_all_including_zeros,
        ROUND(AVG(s.wickets_taken),2) AS avg_wickets
    FROM Players p
    LEFT JOIN Stats s ON p.player_id = s.player_id
    LEFT JOIN Teams t ON p.team_id = t.team_id
    GROUP BY p.player_id, p.player_name, t.team_name
)
SELECT * FROM player_averages
ORDER BY avg_runs_all_including_zeros DESC;

WITH agg AS (
    SELECT p.player_id, p.player_name, t.team_name,
           COALESCE(SUM(s.runs_scored),0) AS runs,
           COALESCE(SUM(s.wickets_taken),0) AS wickets
    FROM Players p
    LEFT JOIN Stats s ON p.player_id = s.player_id
    LEFT JOIN Teams t ON p.team_id = t.team_id
    GROUP BY p.player_id, p.player_name, t.team_name
)
SELECT *, (runs + (wickets * 20)) AS allrounder_score
FROM agg
ORDER BY allrounder_score DESC;

SELECT *
FROM vw_player_leaderboard
INTO OUTFILE 'C:/mysql-files/'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';
