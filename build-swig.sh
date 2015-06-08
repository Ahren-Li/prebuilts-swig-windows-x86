#!/bin/bash -ex
# Download & build swig on the local machine
# works on Linux, OSX, and Windows (Cygwin w/make 4.1, curl, gcc 4.9.2)
# leaves output in /tmp/prebuilts/install/
# cmake must be installed on Windows

PROJ=swig
VER=2.0.11

source $(dirname "$0")/build-common.sh build-common.sh

TGZ=$PROJ-$VER.tar.gz
curl -L http://downloads.sourceforge.net/project/swig/swig/$PROJ-$VER/$TGZ -o $TGZ
tar xzf $TGZ || cat $TGZ
mkdir -p $RD/build
cd $RD/build

# build PCRE as a static library from a tarball just for use during the SWIG build.
# GNU make 3.81 (MinGW version) crashes on Windows
curl -L ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.37.tar.gz -o pcre-8.37.tar.gz
$RD/$PROJ-$VER/Tools/pcre-build.sh

if [ "$OS" == "windows" ]; then
    SWIG_CFLAGS="-static -static-libgcc"
    SWIG_CXXFLAGS="-static -static-libgcc -static-libstdc++"
fi
$RD/$PROJ-$VER/configure CFLAGS="$SWIG_CFLAGS" CXXFLAGS="$SWIG_CXXFLAGS" --prefix=$INSTALL
make -j$CORES
make install
cd $INSTALL/bin

commit_and_push
