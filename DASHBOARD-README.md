# CDN Logs Query Dashboard

This dashboard provides a simple UI for querying CDN logs with advanced filtering capabilities for Alibaba Cloud CDN logs.

## Features

### 🔍 Filtering Options
- **Channel Name**: Filter by channel name extracted from URL pattern `https://hostname/TOKEN/live/CHANNEL_NAME/...`
- **Client IP**: Filter by exact client IP address
- **Status Codes**: Multi-select filter for HTTP status codes (200-503)

### 📊 Visualizations
- **Table View**: Detailed log entries with all relevant fields
- **Time Series**: Request count over time (Advanced dashboard)
- **Pie Chart**: Status code distribution (Advanced dashboard)

### 🎨 UI Features
- Color-coded status codes (green for 2xx, yellow for 3xx, red for 4xx/5xx)
- Sortable columns
- Real-time refresh (30 seconds)
- Responsive design

## Quick Start

### 1. Start Grafana
```bash
cd /home/raf/GITHUB/live-streaming-grafana-docker
docker-compose up -d
```

### 2. Run Setup Script
```bash
./setup-dashboard.sh
```

### 3. Configure Data Source
1. Go to http://localhost:3000
2. Login with `admin`/`admin`
3. Go to **Configuration** → **Data Sources**
4. Click **Add data source**
5. Search for **"Aliyun Log Service"**
6. Configure with your credentials:
   - **Access Key ID**: Your Aliyun Access Key ID
   - **Access Key Secret**: Your Aliyun Access Key Secret
   - **Region**: Your Aliyun region (e.g., `cn-hangzhou`, `us-west-1`)
   - **Project**: Your SLS project name
   - **Logstore**: Your SLS logstore name

### 4. Open Dashboard
- **Basic Dashboard**: "CDN Logs Query Dashboard"
- **Advanced Dashboard**: "Advanced CDN Logs Query Dashboard"

## Dashboard Configurations

### Basic Dashboard (`cdn-logs-dashboard.json`)
- Simple table view with filtering
- Perfect for basic log analysis
- Lightweight and fast

### Advanced Dashboard (`advanced-cdn-logs-dashboard.json`)
- Table view with filtering
- Time series chart showing request count over time
- Pie chart showing status code distribution
- More comprehensive analytics

## Query Logic

### Channel Name Extraction
The dashboard uses regex to extract channel names from URLs:
```sql
extract('https?://[^/]+/[^/]+/live/([^/]+)/', 1, request_url) as channelName
```

This matches URLs like:
- `https://example.com/token123/live/channel1/stream.m3u8`
- `http://cdn.example.com/auth456/live/my-channel/playlist.ts`

### Filtering Logic
```sql
* | where 
  (${channelName:sqlstring} = '*' or request_url like concat('%', ${channelName:sqlstring}, '%')) 
  and (${clientIp:sqlstring} = '*' or client_ip = ${clientIp:sqlstring}) 
  and (${statusCodes:sqlstring} = '*' or http_status in (${statusCodes:sqlstring}))
```

### Available Fields
Based on your Athena table structure:
- `date_time`: Timestamp of the request
- `client_ip`: Client IP address
- `http_status`: HTTP status code
- `request_url`: Full request URL
- `response_time`: Response time in milliseconds
- `request_bytes`: Request size in bytes
- `response_bytes`: Response size in bytes
- `user_agent`: User agent string
- `cache_status`: Cache hit/miss status
- `http_method`: HTTP method (GET, POST, etc.)

## Customization

### Adding New Filters
To add new filters, edit the dashboard JSON and add new variables in the `templating.list` section:

```json
{
  "name": "newFilter",
  "type": "query",
  "query": "* | distinct new_field | order by new_field asc",
  "label": "New Filter",
  "multi": true,
  "includeAll": true
}
```

### Modifying Queries
Update the query in the panel targets to include your new filters:

```sql
* | where 
  (${channelName:sqlstring} = '*' or request_url like concat('%', ${channelName:sqlstring}, '%')) 
  and (${clientIp:sqlstring} = '*' or client_ip = ${clientIp:sqlstring}) 
  and (${statusCodes:sqlstring} = '*' or http_status in (${statusCodes:sqlstring}))
  and (${newFilter:sqlstring} = '*' or new_field = ${newFilter:sqlstring})
```

### Status Code Colors
The dashboard automatically colors status codes:
- 🟢 Green: 200-299 (Success)
- 🟡 Yellow: 300-399 (Redirect)
- 🔴 Red: 400-599 (Client/Server Error)

## Troubleshooting

### Dashboard Not Loading
1. Check if Grafana is running: `docker ps | grep grafana`
2. Verify data source connection
3. Check Aliyun credentials
4. Ensure logstore has data

### No Data Showing
1. Verify time range (default: last 1 hour)
2. Check if filters are too restrictive
3. Ensure logstore contains data for the selected time range
4. Check if channel name extraction is working correctly

### Performance Issues
1. Reduce the limit in queries (default: 1000 rows)
2. Use more specific time ranges
3. Add more restrictive filters
4. Consider using the basic dashboard for better performance

## API Integration

### Import Dashboard via API
```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -d @dashboards/cdn-logs-dashboard.json \
  http://admin:admin@localhost:3000/api/dashboards/db
```

### Export Dashboard
```bash
curl -X GET \
  http://admin:admin@localhost:3000/api/dashboards/uid/cdn-logs-query
```

## Advanced Usage

### Custom Queries
You can create custom queries by modifying the query in the panel targets. Example queries:

```sql
-- Get top 10 client IPs by request count
* | summarize count() by client_ip | order by count_ desc | limit 10

-- Get error rate by hour
* | where http_status >= 400 
| summarize count() by bin(date_time, 1h) 
| order by date_time asc

-- Get cache hit ratio
* | summarize 
    total = count(),
    cache_hits = countif(cache_status = 'HIT')
  by bin(date_time, 1h)
| extend hit_ratio = cache_hits / total
| order by date_time asc
```

### Alerting
You can set up alerts based on the dashboard data:
1. Go to the panel settings
2. Click "Alert" tab
3. Configure alert conditions
4. Set up notification channels

## Support

For issues or questions:
1. Check Grafana logs: `docker logs grafana-aliyun`
2. Verify data source configuration
3. Test queries directly in the Aliyun Log Service console
4. Check network connectivity to Aliyun services

