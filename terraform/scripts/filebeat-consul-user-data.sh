#!/usr/bin/env bash
export AWS_REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
export AWS_AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
export INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
export INSTANCE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
export INSTANCE_TAG_NAME=$(curl -s http://169.254.169.254/latest/meta-data/tags/instance/Name)
export INSTANCE_TAG_NAME_SUFFIX=$RANDOM
echo "Changing Name tag ..."
aws ec2 --region "$AWS_REGION" create-tags --resources "$INSTANCE_ID" --tags Key=Name,Value="$INSTANCE_TAG_NAME"-"$INSTANCE_TAG_NAME_SUFFIX"
echo "Changing hostname ..."
sudo hostnamectl set-hostname "$INSTANCE_TAG_NAME"-"$INSTANCE_TAG_NAME_SUFFIX"
# ------------------------------------
# Consul Setup
# ------------------------------------
echo "Adding consul_server tag ..."
aws ec2 create-tags --resources "$INSTANCE_ID" --region "$AWS_REGION" --tags Key=consul_server,Value=true


echo "Fetching Consul..."
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"


echo "Installing Consul..."
sudo apt-get update && sudo apt-get install consul


echo "Adding user consul ..."
useradd consul
mkdir -p /opt/consul /etc/consul.d /run/consul
chown -R consul:consul /opt/consul /etc/consul.d /run/consul


tee /etc/systemd/system/consul.service > /dev/null <<EOF
[Unit]
Description=Consul service discovery agent
Requires=network-online.target
After=network.target
[Service]
User=consul
Group=consul
PIDFile=/run/consul/consul.pid
Restart=on-failure
Environment=GOMAXPROCS=2
ExecStartPre=+/bin/mkdir -p /run/consul
ExecStartPre=+/bin/chown consul:consul /run/consul
ExecStart=/usr/bin/consul agent -pid-file=/run/consul/consul.pid -config-dir=/etc/consul.d
ExecReload=/bin/kill -s HUP $MAINPID
KillSignal=SIGINT
TimeoutStopSec=5
[Install]
WantedBy=multi-user.target
EOF


echo "Creating /etc/systemd/resolved.conf ..."
tee /etc/systemd/resolved.conf > /dev/null <<EOF
[Resolve]
DNS=127.0.0.1:8600
DNSSEC=false
Domains=~consul
FallbackDNS=10.250.0.2
EOF

echo "Updating /etc/resolv.conf ..."
tee /etc/resolv.conf > /dev/null <<EOF
nameserver 127.0.0.53
options edns0 trust-ad
EOF

echo "Creating /etc/consul.d/consul.hcl ..."
tee /etc/consul.d/consul.hcl > /dev/null <<EOF
advertise_addr = "$INSTANCE_IP"
data_dir = "/opt/consul"
datacenter = "dc-hadar-kandula"
encrypt = "uDBV4e+LbFW3019YKPxIrg=="
disable_remote_exec = true
disable_update_check = true
leave_on_terminate = true
enable_syslog = true
log_level = "info"
retry_join = ["provider=aws region=$AWS_REGION service=ec2 tag_key=consul tag_value=true"]
server = false
node_name = "filebeat-$INSTANCE_ID-kandula"
check = {
  id = "ssh"
  name = "SSH TCP on port 22"
  tcp = "localhost:22"
  interval = "10s"
  timeout = "1s"
}
EOF


echo "Enable & restart consul service ..."
sudo systemctl daemon-reload
sudo systemctl enable consul.service
sudo systemctl restart consul.service
echo "Restarting systemd-resolved service ..."
systemctl restart systemd-resolved


# ------------------------------------
# Filebeat Setup
# ------------------------------------


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
