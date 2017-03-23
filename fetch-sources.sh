#!/bin/bash

# Create the source directory and fetch all of the sources  Chapter 3
# http://www.linuxfromscratch.org/lfs/view/stable/chapter03/introduction.html

# set LFS env variable
source set-LFS.sh
# todo - make certain not blank

# Make certain that #LFS exists
if ! mountpoint $LFS >/dev/null
then
  echo $LFS is not mounted
  exit
fi 

# set some perms
sudo mkdir -v $LFS/sources
sudo chmod -v a+wt $LFS/sources

# populate .../sources
cd $LFS/sources
wget http://www.linuxfromscratch.org/lfs/view/stable/wget-list

wget --input-file=wget-list --continue --directory-prefix=$LFS/sources

wget http://www.linuxfromscratch.org/lfs/view/stable/md5sums
md5sum -c md5sums


