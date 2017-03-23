#!/bin/bash

#
# Build our own tool chain (temporary system.)
# 

if [ ! $USER == 'lfs' ]
then
  echo must su to user lfs \(\'su - lfs\'\)
  exit
fi

# set LFS env variable
source set-LFS.sh
# todo - make certain not blank

# set bash to exit on any error
set -e

cd $LFS/sources


### Binutils (5.4. Binutils-2.27 - Pass 1)

tar xf binutils-2.27.tar.bz2
cd binutils-2.27
mkdir build
cd build

../configure --prefix=/tools\
 --with-sysroot=$LFS\
 --with-lib-path=/tools/lib\
 --target=$LFS_TGT\
 --disable-nls\
 --disable-werror

make

case $(uname -m) in   x86_64) mkdir -v /tools/lib && ln -sv lib /tools/lib64 ;; esac

make install

cd ../..
rm -rf binutils-2.27

### GCC (5.5. GCC-6.3.0 - Pass 1)

tar xf gcc-6.3.0.tar.bz2
cd gcc-6.3.0

tar -xf ../mpfr-3.1.5.tar.xz
mv -v mpfr-3.1.5 mpfr
tar -xf ../gmp-6.1.2.tar.xz
mv -v gmp-6.1.2 gmp
tar -xf ../mpc-1.0.3.tar.gz
mv -v mpc-1.0.3 mpc

for file in gcc/config/{linux,i386/linux{,64}}.h
do
  cp -uv $file{,.orig}
  sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
      -e 's@/usr@/tools@g' $file.orig > $file
  echo '
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
#define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
  touch $file.orig
done

case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
 ;;
esac

mkdir -v build
cd       build

../configure                                       \
    --target=$LFS_TGT                              \
    --prefix=/tools                                \
    --with-glibc-version=2.11                      \
    --with-sysroot=$LFS                            \
    --with-newlib                                  \
    --without-headers                              \
    --with-local-prefix=/tools                     \
    --with-native-system-header-dir=/tools/include \
    --disable-nls                                  \
    --disable-shared                               \
    --disable-multilib                             \
    --disable-decimal-float                        \
    --disable-threads                              \
    --disable-libatomic                            \
    --disable-libgomp                              \
    --disable-libmpx                               \
    --disable-libquadmath                          \
    --disable-libssp                               \
    --disable-libvtv                               \
    --disable-libstdcxx                            \
    --enable-languages=c,c++

make

make install

cd ../..
rm -rf gcc-6.3.0

### Linux Kernel Headers (5.6. Linux-4.9.9 API Headers)

tar xf linux-4.9.9.tar.xz
cd linux-4.9.9

make mrproper

make INSTALL_HDR_PATH=dest headers_install
cp -rv dest/include/* /tools/include

cd ..
rm -rf linux-4.9.9

### Glibc (5.7. Glibc-2.25)

tar xf glibc-2.25.tar.xz
cd glibc-2.25

mkdir -v build
cd       build

../configure                             \
      --prefix=/tools                    \
      --host=$LFS_TGT                    \
      --build=$(../scripts/config.guess) \
      --enable-kernel=2.6.32             \
      --with-headers=/tools/include      \
      libc_cv_forced_unwind=yes          \
      libc_cv_c_cleanup=yes

make

make install

cd ../..

rm -rf glibc-2.25

echo 'int main(){}' > dummy.c
$LFS_TGT-gcc dummy.c
readelf -l a.out | grep ': /tools'

rm -v dummy.c a.out


### Libstdc++ (5.8. Libstdc++-6.3.0)

tar xf gcc-6.3.0.tar.bz2 
cd gcc-6.3.0


mkdir -v build
cd       build

../libstdc++-v3/configure           \
    --host=$LFS_TGT                 \
    --prefix=/tools                 \
    --disable-multilib              \
    --disable-nls                   \
    --disable-libstdcxx-threads     \
    --disable-libstdcxx-pch         \
    --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/6.3.0

make

make install

cd ../..

rm -rf gcc-6.3.0

### Binutils (5.9. Binutils-2.27 - Pass 2)

tar xf binutils-2.27.tar.bz2 
cd binutils-2.27

mkdir -v build
cd       build

CC=$LFS_TGT-gcc                \
AR=$LFS_TGT-ar                 \
RANLIB=$LFS_TGT-ranlib         \
../configure                   \
    --prefix=/tools            \
    --disable-nls              \
    --disable-werror           \
    --with-lib-path=/tools/lib \
    --with-sysroot

make

make install

make -C ld clean
make -C ld LIB_PATH=/usr/lib:/lib
cp -v ld/ld-new /tools/bin

cd ../..
rm -rf binutils-2.27


### GCC (5.10. GCC-6.3.0 - Pass 2)

tar xf gcc-6.3.0.tar.bz2
cd gcc-6.3.0

cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
  `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/include-fixed/limits.h

for file in gcc/config/{linux,i386/linux{,64}}.h
do
  cp -uv $file{,.orig}
  sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
      -e 's@/usr@/tools@g' $file.orig > $file
  echo '
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
#define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
  touch $file.orig
done

case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
  ;;
esac


tar -xf ../mpfr-3.1.5.tar.xz
mv -v mpfr-3.1.5 mpfr
tar -xf ../gmp-6.1.2.tar.xz
mv -v gmp-6.1.2 gmp
tar -xf ../mpc-1.0.3.tar.gz
mv -v mpc-1.0.3 mpc

mkdir -v build
cd       build

CC=$LFS_TGT-gcc                                    \
CXX=$LFS_TGT-g++                                   \
AR=$LFS_TGT-ar                                     \
RANLIB=$LFS_TGT-ranlib                             \
../configure                                       \
    --prefix=/tools                                \
    --with-local-prefix=/tools                     \
    --with-native-system-header-dir=/tools/include \
    --enable-languages=c,c++                       \
    --disable-libstdcxx-pch                        \
    --disable-multilib                             \
    --disable-bootstrap                            \
    --disable-libgomp

make

make install

ln -sv gcc /tools/bin/cc

echo 'int main(){}' > dummy.c
cc dummy.c
readelf -l a.out | grep ': /tools'

rm -v dummy.c a.out

cd ../..
rm -rf gcc-6.3.0

### Tcl-core (5.11. Tcl-core-8.6.6)

tar xf tcl-core8.6.6-src.tar.gz 
cd tcl8.6.6/unix

./configure --prefix=/tools

make

TZ=UTC make test

make install

chmod -v u+w /tools/lib/libtcl8.6.so

make install-private-headers

ln -sv tclsh8.6 /tools/bin/tclsh

cd ../..
rm -rf tcl8.6.6

### Expect (5.12. Expect-5.45)

tar xf expect5.45.tar.gz 
cd expect5.45

cp -v configure{,.orig}
sed 's:/usr/local/bin:/bin:' configure.orig > configure

./configure --prefix=/tools       \
            --with-tcl=/tools/lib \
            --with-tclinclude=/tools/include

make

make test

make SCRIPTS="" install

cd ..
rm -rf expect5.45

### DejaGNU (5.13. DejaGNU-1.6)

tar xf dejagnu-1.6.tar.gz 
cd dejagnu-1.6

./configure --prefix=/tools

make install

make check

cd ..
rm -rf dejagnu-1.6

### check (5.14. Check-0.11.0)

tar xf check-0.11.0.tar.gz 
cd check-0.11.0

PKG_CONFIG= ./configure --prefix=/tools

make
make check
make install

cd ..
rm -rf check-0.11.0

### Ncurses (5.15. Ncurses-6.0)

tar xf ncurses-6.0.tar.gz 
cd ncurses-6.0

sed -i s/mawk// configure

./configure --prefix=/tools \
            --with-shared   \
            --without-debug \
            --without-ada   \
            --enable-widec  \
            --enable-overwrite

make
make install

cd ..
rm -rf ncurses-6.0

### Bash (5.16. Bash-4.4)

tar xf bash-4.4.tar.gz  
cd bash-4.4

./configure --prefix=/tools --without-bash-malloc

make 
make tests
make install

ln -sv bash /tools/bin/sh

cd ..
rm -rf bash-4.4

### Bison (5.17. Bison-3.0.4)

tar xf bison-3.0.4.tar.xz 
cd bison-3.0.4

./configure --prefix=/tools
make
make check
make install
cd ..
rm -rf bison-3.0.4

## Bzip (5.18. Bzip2-1.0.6)

tar xf bzip2-1.0.6.tar.gz 
cd bzip2-1.0.6

make
make PREFIX=/tools install

cd ..
rm -rf bzip2-1.0.6

### Coreutils (5.19. Coreutils-8.26)

tar xf coreutils-8.26.tar.xz 
cd coreutils-8.26

./configure --prefix=/tools --enable-install-program=hostname

make
make RUN_EXPENSIVE_TESTS=yes check
make install

cd ..
rm -rf coreutils-8.26

### Diffutils (5.20. Diffutils-3.5)

tar xf diffutils-3.5.tar.xz 
cd diffutils-3.5

./configure --prefix=/tools

make
make check
make install

cd ..
rm -rf diffutils-3.5

### File (5.21. File-5.30)

tar xf file-5.30.tar.gz 
cd file-5.30

./configure --prefix=/tools

make
make check
make install

cd ..
rm -rf file-5.30

### Findutils (5.22. Findutils-4.6.0)

tar xf findutils-4.6.0.tar.gz 
cd findutils-4.6.0

./configure --prefix=/tools

make
make check
make install

cd ..
rm -rf 
rm -rf findutils-4.6.0

### Gawk (5.23. Gawk-4.1.4)

tar xf gawk-4.1.4.tar.xz 
cd gawk-4.1.4

./configure --prefix=/tools

make
make check
make install

cd .. 
rm -rf gawk-4.1.4

### Gettext (5.24. Gettext-0.19.8.1)

tar xf gettext-0.19.8.1.tar.xz 
cd gettext-0.19.8.1

cd gettext-tools
EMACS="no" ./configure --prefix=/tools --disable-shared

make -C gnulib-lib
make -C intl pluralx.c
make -C src msgfmt
make -C src msgmerge
make -C src xgettext

cp -v src/{msgfmt,msgmerge,xgettext} /tools/bin

cd ../..
rm -rf gettext-0.19.8.1

### Grep (5.25. Grep-3.0)

tar xf grep-3.0.tar.xz 
cd grep-3.0

./configure --prefix=/tools

make
make check
make install

cd ..
rm -rf grep-3.0

### Gzip (5.26. Gzip-1.8)

tar xf gzip-1.8.tar.xz 
cd gzip-1.8

./configure --prefix=/tools

make
make check
make install

cd ..
rm -rf gzip-1.8

### M4 (5.27. M4-1.4.18)

tar xf m4-1.4.18.tar.xz 
cd m4-1.4.18

./configure --prefix=/tools

make
make check
make install

cd ..
rm -rf m4-1.4.18

### Make (5.28. Make-4.2.1)

tar xf make-4.2.1.tar.bz2 
cd make-4.2.1

./configure --prefix=/tools --without-guile

make
make check
make install

cd ..
rm -rf make-4.2.1

### Patch (5.29. Patch-2.7.5)

tar xf patch-2.7.5.tar.xz 
cd patch-2.7.5

make
make check
make install

cd ..
rm -rf patch-2.7.5

### Perl (5.30. Perl-5.24.1)

tar xf perl-5.24.1.tar.bz2 
cd perl-5.24.1

make

cp -v perl cpan/podlators/scripts/pod2man /tools/bin
mkdir -pv /tools/lib/perl5/5.24.1
cp -Rv lib/* /tools/lib/perl5/5.24.1

cd ..
rm -rf perl-5.24.1

### Sed (5.31. Sed-4.4)

tar xf sed-4.4.tar.xz 
cd sed-4.4

./configure --prefix=/tools

make
make check
make install

cd ..
rm -rf sed-4.4

### Tar (5.32. Tar-1.29)

tar xf tar-1.29.tar.xz 
cd 


make
make check
make install

cd ..
rm -rf tar-1.29

### Texinfo (5.33. Texinfo-6.3)

tar xf texinfo-6.3.tar.xz 
cd texinfo-6.3

./configure --prefix=/tools

make
make check
make install

cd ..
rm -rf texinfo-6.3

### Util-linux (5.34. Util-linux-2.29.1)

tar xf util-linux-2.29.1.tar.xz 
cd 


./configure --prefix=/tools                \
            --without-python               \
            --disable-makeinstall-chown    \
            --without-systemdsystemunitdir \
            PKG_CONFIG=""

make
make install

cd ..
rm -rf util-linux-2.29.1

### Xz (5.35. Xz-5.2.3)

tar xf xz-5.2.3.tar.xz 
cd xz-5.2.3

./configure --prefix=/tools

make
make check
make install

cd ..
rm -rf xz-5.2.3

### 5.36. Stripping

strip --strip-debug /tools/lib/*
/usr/bin/strip --strip-unneeded /tools/{,s}bin/*

rm -rf /tools/{,share}/{info,man,doc}

### 5.37. Changing Ownership

chown -R root:root $LFS/tools


