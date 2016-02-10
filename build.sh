#!/bin/bash

# c.f. http://dlbeer.co.nz/articles/mingw64.html
# c.f. http://pete.akeo.ie/2010/07/compiling-mingw-w64-with-multilib-on.html
# Note: ubuntu trusty mingw configure string is as follows:
# $ sudo apt-get install g++-mingw-w64-i686
# $ i686-w64-mingw32-g++ -v
# Using built-in specs.
# COLLECT_GCC=i686-w64-mingw32-g++
# COLLECT_LTO_WRAPPER=/usr/lib/gcc/i686-w64-mingw32/4.8/lto-wrapper
# Target: i686-w64-mingw32
# Configured with: ../../src/configure --build=x86_64-linux-gnu --prefix=/usr --includedir='/usr/include' --mandir='/usr/share/man' --infodir='/usr/share/info' --sysconfdir=/etc --localstatedir=/var --libexecdir='/usr/lib/gcc-mingw-w64' --disable-maintainer-mode --disable-dependency-tracking --prefix=/usr --enable-shared --enable-static --disable-multilib --with-system-zlib --libexecdir=/usr/lib --without-included-gettext --libdir=/usr/lib --enable-libstdcxx-time=yes --with-tune=generic --enable-version-specific-runtime-libs --enable-threads=posix --enable-fully-dynamic-string --enable-sjlj-exceptions --enable-libgomp --enable-languages=c,c++,fortran,objc,obj-c++ --enable-lto --with-plugin-ld --target=i686-w64-mingw32 --with-gxx-include-dir=/usr/include/c++/4.8 --with-as=/usr/bin/i686-w64-mingw32-as --with-ld=/usr/bin/i686-w64-mingw32-ld
# Thread model: posix
# gcc version 4.8.2 (GCC) 

set -e
set -u

export MINGW=mingw-w64-v4.0.4
export BIN=binutils-2.25
export GCC=gcc-4.9.3
export GMP=gmp-6.1.0
export MPF=mpfr-3.1.3
export MPC=mpc-1.0.3

rm -rf build_binutils
rm -rf build_mingw
rm -rf build_gcc
rm -rf build_winpthread
rm -rf prefix
rm -rf $MINGW
rm -rf $BIN
rm -rf $GCC
rm -rf $GMP
rm -rf $MPF
rm -rf $MPC

mkdir build_binutils
mkdir build_mingw
mkdir build_gcc
mkdir build_winpthread
mkdir prefix

# Source the configuration directories
. config.sh

#export CFLAGS="-g0 -O2 -pipe -Wl,-S -march=pentium -march=i686"
#export CXXFLAGS="-g0 -O2 -pipe -Wl,-S -march=pentium -march=i686"
#CFLAGS="-O0"
#CXXFLAGS="-O0"

# -1: Install deps
# sudo apt-get install g++ flex bison yacc texinfo

# 0: Extract things
echo "<<< extract mingw >>>"
tar -xjf $MINGW.tar.bz2
echo "<<< extract binutils >>>"
tar -xzf $BIN.tar.gz
echo "<<< extract gcc >>>"
tar -xjf $GCC.tar.bz2
echo "<<< extract gmp >>>"
tar -xjf $GMP.tar.bz2
echo "<<< extract mpfr >>>"
tar -xjf $MPF.tar.bz2
echo "<<< extract mpc >>>"
tar -xzf $MPC.tar.gz

echo "<<< moving extra libs to gcc folder >>>"
mv $GMP $GCC/gmp
mv $MPF $GCC/mpfr
mv $MPC $GCC/mpc

# 1: Make binutils
BINUTILS_CONFIG="-target=${targ} --disable-multilib --with-sysroot=${MY_SYS_ROOT} --prefix=${MY_SYS_ROOT}"

echo "<<< MAKE BINUTILS >>>"
cd build_binutils
../$BIN/configure $BINUTILS_CONFIG
make -j3
make install
cd ..

# 2: Make symlinks
echo "<<< MAKE SYMLINKS >>>"
ln -s ${MY_SYS_ROOT}/${targ} ${MY_SYS_ROOT}/mingw
mkdir -p ${MY_SYS_ROOT}/${targ}/lib
#ln -s ${MY_SYS_ROOT}/${targ}/lib32

# 3: Make mingw headers
echo "<<< MAKE MINGW HEADERS >>>"
cd build_mingw
../$MINGW/mingw-w64-headers/configure --host=${targ} --prefix=${MY_SYS_ROOT}/${targ}
make -j3
make install
cd ..

# 4: Make gcc core
echo "<<< MAKE GCC CORE >>>"
cd build_gcc
../$GCC/configure $BINUTILS_CONFIG \
  --enable-static --enable-shared --with-system-zlib --without-included-gettext \
  --enable-sjlj-exceptions --enable-threads=posix --enable-libstdcxx-time=yes --enable-fully-dynamic-string \
  --enable-languages=c,c++ \
  --includedir=${MY_SYS_ROOT}/include --libdir=${MY_SYS_ROOT}/lib --with-gxx-include-dir=${MY_SYS_ROOT}/include/c++/4.9 \
  --with-as=${MY_SYS_ROOT}/bin/${targ}-as --with-ld=${MY_SYS_ROOT}/bin/${targ}-ld
make all-gcc -j3
make install-gcc
cd ..

# 5: Make mingw crt

echo "<<< MAKE MINGW CRT >>>"
cd build_mingw
../$MINGW/configure --disable-multilib --target=${targ} \
  --with-sysroot=${MY_SYS_ROOT} --prefix=${MY_SYS_ROOT}/${targ} --host=${targ} 
make -j3
make install
cd ..

# 6: Make win pthreads

echo "<<< MAKE WINPTHREADS >>>"

cd build_winpthread
../$MINGW/mingw-w64-libraries/winpthreads/configure \
    --prefix=${MY_SYS_ROOT}/${targ} --host=${targ} \
    --libdir=${MY_SYS_ROOT}/${targ}/lib \
    --disable-multilib
#    CC="${MY_SYS_ROOT}/bin/${targ}-gcc" \
#    CCAS="${MY_SYS_ROOT}/bin/${targ}-gcc" \
#    DLLTOOL="${MY_SYS_ROOT}/bin/${targ}-dlltool -m i386" \
#    RC="${MY_SYS_ROOT}/bin/${targ}-windres -F pe-i386"
make || echo "expected failure"

cp fakelib/libgcc.a fakelib/libpthread.a

make && make install

cp ${MY_SYS_ROOT}/${targ}/bin/libwinpthread-1.dll \
   ${MY_SYS_ROOT}/${targ}/lib/

cd ..

# 7: Make gcc second pass
echo "<<< MAKE GCC PASS #2 >>>"
cd build_gcc
make -j3
make install
cd ..
