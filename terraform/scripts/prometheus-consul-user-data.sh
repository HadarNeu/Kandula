sudo apt update && apt upgrade
sudo apt install -y nginx
sudo systemctl enable nginx.service
sudo systemctl start nginx.service
sudo systemctl status nginx.service
sudo groupadd prometheus
sudo useradd -s /sbin/nologin --system -g prometheus prometheus
sudo mkdir /var/lib/prometheus
for i in rules rules.d files_sd; do sudo mkdir -p /etc/prometheus/${i}; done
sudo apt install curl
mkdir -p /tmp/prometheus
cd /tmp/prometheus
sudo wget https://github.com/prometheus/prometheus/releases/download/v2.44.0/prometheus-2.44.0.linux-amd64.tar.gz
tar xvf prometheus*.tar.gz
cd /tmp/prometheus/prometheus-2.44.0.linux-amd64
sudo mv prometheus promtool /usr/local/bin/
sudo mv prometheus.yml /etc/prometheus/prometheus.yml
sudo mv consoles/ console_libraries/ /etc/prometheus/
cat /etc/prometheus/prometheus.yml
#now you configure prometheus
