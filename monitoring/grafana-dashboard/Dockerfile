FROM grafana/grafana:latest
COPY dashboard.yml /etc/grafana/provisioning/dashboards
COPY datasource.yml /etc/grafana/provisioning/datasources
COPY cdc-health.json /var/lib/grafana/dashboards/cdc-health.json
COPY monitoring-cdc-operations.json /var/lib/grafana/dashboards/monitoring-cdc-operations.json
COPY performance-evaluation.json /var/lib/grafana/dashboards/performance-evaluation.json
COPY snapshotmode.json /var/lib/grafana/dashboards/snapshotmode.json
