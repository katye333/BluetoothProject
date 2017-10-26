#!/usr/bin/python

import sys
import bluetooth
from termcolor import colored

def sendTxt(addr, port):
	
	print colored('Creating Bluetooth Socket', 'green')

	try:
		# Creates a new connection to the Serial Port Profile
		sockfd = bluetooth.BluetoothSocket(bluetooth.RFCOMM)
		sockfd.connect((addr, port))

	except:
		print colored('Error while creating Bluetooth Socket.\nProgram shutting down.', 'red')
		sys.exit(1)

	else:
		print colored('Successfully created Bluetooth Socket', 'green')

		# ATZ - Reset from Voice Mode
		sockfd.send('ATZ\r')

		# AT+CMGF=1 - Set Message Format to Text Mode
		sockfd.send('AT+CMGF=1\r')

		# AT+CMGS - Destination Address of Text Message
		phoneNumber = raw_input('\nEnter phone number: ')
		sockfd.send('AT+CMGS="+' + phoneNumber + '"\r')

		message = raw_input('Enter message: ')
		sockfd.send(message)

		# Carriage return indicates end of message
		sockfd.send(chr(26))

		# Close Serial Port
		sockfd.close() 

# End sendTxt()

##############################################################################################

# Get parameters passed from Bash Script
theMacAddr = sys.argv[1]
thePort = int(sys.argv[2])

# Call Function to send text messages
sendTxt(theMacAddr, thePort)

# Close all connection and return control to Bash
print colored('\nReturning to Bash Script', 'green')
sys.exit(0)