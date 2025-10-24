-- Total unique tokens in URL over 5-minute periods
-- Shows distinct token counts from URL path in 5-minute buckets

SELECT 
  date_trunc('minute', date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s'))) as time_bucket,
  COUNT(DISTINCT regexp_extract(request_url, '/([^/]+)/live/', 1)) as unique_tokens,
  COUNT(*) as total_requests
FROM "cdn_logs_alibaba_partitioned"."cdn_logs_parquet" 
WHERE 
  -- Smart partition filtering based on time range
  (
    -- If querying current year, use year partition
    (year = date_format($__timeFrom(), '%Y') AND year = date_format($__timeTo(), '%Y')) OR
    -- If spanning years, include both years
    (year = date_format($__timeFrom(), '%Y') OR year = date_format($__timeTo(), '%Y')) OR
    -- If querying within same year, include that year
    (year >= date_format($__timeFrom(), '%Y') AND year <= date_format($__timeTo(), '%Y'))
  )
  -- Time range filtering with timezone adjustment (-8 hours for UTC+8 to UTC)
  AND date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')) >= $__timeFrom()
  AND date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')) <= $__timeTo()
  -- Ensure we have valid token in URL
  AND regexp_extract(request_url, '/([^/]+)/live/', 1) != ''
  AND regexp_extract(request_url, '/([^/]+)/live/', 1) IS NOT NULL
GROUP BY 
  date_trunc('minute', date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')))
ORDER BY time_bucket;

