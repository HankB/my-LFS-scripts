#!/bin/bash

#
# This is stuff that is generally only done once.
#
# Partitioning and creating the filesystem and adding mount point to /etc/fstab
# not included. I use 'gparted' which creates the partition and filesystem in one
# step.

# Update - to be safe, format the partition for LFS as described
# at http://www.linuxfromscratch.org/lfs/view/6.5/chapter02/creatingfilesystem.html


# set LFS (and other) env variables
source set-LFS.sh
# todo - make certain not blank


#
# create filesystme if $LFS is not mouinited
#
if ! mountpoint $LFS >/dev/null
then
	cd /tmp
	wget http://downloads.sourceforge.net/project/e2fsprogs/e2fsprogs/v1.43.4/e2fsprogs-1.43.4.tar.gz
	tar -xzvf e2fsprogs-1.43.4.tar.gz
	cd e2fsprogs-1.43.4
	mkdir -v build
	cd build
	../configure
	make -j4 #note that we intentionally don't 'make install' here!
	sudo ./misc/mke2fs -v -t ext4 $LFS_DEV
	cd /tmp
	rm -rfv e2fsprogs-1.43.4
	rm e2fsprogs-1.43.4.tar.gz
	echo
	echo "Now mount " $LFS " before proceeding"
else
	echo $LFS already mounted - skipping filesystem creation
fi

exit

# determine what 'sh' is linked to
SH=`file /bin/sh | awk '{print $5}'`

if [ $SH == 'dash' ]
then 
  echo sh is linked to dash - fixing
  sudo mv /bin/sh /bin/sh.dash # save the old one
  sudo ln -s /bin/bash /bin/sh 
else
  echo sh is linked to bash
fi

# install required packages (works for Debian Stretch)

sudo apt install -y binutils \
		bison \
		bzip2 \
		coreutils \
		diffutils \
		findutils \
		gawk \
		gcc \
		g++ \
		glibc-source \
		grep \
		gzip \
		m4 \
		make \
		patch \
		perl \
		sed \
		tar \
		texinfo \
		xz-utils

# check versions
cat > version-check.sh << "EOF"
#!/bin/bash
# Simple script to list version numbers of critical development tools
export LC_ALL=C
bash --version | head -n1 | cut -d" " -f2-4
MYSH=$(readlink -f /bin/sh)
echo "/bin/sh -> $MYSH"
echo $MYSH | grep -q bash || echo "ERROR: /bin/sh does not point to bash"
unset MYSH

echo -n "Binutils: "; ld --version | head -n1 | cut -d" " -f3-
bison --version | head -n1

if [ -h /usr/bin/yacc ]; then
  echo "/usr/bin/yacc -> `readlink -f /usr/bin/yacc`";
elif [ -x /usr/bin/yacc ]; then
  echo yacc is `/usr/bin/yacc --version | head -n1`
else
  echo "yacc not found" 
fi

bzip2 --version 2>&1 < /dev/null | head -n1 | cut -d" " -f1,6-
echo -n "Coreutils: "; chown --version | head -n1 | cut -d")" -f2
diff --version | head -n1
find --version | head -n1
gawk --version | head -n1

if [ -h /usr/bin/awk ]; then
  echo "/usr/bin/awk -> `readlink -f /usr/bin/awk`";
elif [ -x /usr/bin/awk ]; then
  echo awk is `/usr/bin/awk --version | head -n1`
else 
  echo "awk not found" 
fi

gcc --version | head -n1
g++ --version | head -n1
ldd --version | head -n1 | cut -d" " -f2-  # glibc version
grep --version | head -n1
gzip --version | head -n1
cat /proc/version
m4 --version | head -n1
make --version | head -n1
patch --version | head -n1
echo Perl `perl -V:version`
sed --version | head -n1
tar --version | head -n1
makeinfo --version | head -n1
xz --version | head -n1

echo 'int main(){}' > dummy.c && g++ -o dummy dummy.c
if [ -x dummy ]
  then echo "g++ compilation OK";
  else echo "g++ compilation failed"; fi
rm -f dummy.c dummy
EOF

bash version-check.sh

# library check

cat > library-check.sh << "EOF"
#!/bin/bash
for lib in lib{gmp,mpfr,mpc}.la; do
  echo $lib: $(if find /usr/lib* -name $lib|
               grep -q $lib;then :;else echo not;fi) found
done
unset lib
EOF

bash library-check.sh
echo should be all present or all not found

if [ ! -d $LFS ]
then
  echo $LFS does not exist
  exit
fi 

