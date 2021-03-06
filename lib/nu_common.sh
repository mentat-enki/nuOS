#!/usr/bin/false
set -e; set -u; set -C

# nuOS 0.0.9.1a3 - lib/nu_common.sh - LICENSE: MOZ_PUB
#
# Copyright (c) 2008-2013 Chad Jacob Milios and Crop Circle Systems, Inc.
# All rights reserved.
#
# This Source Code Form is subject to the terms of the Mozilla Public License, v2.0.
# If a copy of the MPL was not distributed alongside this file, you can obtain one at
# http://mozilla.org/MPL/2.0/ . This software project is not affiliated with the Mozilla
# Foundation.
#
# Official updates and community support available at http://nuos.org .
# Other licensing options and professional services available at http://ccsys.com .

nuos_lib_ver=0.0.9.1a3
[ $nuos_lib_ver = "$NUOS_VER" ]
[ -n "${nuos_lib_system_loaded-}" ]
[ -z "${nuos_lib_common_loaded-}" ]
nuos_lib_common_loaded=y

nuos_init () {
	if [ -r "${CHROOTDIR-}/etc/nuos.conf" ]; then
		. "${CHROOTDIR-}/etc/nuos.conf"
	fi
	echo 'nuos app v#                       ' $NUOS_VER
	echo 'nuos support       NUOS_SUPPORTED ' ${NUOS_SUPPORTED:=UNSUPPORTED}
	echo 'pool name       -p POOL_NAME      ' ${POOL_NAME:=thumb}
	echo 'host opsys                        ' ${HOSTOS_TYPE:=nuOS}
	echo 'host opsys v#                     ' ${HOSTOS_VER:=$NUOS_VER}
}
