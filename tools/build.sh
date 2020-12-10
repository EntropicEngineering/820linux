#!/bin/bash -e
#set -x	# only enable when need to debug

# Taking all arguments as an input
args="$@"

# performing basic necessary things
_home=`pwd`
_whome=`whoami`
_core=`nproc`
DATE=$(date "+%Y.%m.%d-%H.%M.%S")
KERNEL_VER=4.14.0

# getting some colorful information.
source ${_home}/logger.sh

# variables used by the system;
_clean=
_bversion=sid
_build_kernel=
_get_dist=
_create_rootfs=
_install_dependencies=

# list of folders used by this script so its better they be there
_build_dir=${_home}/../binaries
_prebuilt_dir=${_home}/../prebuilt-binaries/binaries
#mount point for rootfs raw image
_mnt_dir=${_build_dir}/mnt_rootfs
#rootfs componants generated from this build
_target_dir=${_home}/../build-rootfs
_rootfs_patch_dir=${_home}/../rootfs-patch
_dl_dir=${_home}/../downloads
# this directories will be present already or created dynanmically
_tools_dir=${_home}
_src_dir=${_home}/../source_packages
_scipt_dir=${_src_dir}/scripts
_config_dir=${_src_dir}/configs
_init_script_dir=${_src_dir}/init.scripts
#_verification_dir=${_home}/../verificationTools
_skl_dir=${_home}/skales
_patch_dir=${_src_dir}/patches
_kn_dir=${_home}/../kernel
_kn_rel=origin/release/qcomlt-4.14
_kn_commit=1d9f9c9a67bf9e3e8501095a87e3f05e2ae007e4
_kn_patches=${_patch_dir}/kernel
_initramfs_dir=${_src_dir}/initramfs
_dtb_dir=${_kn_dir}/arch/arm64/boot/dts/qcom
_linaro_toolchain_dir=${_home}/linaro-toolchain
_kn_local_rel=${KERNEL_VER}-qcomlt-arm64

_lk_dir=${_home}/../lk
_lk_patches=${_patch_dir}/lk
_lk_commit=7a5154bfab6c641a2878db4159e268a75a292c54
# list of files & binaries used by this script
_flash_script=${_build_dir}/flashall.sh
_kn_img=${_kn_dir}/arch/arm64/boot/Image
_initramfs_img=${_build_dir}/initramfs
_dtb_img=${_kn_dir}/dt.img
_linaro_manifest=${_linaro_toolchain_name}/gcc-linaro-7.5.0-2019.12-linux-manifest.txt
_linaro_initramfs_img=initrd.img-4.14.0-qcomlt-arm64


#linaro rootfs build number (Latest as of Dec 9 2020 is 727)
_linaro_build_id=727

#linaro kernel build number (Latest build with kernel 4.14 to remain compatible with Entropic & ITC patches)
_linaro_kernel_build_id=423

# linaro toolchain
_linaro_toolchain_url=https://releases.linaro.org/components/toolchain/binaries/7.5-2019.12/aarch64-linux-gnu
_linaro_toolchain_name=gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu
_linaro_toolchain_ver=${_linaro_toolchain_name}.tar.xz
# skales
_skales_tool=git://codeaurora.org/quic/kernel/skales
_skales_commit=c2bfa15aa5bfc4e3f1b32de28e327b80b37db1cf

# target file system options
_rootfs_name=rootfs-${_bversion}-linaro-${_linaro_build_id}.img
_boot_name=boot-linaro-${_linaro_build_id}.img

_rootfs_mount=rootfs-mount.img

_def_bash=/bin/bash
_qemu_=/usr/bin/qemu-aarch64-static




# this option is always present in every script; indeed it is helpful
usage()
{
	# this is the main usage script used to build the overall system
	echo -e "\n${BOLD}Help${ENDING}:\tThis script fetches  tools/sources/binaries from the linaro and other repositories"
	echo -e "\tThis script also builds LK bootloader and Linux Kernel to create final rootfs"
	echo -e "\t${BOLD}Option${ENDING}: -a|--all\t\t\tTo build all images"
	echo -e "\t\t-c|--clean\t\t\tTo clean projects"
	echo -e "\t\t-lk|--little-kernel\t\tTo build the Little Kernel Bootloader"
	echo -e "\t\t-k|--kernel\t\t\tTo build the Linux kernel"
	echo -e "\t\t-r|--rootfs\t\t\tTo build/create Debian rootfs"
	echo -e "\t\t-h|--help\t\t\tTo show this screen\n"
	echo -e "${BOLD}Example Usage${ENDING}:\t${GREEN}$0 -a\t\t\t- Full build"
	echo -e "\t\t$0 -c\t\t\t- Clean buiild"
	echo -e "\t\t$0 -c -lk\t\t- Clean and build LK bootloader"
	echo -e "\t\t$0 -lk\t\t\t- LK bootloader incremental build"
	echo -e "\t\t$0 -c -k\t\t- Clean and build Kernel"
	echo -e "\t\t$0 -k\t\t\t- Kernel incremental build"
	echo -e "\t\t$0 -r\t\t\t- Create Debian rootfs image"
}

# This will create the basic list of requried directory before the beginning
check_and_create_dirs()
{
	# list of directories needs to be created if not present.
	_dir_list="${_build_dir} ${_target_dir} ${_target_dir}/usr ${_dl_dir} ${_src_dir}"
	for i in ${_dir_list};
	do
		if [ ! -d $i ]; then
			mkdir -p $i
			logme_green "Creating "$i" directory"
		else
			logme_cyan "$i is already present"
		fi
	done
}

install_dependencies()
{
	_hostPackages="git libfdt-dev android-tools-fsutils flex bison libssl-dev libguestfs-tools qemu-utils qemu-user-static"
	for d in $_hostPackages;
	do
		logme_yellow " Checking ${d} installation"
		# Use dpkg to check if a pkg is installed or not.
		# We don't care about the output, so discard.
		if (dpkg -s $d) &> /dev/null
		then
			logme_green "${d} is already present"
		else
			sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install $d
		fi
	done
}

# Getting the toolchain from the *-*-*-*-*-*-*-*-* Internet.
get_lk_toolchain()
{
	cd ${_dl_dir}
	if [ ! -d arm-eabi-4.8 ]; then
		git clone git://codeaurora.org/platform/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8.git -b LA.HB.1.3.2-19600-8x96.0
	fi

	if [ ! -d ${_tools_dir}/arm-eabi-4.8 ]; then
		cp -Rf arm-eabi-4.8 ${_tools_dir}
	fi

	if [ ! -d signlk ]; then
		git clone https://git.linaro.org/landing-teams/working/qualcomm/signlk.git -b 820
		chmod +x ${_dl_dir}/signlk/signlk.sh
	fi

	if [ ! -d ${_tools_dir}/signlk ]; then
		cp -Rf signlk ${_tools_dir}
	fi
}

get_kernel_toolchain()
{
	if [ ! -f ${_dl_dir}/${_linaro_toolchain_ver} ]; then
		wget --no-check-certificate ${_linaro_toolchain_url}/${_linaro_toolchain_ver} -P ${_dl_dir}
		if [ $? -ne 0 ]; then
			logme_red "Download failed .... "
			logme_magenta "Cleaning the mess ... "
			rm -rf ${_dl_dir}/*
		fi
	else
		logme_green "${_linaro_toolchain_ver} is present, only need to extract"
	fi

	if [ ! -d ${_linaro_toolchain_dir} ]; then
		logme_green "Toolchain is not present at ${_linaro_toolchain_dir}"
		tar xvf ${_dl_dir}/${_linaro_toolchain_ver} -C .
		mv ${_linaro_toolchain_name} ${_linaro_toolchain_dir}
		wget --no-check-certificate ${_linaro_toolchain_url}/${_linaro_toolchain_ver}.asc -P ${_linaro_toolchain_dir}
	else
		logme_green "Toolchain is present at ${_linaro_toolchain_dir}"
	fi
}

get_skales()
{
	if [ ! -d ${_dl_dir}/skales ]; then
		logme_green "Getting the skales from ${_skales_tool} to ${_skl_dir}"
		git clone ${_skales_tool} ${_dl_dir}/skales
		cd ${_dl_dir}/skales
		git checkout -b kernel_patches ${_skales_commit}
		if [ $? = 0 ]; then
			logme_green "Downloaded skales in ${_dl_dir}/skales"
		else
			logme_red "Skale download failed from ${_skales_tool}"
		fi
	fi

	if [ ! -d ${_skl_dir} ]; then
		logme_green "Skales is not present at ${_skl_dir}. copying to tools dir"
		cp -Rf ${_dl_dir}/skales ${_skl_dir}
	fi
}

get_rootfs_utils()
{
	cp -rf ${_dl_dir}/e2fsck  ${_tools_dir}
	cp -rf ${_dl_dir}/resize2fs ${_tools_dir}
}

get_repo()
{
	_repo=`which repo` || echo "There is no repo present, downloding it now"
	if [ -z ${_repo} ]; then
		if [ ! -d ${_dl_dir}/bin ]; then
			mkdir ${_dl_dir}/bin
		fi
		curl https://storage.googleapis.com/git-repo-downloads/repo > ${_dl_dir}/bin/repo
		if [ $? = 0 ]; then
			chmod a+x ${_dl_dir}/bin/repo
			_repo=${_dl_dir}/bin/repo
		else
			logme_red "repo download failed, try again or do it manually"
		fi
	else
		logme_green "repo is present in the system, hence not updating it"
	fi
}

git_config_check()
{
	isNameConfigured=`git config --list | grep user.name | cut -d'=' -f2`
	if [ -z "${isNameConfigured}" ]; then
		logme_red "You need to configure the git credentials"
		logme_green "For Example:"
		logme_green "\t\tgit config --global user.name \"<users name>\""
		logme_green "\t\tgit config --global user.email \"<users email>\""
		exit 5;
	fi
}

patch_lk()
{
	for d in `find ${_lk_patches} -type f -name "*.patch" | sort`
	do
		git apply --check $d
		if [ $? = 0 ]; then
			logme_yellow "Applying $d"
			git am --ignore-whitespace $d
		else
		logme_green "No need to apply the "$d""
		fi
	done
}

get_lk()
{
	get_lk_toolchain

	cd ${_home}/..
	git clone https://git.linaro.org/landing-teams/working/qualcomm/lk.git -b release/LA.HB.1.3.2-19600-8x96.0 --single-branch
	cd ${_lk_dir}
	git checkout -b kernel_patches ${_lk_commit}
	patch_lk
}

lk_build()
{
	# Get the kernel externally.
	if [ ! -d ${_lk_dir} ]; then
		get_lk
	fi

	cd ${_lk_dir}

	# Clean/Remove the directory if clean option is enabled
	if [ xy = "x${_clean}" ]; then
		logme_red "Cleaning the LK"
		make -j${_core} msm8996 UFS_BOOT=1 TOOLCHAIN_PREFIX=${_home}/arm-eabi-4.8/bin/arm-eabi- clean
	fi

	if [ -d ${_home}/arm-eabi-4.8 ]; then
		make -j${_core} msm8996 UFS_BOOT=1 TOOLCHAIN_PREFIX=${_home}/arm-eabi-4.8/bin/arm-eabi-
		mv ./build-msm8996/emmc_appsboot.mbn ./build-msm8996/emmc_appsboot_unsigned.mbn
	fi

	if [ -d ${_home}/signlk ]; then
		chmod +x ${_home}/signlk/signlk.sh
		${_home}/signlk/signlk.sh -i=./build-msm8996/emmc_appsboot_unsigned.mbn -o=./build-msm8996/emmc_appsboot.mbn -d
		cp ./build-msm8996/emmc_appsboot.mbn ${_build_dir}
	fi
}

patch_kernel()
{
	for d in `find ${_kn_patches} -type f -name "*.patch" | sort`
	do
		git apply --check $d
		if [ $? = 0 ]; then
			logme_yellow "Applying $d"
			git am --ignore-whitespace $d
		else
			logme_green "No need to apply the "$d""
		fi
	done
}

get_linaro_kernel()
{
	# setting the path for repo binary
	get_repo

	# check git_config
	git_config_check

	# jusn a check for toolchain
	get_kernel_toolchain

	# Starting to take the kernel from internet source
	echo -e "Kernel is not present, taking it from source(internet)"
	echo -e ${_RED}"Attention: User is requried to attend the PC while this process" ${_ENDING}
	cd ${_home}/..
	git clone https://git.linaro.org/landing-teams/working/qualcomm/kernel.git -b release/qcomlt-4.14 --single-branch
	cd ${_kn_dir}
	git checkout -b kernel_patches ${_kn_commit}
	# now its time to apply patches
	patch_kernel
}

# Used to build the kernel with the default config file
kn_build()
{
	# Get the kernel externally.
	if [ ! -d ${_kn_dir} ]; then
		get_linaro_kernel
	fi

	# Clean/Remove the directory if clean option is enabled
	cd ${_kn_dir}
	if [ xy = "x${_clean}" ]; then
		logme_red "Cleaning the kernel"
		make clean;
		make distclean;
	fi

	if [ -d ${_linaro_toolchain_dir} ]; then
		export ARCH=arm64
		export CROSS_COMPILE=${_linaro_toolchain_dir}/bin/aarch64-linux-gnu-
		logme_green "Exported $ARCH and $CROSS_COMPILE"
	else
		logme_red "Compiler is not installed, It is required to build kernel"
		logme_red "Use following command to install it,"
		logme_yellow "$0 -i"
		logme_red "or you may use $0 ${args} adding "-i" option to it"
		logme_yellow "Such as $0 ${args} -i"
		exit
	fi
	make defconfig distro.config
	make -j${_core} Image dtbs KERNELRELEASE=${_kn_local_rel}
	if [ -d ${_target_dir}/usr ]; then
		make INSTALL_HDR_PATH=${_target_dir}/usr headers_install
		make -j${_core} modules KERNELRELEASE=${_kn_local_rel}
		if [ -d ${_target_dir}/lib/modules/${_kn_local_rel} ]; then
			rm -rf ${_target_dir}/lib/modules/${_kn_local_rel}
		fi
		make INSTALL_MOD_PATH=${_target_dir} modules_install KERNELRELEASE=${_kn_local_rel}
	fi

	get_linaro_initramfs
	# from this point all the images will be created one after another.
	logme_green "Creating the device tree package"
	${_skl_dir}/dtbTool -o ${_dtb_img} -s 4096  ${_dtb_dir}
	logme_green "Creating the final package for the device"
	${_skl_dir}/mkbootimg --base 0 --kernel ${_kn_img} --ramdisk ${_dl_dir}/${_linaro_initramfs_img} \
	--output ${_build_dir}/${_boot_name} \
	--dt ${_dtb_img} --pagesize "4096" --base "0x80000000" \
	--cmdline "root=/dev/disk/by-partlabel/userdata rw rootwait console=ttyMSM0,115200n8"
}

get_linaro_initramfs()
{

	cd ${_dl_dir}
	if [ ! -f ${_dl_dir}/${_linaro_initramfs_img} ]; then
		wget http://builds.96boards.org/snapshots/dragonboard820c/linaro/debian/${_linaro_kernel_build_id}/${_linaro_initramfs_img}
	 	if [ $? -ne 0 ]; then
			logme_red "initrd download failed .... "
		fi
	fi
}

get_linaro_rootfs()
{
	if [ ! -f ${_prebuilt_dir}/${_rootfs_name}.gz ]; then
		cd ${_dl_dir}
		if [ ! -f ${_dl_dir}/linaro-sid-alip-dragonboard-820c-${_linaro_build_id}.img.gz ]; then
			wget http://builds.96boards.org/snapshots/dragonboard820c/linaro/debian/${_linaro_build_id}/linaro-sid-alip-dragonboard-820c-${_linaro_build_id}.img.gz
			if [ $? -ne 0 ]; then
				logme_red "rootfs download failed .... "
			fi
		fi
		gunzip -k linaro-sid-alip-dragonboard-820c-${_linaro_build_id}.img.gz
		mv linaro-sid-alip-dragonboard-820c-${_linaro_build_id}.img ${_build_dir}/${_rootfs_mount}
	else
		if [ -f ${_prebuilt_dir}/${_rootfs_name} ]; then
			rm -rf ${_prebuilt_dir}/${_rootfs_name}
		fi
		gunzip -k ${_prebuilt_dir}/${_rootfs_name}.gz
		mv ${_prebuilt_dir}/${_rootfs_name} ${_build_dir}/${_rootfs_mount}
	fi
}

mount_rootfs()
{
	if [ ! -d ${_mnt_dir} ]; then
		mkdir ${_mnt_dir}
	else
		if [ "$(ls -A ${_mnt_dir})" ]; then
			logme_red "Unmount ${_mnt_dir} first"
			sudo umount ${_mnt_dir}
		fi
	fi
	logme_green "Mounting to a temp location"
	simg2img ${_build_dir}/${_rootfs_mount} ${_build_dir}/${_rootfs_mount}.raw
	# resize the image to allow for the new kernel modules
	cd ${_home};
	./e2fsck -f -y ${_build_dir}/${_rootfs_mount}.raw
	./resize2fs ${_build_dir}/${_rootfs_mount}.raw 4G

	if [ "xy" = "x${_server}" ]; then
		guestmount -o allow_other -a ${_build_dir}/${_rootfs_mount}.raw -m /dev/sda --pid-file guestmount.pid ${_mnt_dir}
	else
		sudo mount -o loop  ${_build_dir}/${_rootfs_mount}.raw ${_mnt_dir}
	fi
	sync
}

transfer_image_data()
{
	logme_green "Just transferring everytime, everything"
#	sudo rsync -grupqolJ ${_target_dir}/*  ${_mnt_dir}/ --exclude="/proc"

	if [ "xy" = "x${_server}" ]; then

		#Clean up /boot and /var/lib/initramfs-tools so we can copy in the correct 4.14 kernel versions on top of the 5.7 versions that come from linaro 694
		#This is done to run linaro 694 on kernel 4.14 so that the Entropic and ITC patches still work.
		sudo rm -rf ${_mnt_dir}/boot/*
		sudo rm -rf ${_mnt_dir}/var/lib/initramfs-tools/*

		#copying local build componants
		cp -rf --preserve=links ${_target_dir}/* ${_mnt_dir}/
		#copying rootfs changes for Open-Q platform
		cp -rf --preserve=links ${_rootfs_patch_dir}/* ${_mnt_dir}/

		if [  ! -d ${_mnt_dir}/temp/ ]; then
			mkdir ${_mnt_dir}/temp/
		fi

		logme_green "Copying ${_scipt_dir} & ${_init_script_dir} to target/temp"
		cp -r ${_init_script_dir} ${_mnt_dir}/temp/
		rsync ${_scipt_dir}/*.sh ${_mnt_dir}/temp/

		# copying the qemu binary to make sure chroot works
		if [ -d ${_mnt_dir}/usr/bin/ ]; then
			if [ -f ${_mnt_dir}/${_qemu_} ]; then
				logme_red "${_qemu_} is present in chroot"
			else
				logme_green "Copying ${_qemu_} in chroot"
				cp ${_qemu_} ${_mnt_dir}/usr/bin/
			fi
		fi

		# we will transfer the control from here for further processing
		logme_cyan "Changing root to ${_mnt_dir}"
		if [ -e ${_mnt_dir}/${_def_bash} ]; then
			for d in `ls ${_mnt_dir}/temp/0*.sh`;
			do
				logme_green "Processing ${d##*/}"
				#remove password access to systemd-nspawn to remove user intervention
				sudo systemd-nspawn -D ${_mnt_dir} /temp/${d##*/}
				logme_yellow "Processed ${d##*/}"
			done
		fi
	else
		#Clean up /boot and /var/lib/initramfs-tools so we can copy in the correct 4.14 kernel versions on top of the 5.7 versions that come from linaro 694
		#This is done to run linaro 694 on kernel 4.14 so that the Entropic and ITC patches still work.
		sudo rm -rf ${_mnt_dir}/boot/*
		sudo rm -rf ${_mnt_dir}/var/lib/initramfs-tools/*
		
		sudo rm -rf ${_mnt_dir}/lib/modules/
		#copying local build componants
		sudo cp -rf --preserve=links ${_target_dir}/* ${_mnt_dir}/
		#copying rootfs changes for Open-Q platform
		sudo cp -rf --preserve=links ${_rootfs_patch_dir}/* ${_mnt_dir}/

		if [  ! -d ${_mnt_dir}/temp/ ]; then
			sudo mkdir ${_mnt_dir}/temp/
		fi

		logme_green "Copying ${_scipt_dir} & ${_init_script_dir} to target/temp"
		sudo cp -r ${_init_script_dir} ${_mnt_dir}/temp/
		sudo rsync ${_scipt_dir}/*.sh ${_mnt_dir}/temp/

		# copying the qemu binary to make sure chroot works
		if [ -d ${_mnt_dir}/usr/bin/ ]; then
			if [ -f ${_mnt_dir}/${_qemu_} ]; then
				logme_red "${_qemu_} is present in chroot"
			else
				logme_green "Copying ${_qemu_} in chroot"
				sudo cp ${_qemu_} ${_mnt_dir}/usr/bin/
			fi
		fi

		# we will transfer the control from here for further processing
		logme_cyan "Changing root to ${_mnt_dir}"
		if [ -e ${_mnt_dir}/${_def_bash} ]; then
			for d in `ls ${_mnt_dir}/temp/0*.sh`;
			do
				logme_green "Processing ${d##*/}"
				sudo chroot ${_mnt_dir} /temp/${d##*/}
				logme_yellow "Processed ${d##*/}"
			done
		fi
	fi
	sync
}

unmount_rootfs()
{
	sync
	logme_red "Unmounting the ${_mnt_dir} ..."
	#mount the rootfs
	if [ "xy" = "x${_server}" ]; then
		# Save the PID of guestmount *before* calling guestunmount.
		pid="$(cat guestmount.pid)"
		guestunmount ${_mnt_dir}
		timeout=10
		count=$timeout
		while kill -0 "$pid" 2>/dev/null && [ $count -gt 0 ]; do
			sleep 1
			((count--))
		done
		if [ $count -eq 0 ]; then
			echo "$0: wait for guestmount to exit failed after $timeout seconds"
			exit 1
		fi
		rm -rf guestmount.pid
	else
		sudo umount ${_mnt_dir}
	fi
	#delete old rootfs
	if [ -f ${_build_dir}/${_rootfs_name} ]; then
		rm -rf ${_build_dir}/${_rootfs_name}
	fi
	#create sparse image of rootfs
	img2simg ${_build_dir}/${_rootfs_mount}.raw  ${_build_dir}/${_rootfs_name}
	#compress the rootfs
	gzip -f ${_build_dir}/${_rootfs_name}
	#clean all
	rm -rf ${_build_dir}/${_rootfs_name} ${_build_dir}/${_rootfs_mount} ${_build_dir}/${_rootfs_mount}.raw
	rm -rf ${_mnt_dir}
}

# to create the package for final use
cp_build()
{
	# now need to mount the file system
	mount_rootfs

	# transfer from target to the system image (mounted path)
	transfer_image_data

	# I think I did almost everything so unmounting the file system
	unmount_rootfs

}

create_flashall()
{
	rm -rf ${_flash_script}
	echo -e "#!/bin/bash" >> ${_flash_script}
	echo -e "echo -e \"Erasing the LK bootloader partition\" " >> ${_flash_script}
	echo -e "fastboot erase aboot" >> ${_flash_script}
	echo -e "echo -e \"Flashing the emmc_appsboot.mbn\" " >> ${_flash_script}
	echo -e "fastboot flash aboot emmc_appsboot.mbn" >> ${_flash_script}
	echo -e "echo -e \"Erasing the boot partition\" " >> ${_flash_script}
	echo -e "fastboot erase boot" >> ${_flash_script}
	echo -e "echo -e \"Flashing the boot-linaro-${_linaro_build_id}.img\" " >> ${_flash_script}
	echo -e "fastboot flash:raw boot boot-linaro-${_linaro_build_id}.img" >> ${_flash_script}
	echo -e "echo -e \"Erasing the userdata(rootfs) partition\" " >> ${_flash_script}
	echo -e "if [ ! -f rootfs-${_bversion}-linaro-${_linaro_build_id}.img ]; then" >> ${_flash_script}
	echo -e "\tgunzip -k rootfs-${_bversion}-linaro-${_linaro_build_id}.img.gz" >> ${_flash_script}
	echo -e "fi" >> ${_flash_script}
	echo -e "fastboot erase userdata" >> ${_flash_script}
	echo -e "echo -e \"Flashing the rootfs-${_bversion}-linaro-${_linaro_build_id}.img\" " >> ${_flash_script}
	echo -e "fastboot flash userdata rootfs-${_bversion}-linaro-${_linaro_build_id}.img" >> ${_flash_script}
	echo -e "fastboot reboot" >> ${_flash_script}
	chmod +x ${_flash_script}
}

gen_checksum()
{
	logme_cyan "Generating the checksum for the binaries"
	if [ -f ${_build_dir}/checksum ]; then
		rm -rf ${_build_dir}/checksum
	fi
	md5sum ${_build_dir}/* >> ${_build_dir}/checksum
	sed -i 's|'${_build_dir}'/||g' ${_build_dir}/checksum
}

# This function is only called when trap is triggered;
# this is only for cleaning up the mess which is left in between processes
clean_up()
{
	logme_red "Cleaning up everything I can ... :)"
	if [ -d ${_lk_dir} ]; then
		cd ${_lk_dir}
		make -j${_core} msm8996 UFS_BOOT=1 TOOLCHAIN_PREFIX=${_home}/arm-eabi-4.8/bin/arm-eabi- clean
	fi

	if [ -d ${_kn_dir} ]; then
		cd ${_kn_dir}
		logme_red "Cleaning the kernel"
		make clean;
		make distclean;
	fi
	logme_red "Cleaning the previous binaries"
	rm -rf ${_build_dir}/*
	rm -rf ${_target_dir}
	if [ -d ${_mnt_dir} ]; then
		unmount_rootfs || echo "Unmounting of FS failed"
	fi
	exit
}

parse_me()
{
	if [ -z "${args}" ]; then
		logme_cyan "No arguments found on command line"
		args="*"
	fi
	for i in $args
	do
		arg1=$(echo ${i} | cut -d'=' -f1)
		arg2=$(echo ${i} | cut -d'=' -f2)
		case "$arg1" in
			-c|--clean)
						logme_green "Setting the cleaning parameter"
						_clean=y;
						;;
			-i|--install-dependencies)
						logme_green "Setting option to install dependencies"
						_install_dependencies=y;
						;;
			-lk|--little-kernel)
						logme_green "Setting option to build LK"
						_build_lk=y;
						;;
			-k|--kernel)
						logme_green "Setting option to build kernel"
						_build_kernel=y;
						;;
			-r|--rootfs)
						logme_green "Setting option to create rootfs"
						_create_rootfs=y;
						;;
			-s|--server-build)
						logme_green "Setting option to use guestmount without sudo"
						_server=y;
						;;
			-h|--help)
						logme_green "Printing the help screen"
						usage
						exit
						;;
			-a|--all)
						_bversion=sid;
						_install_dependencies=y;
						_build_kernel=y;
						_build_lk=y;
						_create_rootfs=y;
						logme_green "Default option, no clean build for kernel or distribution"
						;;
		esac
	done
}

main()
{
	# To count total build time
	buildall_start=`date +%s`

	# parsing utility to parse the command line arguements
	parse_me

	# this will make sure each folder is present, if not it will create it
	check_and_create_dirs
	if [ "xy" = "x${_server}" ]; then
		if (dpkg -s libguestfs-tools) &> /dev/null
		then
			logme_blue "libguestfs-tools is already present, make sure to do additional changes to use this package as intended"
		else
			logme_red "Guestmount is not installed on this build system"
		fi
	fi

	if [ "xy" = "x${_install_dependencies}" ]; then
		# Installing dependencies
		install_dependencies
		# get skales if it is not present
		get_skales
		# get repo if it is not present
		get_repo
		#kernel tool chain
		get_kernel_toolchain
		#LK tool chain
		get_lk_toolchain
		#get rootfs utils
		get_rootfs_utils
	fi

	if [ "xy" = "x${_clean}" -a "x" = "x${_build_lk}" -a "x" = "x${_build_kernel}" -a "x" = "x${_create_rootfs}" ]; then
		clean_up
	fi

	if [ "xy" = "x${_build_lk}" ]; then
		lk_build
	fi

	if [ "xy" = "x${_build_kernel}" ]; then
		kn_build		# building the kernel
	fi

	if [ "xy" = "x${_clean}" -a "xy" = "x${_create_rootfs}" ]; then
		rm -rf ${_build_dir}/${_rootfs_name} ${_build_dir}/${_rootfs_name}.gz
	fi

	if [ "xy" = "x${_create_rootfs}" ]; then
		get_linaro_rootfs
		logme_green "Updating the fs name as : ${_rootfs_name}"
		cp_build
	fi

	if [ "xy" = "x${_build_lk}" -a "xy" = "x${_build_kernel}" -a "xy" = "x${_create_rootfs}" ]; then
		create_flashall
		gen_checksum
	fi

	if [ "xy" = "x${_generate_external_package}" ]; then
		create_external_package
	fi

	# To count total build time
	buildall_end=`date +%s`
	buildall_runtime=$((($buildall_end - $buildall_start) / 60))
	logme_blue "Total duration of build was ${buildall_runtime}"
}

# I need some trapping here to cleanup :)
trap clean_up SIGINT SIGTERM


main
exit 0
