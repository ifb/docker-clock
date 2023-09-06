#!/usr/bin/with-contenv bash
#shellcheck shell=bash

APPNAME="ublox-setup"
s6wrap=(s6wrap --quiet --timestamps --prepend="${APPNAME}")

s6wrap --args ubxtool -s 9600 -S 115200
s6wrap --args ubxtool -s 115200 -p MODEL,2
s6wrap --args ubxtool -s 115200 -e BINARY -d NMEA -d GLONASS -d GALILEO -d BEIDOU -e SBAS
s6wrap --args ubxtool -w 3 -s 115200 -p SAVE
