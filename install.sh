#!/bin/bash

. /etc/os-release
if [ "$ID" == "fedora" ] || [ "$ID_LIKE" == "fedora" ] || [ "$ID_LIKE" == "rhel fedora" ]; then
	echo "Installing dependencies..."
	sudo dnf install cargo libevdev-devel -y
elif [ "$ID" == "ubuntu" ] || [ "$ID" == "debian" ] || [ "$ID_LIKE" == "debian" ] || [ "$ID_LIKE" == "ubuntu" ]; then
	echo "Installing dependendies..."
	sudo apt install cargo libevdev-dev -y
else
	echo "You have to install the packages cargo and libevdev-dev/libevdev-devel to use this program. Please do that before continuing"
	read -p "Press Enter to continue" </dev/tty
fi

cargo build --release
sudo killall surface-pen-button
sudo install -Dm 644 ./etc/remap.conf /etc/surface-pen-button/remap.conf
sudo install -m 755 ./target/release/surface-pen-button /usr/bin/surface-pen-button

printf 'Do you want to install the systemd service (y/N)? '
read answer

if [ "$answer" != "${answer#[Yy]}" ]; then
	sudo install -m 644 surface-pen-button.service /etc/systemd/system/surface-pen-button.service
	sudo systemctl daemon-reload
	sudo systemctl enable --now surface-pen-button.service
	echo "Systemd service is installed, enabled and started!"
else
	echo "Systemd service is not installed! Run this tool via 'sudo surface-pen-button'"
fi


printf 'Do you want to clean the target folder (y/N)? '
read answer

if [ "$answer" != "${answer#[Yy]}" ]; then
	sudo rm -r target/
	echo "Removed the target folder."
else
	echo "No cleanup was performed."
fi
