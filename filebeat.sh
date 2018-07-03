#!/bin/bash

curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-5.0.0-x86_64.rpm
sudo rpm -vi filebeat-5.0.0-x86_64.rpm

sudo mkdir -p /var/log/dcos

sudo mv /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.yml.BAK

sudo tee /etc/filebeat/filebeat.yml<<-EOF
filebeat.prospectors:
- input_type: log
  paths:
    - /var/lib/mesos/slave/slaves/*/frameworks/*/executors/*/runs/latest/stdout*
    - /var/lib/mesos/slave/slaves/*/frameworks/*/executors/*/runs/latest/stderr*
    - /var/log/mesos/*.log
    - /var/log/dcos/dcos.log
exclude_files: ["stdout.logrotate.state", "stdout.logrotate.conf", "stderr.logrotate.state", "stderr.logrotate.conf"]
tail_files: true
output.elasticsearch:
  hosts: ["master.elastic.l4lb.thisdcos.directory:9200"]
EOF

sudo tee /etc/systemd/system/dcos-journalctl-filebeat.service<<-EOF
[Unit]
Description=DCOS journalctl parser to filebeat
Wants=filebeat.service
After=filebeat.service

[Service]
Restart=always
RestartSec=5
ExecStart=/bin/sh -c '/usr/bin/journalctl --since="5 minutes ago" --no-tail --follow --unit="dcos*.service" >> /var/log/dcos/dcos.log 2>&1'

[Install]
WantedBy=multi-user.target
EOF

sudo chmod 0755 /etc/systemd/system/dcos-journalctl-filebeat.service
sudo systemctl daemon-reload
sudo systemctl start dcos-journalctl-filebeat.service
sudo systemctl enable dcos-journalctl-filebeat.service
sudo systemctl start filebeat
sudo systemctl enable filebeat
