#!/bin/bash
set -e

export DISPLAY=:99

echo "[INFO] Run Xvfb..."
/usr/bin/Xvfb :99 -screen 0 1366x768x24 -ac +extension GLX +render -noreset &
XVFB_PID=$!

sleep 2

echo "[INFO] Run x11vnc..."
x11vnc -xkb -noxrecord -noxfixes -noxdamage \
       -display :99 -forever -bg -nopw \
       -rfbport 5900 -rfbauth /etc/x11vnc.pass

echo "[INFO] Run JMeter..."
jmeter -Jjmeter.laf=CrossPlatform &

wait $XVFB_PID
