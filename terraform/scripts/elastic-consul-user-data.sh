# elasticsearch
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-oss-7.10.2-amd64.deb
dpkg -i elasticsearch-*.deb
systemctl enable elasticsearch
systemctl start elasticsearch
