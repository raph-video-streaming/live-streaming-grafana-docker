#!/bin/bash

# Grafana with Aliyun Log Service Plugin Startup Script

set -e

echo "🚀 Starting Grafana with Aliyun Log Service Plugin..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "❌ docker-compose is not installed. Please install docker-compose and try again."
    exit 1
fi

# Function to start with docker-compose
start_with_compose() {
    echo "📦 Building and starting Grafana with docker-compose..."
    docker-compose up -d --build
    
    if [ $? -eq 0 ]; then
        echo "✅ Grafana started successfully!"
        echo "🌐 Access Grafana at: http://localhost:3000"
        echo "👤 Default credentials: admin / admin"
        echo ""
        echo "📊 To configure Aliyun Log Service:"
        echo "   1. Go to Configuration → Data Sources"
        echo "   2. Add 'Aliyun Log Service' data source"
        echo "   3. Enter your Aliyun credentials"
        echo ""
        echo "📋 Useful commands:"
        echo "   View logs: docker-compose logs -f"
        echo "   Stop: docker-compose down"
        echo "   Restart: docker-compose restart"
    else
        echo "❌ Failed to start Grafana"
        exit 1
    fi
}

# Function to start with Docker directly
start_with_docker() {
    echo "📦 Building Grafana image..."
    docker build -t grafana-aliyun .
    
    if [ $? -ne 0 ]; then
        echo "❌ Failed to build Docker image"
        exit 1
    fi
    
    echo "🐳 Starting Grafana container..."
    docker run -d \
        --name grafana-aliyun \
        -p 3000:3000 \
        -e "GF_PLUGINS_ALLOW_LOADING_UNSIGNED_PLUGINS=aliyun-log-service-datasource" \
        grafana-aliyun
    
    if [ $? -eq 0 ]; then
        echo "✅ Grafana started successfully!"
        echo "🌐 Access Grafana at: http://localhost:3000"
        echo "👤 Default credentials: admin / admin"
        echo ""
        echo "📊 To configure Aliyun Log Service:"
        echo "   1. Go to Configuration → Data Sources"
        echo "   2. Add 'Aliyun Log Service' data source"
        echo "   3. Enter your Aliyun credentials"
        echo ""
        echo "📋 Useful commands:"
        echo "   View logs: docker logs grafana-aliyun"
        echo "   Stop: docker stop grafana-aliyun"
        echo "   Remove: docker rm grafana-aliyun"
    else
        echo "❌ Failed to start Grafana container"
        exit 1
    fi
}

# Function to stop services
stop_services() {
    echo "🛑 Stopping Grafana services..."
    
    # Try docker-compose first
    if [ -f "docker-compose.yml" ]; then
        docker-compose down 2>/dev/null || true
    fi
    
    # Stop Docker container if running
    docker stop grafana-aliyun 2>/dev/null || true
    docker rm grafana-aliyun 2>/dev/null || true
    
    echo "✅ Services stopped"
}

# Function to show status
show_status() {
    echo "📊 Grafana Status:"
    echo ""
    
    # Check docker-compose services
    if [ -f "docker-compose.yml" ]; then
        echo "Docker Compose Services:"
        docker-compose ps
        echo ""
    fi
    
    # Check Docker containers
    echo "Docker Containers:"
    docker ps --filter "name=grafana-aliyun" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    echo ""
}

# Function to show logs
show_logs() {
    echo "📋 Grafana Logs:"
    echo ""
    
    # Try docker-compose first
    if [ -f "docker-compose.yml" ]; then
        docker-compose logs -f --tail=50
    else
        docker logs grafana-aliyun -f --tail=50
    fi
}

# Main script logic
case "${1:-start}" in
    "start")
        if [ -f "docker-compose.yml" ]; then
            start_with_compose
        else
            start_with_docker
        fi
        ;;
    "stop")
        stop_services
        ;;
    "restart")
        stop_services
        sleep 2
        if [ -f "docker-compose.yml" ]; then
            start_with_compose
        else
            start_with_docker
        fi
        ;;
    "status")
        show_status
        ;;
    "logs")
        show_logs
        ;;
    "help"|"-h"|"--help")
        echo "Grafana with Aliyun Log Service Plugin"
        echo ""
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  start    Start Grafana (default)"
        echo "  stop     Stop Grafana"
        echo "  restart  Restart Grafana"
        echo "  status   Show status"
        echo "  logs     Show logs"
        echo "  help     Show this help"
        echo ""
        echo "Examples:"
        echo "  $0 start    # Start Grafana"
        echo "  $0 stop     # Stop Grafana"
        echo "  $0 logs     # View logs"
        ;;
    *)
        echo "❌ Unknown command: $1"
        echo "Run '$0 help' for usage information"
        exit 1
        ;;
esac
