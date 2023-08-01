#!/bin/sh
BRANCH="main"
URL="https://raw.githubusercontent.com/bluesea-network/bluesea-edge-releases/$BRANCH/jetson"
APP_DIR="/var/cache/bluesea-edge"

mkdir -p $APP_DIR
cd $APP_DIR
rm -f updater.sh
wget "$URL/updater.sh"
chmod +x updater.sh

if crontab -l | grep bluesea-edge; then
  echo "Already has cronjob"
else
  (crontab -l 2>/dev/null; echo "*/5 * * * * $APP_DIR/updater.sh >/dev/null 2>&1") | crontab -
fi

rm -f $APP_DIR/current_version
sh updater.sh
