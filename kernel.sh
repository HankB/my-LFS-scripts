
### 8.3.1. Installation of the kernel

# Note: Following need not be repeated - kernel source is not deleted.
tar xf linux-4.9.9.tar.xz 
cd linux-4.9.9

make mrproper

make defconfig

# Following could be 'make xconfig' with the proper environment
make menuconfig

time make

make modules_install

cp -v arch/x86/boot/bzImage /boot/vmlinuz-4.9.9-lfs-8.0
cp -v System.map /boot/System.map-4.9.9
cp -v .config /boot/config-4.9.9

install -d /usr/share/doc/linux-4.9.9
cp -r Documentation/* /usr/share/doc/linux-4.9.9

install -v -m755 -d /etc/modprobe.d
cat > /etc/modprobe.d/usb.conf << "EOF"
# Begin /etc/modprobe.d/usb.conf

install ohci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i ohci_hcd ; true
install uhci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i uhci_hcd ; true

# End /etc/modprobe.d/usb.conf
EOF

### 8.4. Using GRUB to Set Up the Boot Process

cd /tmp 
grub-mkrescue --output=grub-img.iso # doesn't seem to work

grub-install /dev/sda # Reported warnings and didn;t seem to work

cat > /boot/grub/grub.cfg << "EOF"
# Begin /boot/grub/grub.cfg
set default=0
set timeout=5

insmod ext2
set root=(hd0,2)

menuentry "GNU/Linux, Linux 4.9.9-lfs-8.0" {
        linux   /boot/vmlinuz-4.9.9-lfs-8.0 root=/dev/sda2 ro
}
EOF

