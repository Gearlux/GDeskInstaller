#!/bin/sh

QTDIR=~/Qt/5.4/clang_64/bin

do_clean=0
while [[ $# > 0 ]]
do
	key="$1"

	case $key in
    	clean)
		do_clean=1
    	;;
	esac
	shift
done

if [ $do_clean == 1 ] 
then
	echo "Cleaning"
	rm -rf mac_build
	mkdir mac_build
fi

# Build GDeskTunes Completely
cd mac_build
$QTDIR/qmake ../../GDeskTunes/GDeskTunes.pro -r -spec macx-clang CONFIG+=x86_64
make
make install
cd ..

# Create Qt distribution files
rm -rf GDeskTunes.app
cp -a mac_build/src/release/GDeskTunes.app .
$QTDIR/macdeployqt GDeskTunes.app

rm -rf installer/packages/io.qt/data/*
mkdir -p installer/packages/io.qt/data/GDeskTunes.app/Contents/Frameworks/
mkdir -p installer/packages/io.qt/data/GDeskTunes.app/Contents/PlugIns/
mkdir -p installer/packages/io.qt/data/GDeskTunes.app/Contents/Resources/
cp -Ra GDeskTunes.app/Contents/Frameworks installer/packages/io.qt/data/GDeskTunes.app/Contents
cp -Ra GDeskTunes.app/Contents/PlugIns installer/packages/io.qt/data/GDeskTunes.app/Contents
cp -Ra GDeskTunes.app/Contents/Resources/qt.conf installer/packages/io.qt/data/GDeskTunes.app/Contents/Resources/

rm -rf installer/packages/org.gearlux.gdesktunes/data/*
mkdir -p installer/packages/org.gearlux.gdesktunes/data
cp -Ra GDeskTunes.app installer/packages/org.gearlux.gdesktunes/data/
rm -rf installer/packages/org.gearlux.gdesktunes/data/GDeskTunes.app/Contents/Frameworks
rm -rf installer/packages/org.gearlux.gdesktunes/data/GDeskTunes.app/Contents/PlugIns
rm -f installer/packages/org.gearlux.gdesktunes/data/GDeskTunes.app/Contents/Resources/qt.conf

rm -rf macosx
rm -rf GDeskTunesSetup.app
~/Qt/QtIFW-1.5.0/bin/repogen -e com.microsoft.vcredist_2008,com.microsoft.vcredist_2013,com.slproweb.openssl -p installer/packages macosx
~/Qt/QtIFW-1.5.0/bin/binarycreator --offline-only -c installer/config/mac_config.xml -e com.microsoft.vcredist_2008,com.microsoft.vcredist_2013,com.slproweb.openssl -p installer/packages GDeskInstaller.app
~/Qt/QtIFW-1.5.0/bin/binarycreator -c installer/config/mac_config.xml -e io.qt,com.microsoft.vcredist_2008,com.microsoft.vcredist_2013,com.slproweb.openssl -p installer/packages GDeskSetup.app
cp -a qt_menu.nib GDeskSetup.app/Contents/Resources
cp -a qt_menu.nib GDeskInstaller.app/Contents/Resources

rm -f GDeskInstaller.zip
zip -r GDeskInstaller.zip GDeskInstaller.app
#rm -rf GDeskSetup.app
