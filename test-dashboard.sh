#!/bin/bash

# Test script for CDN Logs Dashboard
# This script verifies that the dashboard setup is working correctly

set -e

echo "🧪 Testing CDN Logs Dashboard Setup..."

# Check if Grafana is running
if ! docker ps | grep -q grafana-aliyun; then
    echo "❌ Grafana container is not running"
    echo "   Please start it first: docker-compose up -d"
    exit 1
fi

echo "✅ Grafana container is running"

# Check if Grafana is accessible
echo "🔍 Testing Grafana connectivity..."
if curl -s http://localhost:3000/api/health > /dev/null; then
    echo "✅ Grafana is accessible at http://localhost:3000"
else
    echo "❌ Grafana is not accessible"
    echo "   Please check if the container is running properly"
    exit 1
fi

# Check if dashboards exist
echo "📊 Checking dashboard files..."
if [ -f "dashboards/cdn-logs-dashboard.json" ]; then
    echo "✅ Basic dashboard file exists"
else
    echo "❌ Basic dashboard file not found"
    exit 1
fi

if [ -f "dashboards/advanced-cdn-logs-dashboard.json" ]; then
    echo "✅ Advanced dashboard file exists"
else
    echo "❌ Advanced dashboard file not found"
    exit 1
fi

# Test dashboard JSON validity
echo "🔍 Validating dashboard JSON..."
if python3 -m json.tool dashboards/cdn-logs-dashboard.json > /dev/null 2>&1; then
    echo "✅ Basic dashboard JSON is valid"
else
    echo "❌ Basic dashboard JSON is invalid"
    exit 1
fi

if python3 -m json.tool dashboards/advanced-cdn-logs-dashboard.json > /dev/null 2>&1; then
    echo "✅ Advanced dashboard JSON is valid"
else
    echo "❌ Advanced dashboard JSON is invalid"
    exit 1
fi

# Test API endpoints
echo "🌐 Testing Grafana API endpoints..."

# Test authentication
if curl -s -u admin:admin http://localhost:3000/api/org > /dev/null; then
    echo "✅ Grafana authentication working"
else
    echo "❌ Grafana authentication failed"
    echo "   Default credentials should be admin/admin"
fi

# Test data sources endpoint
if curl -s -u admin:admin http://localhost:3000/api/datasources > /dev/null; then
    echo "✅ Data sources API accessible"
else
    echo "❌ Data sources API not accessible"
fi

# Test dashboards endpoint
if curl -s -u admin:admin http://localhost:3000/api/search?type=dash-db > /dev/null; then
    echo "✅ Dashboards API accessible"
else
    echo "❌ Dashboards API not accessible"
fi

echo ""
echo "🎉 Dashboard setup test completed!"
echo ""
echo "📋 Next steps:"
echo "1. Configure your Aliyun Log Service data source"
echo "2. Import the dashboards using the setup script"
echo "3. Test the filtering functionality"
echo ""
echo "🔗 Access Grafana at: http://localhost:3000"
echo "👤 Login: admin / admin"
echo ""
echo "📊 Available dashboards:"
echo "   • CDN Logs Query Dashboard (Basic)"
echo "   • Advanced CDN Logs Query Dashboard (With charts)"
echo ""
echo "💡 Dashboard features:"
echo "   • Filter by Channel Name (from URL pattern)"
echo "   • Filter by Client IP"
echo "   • Filter by Status Codes (200-503)"
echo "   • Table view with color-coded status codes"
echo "   • Time series and pie charts (Advanced dashboard)"

