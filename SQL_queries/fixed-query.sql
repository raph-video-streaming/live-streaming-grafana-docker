* | select 
  count(distinct regexp_extract(uri, '/([^/]+)/live/', 1)) as total_unique_long_tokens
from log 
where regexp_extract(uri, '/([^/]+)/live/', 1) != ''

