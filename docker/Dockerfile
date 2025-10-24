# Grafana with Aliyun Log Service Plugin
FROM grafana/grafana:latest

# Set environment variables for plugin loading
ENV GF_PLUGINS_ALLOW_LOADING_UNSIGNED_PLUGINS=aliyun-log-service-datasource
ENV GF_INSTALL_PLUGINS=https://github.com/aliyun/aliyun-log-grafana-datasource-plugin/archive/refs/heads/master.zip;aliyun-log-datasource

# Switch to root to install dependencies
USER root

# Install wget and unzip for plugin installation
RUN apk add --no-cache wget unzip

# Create plugins directory and set permissions
RUN mkdir -p /var/lib/grafana/plugins && \
    chown -R grafana:grafana /var/lib/grafana/plugins

# Switch back to grafana user
USER grafana

# The plugin will be installed automatically via GF_INSTALL_PLUGINS environment variable

# Expose Grafana port
EXPOSE 3000

# Set default user
USER grafana

# Start Grafana
CMD ["grafana-server", "--config=/etc/grafana/grafana.ini", "--homepath=/usr/share/grafana"]
