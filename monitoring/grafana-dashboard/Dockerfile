FROM grafana/grafana:latest
COPY dashboard.yml /etc/grafana/provisioning/dashboards
COPY datasource.yml /etc/grafana/provisioning/datasources
COPY cdc-dashboard.json /var/lib/grafana/dashboards/cdc-dashboard.json