#! /bin/bash
	sudo apt update
	sudo apt-get install ca-certificates curl gnupg
	sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs)  stable"
	sudo apt update
	sudo apt-get install docker-ce
	sudo systemctl start docker
	sudo systemctl enable docker
	sudo groupadd docker
	sudo usermod -aG docker ubuntu
	docker pull yehonatan111/appserver
	sleep 15 # Give the container some time to pull
	docker run -d -p 3001:3001 yehonatan111/appserver
	sleep 5 # Give the container some time to start up
	
