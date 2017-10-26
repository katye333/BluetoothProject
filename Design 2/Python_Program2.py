#!/usr/bin/python

import time
import sys
import bluetooth
import serial
from termcolor import colored
from bluetooth import *


def sdpBrowse(addr):
	print '-------------------------------------------'
	services = find_service(address = addr)
	for service in services:
		name = service['name']
		protocol = service['protocol']
		port = service['port']

		print colored('[+] Found Service: ', 'blue') + str(name)
		print colored('[+] Protocol: ', 'blue') + str(protocol)
		print colored('[+] Using Port: ', 'blue') + str(port) + '\n'

# End sdpBrowse(addr)

def execute_Text_Commands(addr):
	print '-------------------------------------------'
	choosePort = raw_input('Select port to connect to: ')
	print colored('\nCreating Bluetooth Socket...', 'green')

	# Creates a new connection to the Serial Port Profile
	sockfd = bluetooth.BluetoothSocket( bluetooth.RFCOMM )
	sockfd.connect((addr, int(choosePort)))

	# ATZ - Reset from Voice Mode
	sockfd.send('ATZ\r')

	# AT+CMGF=1 - Set Message Format to Text Mode
	sockfd.send('AT+CMGF=1\r')

	# AT+CMGS - Destination Address of Text Message
	phoneNumber = raw_input(colored('Enter phone number to message: ', 'green'))
	sockfd.send('AT+CMGS="+' + phoneNumber + '"\r')

	message = raw_input(colored('Enter message: ', 'green'))
	sockfd.send(message)

	sockfd.send('AT+CPMS="ME"')
	time.sleep(2)

	

	# Carriage return indicates end of message
	sockfd.send(chr(26))

	# Close Serial Port
	sockfd.close() 

# End execute_Text_Commands()

def execute_Voice_Commands(addr):
	print '-------------------------------------------'
	choosePort = raw_input('Select port to connect to: ')
	print colored('\nCreating Bluetooth Socket...', 'green')

	# Creates a new connection to the Serial Port Profile
	sockfd = bluetooth.BluetoothSocket( bluetooth.RFCOMM )
	sockfd.connect((addr, int(choosePort)))

	sockfd.send('ATZ\r')
	time.sleep(2)

	# Call Phone Number
	callNumber = raw_input(colored('Enter phone number to call: ', 'green'))
	sockfd.send('ATD' + callNumber + ';\r')
	time.sleep(2)

	sockfd.send(chr(26))	

# End execute_Voice_Commands()

mac_addr = sys.argv[1]

# Call Function to retrieve services and ports on device
sdpBrowse(mac_addr)

# Choose port and start executing
execute_Text_Commands(mac_addr)

# Choose port and start executing
#execute_Voice_Commands(mac_addr)

