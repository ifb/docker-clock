#!/usr/bin/with-contenv bash
#shellcheck shell=bash

APPNAME="ublox-setup"
s6wrap=(s6wrap --quiet --timestamps --prepend="${APPNAME}")

s6wrap --args ubxtool -P 18 -s 9600 -S 115200 -f /dev/gpsd0
s6wrap --args ubxtool -P 18 -s 115200 -f /dev/gpsd0 -e BINARY
s6wrap --args ubxtool -P 18 -s 115200 -f /dev/gpsd0 -p MODEL,2
s6wrap --args ubxtool -P 18 -s 115200 -f /dev/gpsd0 -d NMEA -d GLONASS -d GALILEO -d BEIDOU -e SBAS
#s6wrap --args ubxtool -P 18 -v 2 -w 2 -s 115200 -f /dev/gpsd0 -d GLONASS
#s6wrap --args ubxtool -P 18 -v 2 -w 2 -s 115200 -f /dev/gpsd0 -d GALILEO
#s6wrap --args ubxtool -P 18 -v 2 -w 2 -s 115200 -f /dev/gpsd0 -d BEIDOU
#s6wrap --args ubxtool -P 18 -v 2 -w 2 -s 115200 -f /dev/gpsd0 -e SBAS
s6wrap --args ubxtool -P 18 -v 2 -w 3 -s 115200 -f /dev/gpsd0 -p SAVE
