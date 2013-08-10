#!/bin/bash
BUILDDIR=~/src
BRANCH=1.2.10
DCH_DISTRO=UNRELEASED
sudo apt-get -y update
sudo apt-get -y install autoconf automake devscripts gawk g++ git-core libjpeg-dev libncurses5-dev libtool make python-dev gawk pkg-config libtiff4-dev libperl-dev libgdbm-dev libdb-dev gettext sudo equivs mlocate git dpkg-dev devscripts sudo wget sox flac
sudo apt-get -y -f install
sudo update-alternatives --set awk /usr/bin/gawk
mkdir $BUILDDIR
cd $BUILDDIR
git clone -b $BRANCH   https://github.com/2600hz/FreeSWITCH freeswitch 
#cp -r freeswitch.old/src/mod/event_handlers/mod_kazoo freeswitch/src/mod/event_handlers/
#(cd freeswitch && patch -p1 < ../mod_kazoo.patch)
DISTRO=`lsb_release -cs`
FS_VERSION="$(cat freeswitch/build/next-release.txt | sed -e 's/-/~/g')~n$(date +%Y%m%dT%H%M%SZ)-1~${DISTRO}+1"

(cd freeswitch && build/set-fs-version.sh "$FS_VERSION")
(cd freeswitch && dch -b -m -v "$FS_VERSION" --force-distribution -D "$DCH_DISTRO" "Custom build.")
if [ -f modules.conf ]; then cp modules.conf freeswitch/debian; fi
(cd freeswitch/debian && ./bootstrap.sh -c ${DISTRO})
sudo mk-build-deps -i freeswitch/debian/control
(cd freeswitch && dpkg-buildpackage -b -uc)
