#Сборка ядра для EM95
#Работа с конфигом
if [ -f .config ]; then
    read -p "Удалить старый конфиг?(Y/n)" -n 1
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        echo "Обновим конфиг новыми значениямо по умолчанию"
        make oldconfig
    else
        echo "Удаляю старый конфиг"
        rm .config
        echo "Создаем конфиг по умолчанию"
        make defconfig
        echo "Обновим значениями из em95.config"
        scripts/kconfig/merge_config.sh .config em95.config
    fi
else
    echo "Создаем конфиг по умолчанию"
    make defconfig
    echo "Обновим значениями из em95.config"
    scripts/kconfig/merge_config.sh .config em95.config
fi
read -p "Запустить menuconfig?(y/N)" -n 1
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    make nconfig
fi

#Сборка ядра
echo "Собираю Image modules dtbs"
make -j4 Image modules dtbs

#Установка ядра
echo "Устанавливаю Image modules dtbs"
sudo make install modules_install dtbs_install

#Создаем пункт загрузки
k_ver=`make -s kernelrelease`
echo ${k_ver}
