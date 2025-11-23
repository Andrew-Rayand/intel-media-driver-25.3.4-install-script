#!/bin/bash

set -e  # Выход при ошибке

# Обновление и установка зависимостей
apt update
apt install -y git cmake pkg-config libdrm-dev automake libtool autoconf xorg xorg-dev openbox libx11-dev libgl1 libglx-mesa0 libxfixes-dev meson vainfo

# Создание рабочей директории
mkdir -p ~/intel-drivers && cd ~/intel-drivers

# Сборка gmmlib
git clone https://github.com/intel/gmmlib.git
cd gmmlib
git checkout intel-gmmlib-22.8.2
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j$(nproc)
make install
cd ../..

# Сборка libva
git clone https://github.com/intel/libva.git
cd libva
git checkout 2.22.0
./autogen.sh --prefix=/usr --libdir=/usr/lib/x86_64-linux-gnu
make -j$(nproc)
make install
cd ..

# Сборка media-driver
git clone https://github.com/intel/media-driver.git
cd media-driver
git checkout intel-media-25.3.4
mkdir build && cd build
cmake ..
make -j$(nproc)
make install
cd ../..

# Настройка окружения
if [ ! -f /etc/profile.d/intel-media.sh ]; then
    echo "export LIBVA_DRIVERS_PATH=/usr/lib/x86_64-linux-gnu/dri" | tee -a /etc/profile.d/intel-media.sh
    echo "export LIBVA_DRIVER_NAME=iHD" | tee -a /etc/profile.d/intel-media.sh
fi

# Очистка
cd ~
rm -rf ~/intel-drivers

echo "Установка завершена. Перезагрузите систему и проверьте 'vainfo'."
