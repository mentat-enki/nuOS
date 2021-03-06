#!/usr/bin/false
set -e; set -u; set -C

# nuOS 0.0.9.1a3 - lib/nu_admin.sh - LICENSE: MOZ_PUB
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
[ -z "${nuos_lib_admin_loaded-}" ]
nuos_lib_admin_loaded=y

admin_init () {
	# OEM Default admin user/pass. Definitely change/disable this.
	echo 'admin           -a ADMIN_ACCT     ' ${ADMIN_ACCT=ninja}
	echo -n 'admin pass         ADMIN_PASS      ' && [ -n "${ADMIN_ACCT-}" ] && echo ${ADMIN_PASS=nutz} || echo n/a
	echo -n 'admin name         ADMIN_NAME      ' && [ -n "${ADMIN_ACCT-}" ] && echo ${ADMIN_NAME:="Code Ninja"} || echo n/a
	echo -n 'admin company      ADMIN_CPNY      ' && [ -n "${ADMIN_ACCT-}" ] && echo ${ADMIN_CPNY:="Whey of Peas and Hominy"} || echo n/a # N/I
	echo -n 'admin keys         ADMIN_KEYS      ' && [ -n "${ADMIN_ACCT-}" ] && echo ${ADMIN_KEYS:=~$ADMIN_ACCT/.ssh/id_ecdsa.pub} || echo n/a
	# OEM Default user/pass. Change this.
	echo 'user            -u USER_ACCT      ' ${USER_ACCT=joe}
	echo -n 'user pass          USER_PASS       ' && [ -n "${USER_ACCT-}" ] && echo ${USER_PASS=mama} || echo n/a
	echo -n 'user name          USER_NAME       ' && [ -n "${USER_ACCT-}" ] && echo ${USER_NAME:="Joe Schmoe"} || echo n/a
	echo -n 'user company       USER_CPNY       ' && [ -n "${USER_ACCT-}" ] && echo ${USER_CPNY:="Schmoe 'n' Co., Inc."} || echo n/a # N/I
	echo -n 'user keys          USER_KEYS       ' && [ -n "${USER_ACCT-}" ] && echo ${USER_KEYS:=~$USER_ACCT/.ssh/id_ecdsa.pub} || echo n/a
	# VAR Default backdoor. Change/disable this this.
	echo 'backdoor user   -b BD_ACCT        ' ${BD_ACCT=sumyungai}
	echo -n 'backdoor pass      BD_PASS         ' && [ -n "${BD_ACCT-}" ] && echo ${BD_PASS=_-cream0f-_} || echo n/a
	echo -n 'backdoor name      BD_NAME         ' && [ -n "${BD_ACCT-}" ] && echo ${BD_NAME:="Sum Yun Gai"} || echo n/a
	echo -n 'backdoor company   BD_CPNY         ' && [ -n "${BD_ACCT-}" ] && echo ${BD_CPNY:="In Yer Eye, L.L.C."} || echo n/a # N/I
	echo -n 'backdoor keys      BD_KEYS         ' && [ -n "${BD_ACCT-}" ] && echo ${BD_KEYS:=~$BD_ACCT/.ssh/id_ecdsa.pub} || echo n/a
}

admin_install () {
	local opt_zfs_create=
	if [ -z = $1 ]; then
		opt_zfs_create=y
		shift
	fi		
	local trgt_path="$1"

	key_install () {
		local acct="$1" keys="$2"
		for key in $keys; do
			key="${key%.pub}.pub"
			key=`eval echo $key`
			if [ -f $key ]; then
				local home=
				echo "WARNING: authorizing key '$key' to connect as user '$acct'" >&2
				: ${home:=`chroot "$trgt_path" pw usershow -n $acct | awk 'FS=":" {print $9}'`}
				if [ ! -d "$trgt_path$home/.ssh" ]; then
					(umask 77 && mkdir "$trgt_path$home/.ssh")
					chroot "$trgt_path" chown $acct "$home/.ssh"
				fi
				if [ ! -f "$trgt_path$home/.ssh/authorized_keys" ]; then
					:> "$trgt_path$home/.ssh/authorized_keys"
					chroot "$trgt_path" chown $acct "$home/.ssh/authorized_keys"
				fi
				cat "$key" >> "$trgt_path$home/.ssh/authorized_keys"
			fi
		done
	}

	acct_install () {
		local opt_zfs_create=
		if [ -z = $1 ]; then
			opt_zfs_create=y
			shift
		fi		
		local acct="$1" pass="$2" name="${3-}" cpny="${4-}" keys="${5-}" useradd_flags="${6-}" groupadd_flags="${7-}"
		if [ -n "$acct" ]; then
			echo "WARNING: creating account '$acct' inside new system" >&2
			if [ -n "$opt_zfs_create" ]; then
				zfs create $POOL_NAME/home/$acct
			fi
			chroot "$trgt_path" pw groupadd -n "$acct" $groupadd_flags
			if [ -n "$pass" ]; then
				chroot "$trgt_path" pw useradd -m -n $acct -g $acct -c "$name" $useradd_flags -h 0 <<EOF
$pass
EOF
			else
				chroot "$trgt_path" pw useradd -m -n $acct -g $acct -c "$name" $useradd_flags
			fi
			key_install $acct "$keys"
		fi
	}

	acct_install "$BD_ACCT" "${BD_PASS-}" "${BD_NAME-}" "${BD_CPNY-}" "${BD_KEYS-}" "-u 1000 -G wheel -d /var/bd -s csh" "-g 1000"
	acct_install ${opt_zfs_create:+-z} "$ADMIN_ACCT" "${ADMIN_PASS-}" "${ADMIN_NAME-}" "${ADMIN_CPNY-}" "${ADMIN_KEYS-}" "-G wheel"
	acct_install ${opt_zfs_create:+-z} "$USER_ACCT" "${USER_PASS-}" "${USER_NAME-}" "${USER_CPNY-}" "${USER_KEYS-}"
}
