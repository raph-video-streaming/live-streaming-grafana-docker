* | select 
  __time__ - __time__ % 300 as time,
  count(case when uri like '%__1080p%' and uri like '%.mp4' then 1 end) as "1080p",
  count(case when uri like '%__720p%' and uri like '%.mp4' then 1 end) as "720p",
  count(case when uri like '%__432p%' and uri like '%.mp4' then 1 end) as "432p",
  count(case when uri like '%segment__4%' and uri like '%.mp4' then 1 end) as "audio1",
  count(case when uri like '%segment__5%' and uri like '%.mp4' then 1 end) as "audio2",
  count(case when uri like '%segment__6%' and uri like '%.mp4' then 1 end) as "audio3",
  count(case when uri like '%segment__7%' and uri like '%.mp4' then 1 end) as "audio4"
from log 
where (uri like '%__1080p%' or uri like '%__720p%' or uri like '%__432p%' or uri like '%segment__4%' or uri like '%segment__5%' or uri like '%segment__6%' or uri like '%segment__7%')
  and uri like '%.mp4'
group by time
order by time
