#!/bin/bash -e

# chroot_config_fs.sh declarations
_hostname=EntropicDK-700
_hostfile0=/etc/hostname
_hostfile1=/etc/hosts
_source_list=/etc/apt/sources.list
_sysctl_conf=/etc/sysctl.conf
_etc_fstab=/etc/fstab
_libfirmware_dir=/lib/firmware
_etc_resolve=/etc/resolv.conf
_init_scripts=/etc/init.d
_sshd_config=/etc/ssh/sshd_config
_init_script_dir=/temp/init.scripts
_lib_modules=/lib/modules
_usr_=/usr/include
_user_name=entropic
_user_password=open-crops-field

add_hostname()
{
	# changing the hostname
	if [ "${_hostname}" = "`grep -s ${_hostname} ${_hostfile0}`" ]; then
		echo "Hostname is as expected ${_hostname}"
	else
		echo "Updating the hostname"
		echo ${_hostname} > ${_hostfile0}
		echo "127.0.0.1  ${_hostname}" > ${_hostfile1}
	fi
}

wifi_firmware_hold()
{
	#New updates of firmware-atheros override ath10k drivers for our wifi card. 
	apt-mark hold firmware-atheros
}


update_passwords_add_accounts()
{
	# changing the password of root ( at present adding intrinsyc as a root user)"
	passwd -d root							# just removing root password

	get_info=`getent passwd ${_user_name}` ||  echo "No ${_user_name} user Found"
	if [[ -z ${get_info} ]]; then
		adduser ${_user_name} --gecos "Entropic Engineering" --disabled-password
		echo "${_user_name}:${_user_password}" | chpasswd
		sudo adduser ${_user_name} sudo
	else
		echo "User already present"
	fi
}

update_rc_scripts()
{
	# updating the rc scripts
	echo "Enabling the rc.d scripts"
	for d in `ls ${_init_script_dir}`;
	do
		echo $d;
		cp ${_init_script_dir}/$d /etc/init.d/;
		update-rc.d $d defaults || echo "Setting $d as defaults"
		update-rc.d $d enable || echo "Enabling $d ..."
	done
}

main()
{
	add_hostname
	update_passwords_add_accounts
	update_rc_scripts
	wifi_firmware_hold
}

main
exit 0
