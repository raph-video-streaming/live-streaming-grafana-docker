* | select 
  __time__ - __time__ % 300 as time,
  approx_distinct(case when uri like '%/ch01%' then regexp_extract(uri_param, 'auth_key=([^&]*)', 1) end) as "ch01",
  approx_distinct(case when uri like '%/ch02%' then regexp_extract(uri_param, 'auth_key=([^&]*)', 1) end) as "ch02",
  approx_distinct(case when uri like '%/ch03%' then regexp_extract(uri_param, 'auth_key=([^&]*)', 1) end) as "ch03",
  approx_distinct(case when uri like '%/ch04%' then regexp_extract(uri_param, 'auth_key=([^&]*)', 1) end) as "ch04",
  approx_distinct(case when uri like '%/ch05%' then regexp_extract(uri_param, 'auth_key=([^&]*)', 1) end) as "ch05",
  approx_distinct(case when uri like '%/ch06%' then regexp_extract(uri_param, 'auth_key=([^&]*)', 1) end) as "ch06",
  approx_distinct(case when uri like '%/ch07%' then regexp_extract(uri_param, 'auth_key=([^&]*)', 1) end) as "ch07",
  approx_distinct(case when uri like '%/ch08%' then regexp_extract(uri_param, 'auth_key=([^&]*)', 1) end) as "ch08",
  approx_distinct(case when uri like '%/ch09%' then regexp_extract(uri_param, 'auth_key=([^&]*)', 1) end) as "ch09",
  approx_distinct(case when uri like '%/ch10%' then regexp_extract(uri_param, 'auth_key=([^&]*)', 1) end) as "ch10",
  approx_distinct(case when uri like '%/ch11%' then regexp_extract(uri_param, 'auth_key=([^&]*)', 1) end) as "ch11"
from log 
where (uri like '%index.m3u8%' or uri like '%ll-index.m3u8%' or uri like '%index-720p.m3u8%')
  and regexp_extract(uri_param, 'auth_key=([^&]*)', 1) is not null 
  and regexp_extract(uri_param, 'auth_key=([^&]*)', 1) != ''
group by time
order by time
