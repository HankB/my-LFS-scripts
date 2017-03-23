### 6.71. About Debugging Symbols (NOP)
### 6.72. Stripping Again

logout

export LFS=/mnt/lfs

chroot $LFS /tools/bin/env -i            \
    HOME=/root TERM=$TERM PS1='\u:\w\$ ' \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin   \
    /tools/bin/bash --login

/tools/bin/find /usr/lib -type f -name \*.a \
   -exec /tools/bin/strip --strip-debug {} ';'

/tools/bin/find /lib /usr/lib -type f -name \*.so* \
   -exec /tools/bin/strip --strip-unneeded {} ';'

/tools/bin/find /{bin,sbin} /usr/{bin,sbin,libexec} -type f \
    -exec /tools/bin/strip --strip-all {} ';'

### 6.73. Cleaning Up

rm -rf /tmp/*

logout

chroot "$LFS" /usr/bin/env -i              \
    HOME=/root TERM="$TERM" PS1='\u:\w\$ ' \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin     \
    /bin/bash --login

rm -f /usr/lib/lib{bfd,opcodes}.a
rm -f /usr/lib/libbz2.a
rm -f /usr/lib/lib{com_err,e2p,ext2fs,ss}.a
rm -f /usr/lib/libltdl.a
rm -f /usr/lib/libfl.a
rm -f /usr/lib/libfl_pic.a
rm -f /usr/lib/libz.a

### 7.2. LFS-Bootscripts-20150222

cd sources
tar xf lfs-bootscripts-20150222.tar.bz2 
cd lfs-bootscripts-20150222

make install

cd ..
rm -rf lfs-bootscripts-20150222

### 7.4.1.2. Creating Custom Udev Rules

bash /lib/udev/init-net-rules.sh

# cat /etc/udev/rules.d/70-persistent-net.rules
less /etc/udev/rules.d/70-persistent-net.rules

### 7.4.2. CD-ROM symlinks

# udevadm test /sys/block/hdd
udevadm test /sys/block/sda
udevadm test /sys/block/sr0

### 7.5.1. Creating Network Interface Configuration Files

cd /etc/sysconfig/
cat > ifconfig.enp0s25 << "EOF"
ONBOOT=yes
IFACE=enp0s25
SERVICE=ipv4-static
IP=192.168.1.33
GATEWAY=192.168.1.1
PREFIX=24
BROADCAST=192.168.1.255
EOF

### 7.5.2. Creating the /etc/resolv.conf File

cat > /etc/resolv.conf << "EOF"
# Begin /etc/resolv.conf

#domain <Your Domain Name>
search localdomain

nameserver 192.168.1.1
nameserver 2601:249:e00:b215:201:2eff:fe6f:f9f9

# End /etc/resolv.conf
EOF

### 7.5.3. Configuring the system hostname

echo "cypresslfs" > /etc/hostname

### 7.5.4. Customizing the /etc/hosts File

cat > /etc/hosts << "EOF"
# Begin /etc/hosts (network card version)
127.0.0.1	localhost
127.0.1.1	cypress

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

# End /etc/hosts (network card version)
EOF

### 7.6.2. Configuring Sysvinit

cat > /etc/inittab << "EOF"
# Begin /etc/inittab

id:3:initdefault:

si::sysinit:/etc/rc.d/init.d/rc S

l0:0:wait:/etc/rc.d/init.d/rc 0
l1:S1:wait:/etc/rc.d/init.d/rc 1
l2:2:wait:/etc/rc.d/init.d/rc 2
l3:3:wait:/etc/rc.d/init.d/rc 3
l4:4:wait:/etc/rc.d/init.d/rc 4
l5:5:wait:/etc/rc.d/init.d/rc 5
l6:6:wait:/etc/rc.d/init.d/rc 6

ca:12345:ctrlaltdel:/sbin/shutdown -t1 -a -r now

su:S016:once:/sbin/sulogin

1:2345:respawn:/sbin/agetty --noclear tty1 9600
2:2345:respawn:/sbin/agetty tty2 9600
3:2345:respawn:/sbin/agetty tty3 9600
4:2345:respawn:/sbin/agetty tty4 9600
5:2345:respawn:/sbin/agetty tty5 9600
6:2345:respawn:/sbin/agetty tty6 9600

# End /etc/inittab
EOF

### 7.6.4. Configuring the System Clock

cat > /etc/sysconfig/clock << "EOF"
# Begin /etc/sysconfig/clock

UTC=1

# Set this to any options you might need to give to hwclock,
# such as machine hardware clock type for Alphas.
CLOCKPARAMS=

# End /etc/sysconfig/clock
EOF

### 7.6.5. Configuring the Linux Console

cat > /etc/sysconfig/console << "EOF"
# Begin /etc/sysconfig/console

KEYMAP="pl2"
FONT="lat2a-16 -m 8859-2"

# End /etc/sysconfig/console
EOF

### 7.7. The Bash Shell Startup Files

cat > /etc/profile << "EOF"
# Begin /etc/profile

export LANG=en_US.iso88591

# End /etc/profile
EOF

### 7.8. Creating the /etc/inputrc File

cat > /etc/inputrc << "EOF"
# Begin /etc/inputrc
# Modified by Chris Lynn <roryo@roryo.dynup.net>

# Allow the command prompt to wrap to the next line
set horizontal-scroll-mode Off

# Enable 8bit input
set meta-flag On
set input-meta On

# Turns off 8th bit stripping
set convert-meta Off

# Keep the 8th bit for display
set output-meta On

# none, visible or audible
set bell-style none

# All of the following map the escape sequence of the value
# contained in the 1st argument to the readline specific functions
"\eOd": backward-word
"\eOc": forward-word

# for linux console
"\e[1~": beginning-of-line
"\e[4~": end-of-line
"\e[5~": beginning-of-history
"\e[6~": end-of-history
"\e[3~": delete-char
"\e[2~": quoted-insert

# for xterm
"\eOH": beginning-of-line
"\eOF": end-of-line

# for Konsole
"\e[H": beginning-of-line
"\e[F": end-of-line

# End /etc/inputrc
EOF

### 7.9. Creating the /etc/shells File

cat > /etc/shells << "EOF"
# Begin /etc/shells

/bin/sh
/bin/bash

# End /etc/shells
EOF

### 8.2. Creating the /etc/fstab File

cat > /etc/fstab << "EOF"
# Begin /etc/fstab

# file system  mount-point  type     options             dump  fsck
#                                                              order

/dev/sda6     /            ext4    defaults,noatime,nodiratime,discard,errors=remount-ro,data=ordered            1     1
/dev/sda4     swap         swap     pri=1               0     0
proc           /proc        proc     nosuid,noexec,nodev 0     0
sysfs          /sys         sysfs    nosuid,noexec,nodev 0     0
devpts         /dev/pts     devpts   gid=5,mode=620      0     0
tmpfs          /run         tmpfs    defaults            0     0
devtmpfs       /dev         devtmpfs mode=0755,nosuid    0     0

# End /etc/fstab
EOF
