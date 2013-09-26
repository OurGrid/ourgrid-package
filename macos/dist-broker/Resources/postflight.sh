#!/bin/bash
chown -R root /Applications/OurGrid\ Broker.app
chgrp -R wheel /Applications/OurGrid\ Broker.app
ln -s /Applications/OurGrid\ Broker.app/Contents/usr/bin/broker /usr/bin/broker | true
ln -s /Applications/OurGrid\ Broker.app/Contents/usr/bin/broker-gui /usr/bin/broker-gui | true
