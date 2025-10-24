* | select 
  __time__ - __time__ % 300 as time,
  count(distinct case when uri like '%index.m3u8%' and uri not like '%index-720p.m3u8%' then regexp_extract(uri_param, 'auth_key=([^&]*)', 1) end) as "index",
  count(distinct case when uri like '%ll-index.m3u8%' then regexp_extract(uri_param, 'auth_key=([^&]*)', 1) end) as "ll-index",
  count(distinct case when uri like '%index-720p.m3u8%' then regexp_extract(uri_param, 'auth_key=([^&]*)', 1) end) as "index-720p",
  count(case when uri like '%index.m3u8%' and uri not like '%index-720p.m3u8%' then 1 end) as "total_index_requests",
  count(case when uri like '%ll-index.m3u8%' then 1 end) as "total_ll-index_requests",
  count(case when uri like '%index-720p.m3u8%' then 1 end) as "total_index-720p_requests",
  count(case when uri like '%index.m3u8%' and uri not like '%index-720p.m3u8%' and return_code in (400, 401, 403, 404) then 1 end) as "4xx_index_requests",
  count(case when uri like '%ll-index.m3u8%' and return_code in (400, 401, 403, 404) then 1 end) as "4xx_ll-index_requests",
  count(case when uri like '%index-720p.m3u8%' and return_code in (400, 401, 403, 404) then 1 end) as "4xx_index-720p_requests",
  count(case when uri like '%index.m3u8%' and uri not like '%index-720p.m3u8%' and return_code >= 500 then 1 end) as "5xx_index_requests",
  count(case when uri like '%ll-index.m3u8%' and return_code >= 500 then 1 end) as "5xx_ll-index_requests",
  count(case when uri like '%index-720p.m3u8%' and return_code >= 500 then 1 end) as "5xx_index-720p_requests",
  round(count(case when uri like '%index.m3u8%' and uri not like '%index-720p.m3u8%' and return_code in (400, 401, 403, 404) then 1 end) * 100.0 / count(case when uri like '%index.m3u8%' and uri not like '%index-720p.m3u8%' then 1 end), 2) as "4xx_index_error_rate",
  round(count(case when uri like '%ll-index.m3u8%' and return_code in (400, 401, 403, 404) then 1 end) * 100.0 / count(case when uri like '%ll-index.m3u8%' then 1 end), 2) as "4xx_ll-index_error_rate",
  round(count(case when uri like '%index-720p.m3u8%' and return_code in (400, 401, 403, 404) then 1 end) * 100.0 / count(case when uri like '%index-720p.m3u8%' then 1 end), 2) as "4xx_index-720p_error_rate",
  round(count(case when uri like '%index.m3u8%' and uri not like '%index-720p.m3u8%' and return_code >= 500 then 1 end) * 100.0 / count(case when uri like '%index.m3u8%' and uri not like '%index-720p.m3u8%' then 1 end), 2) as "5xx_index_error_rate",
  round(count(case when uri like '%ll-index.m3u8%' and return_code >= 500 then 1 end) * 100.0 / count(case when uri like '%ll-index.m3u8%' then 1 end), 2) as "5xx_ll-index_error_rate",
  round(count(case when uri like '%index-720p.m3u8%' and return_code >= 500 then 1 end) * 100.0 / count(case when uri like '%index-720p.m3u8%' then 1 end), 2) as "5xx_index-720p_error_rate"
from log 
where (uri like '%index.m3u8%' or uri like '%ll-index.m3u8%' or uri like '%index-720p.m3u8%')
  and regexp_extract(uri_param, 'auth_key=([^&]*)', 1) is not null 
  and regexp_extract(uri_param, 'auth_key=([^&]*)', 1) != ''
group by time
order by time

