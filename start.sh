#!/bin/bash
# A shell script to install bitcoin essential libraries on a fresh rasbian/debian on a single board computer.
# Written by Aussiehash http://www.reddit.com/user/Aussiehash
# v0.0.8.5
# Last updated on, 10th Feb 2015

## local variable
#newest_armory_rpi=""
#trezor_firmwares=""

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
function install_trezor
{
	echo "$(tput setaf 1)$(tput bold mode)This will install several python libraries, then pip, then will build cython 0.21.1"
	echo "Note the cython compilation time is over 40 mins !"
	echo "After that the trezor/hidapi/cython-hidapi/udev rules will be installed$(tput sgr0)"
#		sudo apt-get install python-dev python-setuptools cython git libusb-1.0-0-dev libudev-dev # with cython
		sudo apt-get --yes install python-dev python-setuptools git libusb-1.0-0-dev libudev-dev ## without cython (on debian/wheezy, only cython 0.15.1 is available)
		sudo apt-get --yes install python-qt4 python-dev pyqt-dev-tools python-pip # from electrum, python-qt4 necessary for BTChip # package pyqt-dev-tools is ubuntu only
		sudo apt-get install python-usb libusb-dev
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
#		python btchipPersoWizard.py ImportError: No module named PyQt4
	echo "$(tput setaf 1)$(tput bold mode)Installing c-api$(tput sgr0)"
			cd ../..
		git clone https://github.com/LedgerHQ/btchip-c-api.git
			cd btchip-c-api
			mkdir bin
		make
			cd bin
		./btchip_getFirmwareVersion #No dongle found
}
function install_electrum
{
	echo "$(tput setaf 1)$(tput bold mode)Installing electrum 2.0 beta$(tput sgr0)"
			cd ~
		sudo apt-get install python-pip python-slowaes python-socksipy pyqt4-dev-tools #E: Unable to locate package python-slowaes
		sudo apt-get --yes install python-pip python-qt4 pyqt4-dev-tools python-slowaes python-ecdsa python-zbar #E: Unable to locate package python-ecdsa
		sudo apt-get --yes install python-pip python-qt4 pyqt4-dev-tools python-zbar #python-pip is already the newest version.
		sudo pip install pyasn1 pyasn1-modules pbkdf2 tlslite qrcode
	echo "$(tput setaf 1)$(tput bold mode)git clone$(tput sgr0)"
		git clone https://github.com/spesmilo/electrum.git
#Traceback (most recent call last):
#File "mki18n.py", line 3, in <module>
#import urllib2, os, zipfile, pycurl
#ImportError: No module named pycurl
			cd electrum
		pyrcc4 icons.qrc -o gui/qt/icons_rc.py
		python mki18n.py
		python setup.py sdist --format=zip,gztar
		sudo python setup.py install
}
function install_armory
{
	echo "$(tput setaf 1)$(tput bold mode)Installing armory Raspberry Pi bundle$(tput sgr0)"
			cd ~
			mkdir armory
			cd armory
		wget https://s3.amazonaws.com/bitcoinarmory-releases/armory_0.92.3_rpi_bundle.tar.gz
		sudo tar -xvzf armory_0.92.3_rpi_bundle.tar.gz
			cd OfflineBundle
		sudo python Install_DblClick_RunInTerminal.py ##Granted permissions without asking for password
	echo "$(tput setaf 1)$(tput bold mode)Untar.gz$(tput sgr0)"
			cd ..
		sudo apt-get --yes install git-core build-essential pyqt4-dev-tools swig libqtcore4 libqt4-dev python-qt4 python-dev python-twisted python-psutil
		git clone git://github.com/etotheipi/BitcoinArmory.git
			cd BitcoinArmory
	echo "$(tput setaf 1)$(tput bold mode)Installing libcrypto++$(tput sgr0)"
		sudo apt-get --yes install libcrypto++-dev #(23mb)
#		make # (make disabled, fails after 16min on Raspbian Pi)"
#		python ArmoryQt.py
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
		sudo apt-get install ssss
}
function install_coinkite
{
	echo "$(tput setaf 1)$(tput bold mode)Installing Coinkite command line tools, plus BitMEX beta signing tools$(tput sgr0)"
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
		sudo apt-get --yes install iceweasel chromium
}
function install_pybitcoin
{
	echo "$(tput setaf 1)$(tput bold mode)Installing V Buterin pybitcoin tools$(tput sgr0)"
			cd ~
		git clone https://github.com/vbuterin/pybitcointools.git
			cd pybitcointools
		sudo python setup.py install
}

###################################
# Future To Do List               #
###################################

# function install_pi_qr_reader
# {
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
	echo "! - Install everything, no prompts. Recommended. (Approx 200-600Mb, 1-2 hrs)"
	echo "1 - Update Raspian/Debian (on the Model B+ 8GB NOOBs edition, 392Mb and > 1hour)"
	echo "2 - Install Trezor + Libs (Cython build takes 45 mins)"
	echo "3 - Install Ledger/BTChip + Libs"
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
	echo "F - Install Chromium 22 and Iceweasel 31.2"
	echo "G - Vitalik Buterin's pybitcoin tools"
	echo ""
	echo "0 - exit program"
	echo ""
	echo -n "Enter selection: "
	read selection
	echo ""
	case $selection in
		1 ) update_upgrade ; press_enter ;;
		2 ) install_trezor ; press_enter ;;
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
		! ) update_upgrade ; install_trezor ; install_ledger ; install_electrum ; install_armory ; install_qr_tools ; install_bitaddress ; install_imagemagick ; install_ssss ; install_coinkite ; download_trezor_firmware ; install_bip39 ; install_passguardian ; install_greenaddress ; install_browsers ; install_pybitcoin ; press_enter ;;
		0 ) exit ;;
		* ) echo "$(tput setaf 3)$(tput bold mode)Please enter ! - G, or 0$(tput sgr0)"; press_enter
	esac
done
