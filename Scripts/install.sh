#!/bin/bash


INSTALL_DIR="/Library/AutoPkg"
LAUNCH_DAEMON="/Library/LaunchDaemons/com.github.autopkg.autopkgserver.plist"


if [ `id -u` -ne 0 ]; then
    echo "Installation must be done as root."
    exit 1
fi


# Remove previously installed version
if [ -e "$INSTALL_DIR" ]; then
    echo "Removing existing install"
    if [ -e "$LAUNCH_DAEMON" ]; then
        echo "Removing Launch Daemon"
        launchctl unload "$LAUNCH_DAEMON"
        rm -f "$LAUNCH_DAEMON"
    fi
    rm -rf "$INSTALL_DIR"
fi


echo "Installing AutoPkg to $INSTALL_DIR"

echo "Creating directories"
mkdir -m 0755 "$INSTALL_DIR"
mkdir -m 0755 "$INSTALL_DIR/autopkglib"
mkdir -m 0755 "$INSTALL_DIR/autopkgserver"

echo "Copying executable"
cp Code/autopkg "$INSTALL_DIR/"
cp Code/automunkiimport "$INSTALL_DIR/"
ln -sf "$INSTALL_DIR/autopkg" /usr/local/bin/autopkg
ln -sf "$INSTALL_DIR/automunkiimport" /usr/local/bin/automunkiimport

echo "Copying library"
cp Code/autopkglib/*.py "$INSTALL_DIR/autopkglib/"
cp Code/autopkglib/version.plist "$INSTALL_DIR/autopkglib/"

echo "Copying server"
cp Code/autopkgserver/autopkgserver "$INSTALL_DIR/autopkgserver/"
cp Code/autopkgserver/*.py "$INSTALL_DIR/autopkgserver/"
cp Code/autopkgserver/autopkgserver.plist "$LAUNCH_DAEMON"

echo "Setting permissions"
find "$INSTALL_DIR" -type f -exec chmod 755 {} \;
chown -hR root:wheel "$INSTALL_DIR"

echo "Installing Launch Daemon"
launchctl load "$LAUNCH_DAEMON"
