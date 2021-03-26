#!/bin/bash

if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

echo Installing Docker Repositories.

apt-get update
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release cifs-utils

file=/usr/share/keyrings/docker-archive-keyring.gpg
if [ -f "$file" ]; then
	echo "Docker GPG key already exists."
else
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o $file
fi

file=/etc/apt/sources.list.d/docker.list

if [ -f "$file" ]; then
	echo "Repository entry already exists."
else
	echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
	  $(lsb_release -cs) stable" | sudo tee $file > /dev/null
fi
  
echo Installing Docker engine.

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

echo Setting up Local Registry.

file=/etc/docker/share-credentials
if [ ! -f "$file" ]; then
	echo
	echo Enter credentials for registry share.
	read -p Username: user
	read -s -p Password: pwd

	touch $file
	chmod 600 $file
		
	echo "username=$user" >> $file
	echo "password=$pwd" >> $file

fi

mnt=/mnt/docker-registry
cred=/etc/docker/share-credentials
entry="//192.168.1.201/docker	$mnt	cifs	credentials=$cred	0	0 "

if ! grep -q "Docker-Registry" "/etc/fstab"
then
	mkdir $mnt
    echo "#Docker-Registry" >> /etc/fstab
    echo "$entry" >> /etc/fstab
else
    echo "Entry in fstab exists."
fi
mount -a

docker run -p 5000:5000 --restart=always --name registry -v $mnt/docker-registry:/var/lib/registry --detach registry serve /var/lib/registry/config.yml

file=/etc/docker/daemon.json
if [ ! -f "$file" ]; then
	printf '{\n  "registry-mirrors": ["http://localhost:5000"]\n}\n' > /etc/docker/daemon.json
fi

service docker restart





