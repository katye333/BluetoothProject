#!/bin/bash

# Define colors 
red='\e[1;31m'
green='\e[1;32m'
blue='\e[1;34m'
endColor='\e[0m'

alias grep='grep --color=auto'
##############################################################################################

# This method adds an ellipsis to text 
appendEllipsis() {
	numberOfDots=0
	until [[ $numberOfDots > 2 ]]; do
		echo -n "."
		sleep 0.3
		let "numberOfDots = $numberOfDots + 1"
	done
}

# Detect if Bluetooth is enabled on Master Device
checkBluetooth() {
	testBluetooth="hciconfig | grep UP"
	eval $testBluetooth > /dev/null 
	exit_codes=$(echo $?)

	# If Bluetooth is turned off:
	if [ $exit_codes != "0" ]; then
		echo -n -e "Master Device Bluetooth: ${red}Off${endColor}"
		echo -n -e "\nTurn on? [${green}y${endColor}/${red}n${endColor}]: "; read answer;
		
		# Call Function to turn Bluetooth on
		if [ $answer == "y" ]; then
			enableBluetooth
		elif [ $answer == "n" ]; then
			echo -n -e "${red}Shutting down${endColor}"; appendEllipsis; echo;
		fi

	else
		echo -n -e "Master Device Bluetooth: ${green}On${endColor}\n"
	fi
}

enableBluetooth() {
	echo -e -n "\n${green}Enabling Bluetooth${endColor}"; appendEllipsis; echo;
	turn_on="hciconfig hci0 up"
	eval $turn_on > /dev/tty 
	exit_codes=$(echo $?)

	# If turn_on command failed:
	if [ $exit_codes != "0" ]; then
		rfkill="rfkill unblock all"
		eval $rfkill > /dev/tty
		exit_codes=$(echo $?)

		# If rfkill command failed: 
		if [ $exit_codes != "0" ]; then
			resetBluetooth
		fi

	# If turn_on command succeeded:	
	else
		echo -e -n "Master Device Bluetooth: ${green}On${endColor}"; echo;
	fi
}

resetBluetooth() {
	echo -e -n "${green}Resetting Bluetooth${endColor}"; appendEllipsis; echo;
	
	reset_bluetooth="hciconfig hci0 reset"
	eval $reset_bluetooth > /dev/null
	exit_codes=$(echo $?)

	if [ $exit_codes != "0" ]; then
		echo -e "\n${red}Error:${endColor} Unspecified Bluetooth Error"
		echo -e -n "${red}Exiting now${endColor}"; appendEllipsis; echo;
	else
		checkBluetooth
	fi
}


###################################################################################

# Check if user is root
	# True - Assign permissions 
	# False - Remove stderr, use formatted error msgs and exit

FILE="/tmp/out.$$"

GREP="/bin/grep"
if test $EUID -eq 0; then
	echo `chmod 744 bash_worm2.sh`
	
else > /dev/null # Removes stderr and replaces with custom error message
	E_NOTROOT=67
	echo -e "${red}Error:${endColor} This script must be run as root" 
	echo -e "${red}Exit Code: $E_NOTROOT ${endColor}"
	exit $E_NOTROOT
fi

# Call checkBluetooth Function
echo -e -n "${green}Checking Bluetooth on computer${endColor}"; appendEllipsis; echo;
checkBluetooth

# Execute Command: hcitool scan
echo -e -n "\n${green}Scanning nearby devices${endColor}"; appendEllipsis; echo;
mac_addr=$(hcitool scan | grep -o -E -m 1 '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}'); echo;

# Print MAC_Addresses and obtain names for each
echo -e "${blue}[*] Found Bluetooth Device${endColor}: $(hcitool name ${mac_addr})"
echo -e "${blue}[+] MAC_Address${endColor}: ${mac_addr}" 

# Call Python Function
python="python alert2.py '$mac_addr'"
eval $python > /dev/tty
exit_codes=$(echo $?)










