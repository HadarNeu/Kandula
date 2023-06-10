# td-agent 4
curl -fsSL https://toolbelt.treasuredata.com/sh/install-ubuntu-focal-td-agent4.sh | sh
sudo systemctl start td-agent.service
sudo systemctl status td-agent.service