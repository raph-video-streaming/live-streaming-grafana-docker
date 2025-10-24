-- UNIQUE TOKENS PER CHANNEL - Athena Query
-- Shows unique token counts by channel over time with smart time grouping
-- Extracts tokens from URL pattern /([^/]+)/live/ and groups by channel

SELECT 
  CASE 
    WHEN date_diff('hour', $__timeFrom(), $__timeTo()) <= 1 THEN date_trunc('minute', date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')))
    WHEN date_diff('hour', $__timeFrom(), $__timeTo()) <= 6 THEN date_trunc('minute', date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')))
    WHEN date_diff('hour', $__timeFrom(), $__timeTo()) <= 24 THEN date_trunc('minute', date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')))
    WHEN date_diff('hour', $__timeFrom(), $__timeTo()) <= 168 THEN date_trunc('hour', date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')))
    ELSE date_trunc('day', date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')))
  END as time,
  CASE 
    WHEN request_url LIKE '%/ch01%' THEN 'ch01'
    WHEN request_url LIKE '%/ch02%' THEN 'ch02'
    WHEN request_url LIKE '%/ch03%' THEN 'ch03'
    WHEN request_url LIKE '%/ch04%' THEN 'ch04'
    WHEN request_url LIKE '%/ch05%' THEN 'ch05'
    WHEN request_url LIKE '%/ch06%' THEN 'ch06'
    WHEN request_url LIKE '%/ch07%' THEN 'ch07'
    WHEN request_url LIKE '%/ch08%' THEN 'ch08'
    WHEN request_url LIKE '%/ch09%' THEN 'ch09'
    WHEN request_url LIKE '%/ch10%' THEN 'ch10'
    WHEN request_url LIKE '%/ch11%' THEN 'ch11'
    ELSE 'others'
  END as channel,
  COUNT(DISTINCT regexp_extract(request_url, '/([^/]+)/live/', 1)) as "Unique Tokens"
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
  -- Filter for m3u8 requests and ensure token extraction is possible
  AND (request_url LIKE '%index.m3u8%' OR request_url LIKE '%ll-index.m3u8%' OR request_url LIKE '%index-720p.m3u8%')
  AND regexp_extract(request_url, '/([^/]+)/live/', 1) != ''
GROUP BY 
  CASE 
    WHEN date_diff('hour', $__timeFrom(), $__timeTo()) <= 1 THEN date_trunc('minute', date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')))
    WHEN date_diff('hour', $__timeFrom(), $__timeTo()) <= 6 THEN date_trunc('minute', date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')))
    WHEN date_diff('hour', $__timeFrom(), $__timeTo()) <= 24 THEN date_trunc('minute', date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')))
    WHEN date_diff('hour', $__timeFrom(), $__timeTo()) <= 168 THEN date_trunc('hour', date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')))
    ELSE date_trunc('day', date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')))
  END,
  CASE 
    WHEN request_url LIKE '%/ch01%' THEN 'ch01'
    WHEN request_url LIKE '%/ch02%' THEN 'ch02'
    WHEN request_url LIKE '%/ch03%' THEN 'ch03'
    WHEN request_url LIKE '%/ch04%' THEN 'ch04'
    WHEN request_url LIKE '%/ch05%' THEN 'ch05'
    WHEN request_url LIKE '%/ch06%' THEN 'ch06'
    WHEN request_url LIKE '%/ch07%' THEN 'ch07'
    WHEN request_url LIKE '%/ch08%' THEN 'ch08'
    WHEN request_url LIKE '%/ch09%' THEN 'ch09'
    WHEN request_url LIKE '%/ch10%' THEN 'ch10'
    WHEN request_url LIKE '%/ch11%' THEN 'ch11'
    ELSE 'others'
  END
ORDER BY time, "Unique Tokens" DESC;
