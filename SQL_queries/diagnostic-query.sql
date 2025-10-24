* | select 
  __time__ - __time__ % 300 as time,
  count(case when uri like '%index.m3u8%' and uri not like '%index-720p.m3u8%' then 1 end) as "index_count",
  count(case when uri like '%ll-index.m3u8%' then 1 end) as "ll-index_count", 
  count(case when uri like '%index-720p.m3u8%' then 1 end) as "index-720p_count",
  count(case when uri like '%index.m3u8%' and uri not like '%index-720p.m3u8%' and return_code in (400, 401, 403, 404) then 1 end) as "4xx_index_count",
  count(case when uri like '%ll-index.m3u8%' and return_code in (400, 401, 403, 404) then 1 end) as "4xx_ll-index_count",
  count(case when uri like '%index-720p.m3u8%' and return_code in (400, 401, 403, 404) then 1 end) as "4xx_index-720p_count"
from log 
where (uri like '%index.m3u8%' or uri like '%ll-index.m3u8%' or uri like '%index-720p.m3u8%')
  and regexp_extract(uri_param, 'auth_key=([^&]*)', 1) is not null 
  and regexp_extract(uri_param, 'auth_key=([^&]*)', 1) != ''
group by time
order by time
