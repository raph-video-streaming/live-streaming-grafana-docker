* | select 
  __time__ - __time__ % 300 as time,
  case 
    when uri like '%/ch%' then regexp_extract(uri, 'ch([0-9]+)', 1)
    else 'unknown'
  end as channel,
  count(distinct regexp_extract(uri, '/([^/]+)/live/', 1)) as "Unique Tokens",
  count(distinct case when uri not like '%/ch01%' and uri not like '%/ch02%' and uri not like '%/ch03%' and uri not like '%/ch04%' and uri not like '%/ch05%' and uri not like '%/ch06%' and uri not like '%/ch07%' and uri not like '%/ch08%' and uri not like '%/ch09%' and uri not like '%/ch10%' and uri not like '%/ch11%' then regexp_extract(uri, '/([^/]+)/live/', 1) end) as "others"
from log 
where (uri like '%index.m3u8%' or uri like '%ll-index.m3u8%' or uri like '%index-720p.m3u8%')
  and regexp_extract(uri, '/([^/]+)/live/', 1) != ''
group by time, channel
order by time, "Unique Tokens" desc
