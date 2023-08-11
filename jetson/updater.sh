#!/bin/sh -e
BRANCH="main"
URL="https://raw.githubusercontent.com/bluesea-network/bluesea-edge-releases/$BRANCH/jetson"
APP_DIR="/var/cache/bluesea-edge"

if [ -f /tmp/bluesea-edge-updating ]; then
  exit;
fi
cleanup() {
  echo "Removing /tmp/bluesea-edge-updating"
  rm -f /tmp/bluesea-edge-updating
}
trap cleanup EXIT
touch /tmp/bluesea-edge-updating
mkdir -p $APP_DIR
VERSION=$(curl $URL/version.txt)
CURRENT_VERSION=""
if [ -f $APP_DIR/current_version ]; then
  CURRENT_VERSION=$(cat $APP_DIR/current_version)
fi

set -e
if [ "$VERSION" != "$CURRENT_VERSION" ]; then
    echo "New version: $VERSION => download."
    rm -f $APP_DIR/edge-rs-new
    rm -f $APP_DIR/updater.sh-new
    rm -f $APP_DIR/runner.sh-new
    rm -f $APP_DIR/bluesea-edge.service-new

    wget -O $APP_DIR/edge-rs-new.tar.gz "$VERSION"
    rm -rf /tmp/edge-rs-new
    mkdir -p /tmp/edge-rs-new
    tar -xvf $APP_DIR/edge-rs-new.tar.gz -C /tmp/edge-rs-new
    rm $APP_DIR/edge-rs-new.tar.gz
    mv /tmp/edge-rs-new/* $APP_DIR/edge-rs-new
    wget -O $APP_DIR/updater.sh-new "$URL/updater.sh"
    wget -O $APP_DIR/runner.sh-new "$URL/runner.sh"
    wget -O $APP_DIR/bluesea-edge.service-new "$URL/bluesea-edge.service"

    rm -f $APP_DIR/edge-rs    
    mv $APP_DIR/edge-rs-new $APP_DIR/edge-rs
    chmod +x $APP_DIR/edge-rs

    rm -f $APP_DIR/updater.sh
    mv $APP_DIR/updater.sh-new $APP_DIR/updater.sh
    chmod +x $APP_DIR/updater.sh

    rm -f $APP_DIR/runner.sh
    mv $APP_DIR/runner.sh-new $APP_DIR/runner.sh
    chmod +x $APP_DIR/runner.sh

    rm -f /etc/systemd/system/bluesea-edge-agent.service
    mv $APP_DIR/bluesea-edge.service-new /etc/systemd/system/bluesea-edge-agent.service
    chmod +x /etc/systemd/system/bluesea-edge-agent.service

    echo "$VERSION" > $APP_DIR/current_version
    systemctl enable bluesea-edge-agent
    systemctl restart bluesea-edge-agent
fi
