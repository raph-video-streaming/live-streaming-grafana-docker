* | select 
  __time__ - __time__ % 300 as time,
  count(distinct case when uri like '%index.m3u8%' and uri not like '%index-720p.m3u8%' then regexp_extract(uri_param, 'auth_key=([^&]*)', 1) end) as "index",
  count(distinct case when uri like '%ll-index.m3u8%' then regexp_extract(uri_param, 'auth_key=([^&]*)', 1) end) as "ll-index",
  count(distinct case when uri like '%index-720p.m3u8%' then regexp_extract(uri_param, 'auth_key=([^&]*)', 1) end) as "index-720p",
  count(distinct case when uri like '%index.m3u8%' and uri not like '%index-720p.m3u8%' and return_code in (400, 401, 403, 404) then regexp_extract(uri_param, 'auth_key=([^&]*)', 1) end) as "4xx_index",
  count(distinct case when uri like '%ll-index.m3u8%' and return_code in (400, 401, 403, 404) then regexp_extract(uri_param, 'auth_key=([^&]*)', 1) end) as "4xx_ll-index",
  count(distinct case when uri like '%index-720p.m3u8%' and return_code in (400, 401, 403, 404) then regexp_extract(uri_param, 'auth_key=([^&]*)', 1) end) as "4xx_index-720p",
  count(distinct case when uri like '%index.m3u8%' and uri not like '%index-720p.m3u8%' and return_code >= 500 then regexp_extract(uri_param, 'auth_key=([^&]*)', 1) end) as "5xx_index",
  count(distinct case when uri like '%ll-index.m3u8%' and return_code >= 500 then regexp_extract(uri_param, 'auth_key=([^&]*)', 1) end) as "5xx_ll-index",
  count(distinct case when uri like '%index-720p.m3u8%' and return_code >= 500 then regexp_extract(uri_param, 'auth_key=([^&]*)', 1) end) as "5xx_index-720p"
from log 
where (uri like '%index.m3u8%' or uri like '%ll-index.m3u8%' or uri like '%index-720p.m3u8%')
  and regexp_extract(uri_param, 'auth_key=([^&]*)', 1) is not null 
  and regexp_extract(uri_param, 'auth_key=([^&]*)', 1) != ''
group by time
order by time