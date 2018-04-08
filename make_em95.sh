#linux build script for EM95 TVbox

export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-
export INSTALL_MOD_PATH=tmp_dir
export INSTALL_PATH=${INSTALL_MOD_PATH}/boot

if [ -f .config ]; then
    read -p "Remove old config?(Y/n)" -n 1
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        echo "Update config by new default values"
        make olddefconfig
    else
        echo "Remove old config"
        rm .config
        echo "Create new default config"
        make defconfig
        echo "Update config values by em95.config"
        scripts/kconfig/merge_config.sh -r -m .config em95.config
    fi
else
    echo "Create default config"
    make defconfig
    echo "Update config values by em95.config"
    scripts/kconfig/merge_config.sh -r -m .config em95.config
fi

read -p "Add debug options to config?(y/N)" -n 1
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    scripts/kconfig/merge_config.sh -r -m .config dev.config
    BUILD_DEBUG=1
else
    export INSTALL_MOD_STRIP=1    #Modules to be stripped after they are installed.
fi

read -p "Run nconfig?(y/N)" -n 1
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    make nconfig
fi

make olddefconfig

echo "Build Image modules dtbs"
make -j4 Image modules dtbs

read -p "Make tar? (else install)(Y/n)" -n 1
if [[ $REPLY =~ ^[Nn]$ ]]; then #Install new linux image, dtbs, modules

    echo "Install Image modules dtbs"
    sudo make install modules_install dtbs_install

else #Build package

#Make deb packages
#make -j4 bindeb-pkg KBUILD_DEBARCH=arm64

    _kernver=`make kernelrelease`
    echo ${_kernver}
    mkdir -p ${INSTALL_PATH}
    fakeroot make install modules_install dtbs_install

    if [ -n "$BUILD_DEBUG" ] ; then
        echo "Add debug vmlinux to archive"
        # Different tools want the image in different locations
        # perf
        mkdir -p ${INSTALL_MOD_PATH}/usr/lib/debug/lib/modules/${_kernver}/
        cp vmlinux ${INSTALL_MOD_PATH}/usr/lib/debug/lib/modules/${_kernver}/
        # systemtap
        mkdir -p ${INSTALL_MOD_PATH}/usr/lib/debug/boot/
        ln -s ../lib/modules/${_kernver}/vmlinux ${INSTALL_MOD_PATH}/usr/lib/debug/boot/vmlinux-${_kernver}
        # kdump-tools
        ln -s lib/modules/${_kernver}/vmlinux ${INSTALL_MOD_PATH}/usr/lib/debug/vmlinux-${_kernver}
    fi

    cp .config "${INSTALL_PATH}/config-${_kernver}"
    cd ${INSTALL_MOD_PATH}
    tar -cvzf ../linux-${_kernver}.tar.gz *
    cd ..

    rm -R ${INSTALL_MOD_PATH}
fi
