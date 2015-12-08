#!/bin/bash
# A shell script to install bitcoin essential libraries on a fresh rasbian/debian on a single board computer.
# Written by Aussiehash http://www.reddit.com/user/Aussiehash
# v0.1.01.5
# Last updated on, 8th Dec 2015

## local variable
#newest_armory_rpi=""
#trezor_firmwares=""
#newest_electrum_unix=""
#newest_multibit=""
#newest_ledgerwallet=""

###############################
#  User Defined Functions    #
###############################
function press_enter
{
	echo ""
	echo -n "Press Enter to continue"
	read
}
function update_upgrade
{
	echo "$(tput setaf 1)$(tput bold mode)This will update and upgrade via apt-get$(tput sgr0)"
		sudo apt-get update
		sudo apt-get --yes upgrade 
		sudo apt-get clean
		sudo apt-get --yes install -f
}
function install_trezor_keepkey
{
	echo "$(tput setaf 1)$(tput bold mode)This will install several python libraries, then pip, then will build cython 0.21.1"
	echo "Note the cython compilation time is over 40 mins !"
	echo "After that the trezor/hidapi/cython-hidapi/udev rules will be installed$(tput sgr0)"
#		sudo apt-get install python-dev python-setuptools cython git libusb-1.0-0-dev libudev-dev # with cython
		sudo apt-get --yes install python-dev python-setuptools git libusb-1.0-0-dev libudev-dev ## without cython (on debian/wheezy, only cython 0.15.1 is available)
		sudo apt-get --yes install python-qt4 python-dev pyqt-dev-tools python-pip # from electrum, python-qt4 necessary for BTChip # package pyqt-dev-tools is ubuntu only
		sudo apt-get --yes install python-usb libusb-dev
 		sudo apt-get --yes install python-pip
	echo "$(tput setaf 1)$(tput bold mode)pip install steps .... cython build will take 40+ mins !!$(tput sgr0)"
		sudo pip install --upgrade pyusb 
		sudo pip install --upgrade cython
	echo "$(tput setaf 1)$(tput bold mode)Installing trezor libraries$(tput sgr0)"
			cd ~
			mkdir trezor
			cd trezor
		sudo pip install trezor
		git clone https://github.com/trezor/cython-hidapi.git
			cd cython-hidapi/
		git submodule init
		git submodule update
		python setup.py build
		sudo python setup.py install
			cd ..
		git clone https://github.com/trezor/python-trezor.git
			cd python-trezor
		git submodule add https://github.com/trezor/trezor-common.git
		sudo python setup.py install
		sudo cp trezor-common/udev/51-trezor-udev.rules /lib/udev/rules.d/
			cd ..
		git clone https://github.com/trezor/python-mnemonic.git
			cd python-mnemonic
		sudo python setup.py install
	echo "$(tput setaf 1)$(tput bold mode)Installing KeepKey support$(tput sgr0)"
			cd ~
			mkdir keepkey
			cd keepkey
		git clone https://github.com/keepkey/python-keepkey.git
			cd python-keepkey
		sudo python setup.py install
			cd ..
		git clone https://github.com/keepkey/udev-rules.git
		sudo cp udev-rules/51-usb-keepkey.rules /lib/udev/rules.d/
}
function install_ledger
{
	echo "$(tput setaf 1)$(tput bold mode)This will install the BTChip/Ledger support$(tput sgr0)"
			cd ~
			mkdir btchip
			cd btchip
		wget https://hardwarewallet.com/zip/add_btchip_driver.sh
		sudo bash add_btchip_driver.sh
		sudo udevadm control --reload-rules
		git clone https://github.com/LedgerHQ/btchip-python.git
			cd btchip-python
		sudo python setup.py install
	echo "$(tput setaf 1)$(tput bold mode)Testing btchip installation$(tput sgr0)"
			cd samples
		python getFirmwareVersion.py #btchip.btchipException.BTChipException: Exception : No dongle found
			cd ../btchip
		python btchipPersoWizard.py #ImportError: No module named PyQt4
	echo "$(tput setaf 1)$(tput bold mode)Installing c-api$(tput sgr0)"
			cd ../..
		git clone https://github.com/LedgerHQ/btchip-c-api.git
			cd btchip-c-api
			mkdir bin
		make
		make -f Makefile.hidapi ## For firmware Version 0.6 - 10.04.15_1 / for LW 1.0.1
			cd bin
		./btchip_getFirmwareVersion #No dongle found
	echo "$(tput setaf 1)$(tput bold mode)Installing the Ledger Chrome Wallet -- (for coinkite multisig)$(tput sgr0)"
			cd ../..
#		git clone https://github.com/LedgerHQ/ledger-wallet-chrome.git
			mkdir ledger-wallet-chrome-crx
			cd ledger-wallet-chrome-crx
		wget https://github.com/LedgerHQ/ledger-wallet-chrome/releases/download/1.4.7/ledger-wallet-1.4.7.crx
			cd ..
	echo "$(tput setaf 1)$(tput bold mode)Installing the Ledger JS API, for 2nd factor card -- (for coinkite multisig)$(tput sgr0)"
		git clone https://github.com/LedgerHQ/btchip-js-api
}
function install_electrum
{
	echo "$(tput setaf 1)$(tput bold mode)Installing electrum 2.5.4$(tput sgr0)"
			cd ~
		sudo apt-get --yes install python-pip python-slowaes python-socksipy pyqt4-dev-tools #E: Unable to locate package python-slowaes
		sudo apt-get --yes install python-pip python-qt4 pyqt4-dev-tools python-slowaes python-ecdsa python-zbar #E: Unable to locate package python-ecdsa
		sudo apt-get --yes install python-pip python-qt4 pyqt4-dev-tools python-zbar #python-pip is already the newest version.
		sudo pip install pyasn1 pyasn1-modules pbkdf2 tlslite qrcode
	echo "$(tput setaf 1)$(tput bold mode)git clone$(tput sgr0)"
		git clone -b 2.5.4 https://github.com/spesmilo/electrum.git
#Traceback (most recent call last):
#File "mki18n.py", line 3, in <module>
#import urllib2, os, zipfile, pycurl
#ImportError: No module named pycurl
			cd electrum
		pyrcc4 icons.qrc -o gui/qt/icons_rc.py
		python mki18n.py
		python setup.py sdist --format=zip,gztar
		sudo python setup.py install
### official electrum release
#		sudo pip install https://download.electrum.org/Electrum-2.0.tar.gz#md5=ad9db1c037babe0829c55e3a3c1f7630
}
function install_armory
{
	echo "$(tput setaf 1)$(tput bold mode)Installing armory Raspberry Pi bundle$(tput sgr0)"
			cd ~
			mkdir armory
			cd armory
#		wget https://s3.amazonaws.com/bitcoinarmory-releases/armory_0.92.3_rpi_bundle.tar.gz
#		sudo tar -xvzf armory_0.92.3_rpi_bundle.tar.gz
#		wget https://s3.amazonaws.com/bitcoinarmory-releases/armory_0.93_raspbian-armhf.tar.gz
#		sudo tar -xvzf armory_0.93_raspbian-armhf.tar.gz
#		wget https://s3.amazonaws.com/bitcoinarmory-releases/armory_0.93_rpi_bundle.tar.gz
#		sudo tar -xvzf armory_0.93_rpi_bundle.tar.gz
#		wget https://s3.amazonaws.com/bitcoinarmory-releases/armory_0.93.1_rpi_bundle.tar.gz
#		sudo tar -xvzf armory_0.93.1_rpi_bundle.tar.gz
#		wget https://s3.amazonaws.com/bitcoinarmory-releases/armory_0.93.2_rpi_bundle.tar.gz
#		sudo tar -xvzf armory_0.93.2_rpi_bundle.tar.gz
		wget https://s3.amazonaws.com/bitcoinarmory-releases/armory_0.93.3_rpi_bundle.tar.gz
		sudo tar -xvzf armory_0.93.3_rpi_bundle.tar.gz
			cd OfflineBundle
	echo "$(tput setaf 1)$(tput bold mode)Untar.gz$(tput sgr0)"
		sudo python Install_DblClick_RunInTerminal.py ##Granted permissions without asking for password
			cd ..
		sudo apt-get --yes install git-core build-essential pyqt4-dev-tools swig libqtcore4 libqt4-dev python-qt4 python-dev python-twisted python-psutil
#		git clone git://github.com/etotheipi/BitcoinArmory.git
#			cd BitcoinArmory
	echo "$(tput setaf 1)$(tput bold mode)Installing libcrypto++$(tput sgr0)"
		sudo apt-get --yes install libcrypto++-dev #(23mb) ## Armory works without this library
	echo "$(tput setaf 1)$(tput bold mode)Correcting privileges for ODROID C1/ubuntu 14.04$(tput sgr0)"
		sudo chmod +755 /usr/lib/armory/qt4reactor.py
}
function install_qr_tools
{
	echo "$(tput setaf 1)$(tput bold mode)Installing QR code python - qr, QTQR, zbar, and angular javascript$(tput sgr0)"
	echo "$(tput setaf 1)$(tput bold mode)This can be combined with : raspistill -o capture.jpg$(tput sgr0)"
			cd ~
			mkdir QR
			cd QR
		git clone https://github.com/lincolnloop/python-qrcode.git
			cd python-qrcode
	echo "$(tput setaf 1)$(tput bold mode)Installing Pillow, takes 7 mins approx - then pymaging$(tput sgr0)"
		sudo pip install Pillow
		sudo pip install git+git://github.com/ojii/pymaging.git#egg=pymaging
		sudo pip install git+git://github.com/ojii/pymaging-png.git#egg=pymaging-png
		sudo python setup.py install
	echo "$(tput setaf 1)$(tput bold mode)Installing qtqr, Usage: qtqr$(tput sgr0)"	
		sudo apt-get --yes install qtqr
	echo "$(tput setaf 1)$(tput bold mode)Installing zbar, Usage: zbarimg -d test.png$(tput sgr0)"	
		sudo apt-get --yes install zbar-tools
	echo "$(tput setaf 1)$(tput bold mode)Installing angular-qr$(tput sgr0)"
			cd ..
		git clone https://github.com/janantala/angular-qr.git
}
function install_bitaddress
{
	echo "$(tput setaf 1)$(tput bold mode)Installing Bitaddress$(tput sgr0)"
			cd ~
		git clone https://github.com/pointbiz/bitaddress.org.git
}
function install_imagemagick
{
	echo "$(tput setaf 1)$(tput bold mode)Installing imagemagick$(tput sgr0)"
		sudo apt-get --yes install imagemagick
}
function install_ssss
{
	echo "$(tput setaf 1)$(tput bold mode)Installing Shamir's Secret Sharing Scheme - ssss-split$(tput sgr0)"
		sudo apt-get --yes install ssss
}
function install_coinkite
{
	echo "$(tput setaf 1)$(tput bold mode)Installing Coinkite command line tools, plus BitMEX signing tools$(tput sgr0)"
			cd ~ ; mkdir coinkite ; cd coinkite
		git clone https://github.com/coinkite/coinkite-python.git
		git clone https://github.com/coinkite/offline-multisig-python.git
			cd offline-multisig-python
		sudo pip install -r requirements.txt
			cd ..
		git clone https://github.com/BitMEX/btchip-signing-tools.git
			cd btchip-signing-tools
		sudo python setup.py develop
			cd ..
		git clone https://github.com/jmcorgan/bip32utils.git
}
function download_trezor_firmware
{
	echo "$(tput setaf 1)$(tput bold mode)Downloading Trezor old firmware$(tput sgr0)"
			cd ~
			cd trezor
			mkdir firmware
			cd firmware
		wget https://raw.githubusercontent.com/trezor/webwallet-data/master/firmware/trezor-1.3.4.bin.hex
		wget https://raw.githubusercontent.com/trezor/webwallet-data/master/firmware/trezor-1.3.3.bin.hex
		wget https://raw.githubusercontent.com/trezor/webwallet-data/master/firmware/trezor-1.3.2.bin.hex
		wget https://raw.githubusercontent.com/trezor/webwallet-data/master/firmware/trezor-1.3.1.bin.hex
		wget https://raw.githubusercontent.com/trezor/webwallet-data/master/firmware/trezor-1.3.0.bin.hex
		wget https://raw.githubusercontent.com/trezor/webwallet-data/master/firmware/trezor-1.2.1.bin.hex
		wget https://raw.githubusercontent.com/trezor/webwallet-data/master/firmware/trezor-1.2.0.bin.hex
		wget https://raw.githubusercontent.com/trezor/webwallet-data/master/firmware/trezor-1.1.0.bin.hex
		wget https://raw.githubusercontent.com/trezor/webwallet-data/master/firmware/trezor-1.0.0.bin.hex
		wget https://raw.githubusercontent.com/trezor/webwallet-data/master/firmware/releases.json
}
function install_bip39
{
	echo "$(tput setaf 1)$(tput bold mode)Installing BIP39 scripts$(tput sgr0)"
			cd ~
			mkdir bip39
			cd bip39
		git clone https://github.com/bip32JP/bip32JP.github.io.git
		git clone https://github.com/dcpos/bip39.git
}
function install_passguardian
{
	echo "$(tput setaf 1)$(tput bold mode)Installing PassGuardian$(tput sgr0)" ; cd ~ ; mkdir passguardian ; cd passguardian
		git clone https://github.com/amper5and/secrets.js.git
}
function install_greenaddress
{
	echo "$(tput setaf 1)$(tput bold mode)Installing Greenaddress.it Wallet CRX$(tput sgr0)" ; cd ~
		git clone https://github.com/greenaddress/WalletCrx.git
}
function install_browsers
{
	echo "$(tput setaf 1)$(tput bold mode)Installing Chromium 22 and Iceweasel$(tput sgr0)"
		sudo apt-get --yes install chromium
		sudo apt-get --yes install iceweasel
		sudo apt-get --yes install chromium-browser #BBB Ubuntu 14.04 package v40 #http://elinux.org/Beagleboard:Ubuntu_On_BeagleBone_Black#Ubuntu_Precise_On_Micro_SD
		sudo apt-get --yes install firefox #BBB Ubuntu 14.04 package
	
}
function install_pybitcoin
{
	echo "$(tput setaf 1)$(tput bold mode)Installing V Buterin pybitcoin tools$(tput sgr0)"
			cd ~
		git clone https://github.com/vbuterin/pybitcointools.git
			cd pybitcointools
		sudo python setup.py install
}
function install_multibit
{
	echo "$(tput setaf 1)$(tput bold mode)Installing MultiBit HD Beta -- UNTESTED$(tput sgr0)"
			cd ~
			mkdir multibit-hd
			cd multibit-hd
#		wget https://multibit.org/releases/multibit-hd/multibit-hd-0.0.7beta/multibit-hd-unix-0.0.7beta.sh
#		wget https://multibit.org/releases/multibit-hd/multibit-hd-0.1.1/multibit-hd-unix-0.1.1.sh
		wget https://multibit.org/releases/multibit-hd/multibit-hd-0.1.4/multibit-hd-unix-0.1.4.sh
		wget https://multibit.org/en/help/hd0.1/how-to-install-linux.html
		chmod +x multibit-hd-unix-0.1.4.sh
		./multibit-hd-unix-0.1.4.sh
}
function install_source
{
	echo "$(tput setaf 1)$(tput bold mode)pull Armory github repo$(tput sgr0)"
			cd ~
			mkdir armory
			cd armory
		git clone git://github.com/etotheipi/BitcoinArmory.git
			cd BitcoinArmory
	echo "$(tput setaf 1)$(tput bold mode)Installing libcrypto++$(tput sgr0)"
		sudo apt-get --yes install libcrypto++-dev #(23mb) ## Armory works without this library
#		make # (make disabled, fails after 16min on Raspbian Pi B+, also fails on C1, Pi 2)"
#		python ArmoryQt.py
}
function test_hardwarewallet
{
	echo "$(tput setaf 1)$(tput bold mode)Testing Trezor$(tput sgr0)"
			cd ~
			cd trezor
			cd python-trezor
	echo "$(tput setaf 1)$(tput bold mode)Trezor helloworld$(tput sgr0)"
		python helloworld.py
	echo "$(tput setaf 1)$(tput bold mode)Testing KeepKey(tput sgr0)"
			cd ~
			cd keepkey
			cd python-keepkey
	echo "$(tput setaf 1)$(tput bold mode)KeepKey helloworld$(tput sgr0)"
		python helloworld.py
	echo "$(tput setaf 1)$(tput bold mode)Testing btchip HW-1$(tput sgr0)"
			cd ~
			cd btchip
	echo "$(tput setaf 1)$(tput bold mode)Testing btchip-python(tput sgr0)"
			cd btchip-python
			cd samples
		python getFirmwareVersion.py #btchip.btchipException.BTChipException: Exception : No dongle found
	echo "$(tput setaf 1)$(tput bold mode)Testing pyusb and PyQt4(tput sgr0)"
			cd ../btchip
		python btchipPersoWizard.py #ImportError: No module named PyQt4
	echo "$(tput setaf 1)$(tput bold mode)Testing btchip-c-api$(tput sgr0)"
			cd ../..
			cd btchip-c-api
			cd bin
		./btchip_getFirmwareVersion #No dongle found
}
function install_armory_companion
{
	echo "$(tput setaf 1)$(tput bold mode)Install Armory Companion Python (requires python-qrcode and python six$(tput sgr0)"
			cd ~
			mkdir armory
			cd armory
		git clone https://github.com/hank/armorycompanion-python.git
	echo "$(tput setaf 1)$(tput bold mode)Install Armory Companion Android(tput sgr0)"
		git clone https://github.com/hank/armorycompanion.git
}
function build_ledger_chrome_wallet
{
	echo "$(tput setaf 1)$(tput bold mode)Build ledger-chrome-wallet, requires nodejs, npm, gulp$(tput sgr0)"
			cd ~
			mkdir btchip
			cd btchip
	echo "$(tput setaf 1)$(tput bold mode)Cloning Ledger Chrome Wallet$(tput sgr0)"
		git clone https://github.com/LedgerHQ/ledger-wallet-chrome.git
	echo "$(tput setaf 1)$(tput bold mode)Installing nodejs, requires curl$(tput sgr0)"
		curl -sL https://deb.nodesource.com/setup | sudo bash -
		sudo apt-get --yes install -y nodejs
	echo "$(tput setaf 1)$(tput bold mode)Building crx in /dist, needs full system memory, close all other apps...$(tput sgr0)"
		sudo npm install -g gulp
		sudo npm install
		gulp package
}
###################################
# Future To Do List               #
###################################

# function install_pi_qr_reader
# {
#sudo apt-get install python-picamera
### note http://www.raspberrypi.org/forums/viewtopic.php?f=32&t=98466
# }
# function install_cups_pdf
# {
# }
# function git_pull_recursive
# {
# }

## Purpose: Determine if current user is root or not
#is_root_user(){
# [ $(id -u) -eq 0 ]
#}
# 
## invoke the function
## make decision using conditional logical operators 
#is_root_user && echo "You can run this script." || echo "You need to run this script as a root user."

# consider 'pip install' instead of 'git clone'
# http://stackoverflow.com/questions/3689685/how-is-pip-install-using-git-different-than-just-cloning-a-repository
# http://stackoverflow.com/questions/4830856/is-it-possible-to-use-pip-to-install-a-package-from-a-private-github-repository

###################################
# Main Script Logic Starts Here   #
###################################
selection=
until [ "$selection" = "0" ]; do
	echo ""
	echo "$(tput setaf 7)$(tput bold mode)RASPBERRY PI COLD OFFLINE SETUP SCRIPT$(tput sgr0)"
	echo "! - Install 1-G, no prompts. Recommended. (Approx 200-600Mb, 1-2 hrs)"
	echo "1 - Update Raspian/Debian (on the Model B+ 8GB NOOBs edition, 392Mb and > 1hour)"
	echo "2 - Install Trezor + Libs + KeepKey (Cython build takes 15 mins Pi 2 - 40 mins Pi B+)"
	echo "3 - Install Ledger/BTChip + Libs, Download Ledger wallet chrome 1.20 and 2nd factor JS"
	echo "4 - Install Electrum 2 + Libs"
	echo "5 - Install Armory + Libs (Approx 10 mins and 175Mb)"
	echo "6 - Install QR Code (Pillow build takes 10mins)"
	echo "7 - Install Bitaddress"
	echo "8 - Install ImageMagick (5mins)"
	echo "9 - Install Shamir's Secret Sharing Scheme"
	echo "A - Install Coinkite + BitMEX signing beta tools (3+ min)"
	echo "B - Download Trezor firmwares"
	echo "C - Install BIP39 scripts"
	echo "D - Install PassGuardian"
	echo "E - Install GreenAddress"
	echo "F - Install Chromium 22 and Iceweasel 31.2 on Raspbian, Chromium 40 + Firefox on BBB Ubuntu 14.04"
	echo "G - Vitalik Buterin's pybitcoin tools"
	echo "-------------------------------------------------------------------------------------------------"
	echo "H - Multibit HD beta 0.1.4 (OPTIONAL untested, NOT yet part of !, likely needs JRE prior)"
	echo "I - Install Armory github source (OPTIONAL - cannot be built on ARM)"
	echo "J - Test installation of Trezor, KeepKey (helloworld) and btchip (pyusb, c-api, python-api).  Plug in hardware wallet first ! "
	echo "K - Install Armory Companion (OPTIONS, untested)"
	echo "L - Build from source Ledger Chrome Wallet crx"
	echo ""
	echo "0 - exit program"
	echo ""
	echo -n "Enter selection: "
	read selection
	echo ""
	case $selection in
		1 ) update_upgrade ; press_enter ;;
		2 ) install_trezor_keepkey ; press_enter ;;
		3 ) install_ledger ; press_enter ;;
		4 ) install_electrum ; press_enter ;;
		5 ) install_armory ; press_enter ;;
		6 ) install_qr_tools ; press_enter ;;
		7 ) install_bitaddress ; press_enter ;;
		8 ) install_imagemagick ; press_enter ;;
		9 ) install_ssss ; press_enter ;;
		A ) install_coinkite ; press_enter ;;
		B ) download_trezor_firmware ; press_enter ;;
		C ) install_bip39 ; press_enter ;;
        	D ) install_passguardian ; press_enter ;;
		E ) install_greenaddress ; press_enter ;;
		F ) install_browsers ; press_enter ;;
		G ) install_pybitcoin ; press_enter ;;
		H ) install_multibit ; press_enter ;;
		I ) install_source ; press_enter ;;
		J ) test_hardwarewallet ; press_enter ;;
		K ) install_armory_companion ; press_enter ;;
		L ) build_ledger_chrome_wallet ; press_enter ;;
		! ) update_upgrade ; install_trezor_keepkey ; install_ledger ; install_electrum ; install_armory ; install_qr_tools ; install_bitaddress ; install_imagemagick ; install_ssss ; install_coinkite ; download_trezor_firmware ; install_bip39 ; install_passguardian ; install_greenaddress ; install_browsers ; install_pybitcoin ; press_enter ;;
		0 ) exit ;;
		* ) echo "$(tput setaf 3)$(tput bold mode)Please enter ! - G, or 0$(tput sgr0)"; press_enter
	esac
done
