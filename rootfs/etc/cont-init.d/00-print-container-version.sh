#!/usr/bin/with-contenv bash
# shellcheck shell=bash disable=SC1091,SC2015

source /scripts/common

# Print container version
#---------------------------------------------------------------------------------------------
# Copyright (C) 2023, Ramon F. Kolb (kx1t)
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation, either version 3 of the License, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with this program.
# If not, see <https://www.gnu.org/licenses/>.
#---------------------------------------------------------------------------------------------

[[ -f /.CONTAINER_VERSION ]] && s6wrap --quiet --prepend=00-print-container-version --timestamps --args echo "Container Version: $(cat /.CONTAINER_VERSION), build date $(stat -c '%y' /.CONTAINER_VERSION |sed 's|\(.*\)\.[0-9]* \(.*\)|\1 \2|g')" || true
