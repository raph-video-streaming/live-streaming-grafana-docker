#!/bin/bash

# Setup script for CDN Logs Dashboard
# This script helps configure Grafana with the CDN logs dashboard

set -e

echo "🚀 Setting up CDN Logs Dashboard for Grafana..."

# Create dashboards directory if it doesn't exist
mkdir -p /home/raf/GITHUB/live-streaming-grafana-docker/dashboards

# Check if Grafana is running
if ! docker ps | grep -q grafana-aliyun; then
    echo "❌ Grafana container is not running. Please start it first:"
    echo "   cd /home/raf/GITHUB/live-streaming-grafana-docker"
    echo "   docker-compose up -d"
    exit 1
fi

echo "✅ Grafana container is running"

# Wait for Grafana to be ready
echo "⏳ Waiting for Grafana to be ready..."
sleep 10

# Check if Grafana is accessible
if ! curl -s http://localhost:3000/api/health > /dev/null; then
    echo "❌ Grafana is not accessible at http://localhost:3000"
    echo "   Please check if the container is running properly"
    exit 1
fi

echo "✅ Grafana is accessible"

# Create a script to import dashboards via API
cat > /tmp/import-dashboard.sh << 'EOF'
#!/bin/bash

# Import dashboard using Grafana API
DASHBOARD_FILE="$1"
DASHBOARD_NAME="$2"

if [ -z "$DASHBOARD_FILE" ] || [ -z "$DASHBOARD_NAME" ]; then
    echo "Usage: $0 <dashboard-file> <dashboard-name>"
    exit 1
fi

# Check if dashboard file exists
if [ ! -f "$DASHBOARD_FILE" ]; then
    echo "❌ Dashboard file not found: $DASHBOARD_FILE"
    exit 1
fi

echo "📊 Importing dashboard: $DASHBOARD_NAME"

# Import dashboard
curl -X POST \
  -H "Content-Type: application/json" \
  -d @"$DASHBOARD_FILE" \
  http://admin:admin@localhost:3000/api/dashboards/db

echo ""
echo "✅ Dashboard imported successfully!"
echo "🌐 Access your dashboard at: http://localhost:3000"
EOF

chmod +x /tmp/import-dashboard.sh

echo "📊 Importing dashboards..."

# Import basic dashboard
if [ -f "/home/raf/GITHUB/live-streaming-grafana-docker/dashboards/cdn-logs-dashboard.json" ]; then
    /tmp/import-dashboard.sh "/home/raf/GITHUB/live-streaming-grafana-docker/dashboards/cdn-logs-dashboard.json" "CDN Logs Query Dashboard"
else
    echo "⚠️  Basic dashboard file not found"
fi

# Import advanced dashboard
if [ -f "/home/raf/GITHUB/live-streaming-grafana-docker/dashboards/advanced-cdn-logs-dashboard.json" ]; then
    /tmp/import-dashboard.sh "/home/raf/GITHUB/live-streaming-grafana-docker/dashboards/advanced-cdn-logs-dashboard.json" "Advanced CDN Logs Query Dashboard"
else
    echo "⚠️  Advanced dashboard file not found"
fi

# Clean up
rm -f /tmp/import-dashboard.sh

echo ""
echo "🎉 Setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Go to http://localhost:3000"
echo "2. Login with admin/admin"
echo "3. Configure your Aliyun Log Service data source:"
echo "   - Go to Configuration → Data Sources"
echo "   - Add 'Aliyun Log Service' data source"
echo "   - Enter your credentials:"
echo "     * Access Key ID: [your-access-key]"
echo "     * Access Key Secret: [your-secret-key]"
echo "     * Region: [your-region]"
echo "     * Project: [your-project-name]"
echo "     * Logstore: [your-logstore-name]"
echo "4. Open the 'CDN Logs Query Dashboard' or 'Advanced CDN Logs Query Dashboard'"
echo "5. Configure the variables (Channel Name, Client IP, Status Codes)"
echo ""
echo "🔧 Dashboard Features:"
echo "   • Filter by Channel Name (extracted from URL pattern)"
echo "   • Filter by Client IP"
echo "   • Filter by HTTP Status Codes (200-503)"
echo "   • Table view with all log details"
echo "   • Time series charts (Advanced dashboard)"
echo "   • Status code distribution pie chart (Advanced dashboard)"
echo ""
echo "💡 Query Logic:"
echo "   • Channel Name: Extracts from URL pattern https://hostname/TOKEN/live/CHANNEL_NAME/..."
echo "   • Client IP: Exact match with client_ip field"
echo "   • Status Codes: Multiple selection from predefined list"
echo ""

