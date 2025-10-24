-- UNIQUE AUTH_KEY PER CHANNEL - Athena Query
-- Shows unique auth_key counts by channel over time with smart time grouping
-- Extracts auth_key from query parameters and groups by channel

SELECT 
  CASE 
    WHEN date_diff('hour', $__timeFrom(), $__timeTo()) <= 1 THEN date_trunc('minute', date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')))
    WHEN date_diff('hour', $__timeFrom(), $__timeTo()) <= 6 THEN date_trunc('minute', date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')))
    WHEN date_diff('hour', $__timeFrom(), $__timeTo()) <= 24 THEN date_trunc('minute', date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')))
    WHEN date_diff('hour', $__timeFrom(), $__timeTo()) <= 168 THEN date_trunc('hour', date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')))
    ELSE date_trunc('day', date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')))
  END as time,
  COUNT(DISTINCT CASE WHEN request_url LIKE '%/ch01%' THEN regexp_extract(request_url, 'auth_key=([^&]*)', 1) END) as "ch01",
  COUNT(DISTINCT CASE WHEN request_url LIKE '%/ch02%' THEN regexp_extract(request_url, 'auth_key=([^&]*)', 1) END) as "ch02",
  COUNT(DISTINCT CASE WHEN request_url LIKE '%/ch03%' THEN regexp_extract(request_url, 'auth_key=([^&]*)', 1) END) as "ch03",
  COUNT(DISTINCT CASE WHEN request_url LIKE '%/ch04%' THEN regexp_extract(request_url, 'auth_key=([^&]*)', 1) END) as "ch04",
  COUNT(DISTINCT CASE WHEN request_url LIKE '%/ch05%' THEN regexp_extract(request_url, 'auth_key=([^&]*)', 1) END) as "ch05",
  COUNT(DISTINCT CASE WHEN request_url LIKE '%/ch06%' THEN regexp_extract(request_url, 'auth_key=([^&]*)', 1) END) as "ch06",
  COUNT(DISTINCT CASE WHEN request_url LIKE '%/ch07%' THEN regexp_extract(request_url, 'auth_key=([^&]*)', 1) END) as "ch07",
  COUNT(DISTINCT CASE WHEN request_url LIKE '%/ch08%' THEN regexp_extract(request_url, 'auth_key=([^&]*)', 1) END) as "ch08",
  COUNT(DISTINCT CASE WHEN request_url LIKE '%/ch09%' THEN regexp_extract(request_url, 'auth_key=([^&]*)', 1) END) as "ch09",
  COUNT(DISTINCT CASE WHEN request_url LIKE '%/ch10%' THEN regexp_extract(request_url, 'auth_key=([^&]*)', 1) END) as "ch10",
  COUNT(DISTINCT CASE WHEN request_url LIKE '%/ch11%' THEN regexp_extract(request_url, 'auth_key=([^&]*)', 1) END) as "ch11"
FROM "cdn_logs_alibaba_partitioned"."cdn_logs_parquet" 
WHERE 
  -- Smart partition filtering based on time range
  (
    (year = date_format($__timeFrom(), '%Y') AND year = date_format($__timeTo(), '%Y')) OR
    (year = date_format($__timeFrom(), '%Y') OR year = date_format($__timeTo(), '%Y')) OR
    (year >= date_format($__timeFrom(), '%Y') AND year <= date_format($__timeTo(), '%Y'))
  )
  -- Time range filtering with timezone adjustment (-8 hours for UTC+8 to UTC)
  AND date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')) >= $__timeFrom()
  AND date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')) <= $__timeTo()
  -- Filter for m3u8 requests with auth_key parameter
  AND (request_url LIKE '%index.m3u8%' OR request_url LIKE '%ll-index.m3u8%' OR request_url LIKE '%index-720p.m3u8%')
  AND regexp_extract(request_url, 'auth_key=([^&]*)', 1) IS NOT NULL 
  AND regexp_extract(request_url, 'auth_key=([^&]*)', 1) != ''
GROUP BY 
  CASE 
    WHEN date_diff('hour', $__timeFrom(), $__timeTo()) <= 1 THEN date_trunc('minute', date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')))
    WHEN date_diff('hour', $__timeFrom(), $__timeTo()) <= 6 THEN date_trunc('minute', date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')))
    WHEN date_diff('hour', $__timeFrom(), $__timeTo()) <= 24 THEN date_trunc('minute', date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')))
    WHEN date_diff('hour', $__timeFrom(), $__timeTo()) <= 168 THEN date_trunc('hour', date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')))
    ELSE date_trunc('day', date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')))
  END
ORDER BY time;
