#!/usr/bin/with-contenv bash
#shellcheck shell=bash

s6-setuidgid root /usr/bin/ublox-setup.sh
