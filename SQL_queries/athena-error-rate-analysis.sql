-- ERROR RATE ANALYSIS - Athena Query
-- Shows unique auth_key counts, total requests, error requests, and error rates by stream type
-- Comprehensive analysis of index.m3u8, ll-index.m3u8, and index-720p.m3u8 streams

SELECT 
  CASE 
    WHEN date_diff('hour', $__timeFrom(), $__timeTo()) <= 1 THEN date_trunc('minute', date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')))
    WHEN date_diff('hour', $__timeFrom(), $__timeTo()) <= 6 THEN date_trunc('minute', date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')))
    WHEN date_diff('hour', $__timeFrom(), $__timeTo()) <= 24 THEN date_trunc('minute', date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')))
    WHEN date_diff('hour', $__timeFrom(), $__timeTo()) <= 168 THEN date_trunc('hour', date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')))
    ELSE date_trunc('day', date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')))
  END as time,
  -- Unique auth_key counts by stream type
  COUNT(DISTINCT CASE WHEN request_url LIKE '%index.m3u8%' AND request_url NOT LIKE '%index-720p.m3u8%' THEN regexp_extract(request_url, 'auth_key=([^&]*)', 1) END) as "index",
  COUNT(DISTINCT CASE WHEN request_url LIKE '%ll-index.m3u8%' THEN regexp_extract(request_url, 'auth_key=([^&]*)', 1) END) as "ll-index",
  COUNT(DISTINCT CASE WHEN request_url LIKE '%index-720p.m3u8%' THEN regexp_extract(request_url, 'auth_key=([^&]*)', 1) END) as "index-720p",
  -- Total request counts by stream type
  COUNT(CASE WHEN request_url LIKE '%index.m3u8%' AND request_url NOT LIKE '%index-720p.m3u8%' THEN 1 END) as "total_index_requests",
  COUNT(CASE WHEN request_url LIKE '%ll-index.m3u8%' THEN 1 END) as "total_ll-index_requests",
  COUNT(CASE WHEN request_url LIKE '%index-720p.m3u8%' THEN 1 END) as "total_index-720p_requests",
  -- 4xx error request counts by stream type
  COUNT(CASE WHEN request_url LIKE '%index.m3u8%' AND request_url NOT LIKE '%index-720p.m3u8%' AND status_code IN (400, 401, 403, 404) THEN 1 END) as "4xx_index_requests",
  COUNT(CASE WHEN request_url LIKE '%ll-index.m3u8%' AND status_code IN (400, 401, 403, 404) THEN 1 END) as "4xx_ll-index_requests",
  COUNT(CASE WHEN request_url LIKE '%index-720p.m3u8%' AND status_code IN (400, 401, 403, 404) THEN 1 END) as "4xx_index-720p_requests",
  -- 5xx error request counts by stream type
  COUNT(CASE WHEN request_url LIKE '%index.m3u8%' AND request_url NOT LIKE '%index-720p.m3u8%' AND status_code >= 500 THEN 1 END) as "5xx_index_requests",
  COUNT(CASE WHEN request_url LIKE '%ll-index.m3u8%' AND status_code >= 500 THEN 1 END) as "5xx_ll-index_requests",
  COUNT(CASE WHEN request_url LIKE '%index-720p.m3u8%' AND status_code >= 500 THEN 1 END) as "5xx_index-720p_requests",
  -- 4xx error rates by stream type
  ROUND(COUNT(CASE WHEN request_url LIKE '%index.m3u8%' AND request_url NOT LIKE '%index-720p.m3u8%' AND status_code IN (400, 401, 403, 404) THEN 1 END) * 100.0 / COUNT(CASE WHEN request_url LIKE '%index.m3u8%' AND request_url NOT LIKE '%index-720p.m3u8%' THEN 1 END), 2) as "4xx_index_error_rate",
  ROUND(COUNT(CASE WHEN request_url LIKE '%ll-index.m3u8%' AND status_code IN (400, 401, 403, 404) THEN 1 END) * 100.0 / COUNT(CASE WHEN request_url LIKE '%ll-index.m3u8%' THEN 1 END), 2) as "4xx_ll-index_error_rate",
  ROUND(COUNT(CASE WHEN request_url LIKE '%index-720p.m3u8%' AND status_code IN (400, 401, 403, 404) THEN 1 END) * 100.0 / COUNT(CASE WHEN request_url LIKE '%index-720p.m3u8%' THEN 1 END), 2) as "4xx_index-720p_error_rate",
  -- 5xx error rates by stream type
  ROUND(COUNT(CASE WHEN request_url LIKE '%index.m3u8%' AND request_url NOT LIKE '%index-720p.m3u8%' AND status_code >= 500 THEN 1 END) * 100.0 / COUNT(CASE WHEN request_url LIKE '%index.m3u8%' AND request_url NOT LIKE '%index-720p.m3u8%' THEN 1 END), 2) as "5xx_index_error_rate",
  ROUND(COUNT(CASE WHEN request_url LIKE '%ll-index.m3u8%' AND status_code >= 500 THEN 1 END) * 100.0 / COUNT(CASE WHEN request_url LIKE '%ll-index.m3u8%' THEN 1 END), 2) as "5xx_ll-index_error_rate",
  ROUND(COUNT(CASE WHEN request_url LIKE '%index-720p.m3u8%' AND status_code >= 500 THEN 1 END) * 100.0 / COUNT(CASE WHEN request_url LIKE '%index-720p.m3u8%' THEN 1 END), 2) as "5xx_index-720p_error_rate"
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
