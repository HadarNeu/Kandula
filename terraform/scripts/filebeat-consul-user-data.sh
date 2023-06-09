# filebeat
curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-8.8.1-linux-x86_64.tar.gz
tar xzvf filebeat-8.8.1-linux-x86_64.tar.gz

: '
sudo cat <<\EOF > /etc/filebeat/filebeat.yml
filebeat.inputs:
  - type: log
    enabled: false
    paths:
      - /var/log/auth.log

filebeat.modules:
  - module: system
    syslog:
      enabled: false
    auth:
      enabled: false

filebeat.config.modules:
  path: ${path.config}/modules.d/*.yml
  reload.enabled: false

setup.dashboards.enabled: false

setup.template.name: "filebeat"
setup.template.pattern: "filebeat-*"
setup.template.settings:
  index.number_of_shards: 1

processors:
  - add_host_metadata:
      when.not.contains.tags: forwarded
  - add_cloud_metadata: ~

output.elasticsearch:
  hosts: [ "localhost:9200" ]
  index: "filebeat-%{[agent.version]}-%{+yyyy.MM.dd}"
## OR
#output.logstash:
#  hosts: [ "127.0.0.1:5044" ]
EOF
'
echo "INFO: userdata finished"
