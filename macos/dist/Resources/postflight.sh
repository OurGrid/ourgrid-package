#!/bin/bash
APP_ROOT=/Applications/OurGrid.app/Contents

mv /tmp/OurGrid.app/Contents/etc/ourgrid/qemu_images/og-image.qcow2 $APP_ROOT/etc/ourgrid/qemu_images/

mkdir -p /usr/share/ourgrid
chown -R root /Applications/OurGrid.app
chgrp -R wheel /Applications/OurGrid.app
ln -s $APP_ROOT/usr/share/ourgrid/idleness /usr/share/ourgrid/idleness
ln -s $APP_ROOT/Library/LaunchDaemons/org.ourgrid.worker.plist /Library/LaunchDaemons/org.ourgrid.worker.plist
ln -s $APP_ROOT/usr/bin/worker /usr/bin/worker
ln -s $APP_ROOT/usr/bin/worker-gui /usr/bin/worker-gui
launchctl -w load /Library/LaunchDaemons/org.ourgrid.worker.plist
launchctl start org.ourgrid.worker
