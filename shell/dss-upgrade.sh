#!/bin/bash

dss_version=$1

echo "[DSS_UPGRADE_WIZARD] You asked for Dataiku DSS version $1. You shall be served, my dear."

cd $DSS_INSTALL_DIRS

# Download new version and unpack it
installer_targz=dataiku-dss-$dss_version-osx.tar.gz
installer_dir=dataiku-dss-$dss_version-osx/


if [ -d "$installer_dir" ]
then
	echo "[DSS_UPGRADE_WIZARD] Directory $installer_dir found, reusing"
else
	echo "[DSS_UPGRADE_WIZARD] Directory $installer_dir not found"
	if [ -f "$installer_targz" ]
	then
		echo "[DSS_UPGRADE_WIZARD] File $installer_targz found, reusing"
	else
		echo "[DSS_UPGRADE_WIZARD] File $installer_targz not found, downloading"
		wget http://downloads.dataiku.com/public/studio/$dss_version/$installer_targz
	fi
	echo "[DSS_UPGRADE_WIZARD] File $installer_targz downloaded, now unpacking"
	tar xzf $installer_targz
	rm $installer_targz
fi

DSS_DESIGN_VERSION=$(cat $DSS_DESIGN_DATADIR/dss-version.json | grep "product_version" | cut -d ":" -f 2 | tr -d '"')
DSS_AUTOMATION_VERSION=$(cat $DSS_AUTOMATION_DATADIR/dss-version.json | grep "product_version" | cut -d ":" -f 2 | tr -d '"')
DSS_API_VERSION=$(cat $DSS_API_DATADIR/dss-version.json | grep "product_version" | cut -d ":" -f 2 | tr -d '"')

# Stop all Dataiku DSS instances
echo "[DSS_UPGRADE_WIZARD] Stopping all DSS instances"
echo "[DSS_UPGRADE_WIZARD] Stopping DSS design node"
$DSS_DESIGN_DATADIR/bin/dss stop
echo "[DSS_UPGRADE_WIZARD] Stopping DSS automation node"
$DSS_AUTOMATION_DATADIR/bin/dss stop
echo "[DSS_UPGRADE_WIZARD] Stopping DSS api node"
$DSS_API_DATADIR/bin/dss stop

# Upgrade the instances
echo "[DSS_UPGRADE_WIZARD] Upgrading all DSS instances to version $dss_version"
echo "[DSS_UPGRADE_WIZARD] Upgrading DSS design node to version $dss_version"
$installer_dir/installer.sh -d $DSS_DESIGN_DATADIR -u
echo "[DSS_UPGRADE_WIZARD] Upgrading DSS automation node to version $dss_version"
$installer_dir/installer.sh -d $DSS_AUTOMATION_DATADIR -u
echo "[DSS_UPGRADE_WIZARD] Upgrading DSS api node to version $dss_version"
$installer_dir/installer.sh -d $DSS_API_DATADIR -u

# Re install R integration
echo "[DSS_UPGRADE_WIZARD] Reinstalling R on all instances. What I am doing??? Please stop this madness"
echo "[DSS_UPGRADE_WIZARD] Reinstalling R on DSS design node. Arg."
$DSS_DESIGN_DATADIR/bin/dssadmin install-R-integration
echo "[DSS_UPGRADE_WIZARD] Reinstalling R on DSS automation node. Je vous demande de vous arrêter."
$DSS_AUTOMATION_DATADIR/bin/dssadmin install-R-integration
echo "[DSS_UPGRADE_WIZARD] Reinstalling R on DSS api node. Ayez pitié, tuez moi."
$DSS_API_DATADIR/bin/dssadmin install-R-integration

# Start all Dataiku DSS instances
echo "[DSS_UPGRADE_WIZARD] Waking up all DSS instances"
echo "[DSS_UPGRADE_WIZARD] Waking up DSS design node"
$DSS_DESIGN_DATADIR/bin/dss start
echo "[DSS_UPGRADE_WIZARD] Waking up DSS automation node"
$DSS_AUTOMATION_DATADIR/bin/dss start
echo "[DSS_UPGRADE_WIZARD] Waking up DSS api node"
$DSS_API_DATADIR/bin/dss start
echo "[DSS_UPGRADE_WIZARD] Get back to work, lazy statistician. DSS is back online."
