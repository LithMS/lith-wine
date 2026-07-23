#!/bin/bash
# B1 build: wine from crossover-sources-26.2.0 for x86_64 (Rosetta), mirroring retail CX layout.
# Adapted from neptuwunium/wine-cx-build (itself from Gcenx/crossover-wine-ci).
set -uxo pipefail
B1="$HOME/b1"
WINE_CONFIGURE="$B1/sources/wine/configure"
BUILDROOT="$B1/build"
INSTALLROOT="$B1/install"
WINE_INSTALLATION=wine-cx26.2.0

eval "$(/usr/local/bin/brew shellenv)"
export PATH="/usr/local/opt/llvm/bin:/usr/local/opt/bison/bin:$PATH"
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:${PKG_CONFIG_PATH:-}"
export CC="clang -arch x86_64"
export CXX="clang++ -arch x86_64"
export i386_CC="i686-w64-mingw32-gcc"
export x86_64_CC="x86_64-w64-mingw32-gcc"
export CPATH="/usr/local/include"
export LIBRARY_PATH="/usr/local/lib"
export MACOSX_DEPLOYMENT_TARGET="15.0"
export OPTFLAGS="-O2"
export CFLAGS="${OPTFLAGS} -Wno-deprecated-declarations -Wno-format"
export CROSSCFLAGS="${OPTFLAGS} -Wno-incompatible-pointer-types"
export CPPFLAGS="-I/usr/local/opt/llvm/include -I/usr/local/opt/bison/include"
export LDFLAGS="-L/usr/local/opt/llvm/lib -L/usr/local/opt/bison/lib -Wl,-headerpad_max_install_names -Wl,-rpath,@loader_path/../../ -Wl,-rpath,/usr/local/lib -Wl,-rpath,/opt/X11/lib"
export ac_cv_lib_soname_vulkan=""
export DYLD_FALLBACK_LIBRARY_PATH="${DYLD_FALLBACK_LIBRARY_PATH:-}:/usr/lib:/usr/X11/lib"

cp "$B1/distversion.h" "$B1/sources/wine/programs/winedbg/distversion.h"

mkdir -p "$BUILDROOT/winecx-26.2.0"
cd "$BUILDROOT/winecx-26.2.0"
"$WINE_CONFIGURE" \
    --build=x86_64-apple-darwin \
    --prefix= \
    --disable-tests \
    --enable-win64 \
    --enable-archs=i386,x86_64 \
    --without-alsa --without-capi --with-coreaudio --with-cups --without-dbus \
    --without-fontconfig --with-freetype --with-gettext --without-gettextpo \
    --without-gphoto --with-gnutls --without-gssapi --without-gstreamer \
    --without-inotify --without-krb5 --with-mingw --without-netapi \
    --with-opencl --without-opengl --without-oss --with-pcap --with-pthread \
    --without-pulse --without-sane --with-sdl --without-udev --with-unwind \
    --without-usb --without-v4l2 --with-vulkan --without-x \
    || { echo "BUILD_FAIL=configure"; exit 1; }

make -j4 || { echo "BUILD_FAIL=make"; exit 1; }
make install-image DESTDIR="$INSTALLROOT/$WINE_INSTALLATION" || { echo "BUILD_FAIL=install"; exit 1; }
echo "BUILD_DONE"
