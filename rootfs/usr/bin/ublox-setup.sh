#!/usr/bin/with-contenv bash
#shellcheck shell=bash

APPNAME="ublox-setup"
s6wrap=(s6wrap --quiet --timestamps --prepend="${APPNAME}")

s6wrap --args ubxtool -P 18 -v 0 -s 9600 -S 115200 -f /dev/ttyAMA0
s6wrap --args ubxtool -P 18 -v 0 -s 115200 -f /dev/ttyAMA0 -p MODEL,2
s6wrap --args ubxtool -P 18 -v 0 -s 115200 -f /dev/ttyAMA0 -e BINARY -d NMEA -d GLONASS -d GALILEO -d BEIDOU -e SBAS
s6wrap --args ubxtool -P 18 -v 2 -w 3 -s 115200 -f /dev/ttyAMA0 -p SAVE
