-- Resolution analysis with percentage breakdown
-- Shows request counts by resolution and percentage of each resolution over total

SELECT 
  CASE 
    WHEN date_diff('hour', $__timeFrom(), $__timeTo()) <= 1 THEN date_trunc('minute', date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')))
    WHEN date_diff('hour', $__timeFrom(), $__timeTo()) <= 6 THEN date_trunc('minute', date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')))
    WHEN date_diff('hour', $__timeFrom(), $__timeTo()) <= 24 THEN date_trunc('minute', date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')))
    WHEN date_diff('hour', $__timeFrom(), $__timeTo()) <= 168 THEN date_trunc('hour', date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')))
    ELSE date_trunc('day', date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')))
  END as time,
  CASE 
    WHEN request_url LIKE '%_720p%' THEN '720p'
    WHEN request_url LIKE '%_1080p%' THEN '1080p'
    WHEN request_url LIKE '%_480p%' THEN '480p'
    WHEN request_url LIKE '%_2160p%' THEN '2160p'
    ELSE 'other'
  END as resolution,
  COUNT(*) as request_count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY 
    CASE 
      WHEN date_diff('hour', $__timeFrom(), $__timeTo()) <= 1 THEN date_trunc('minute', date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')))
      WHEN date_diff('hour', $__timeFrom(), $__timeTo()) <= 6 THEN date_trunc('minute', date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')))
      WHEN date_diff('hour', $__timeFrom(), $__timeTo()) <= 24 THEN date_trunc('minute', date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')))
      WHEN date_diff('hour', $__timeFrom(), $__timeTo()) <= 168 THEN date_trunc('hour', date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')))
      ELSE date_trunc('day', date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')))
    END
  ), 2) as percentage
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
  -- Filter for resolution-specific requests
  AND (
    request_url LIKE '%_720p%' OR 
    request_url LIKE '%_1080p%' OR 
    request_url LIKE '%_480p%' OR 
    request_url LIKE '%_2160p%'
  )
GROUP BY 
  CASE 
    WHEN date_diff('hour', $__timeFrom(), $__timeTo()) <= 1 THEN date_trunc('minute', date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')))
    WHEN date_diff('hour', $__timeFrom(), $__timeTo()) <= 6 THEN date_trunc('minute', date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')))
    WHEN date_diff('hour', $__timeFrom(), $__timeTo()) <= 24 THEN date_trunc('minute', date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')))
    WHEN date_diff('hour', $__timeFrom(), $__timeTo()) <= 168 THEN date_trunc('hour', date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')))
    ELSE date_trunc('day', date_add('hour', -8, date_parse(date_time, '%d/%b/%Y:%H:%i:%s')))
  END,
  CASE 
    WHEN request_url LIKE '%_720p%' THEN '720p'
    WHEN request_url LIKE '%_1080p%' THEN '1080p'
    WHEN request_url LIKE '%_480p%' THEN '480p'
    WHEN request_url LIKE '%_2160p%' THEN '2160p'
    ELSE 'other'
  END
ORDER BY time, request_count DESC;

