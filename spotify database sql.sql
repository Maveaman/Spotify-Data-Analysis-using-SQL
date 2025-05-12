-- Advance SQL Project -- Spotify Database

drop table if exists spotify;
create table spotify (
   artist varchar(255),
   track varchar(255),
   album varchar(255),
   album_type varchar(50),
   danceability float,
   energy float,
   loudness float,
   speechiness float,
   acousticness float,
   instrumentalness float,
   liveness float,
   valence float,
   tempo float,
   duration_min float,
   title varchar(255),
   channel varchar(255),
   views float,
   likes bigint,
   comments bigint,
   licensed boolean,
   official_video boolean,
   stream bigint,
   energy_liveness float,
   most_played_on varchar(50)
);


-- EDA
select * from spotify;
select count(distinct artist) from spotify;
select count(distinct album) from spotify;
select distinct album_type from spotify;

select * from spotify
where duration_min = 0
delete from spotify
where duration_min = 0

-- ----------------------------------------------------------
-- Data Analysis - Easy Category
-- ----------------------------------------------------------


-- Q1. Retrieve the names of all tracks that have more thaan 1 billion streams. --

select * from spotify
where stream > 1000000000;



-- Q2. List all album along with their respective artists. --

select 
   distinct album,artist
   from spotify
   order by 1;
   

-- Q3. Get the total number of comments for tracks where licensed = True --

select 
      sum(comments) as total_comments
	  from spotify
where licensed = 'true';



-- Q4. Find all tracks that belong to the album type single. --

select * from spotify
where album_type = 'single';



-- Q5. Count the total number of tracks by each artist. --

select 
    artist,
	count(*) as total_no_songs
from spotify
group by artist
order by 2 desc



-- ----------------------------------------------------------
-- Data Analysis - Medium Category
-- ----------------------------------------------------------


-- Q6. Calculate the average danceability of tracks in each album. --

select 
   album,
   avg(danceability) as avg_danceability
from spotify
group by 1
order by 2 desc


-- Q7. Find the top 5 tracks with the highest energy values. --

Select 
    track,
	max(energy)
from spotify
group by 1
order by 2 desc
limit 5


-- Q8. List all tracks along witht their views and likes where official_video = true

Select 
    track,
	sum(views) as total_views,
	sum(likes) as total_likes
from spotify
where official_video ='true'
group by 1
order by 2 desc
limit 5


-- Q9. For each album, calculate the total views of all associated tracks. --

select 
   album,
   track,
   sum(views)
from spotify
group by 1, 2
order by 3 desc


-- Q10. Retrieve the track names that have been streamed on spotify more than youtube. --

SELECT * FROM 
(
    SELECT
        track,
        COALESCE(SUM(CASE WHEN LOWER(most_played_on) = 'youtube' THEN stream END), 0) AS streamed_on_youtube,
        COALESCE(SUM(CASE WHEN LOWER(most_played_on) = 'spotify' THEN stream END), 0) AS streamed_on_spotify
    FROM spotify
    GROUP BY 1
) AS t1
WHERE streamed_on_spotify > streamed_on_youtube
and
streamed_on_youtube <> 0




-- ----------------------------------------------------------
-- Data Analysis - Advance Category
-- ----------------------------------------------------------

-- Q11. Find the top 3 most-viewed tracks for each artist using window function. --

with ranking_artist
as
(select 
  artist,
  track,
  sum(views) as total_view,
  dense_rank() over(partition by artist order by sum(views) desc) as rank
from spotify
group by 1, 2
order by 1, 3 desc
)
select * from ranking_artist
where rank <= 3


-- Q12. Write a query to find tracks where the liveness score is above the average. --

select 
  track,
  artist,
  liveness
from spotify
where liveness > (select avg(liveness) from spotify)

select avg(liveness) from spotify -- 0.19



-- Q13. Use a with clause to calculate the difference between the highest and lowest energy values for track in each. --

with cte
as
(select 
   album,
   max(energy) as highest_energy,
   min(energy) as lowest_energy
   from spotify
group by 1
)
select
   album,
   highest_energy - lowest_energy as energy_diff
   from cte
   order by 2 desc


-- Q14. Find tracks where the energy-to-liveness ratio is greater than 1.2. --

SELECT
    track,
    energy,
    liveness,
    (energy / liveness) AS energy_to_liveness_ratio
FROM spotify
WHERE liveness IS NOT NULL AND liveness <> 0
  AND (energy / liveness) > 1.2;


-- Q15. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window function.--

SELECT
    track,
    views,
    likes,
    SUM(likes) OVER (ORDER BY views) AS cumulative_likes
FROM spotify;




