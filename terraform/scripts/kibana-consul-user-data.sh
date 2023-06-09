# kibana
wget https://artifacts.elastic.co/downloads/kibana/kibana-oss-7.10.2-amd64.deb
sudo dpkg -i kibana-*.deb
echo 'server.host: "0.0.0.0"' > /etc/kibana/kibana.yml
sudo systemctl enable kibana
sudo systemctl start kibana
