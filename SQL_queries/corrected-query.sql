* | select 
  __time__ - __time__ % 300 as time,
  regexp_extract(uri, 'ch([0-9]+)', 1) as channel,
  count(distinct regexp_extract(uri, '/([^/]+)/live/', 1)) as unique_tokens_per_channel,
  count(*) as total_requests
from log 
where (uri like '%index.m3u8' or uri like '%ll-index.m3u8' or uri like '%index-720p.m3u8')
  and regexp_extract(uri, 'ch([0-9]+)', 1) != ''
  and regexp_extract(uri, '/([^/]+)/live/', 1) != ''
group by time, channel 
order by time, channel

