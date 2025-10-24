* | select 
  __time__ - __time__ % 300 as time,
  count(distinct regexp_extract(uri, '/([^/]+)/live/', 1)) as unique_tokens
from log 
where regexp_extract(uri, '/([^/]+)/live/', 1) != ''
group by time 
order by time

