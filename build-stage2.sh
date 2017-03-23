#!/bin/bash

# search for '##########################' for stuff to tailor

### 6.2. Preparing Virtual Kernel File Systems

mkdir -pv $LFS/{dev,proc,sys,run}
sudo -s
mknod -m 600 $LFS/dev/console c 5 1
mknod -m 666 $LFS/dev/null c 1 3

mount -v --bind /dev $LFS/dev

mount -vt devpts devpts $LFS/dev/pts -o gid=5,mode=620
mount -vt proc proc $LFS/proc
mount -vt sysfs sysfs $LFS/sys
mount -vt tmpfs tmpfs $LFS/run

if [ -h $LFS/dev/shm ]; then
  mkdir -pv $LFS/$(readlink $LFS/dev/shm)
fi

### 6.3. Package Management

# nothing to execute

### 6.4. Entering the Chroot Environment

chroot "$LFS" /tools/bin/env -i \
    HOME=/root                  \
    TERM="$TERM"                \
    PS1='\u:\w\$ '              \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin \
    /tools/bin/bash --login +h

### 6.5. Creating Directories

mkdir -pv /{bin,boot,etc/{opt,sysconfig},home,lib/firmware,mnt,opt}
mkdir -pv /{media/{floppy,cdrom},sbin,srv,var}
install -dv -m 0750 /root
install -dv -m 1777 /tmp /var/tmp
mkdir -pv /usr/{,local/}{bin,include,lib,sbin,src}
mkdir -pv /usr/{,local/}share/{color,dict,doc,info,locale,man}
mkdir -v  /usr/{,local/}share/{misc,terminfo,zoneinfo}
mkdir -v  /usr/libexec
mkdir -pv /usr/{,local/}share/man/man{1..8}

case $(uname -m) in
 x86_64) mkdir -v /lib64 ;;
esac

mkdir -v /var/{log,mail,spool}
ln -sv /run /var/run
ln -sv /run/lock /var/lock
mkdir -pv /var/{opt,cache,lib/{color,misc,locate},local}

### 6.6. Creating Essential Files and Symlinks

ln -sv /tools/bin/{bash,cat,echo,pwd,stty} /bin
ln -sv /tools/bin/perl /usr/bin
ln -sv /tools/lib/libgcc_s.so{,.1} /usr/lib
ln -sv /tools/lib/libstdc++.so{,.6} /usr/lib
sed 's/tools/usr/' /tools/lib/libstdc++.la > /usr/lib/libstdc++.la
ln -sv bash /bin/sh

ln -sv /proc/self/mounts /etc/mtab

cat > /etc/passwd << "EOF"
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/dev/null:/bin/false
daemon:x:6:6:Daemon User:/dev/null:/bin/false
messagebus:x:18:18:D-Bus Message Daemon User:/var/run/dbus:/bin/false
nobody:x:99:99:Unprivileged User:/dev/null:/bin/false
EOF

cat > /etc/group << "EOF"
root:x:0:
bin:x:1:daemon
sys:x:2:
kmem:x:3:
tape:x:4:
tty:x:5:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
usb:x:14:
cdrom:x:15:
adm:x:16:
messagebus:x:18:
systemd-journal:x:23:
input:x:24:
mail:x:34:
nogroup:x:99:
users:x:999:
EOF

exec /tools/bin/bash --login +h

touch /var/log/{btmp,lastlog,faillog,wtmp}
chgrp -v utmp /var/log/lastlog
chmod -v 664  /var/log/lastlog
chmod -v 600  /var/log/btmp


### 6.7. Linux-4.9.9 API Headers

cd sources

tar xf linux-4.9.9.tar.xz 
cd linux-4.9.9

make mrproper

make INSTALL_HDR_PATH=dest headers_install
find dest/include \( -name .install -o -name ..install.cmd \) -delete
cp -rv dest/include/* /usr/include

cd ..
rm -rf linux-4.9.9

### 6.8. Man-pages-4.09

tar xf man-pages-4.09.tar.xz 
cd man-pages-4.09

make install

cd ..
rm -rf man-pages-4.09

### 6.9. Glibc-2.25

tar xf glibc-2.25.tar.xz 
cd glibc-2.25

patch -Np1 -i ../glibc-2.25-fhs-1.patch

case $(uname -m) in
    x86) ln -s ld-linux.so.2 /lib/ld-lsb.so.3
    ;;
    x86_64) ln -s ../lib/ld-linux-x86-64.so.2 /lib64
            ln -s ../lib/ld-linux-x86-64.so.2 /lib64/ld-lsb-x86-64.so.3
    ;;
esac

mkdir -v build
cd       build

../configure --prefix=/usr                   \
             --enable-kernel=2.6.32          \
             --enable-obsolete-rpc           \
             --enable-stack-protector=strong \
             libc_cv_slibdir=/lib

make

make check

touch /etc/ld.so.conf

make install

cp -v ../nscd/nscd.conf /etc/nscd.conf
mkdir -pv /var/cache/nscd

mkdir -pv /usr/lib/locale
localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8
localedef -i de_DE -f ISO-8859-1 de_DE
localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro
localedef -i de_DE -f UTF-8 de_DE.UTF-8
localedef -i en_GB -f UTF-8 en_GB.UTF-8
localedef -i en_HK -f ISO-8859-1 en_HK
localedef -i en_PH -f ISO-8859-1 en_PH
localedef -i en_US -f ISO-8859-1 en_US
localedef -i en_US -f UTF-8 en_US.UTF-8
localedef -i es_MX -f ISO-8859-1 es_MX
localedef -i fa_IR -f UTF-8 fa_IR
localedef -i fr_FR -f ISO-8859-1 fr_FR
localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
localedef -i fr_FR -f UTF-8 fr_FR.UTF-8
localedef -i it_IT -f ISO-8859-1 it_IT
localedef -i it_IT -f UTF-8 it_IT.UTF-8
localedef -i ja_JP -f EUC-JP ja_JP
localedef -i ru_RU -f KOI8-R ru_RU.KOI8-R
localedef -i ru_RU -f UTF-8 ru_RU.UTF-8
localedef -i tr_TR -f UTF-8 tr_TR.UTF-8
localedef -i zh_CN -f GB18030 zh_CN.GB18030

cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf

passwd: files
group: files
shadow: files

hosts: files dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End /etc/nsswitch.conf
EOF

tar -xf ../../tzdata2016j.tar.gz

ZONEINFO=/usr/share/zoneinfo
mkdir -pv $ZONEINFO/{posix,right}

for tz in etcetera southamerica northamerica europe africa antarctica  \
          asia australasia backward pacificnew systemv; do
    zic -L /dev/null   -d $ZONEINFO       -y "sh yearistype.sh" ${tz}
    zic -L /dev/null   -d $ZONEINFO/posix -y "sh yearistype.sh" ${tz}
    zic -L leapseconds -d $ZONEINFO/right -y "sh yearistype.sh" ${tz}
done

cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
zic -d $ZONEINFO -p America/New_York
unset ZONEINFO


tzselect

########################## replace 'America/Chicago' with your result from the tzselect script 
cp -v /usr/share/zoneinfo/America/Chicago /etc/localtime

cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib

EOF


cat >> /etc/ld.so.conf << "EOF"
# Add an include directory
include /etc/ld.so.conf.d/*.conf

EOF
mkdir -pv /etc/ld.so.conf.d


cd ../..
rm -rf glibc-2.25

### 6.10. Adjusting the Toolchain
mv -v /tools/bin/{ld,ld-old}
mv -v /tools/$(uname -m)-pc-linux-gnu/bin/{ld,ld-old}
mv -v /tools/bin/{ld-new,ld}
ln -sv /tools/bin/ld /tools/$(uname -m)-pc-linux-gnu/bin/ld

gcc -dumpspecs | sed -e 's@/tools@@g'                   \
    -e '/\*startfile_prefix_spec:/{n;s@.*@/usr/lib/ @}' \
    -e '/\*cpp:/{n;s@$@ -isystem /usr/include@}' >      \
    `dirname $(gcc --print-libgcc-file-name)`/specs

echo 'int main(){}' > dummy.c
cc dummy.c -v -Wl,--verbose &> dummy.log
readelf -l a.out | grep ': /lib'

grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log

grep -B1 '^ /usr/include' dummy.log

grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'

grep "/lib.*/libc.so.6 " dummy.log

grep found dummy.log

rm -v dummy.c a.out dummy.log

### 6.11. Zlib-1.2.11

tar xf zlib-1.2.11.tar.xz 
cd zlib-1.2.11

./configure --prefix=/usr

make

make check

make install

mv -v /usr/lib/libz.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libz.so) /usr/lib/libz.so

cd ..  
rm -rf zlib-1.2.11

### 6.12. File-5.30

tar xf file-5.30.tar.gz 
cd file-5.30

./configure --prefix=/usr

make

make install

cd ..
rm -rf file-5.30

### 6.13. Binutils-2.27

expect -c "spawn ls"
# output should be "spawn ls" 

tar xf binutils-2.27.tar.bz2 
cd binutils-2.27


mkdir -v build
cd       build

../configure --prefix=/usr       \
             --enable-gold       \
             --enable-ld=default \
             --enable-plugins    \
             --enable-shared     \
             --disable-werror    \
             --with-system-zlib

make tooldir=/usr

make -k check

make tooldir=/usr install

cd ../..
rm -rf binutils-2.27

### 6.14. GMP-6.1.2

tar xf gmp-6.1.2.tar.xz 
cd gmp-6.1.2

./configure --prefix=/usr    \
            --enable-cxx     \
            --disable-static \
            --docdir=/usr/share/doc/gmp-6.1.2

make
make html

make check 2>&1 | tee gmp-check-log

awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log

make install
make install-html

cd ..
rm -rf gmp-6.1.2

### 6.15. MPFR-3.1.5

tar xf mpfr-3.1.5.tar.xz 
cd mpfr-3.1.5

./configure --prefix=/usr        \
            --disable-static     \
            --enable-thread-safe \
            --docdir=/usr/share/doc/mpfr-3.1.5

make
make html

make check

make install
make install-html

cd ..
rm -rf mpfr-3.1.5

### 6.16. MPC-1.0.3

tar xf mpc-1.0.3.tar.gz 
cd mpc-1.0.3

make
make html

make check

make install
make install-html

cd ..
rm -rf mpc-1.0.3

### 6.17. GCC-6.3.0

tar xf gcc-6.3.0.tar.bz2 
cd gcc-6.3.0

case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
  ;;
esac

mkdir -v build
cd       build

SED=sed                               \
../configure --prefix=/usr            \
             --enable-languages=c,c++ \
             --disable-multilib       \
             --disable-bootstrap      \
             --with-system-zlib

make

ulimit -s 32768

make -k check

########################## ../contrib/test_summary|grep -A7 Summ

make install

ln -sv ../usr/bin/cpp /lib

ln -sv gcc /usr/bin/cc

install -v -dm755 /usr/lib/bfd-plugins
ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/6.3.0/liblto_plugin.so \
        /usr/lib/bfd-plugins/

echo 'int main(){}' > dummy.c
cc dummy.c -v -Wl,--verbose &> dummy.log
readelf -l a.out | grep ': /lib'

grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log

grep -B4 '^ /usr/include' dummy.log

grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'

grep "/lib.*/libc.so.6 " dummy.log

grep found dummy.log

rm -v dummy.c a.out dummy.log

mkdir -pv /usr/share/gdb/auto-load/usr/lib
mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib

cd ../..
rm -rf gcc-6.3.0

### 6.18. Bzip2-1.0.6

tar xf bzip2-1.0.6.tar.gz
cd bzip2-1.0.6

patch -Np1 -i ../bzip2-1.0.6-install_docs-1.patch

sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile

sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile

make -f Makefile-libbz2_so
make clean

make

make PREFIX=/usr install

cp -v bzip2-shared /bin/bzip2
cp -av libbz2.so* /lib
ln -sv ../../lib/libbz2.so.1.0 /usr/lib/libbz2.so
rm -v /usr/bin/{bunzip2,bzcat,bzip2}
ln -sv bzip2 /bin/bunzip2
ln -sv bzip2 /bin/bzcat

cd ..
rm -rf bzip2-1.0.6

### 6.19. Pkg-config-0.29.1

tar xf pkg-config-0.29.1.tar.gz 
cd pkg-config-0.29.1

./configure --prefix=/usr              \
            --with-internal-glib       \
            --disable-compile-warnings \
            --disable-host-tool        \
            --docdir=/usr/share/doc/pkg-config-0.29.1

make

make check

make install

cd ..
rm -rf pkg-config-0.29.1

### 6.20. Ncurses-6.0

tar xf ncurses-6.0.tar.gz 
cd ncurses-6.0

sed -i '/LIBTOOL_INSTALL/d' c++/Makefile.in

./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --with-shared           \
            --without-debug         \
            --without-normal        \
            --enable-pc-files       \
            --enable-widec

make

make install

mv -v /usr/lib/libncursesw.so.6* /lib

ln -sfv ../../lib/$(readlink /usr/lib/libncursesw.so) /usr/lib/libncursesw.so

for lib in ncurses form panel menu ; do
    rm -vf                    /usr/lib/lib${lib}.so
    echo "INPUT(-l${lib}w)" > /usr/lib/lib${lib}.so
    ln -sfv ${lib}w.pc        /usr/lib/pkgconfig/${lib}.pc
done

rm -vf                     /usr/lib/libcursesw.so
echo "INPUT(-lncursesw)" > /usr/lib/libcursesw.so
ln -sfv libncurses.so      /usr/lib/libcurses.so

mkdir -v       /usr/share/doc/ncurses-6.0
cp -v -R doc/* /usr/share/doc/ncurses-6.0

cd ..
rm -rf ncurses-6.0

### 6.21. Attr-2.4.47

tar xf attr-2.4.47.src.tar.gz 
cd attr-2.4.47

sed -i -e 's|/@pkg_name@|&-@pkg_version@|' include/builddefs.in

sed -i -e "/SUBDIRS/s|man[25]||g" man/Makefile

./configure --prefix=/usr \
            --bindir=/bin \
            --disable-static
make

make -j1 tests root-tests

make install install-dev install-lib
chmod -v 755 /usr/lib/libattr.so

mv -v /usr/lib/libattr.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libattr.so) /usr/lib/libattr.so

cd ..
rm -rf attr-2.4.47

### 6.22. Acl-2.2.52

tar xf acl-2.2.52.src.tar.gz 
cd acl-2.2.52

sed -i -e 's|/@pkg_name@|&-@pkg_version@|' include/builddefs.in

sed -i "s:| sed.*::g" test/{sbits-restore,cp,misc}.test

sed -i -e "/TABS-1;/a if (x > (TABS-1)) x = (TABS-1);" \
    libacl/__acl_to_any_text.c

./configure --prefix=/usr    \
            --bindir=/bin    \
            --disable-static \
            --libexecdir=/usr/lib

make

make install install-dev install-lib
chmod -v 755 /usr/lib/libacl.so

mv -v /usr/lib/libacl.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libacl.so) /usr/lib/libacl.so

cd ..
rm -rf acl-2.2.52

### 6.23. Libcap-2.25

tar xf libcap-2.25.tar.xz 
cd libcap-2.25

sed -i '/install.*STALIBNAME/d' libcap/Makefile

make

make RAISE_SETFCAP=no lib=lib prefix=/usr install
chmod -v 755 /usr/lib/libcap.so

mv -v /usr/lib/libcap.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libcap.so) /usr/lib/libcap.so

cd ..
rm -rf libcap.so.2.25

### 6.24. Sed-4.4

tar xf sed-4.4.tar.xz 
cd sed-4.4

sed -i 's/usr/tools/'       build-aux/help2man
sed -i 's/panic-tests.sh//' Makefile.in

./configure --prefix=/usr --bindir=/bin

make
make html

make check

make install
install -d -m755           /usr/share/doc/sed-4.4
install -m644 doc/sed.html /usr/share/doc/sed-4.4

cd ..
rm -rf sed-4.4

### 6.25. Shadow-4.4

tar xf shadow-4.4.tar.xz 
cd shadow-4.4

sed -i 's/groups$(EXEEXT) //' src/Makefile.in
find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \;
find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;

echo '--- src/useradd.c   (old)
+++ src/useradd.c   (new)
@@ -2027,6 +2027,8 @@
        is_shadow_grp = sgr_file_present ();
 #endif
 
+       get_defaults ();
+
        process_flags (argc, argv);
 
 #ifdef ENABLE_SUBIDS
@@ -2036,8 +2038,6 @@
            (!user_id || (user_id <= uid_max && user_id >= uid_min));
 #endif                         /* ENABLE_SUBIDS */
 
-       get_defaults ();
-
 #ifdef ACCT_TOOLS_SETUID
 #ifdef USE_PAM
        {' | patch -p0 -l

sed -i 's/1000/999/' etc/useradd

sed -i -e '47 d' -e '60,65 d' libmisc/myname.c

make

make install

mv -v /usr/bin/passwd /bin

pwconv
grpconv

passwd root

cd ..
rm -rf shadow-4.4

### 6.26. Psmisc-22.21

tar xf psmisc-22.21.tar.gz 
cd psmisc-22.21

./configure --prefix=/usr

make

make install

mv -v /usr/bin/fuser   /bin
mv -v /usr/bin/killall /bin

cd ..
rm -rf psmisc-22.21

### 6.27. Iana-Etc-2.30 

tar xf iana-etc-2.30.tar.bz2 
cd iana-etc-2.30

make
make install

cd .. 
rm -rf iana-etc-2.30

### 6.28. M4-1.4.18

tar xf m4-1.4.18.tar.xz 
cd m4-1.4.18

./configure --prefix=/usr

make

make check

make install

cd ..
rm -rf m4-1.4.18
 
### 6.29. Bison-3.0.4

tar xf bison-3.0.4.tar.xz 
cd bison-3.0.4

./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.0.4

make

make install

cd ..
rm -rf bison-3.0.4

### 6.30. Flex-2.6.3

tar xf flex-2.6.3.tar.gz 
cd flex-2.6.3

HELP2MAN=/tools/bin/true \
./configure --prefix=/usr --docdir=/usr/share/doc/flex-2.6.3

make

make check

make install

ln -sv flex /usr/bin/lex

cd ..
rm -rf flex-2.6.3

### 6.31. Grep-3.0

tar xf grep-3.0.tar.xz 
cd grep-3.0

./configure --prefix=/usr --bindir=/bin

make

make check

make install

cd ..       
rm -rf grep-3.0

### 6.32. Readline-7.0

tar xf readline-7.0.tar.gz 
cd readline-7.0

sed -i '/MV.*old/d' Makefile.in
sed -i '/{OLDSUFF}/c:' support/shlib-install

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/readline-7.0

make SHLIB_LIBS=-lncurses

make SHLIB_LIBS=-lncurses install

mv -v /usr/lib/lib{readline,history}.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libreadline.so) /usr/lib/libreadline.so
ln -sfv ../../lib/$(readlink /usr/lib/libhistory.so ) /usr/lib/libhistory.so

cd ..
rm -rf readline-7.0

### 6.33. Bash-4.4

tar xf bash-4.4.tar.gz 
cd bash-4.4

patch -Np1 -i ../bash-4.4-upstream_fixes-1.patch

./configure --prefix=/usr                       \
            --docdir=/usr/share/doc/bash-4.4 \
            --without-bash-malloc               \
            --with-installed-readline

make

chown -Rv nobody .

su nobody -s /bin/bash -c "PATH=$PATH make tests"

make install
mv -vf /usr/bin/bash /bin

exec /bin/bash --login +h

cd ..
rm -rf bash-4.4

### 6.34. Bc-1.06.95

tar xf bc-1.06.95.tar.bz2 
cd bc-1.06.95

patch -Np1 -i ../bc-1.06.95-memory_leak-1.patch

./configure --prefix=/usr           \
            --with-readline         \
            --mandir=/usr/share/man \
            --infodir=/usr/share/info

make

echo "quit" | ./bc/bc -l Test/checklib.b

make install

cd ..
rm -rf bc-1.06.95

### 6.35. Libtool-2.4.6

tar xf libtool-2.4.6.tar.xz 
cd libtool-2.4.6

./configure --prefix=/usr

make

make check

make install

cd ..
rm -rf libtool-2.4.6

### 6.36. GDBM-1.12

tar xf gdbm-1.12.tar.gz 
cd gdbm-1.12

./configure --prefix=/usr \
            --disable-static \
            --enable-libgdbm-compat

make

make check

make install

cd ..
rm -rf gdbm-1.12

### 6.37. Gperf-3.0.4

tar xf gperf-3.0.4.tar.gz 
cd gperf-3.0.4

./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.0.4

make

make -j1 check

make install

cd ..
rm -rf gperf-3.0.4

### 6.38. Expat-2.2.0

tar xf expat-2.2.0.tar.bz2 
cd expat-2.2.0

./configure --prefix=/usr --disable-static

make

make check

make install

install -v -dm755 /usr/share/doc/expat-2.2.0
install -v -m644 doc/*.{html,png,css} /usr/share/doc/expat-2.2.0

cd ..
rm -rf expat-2.2.0

### 6.39. Inetutils-1.9.4

tar xf inetutils-1.9.4.tar.xz 
cd inetutils-1.9.4

./configure --prefix=/usr        \
            --localstatedir=/var \
            --disable-logger     \
            --disable-whois      \
            --disable-rcp        \
            --disable-rexec      \
            --disable-rlogin     \
            --disable-rsh        \
            --disable-servers

make

make check

make install

mv -v /usr/bin/{hostname,ping,ping6,traceroute} /bin
mv -v /usr/bin/ifconfig /sbin

cd ..
rm -rf inetutils-1.9.4

### 6.40. Perl-5.24.1

tar xf perl-5.24.1.tar.bz2 
cd perl-5.24.1

echo "127.0.0.1 localhost $(hostname)" > /etc/hosts

export BUILD_ZLIB=False
export BUILD_BZIP2=0

sh Configure -des -Dprefix=/usr                 \
                  -Dvendorprefix=/usr           \
                  -Dman1dir=/usr/share/man/man1 \
                  -Dman3dir=/usr/share/man/man3 \
                  -Dpager="/usr/bin/less -isR"  \
                  -Duseshrplib

make

make -k test

make install
unset BUILD_ZLIB BUILD_BZIP2

cd ..
rm -rf perl-5.24.1

### 6.41. XML::Parser-2.44

tar tf XML-Parser-2.44.tar.gz
cd XML-Parser-2.44

perl Makefile.PL

make

make test

make install

cd ..
rm -rf XML-Parser-2.44

### 6.42. Intltool-0.51.0

tar xf intltool-0.51.0.tar.gz 
cd intltool-0.51.0

sed -i 's:\\\${:\\\$\\{:' intltool-update.in

./configure --prefix=/usr

make

make check

make install
install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO

cd ..
rm -rf intltool-0.51.0

### 6.43. Autoconf-2.69

tar xf autoconf-2.69.tar.xz 
cd autoconf-2.69

./configure --prefix=/usr

make

make check

make install

cd ..
rm -rf autoconf-2.69

### 6.44. Automake-1.15

tar xf automake-1.15.tar.xz 
cd automake-1.15

sed -i 's:/\\\${:/\\\$\\{:' bin/automake.in

./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.15

make

sed -i "s:./configure:LEXLIB=/usr/lib/libfl.a &:" t/lex-{clean,depend}-cxx.sh
make -j4 check

make install

cd ..
rm -rf automake-1.15

### 6.45. Xz-5.2.3

tar xf xz-5.2.3.tar.xz 
cd xz-5.2.3

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/xz-5.2.3

make

make check

make install
mv -v   /usr/bin/{lzma,unlzma,lzcat,xz,unxz,xzcat} /bin
mv -v /usr/lib/liblzma.so.* /lib
ln -svf ../../lib/$(readlink /usr/lib/liblzma.so) /usr/lib/liblzma.so

cd ..
rm -rf xz-5.2.3

### 6.46. Kmod-23

tar xf kmod-23.tar.xz 
cd kmod-23

./configure --prefix=/usr          \
            --bindir=/bin          \
            --sysconfdir=/etc      \
            --with-rootlibdir=/lib \
            --with-xz              \
            --with-zlib

make

make install

for target in depmod insmod lsmod modinfo modprobe rmmod; do
  ln -sfv ../bin/kmod /sbin/$target
done

ln -sfv kmod /bin/lsmod

cd ..
rm -rf kmod-23

### 6.47. Gettext-0.19.8.1

tar xf gettext-0.19.8.1.tar.xz
cd gettext-0.19.8.1

sed -i '/^TESTS =/d' gettext-runtime/tests/Makefile.in &&
sed -i 's/test-lock..EXEEXT.//' gettext-tools/gnulib-tests/Makefile.in

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/gettext-0.19.8.1

make

make check

make install
chmod -v 0755 /usr/lib/preloadable_libintl.so

cd ..
rm -rf gettext-0.19.8.1

### 6.48. Procps-ng-3.3.12

tar xf procps-ng-3.3.12.tar.xz 
cd procps-ng-3.3.12

./configure --prefix=/usr                            \
            --exec-prefix=                           \
            --libdir=/usr/lib                        \
            --docdir=/usr/share/doc/procps-ng-3.3.12 \
            --disable-static                         \
            --disable-kill

make

sed -i -r 's|(pmap_initname)\\\$|\1|' testsuite/pmap.test/pmap.exp
make check

make install

mv -v /usr/lib/libprocps.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libprocps.so) /usr/lib/libprocps.so

cd ..
rm -rf procps-ng-3.3.12

### 6.49. E2fsprogs-1.43.4

tar xf e2fsprogs-1.43.4.tar.gz 
cd e2fsprogs-1.43.4

mkdir -v build
cd build

LIBS=-L/tools/lib                    \
CFLAGS=-I/tools/include              \
PKG_CONFIG_PATH=/tools/lib/pkgconfig \
../configure --prefix=/usr           \
             --bindir=/bin           \
             --with-root-prefix=""   \
             --enable-elf-shlibs     \
             --disable-libblkid      \
             --disable-libuuid       \
             --disable-uuidd         \
             --disable-fsck

make

ln -sfv /tools/lib/lib{blk,uu}id.so.1 lib
make LD_LIBRARY_PATH=/tools/lib check

make install

make install-libs

chmod -v u+w /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a

# documentation
# gunzip -v /usr/share/info/libext2fs.info.gz
# install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info

# even more documentation
# makeinfo -o      doc/com_err.info ../lib/et/com_err.texinfo
# install -v -m644 doc/com_err.info /usr/share/info
# install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info

cd ../..
rm -rf e2fsprogs-1.43.4

### 6.50. Coreutils-8.26

tar xf coreutils-8.26.tar.xz 
cd coreutils-8.26

patch -Np1 -i ../coreutils-8.26-i18n-1.patch

sed -i '/test.lock/s/^/#/' gnulib-tests/gnulib.mk

FORCE_UNSAFE_CONFIGURE=1 ./configure \
            --prefix=/usr            \
            --enable-no-install-program=kill,uptime

FORCE_UNSAFE_CONFIGURE=1 make

make NON_ROOT_USERNAME=nobody check-root

echo "dummy:x:1000:nobody" >> /etc/group

chown -Rv nobody . 

su nobody -s /bin/bash \
          -c "PATH=$PATH make RUN_EXPENSIVE_TESTS=yes check"

sed -i '/dummy/d' /etc/group

make install

mv -v /usr/bin/{cat,chgrp,chmod,chown,cp,date,dd,df,echo} /bin
mv -v /usr/bin/{false,ln,ls,mkdir,mknod,mv,pwd,rm} /bin
mv -v /usr/bin/{rmdir,stty,sync,true,uname} /bin
mv -v /usr/bin/chroot /usr/sbin
mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
sed -i s/\"1\"/\"8\"/1 /usr/share/man/man8/chroot.8

mv -v /usr/bin/{head,sleep,nice,test,[} /bin

cd ..
rm -rf coreutils-8.26

### 6.51. Diffutils-3.5

tar xf diffutils-3.5.tar.xz 
cd diffutils-3.5

sed -i 's:= @mkdir_p@:= /bin/mkdir -p:' po/Makefile.in.in

./configure --prefix=/usr

make

make check

make install

cd ..      
rm -rf diffutils-3.5

### 6.52. Gawk-4.1.4

tar xf gawk-4.1.4.tar.xz 
cd gawk-4.1.4

./configure --prefix=/usr

make

make check

make install

# documentation
# mkdir -v /usr/share/doc/gawk-4.1.4
# cp    -v doc/{awkforai.txt,*.{eps,pdf,jpg}} /usr/share/doc/gawk-4.1.4

cd ..
rm -rf gawk-4.1.4

### 6.53. Findutils-4.6.0

tar xf findutils-4.6.0.tar.gz 
cd findutils-4.6.0

sed -i 's/test-lock..EXEEXT.//' tests/Makefile.in

./configure --prefix=/usr --localstatedir=/var/lib/locate

make

make check

make install

mv -v /usr/bin/find /bin
sed -i 's|find:=${BINDIR}|find:=/bin|' /usr/bin/updatedb

cd ..
rm -rf findutils-4.6.0

### 6.54. Groff-1.22.3

tar xf groff-1.22.3.tar.gz 
cd groff-1.22.3

########################## 'letter' or 'A4' depending on your preference
PAGE=letter ./configure --prefix=/usr

make

make install

cd ..
rm -rf groff-1.22.3

### 6.55. GRUB-2.02~beta3

tar xf grub-2.02~beta3.tar.xz 
cd grub-2.02~beta3

./configure --prefix=/usr          \
            --sbindir=/sbin        \
            --sysconfdir=/etc      \
            --disable-efiemu       \
            --disable-werror

make

make install

cd ..
rm -rf grub-2.02~beta3

### 6.56. Less-481

tar xf less-481.tar.gz 
cd less-481

./configure --prefix=/usr --sysconfdir=/etc

make

make install

cd ..
rm -rf less-481

### 6.57. Gzip-1.8

tar xf gzip-1.8.tar.xz 
cd gzip-1.8

./configure --prefix=/usr

make

make check

make install

mv -v /usr/bin/gzip /bin

cd ..
rm -rf gzip-1.8

### 6.58. IPRoute2-4.9.0

tar xf iproute2-4.9.0.tar.xz 
cd iproute2-4.9.0

sed -i /ARPD/d Makefile
sed -i 's/arpd.8//' man/man8/Makefile
rm -v doc/arpd.sgml

sed -i 's/m_ipt.o//' tc/Makefile

make

make DOCDIR=/usr/share/doc/iproute2-4.9.0 install

cd ..
rm -rf iproute2-4.9.0

### 6.59. Kbd-2.0.4

tar xf kbd-2.0.4.tar.xz 
cd kbd-2.0.4

patch -Np1 -i ../kbd-2.0.4-backspace-1.patch

sed -i 's/\(RESIZECONS_PROGS=\)yes/\1no/g' configure
sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in

PKG_CONFIG_PATH=/tools/lib/pkgconfig ./configure --prefix=/usr --disable-vlock

make

make check

make install

mkdir -v       /usr/share/doc/kbd-2.0.4
cp -R -v docs/doc/* /usr/share/doc/kbd-2.0.4

cd ..
rm -rf kbd-2.0.4

### 6.60. Libpipeline-1.4.1

tar xf libpipeline-1.4.1.tar.gz 
cd libpipeline-1.4.1

PKG_CONFIG_PATH=/tools/lib/pkgconfig ./configure --prefix=/usr

make

make check

make install

cd ..
rm -rf libpipeline-1.4.1

### 6.61. Make-4.2.1

tar xf make-4.2.1.tar.bz2 
cd make-4.2.1

./configure --prefix=/usr

make

make check

make install

cd ..
rm -rf make-4.2.1

### 6.62. Patch-2.7.5

tar xf patch-2.7.5.tar.xz 
cd patch-2.7.5

./configure --prefix=/usr

make

make check

make install

cd ..
rm -rf patch-2.7.5

### 6.63. Sysklogd-1.5.1

tar xf sysklogd-1.5.1.tar.gz 
cd sysklogd-1.5.1

sed -i '/Error loading kernel symbols/{n;n;d}' ksym_mod.c
sed -i 's/union wait/int/' syslogd.c

make

make BINDIR=/sbin install

cat > /etc/syslog.conf << "EOF"
# Begin /etc/syslog.conf

auth,authpriv.* -/var/log/auth.log
*.*;auth,authpriv.none -/var/log/sys.log
daemon.* -/var/log/daemon.log
kern.* -/var/log/kern.log
mail.* -/var/log/mail.log
user.* -/var/log/user.log
*.emerg *

# End /etc/syslog.conf
EOF

cd ..
rm -rf sysklogd-1.5.1

### 6.64. Sysvinit-2.88dsf

tar xf sysvinit-2.88dsf.tar.bz2 
cd sysvinit-2.88dsf

patch -Np1 -i ../sysvinit-2.88dsf-consolidated-1.patch

make -C src

make -C src install

cd ..
rm -rf sysvinit-2.88dsf

### 6.65. Eudev-3.2.1

tar xf eudev-3.2.1.tar.gz 
cd eudev-3.2.1

sed -r -i 's|/usr(/bin/test)|\1|' test/udev-test.pl

sed -i '/keyboard_lookup_key/d' src/udev/udev-builtin-keyboard.c

cat > config.cache << "EOF"
HAVE_BLKID=1
BLKID_LIBS="-lblkid"
BLKID_CFLAGS="-I/tools/include"
EOF

./configure --prefix=/usr           \
            --bindir=/sbin          \
            --sbindir=/sbin         \
            --libdir=/usr/lib       \
            --sysconfdir=/etc       \
            --libexecdir=/lib       \
            --with-rootprefix=      \
            --with-rootlibdir=/lib  \
            --enable-manpages       \
            --disable-static        \
            --config-cache

LIBRARY_PATH=/tools/lib make

mkdir -pv /lib/udev/rules.d
mkdir -pv /etc/udev/rules.d

make LD_LIBRARY_PATH=/tools/lib check

make LD_LIBRARY_PATH=/tools/lib install

tar -xvf ../udev-lfs-20140408.tar.bz2
make -f udev-lfs-20140408/Makefile.lfs install

LD_LIBRARY_PATH=/tools/lib udevadm hwdb --update

cd ..
rm -rf eudev-3.2.1

### 6.66. Util-linux-2.29.1

tar xf util-linux-2.29.1.tar.xz 
cd util-linux-2.29.1

mkdir -pv /var/lib/hwclock

./configure ADJTIME_PATH=/var/lib/hwclock/adjtime   \
            --docdir=/usr/share/doc/util-linux-2.29.1 \
            --disable-chfn-chsh  \
            --disable-login      \
            --disable-nologin    \
            --disable-su         \
            --disable-setpriv    \
            --disable-runuser    \
            --disable-pylibmount \
            --disable-static     \
            --without-python     \
            --without-systemd    \
            --without-systemdsystemunitdir

make

chown -Rv nobody .
su nobody -s /bin/bash -c "PATH=$PATH make -k check"

make install

cd ..
rm -rf util-linux-2.29.1

### 6.67. Man-DB-2.7.6.1

tar xf man-db-2.7.6.1.tar.xz 
cd man-db-2.7.6.1

./configure --prefix=/usr                        \
            --docdir=/usr/share/doc/man-db-2.7.6.1 \
            --sysconfdir=/etc                    \
            --disable-setuid                     \
            --enable-cache-owner=bin             \
            --with-browser=/usr/bin/lynx         \
            --with-vgrind=/usr/bin/vgrind        \
            --with-grap=/usr/bin/grap            \
            --with-systemdtmpfilesdir=

make

make check

make install

cd ..
rm -rf man-db-2.7.6.1

### 6.68. Tar-1.29

tar xf tar-1.29.tar.xz 
cd tar-1.29

FORCE_UNSAFE_CONFIGURE=1  \
./configure --prefix=/usr \
            --bindir=/bin

make

make check

make install
make -C doc install-html docdir=/usr/share/doc/tar-1.29

cd ..
rm -rf tar-1.29

### 6.69. Texinfo-6.3

tar xf texinfo-6.3.tar.xz 
cd texinfo-6.3

./configure --prefix=/usr --disable-static

make

make check

make install

# documentation
# make TEXMF=/usr/share/texmf install-tex

pushd /usr/share/info
rm -v dir
for f in *
  do install-info $f dir 2>/dev/null
done
popd

cd ..
rm -rf texinfo-6.3

### 6.70. Vim-8.0.069

tar xf vim-8.0.069.tar.bz2
cd vim80

echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h

./configure --prefix=/usr

make

make -j1 test

make install

ln -sv vim /usr/bin/vi
for L in  /usr/share/man/{,*/}man1/vim.1; do
    ln -sv vim.1 $(dirname $L)/vi.1
done

ln -sv ../vim/vim80/doc /usr/share/doc/vim-8.0.069

cat > /etc/vimrc << "EOF"
" Begin /etc/vimrc

set nocompatible
set backspace=2
set mouse=r
syntax on
if (&term == "xterm") || (&term == "putty")
  set background=dark
endif


" End /etc/vimrc
EOF

cd ..
rm -rf vim80


