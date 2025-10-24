# Grafana with Aliyun Log Service Plugin

This directory contains Docker configuration files to run Grafana with the Aliyun Log Service plugin pre-installed.
Using this plugin: https://github.com/aliyun/aliyun-log-grafana-datasource-plugin/blob/master/README_EN.md


## Quick Start

### Using Docker Compose (Recommended)

```bash
# Build and start the container
docker-compose up -d

# View logs
docker-compose logs -f

# Stop the container
docker-compose down
```

### Using Docker directly

```bash
# Build the image
docker build -t grafana-aliyun .

# Run the container
docker run -d \
  --name grafana-aliyun \
  -p 3000:3000 \
  grafana-aliyun

# View logs
docker logs grafana-aliyun

# Stop the container
docker stop grafana-aliyun
docker rm grafana-aliyun
```

## Access Grafana

1. Open your browser and navigate to `http://localhost:3000`
2. Login with default credentials:
   - Username: `admin`
   - Password: `admin`

## Configure Aliyun Log Service Data Source

1. Go to **Configuration** → **Data Sources**
2. Click **Add data source**
3. Search for **"Aliyun Log Service"** or **"log-service-datasource"**
4. Select **Aliyun Log Service**
5. Fill in your Aliyun credentials:
   - **Access Key ID**: Your Aliyun Access Key ID
   - **Access Key Secret**: Your Aliyun Access Key Secret
   - **Region**: Your Aliyun region (e.g., `cn-hangzhou`, `us-west-1`, `eu-central-1`)
   - **Project**: Your SLS project name
   - **Logstore**: Your SLS logstore name

## Files

- `Dockerfile`: Custom Grafana image with Aliyun plugin pre-installed
- `docker-compose.yml`: Docker Compose configuration for easy deployment
- `README.md`: This documentation file

## Troubleshooting

### Plugin Not Loading

1. Check if the plugin is installed:
   ```bash
   docker exec grafana-aliyun ls -la /var/lib/grafana/plugins/
   ```

2. Check Grafana logs:
   ```bash
   docker logs grafana-aliyun | grep -i "aliyun\|plugin"
   ```

3. Ensure the environment variable is set:
   ```bash
   docker exec grafana-aliyun env | grep PLUGINS_ALLOW_LOADING_UNSIGNED_PLUGINS
   ```

### Authentication Issues

1. Verify your Access Key ID and Secret are correct
2. Check if your Access Key has the necessary permissions:
   - `AliyunLogReadOnlyAccess`
   - `AliyunRAMReadOnlyAccess` (if using STS)

## Data Persistence

The Docker Compose configuration includes a named volume `grafana-storage` to persist Grafana data, including:
- Dashboards
- Data sources
- User preferences
- Plugin configurations

This ensures your configurations persist across container restarts.
