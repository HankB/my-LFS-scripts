#!/bin/bash

# set LFS env variable
source set-LFS.sh
# todo - make certain not blank

### 4.2. Creating the $LFS/tools Directory

if [ ! -d $LFS/tools ]
then
	sudo mkdir -v $LFS/tools
	sudo ln -sv $LFS/tools /
else
	echo $LFS/tools exists
fi

### 4.3. Adding the LFS User
if ! getent passwd lfs >/dev/null
then
	sudo groupadd lfs
	sudo useradd -s /bin/bash -g lfs -m -k /dev/null lfs

	echo enter password for user lfs
	sudo passwd lfs

	sudo chown -v lfs $LFS/tools

	sudo chown -v lfs $LFS/sources

	su - lfs -c /home/hbarta/bin/final-prep-as-lfs.sh

else

	echo lfs user already exists
fi

# custom - create the $LFS/completed Directory
sudo mkdir $LFS/completed
sudo chown -v lfs $LFS/completed
