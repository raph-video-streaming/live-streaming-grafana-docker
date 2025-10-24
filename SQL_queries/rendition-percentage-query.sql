* | select 
  count(case when uri like '%__1080p%' and uri like '%.mp4' then 1 end) as "1080p_requests",
  count(case when uri like '%__720p%' and uri like '%.mp4' then 1 end) as "720p_requests",
  count(case when uri like '%__432p%' and uri like '%.mp4' then 1 end) as "432p_requests",
  count(case when uri like '%__2160p%' and uri like '%.mp4' then 1 end) as "2160p_requests",
  count(case when uri like '%.mp4' and (uri like '%__1080p%' or uri like '%__720p%' or uri like '%__432p%' or uri like '%__2160p%') then 1 end) as "total_video_requests",
  round(count(case when uri like '%__1080p%' and uri like '%.mp4' then 1 end) * 100.0 / count(case when uri like '%.mp4' and (uri like '%__1080p%' or uri like '%__720p%' or uri like '%__432p%' or uri like '%__2160p%') then 1 end), 2) as "1080p_percentage",
  round(count(case when uri like '%__720p%' and uri like '%.mp4' then 1 end) * 100.0 / count(case when uri like '%.mp4' and (uri like '%__1080p%' or uri like '%__720p%' or uri like '%__432p%' or uri like '%__2160p%') then 1 end), 2) as "720p_percentage",
  round(count(case when uri like '%__432p%' and uri like '%.mp4' then 1 end) * 100.0 / count(case when uri like '%.mp4' and (uri like '%__1080p%' or uri like '%__720p%' or uri like '%__432p%' or uri like '%__2160p%') then 1 end), 2) as "432p_percentage",
  round(count(case when uri like '%__2160p%' and uri like '%.mp4' then 1 end) * 100.0 / count(case when uri like '%.mp4' and (uri like '%__1080p%' or uri like '%__720p%' or uri like '%__432p%' or uri like '%__2160p%') then 1 end), 2) as "2160p_percentage"
from log 
where uri like '%.mp4' and (uri like '%__1080p%' or uri like '%__720p%' or uri like '%__432p%' or uri like '%__2160p%')
