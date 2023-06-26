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
DNS=127.0.0.1
Domains=~consul
EOF

echo "Updating /etc/resolv.conf ..."
tee /etc/resolv.conf > /dev/null <<EOF
[Resolve]
DNS=127.0.0.1
Domains=~consul
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
node_name = "elastic-$INSTANCE_ID-kandula"
check = {
  id = "kibana"
  name = "http access to kibana on port 9200"
  tcp = "localhost:9200"
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
# Elasticsearch Setup
# ------------------------------------

curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
sudo apt update
sudo apt -y install elasticsearch

tee /etc/elasticsearch/elasticsearch.yml > /dev/null <<EOF
path.data: /var/lib/elasticsearch
path.logs: /var/log/elasticsearch
# network.host: kibana.service.consul DIDNT WORK - error- failed to bind
network.host: 0.0.0.0
# By default Elasticsearch listens for HTTP traffic on the first free port it
# finds starting at 9200. Set a specific HTTP port here:
http.port: 9200
discovery.seed_hosts: ["127.0.0.1", "[::1]"]
cluster.initial_master_nodes: ["node-1"]
EOF


sudo systemctl start elasticsearch
sudo systemctl enable elasticsearch



# ------------------------------------
# Node Exporter
# ------------------------------------

node_exporter_ver="0.18.0"

wget \
  https://github.com/prometheus/node_exporter/releases/download/v$node_exporter_ver/node_exporter-$node_exporter_ver.linux-amd64.tar.gz \
  -O /tmp/node_exporter-$node_exporter_ver.linux-amd64.tar.gz

tar zxvf /tmp/node_exporter-$node_exporter_ver.linux-amd64.tar.gz

sudo cp ./node_exporter-$node_exporter_ver.linux-amd64/node_exporter /usr/local/bin

sudo useradd --no-create-home --shell /bin/false node_exporter

sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

sudo mkdir -p /var/lib/node_exporter/textfile_collector
sudo chown node_exporter:node_exporter /var/lib/node_exporter
sudo chown node_exporter:node_exporter /var/lib/node_exporter/textfile_collector

sudo tee /etc/systemd/system/node_exporter.service &>/dev/null << EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter --collector.textfile.directory /var/lib/node_exporter/textfile_collector \
 --no-collector.infiniband

[Install]
WantedBy=multi-user.target
EOF

rm -rf /tmp/node_exporter-$node_exporter_ver.linux-amd64.tar.gz \
  ./node_exporter-$node_exporter_ver.linux-amd64

sudo systemctl daemon-reload
systemctl status --no-pager node_exporter
sudo systemctl enable node_exporter
sudo systemctl start node_exporter

sudo systemctl enable consul.service
sudo systemctl restart consul.service
echo "Restarting systemd-resolved service ..."
systemctl restart systemd-resolved


consul services register -name elastic -port 9200

sudo iptables --table nat --append OUTPUT --destination localhost --protocol udp --match udp --dport 53 --jump REDIRECT --to-ports 8600
sudo iptables --table nat --append OUTPUT --destination localhost --protocol tcp --match tcp --dport 53 --jump REDIRECT --to-ports 8600