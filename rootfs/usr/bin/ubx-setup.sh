#!/bin/bash

s6wrap --quiet --prepend=01-ubxtool --timestamps --args  echo "Setting up UBLOX GPS module"
s6wrap --quiet --prepend=01-ubxtool --timestamps --args  ubxtool $UBXOPTS -s 9600 -S 115200
s6wrap --quiet --prepend=01-ubxtool --timestamps --args  ubxtool $UBXOPTS -s 115200 -p MODEL,2
s6wrap --quiet --prepend=01-ubxtool --timestamps --args  ubxtool $UBXOPTS -s 115200 -e BINARY -d NMEA -d GLONASS -d GALILEO -d BEIDOU -e SBAS
s6wrap --quiet --prepend=01-ubxtool --timestamps --args  ubxtool $UBXOPTS -s 115200 -w 3 -p SAVE