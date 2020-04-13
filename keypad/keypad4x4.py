#!/usr/bin/python
# -*- coding: utf-8 -*-

# Import der notwendigen Bibliotheken
import os
import sys
import json
import urllib
import thread
import serial
import socket
import subprocess as sub

# Zugangsdaten importieren
with open("YOURS") as creds:
	credentials = json.load(creds)

# Zuweisen der Logindaten
username = credentials['benutzername']
password = credentials['passwort']
server = credentials['server']
rtspport = credentials['rtspport']
httpport = credentials['httpport']

# Hilfsvariablen erstellen
mode = 0
changefromstoremode = 0
baud = 9600
online = None
connection = None
modelist=['A','B','C','D']
positionlist=[0,1,2,3,4,5,6,7]
ptzsteplist=['2','4','6','8','*','#']
ptzdrivelist=['2','4','5','6','8','*','#']
setlist=[0,1,2,3,4,5,6,7]

# Prüfen ob Keypad angeschlossen und serielle Verbindung herstellen
try:
	connection = serial.Serial('/dev/keypad', baud)
	connection.close()
	connection.open()
except:
	sys.exit(0)

# Funktion zum prüfen ob Kamera erreichbar
def servercheck(server):
	try:
		response = os.system("fping -c 1 -t 80 " + server + ">/dev/null 2>&1")
  		if response == 0:
			return True
		else:
			return False
	except:
		return False

# Funktion Feedbacksound Okay
def feedbacksoundok():
	try:
		sub.call (["aplay -q /opt/keypad/sounds/feedbackok.wav"], shell=True)
	except:
		pass
	return

# Funktion Feedbacksound Failure
def feedbacksoundfailure():
	try:
		sub.call (["aplay -q /opt/keypad/sounds/feedbackfailure.wav"], shell=True)
	except:
		pass
	return

# Funktion gespeicherte Kameraposition anfahren
def gotocamerapostion(username,password,server,httpport,input):
	urllib.urlopen('http://%s:%s@%s:%s/ptzctrl.cgi?-step=0&-act=stop' %(username,password,server,httpport))
	urllib.urlopen('http://%s:%s@%s:%s/param.cgi?cmd=preset&-act=goto&-status=1&-number=%s' %(username,password,server,httpport,input))
	return

# Funktion schrittweise PTZ-Fahrt
def ptzstep(username,password,server,httpport,input):
	if input == '2':
		input = "-step=1&-act=up"
	elif input == '4':
		input = "-step=1&-act=left"
	elif input == '6':
		input = "-step=1&-act=right"
	elif input == '8':
		input = "-step=1&-act=down"
	elif input == '*':
		input = "-step=1&-act=zoomin"
	elif input == '#':
		input = "-step=1&-act=zoomout"
	urllib.urlopen('http://%s:%s@%s:%s/ptzctrl.cgi?-step=0&-act=stop' %(username,password,server,httpport))
	urllib.urlopen('http://%s:%s@%s:%s/ptzctrl.cgi?%s' %(username,password,server,httpport,input))
	return

# Funktion kontinuierliche PTZ-Fahrt
def ptzdrive(username,password,server,httpport,input):
	if input == '2':
		input = "-step=0&-act=up&-speed=10"
	elif input == '4':
		input = "-step=0&-act=left&-speed=10"
	elif input == '5':
		input = "-step=0&-act=stop"
	elif input == '6':
		input = "-step=0&-act=right&-speed=10"
	elif input == '8':
		input = "-step=0&-act=down&-speed=10"
	elif input == '*':
		input = "-step=0&-act=zoomin&-speed=35"
	elif input == '#':
		input = "-step=0&-act=zoomout&-speed=35"
	urllib.urlopen('http://%s:%s@%s:%s/ptzctrl.cgi?-step=0&-act=stop' %(username,password,server,httpport))
	urllib.urlopen('http://%s:%s@%s:%s/ptzctrl.cgi?%s' %(username,password,server,httpport,input))
	return

# Funktion Kameraposition speichern
def setcamerapostion(username,password,server,httpport,input):
	urllib.urlopen('http://%s:%s@%s:%s/ptzctrl.cgi?-step=0&-act=stop' %(username,password,server,httpport))
	urllib.urlopen('http://%s:%s@%s:%s/param.cgi?cmd=preset&-act=set&-status=1&-number=%s' %(username,password,server,httpport,input))
	return

# Hauptprogramm
while True:
	try:
		input = connection.readline()
		input = input[0]
	except:
		sys.exit(0)
	if input in modelist:
		if input == 'A':
			mode = 0
			if changefromstoremode == 0:
				thread.start_new_thread(feedbacksoundok,())
			else:
				changefromstoremode = 0
		elif input == 'B':
			mode = 1
			if changefromstoremode == 0:
				thread.start_new_thread(feedbacksoundok,())
			else:
				changefromstoremode = 0
		elif input == 'C':
			mode = 2
			if changefromstoremode == 0:
				thread.start_new_thread(feedbacksoundok,())
			else:
				changefromstoremode = 0
		elif input == 'D':
			mode = 3
			thread.start_new_thread(feedbacksoundok,())
	else:
		if mode == 0:
			try:
				input = int(input)
				input = input - 1
			except:
				thread.start_new_thread(feedbacksoundfailure,())
				continue
			if input in positionlist:
				input = str(input)
				online = servercheck(server)
				if online == True:
					thread.start_new_thread(feedbacksoundok,())
					thread.start_new_thread(gotocamerapostion,(username,password,server,httpport,input))
				else:
					thread.start_new_thread(feedbacksoundfailure,())
			else:
				thread.start_new_thread(feedbacksoundfailure,())
		if mode == 1:
			if input in ptzsteplist:
				online = servercheck(server)
				if online == True:
					thread.start_new_thread(feedbacksoundok,())
					thread.start_new_thread(ptzstep,(username,password,server,httpport,input))
				else:
					thread.start_new_thread(feedbacksoundfailure,())
			else:
				thread.start_new_thread(feedbacksoundfailure,())
		if mode == 2:
			if input in ptzdrivelist:
				online = servercheck(server)
				if online == True:
					thread.start_new_thread(feedbacksoundok,())
					thread.start_new_thread(ptzdrive,(username,password,server,httpport,input))
				else:
					thread.start_new_thread(feedbacksoundfailure,())
			else:
				thread.start_new_thread(feedbacksoundfailure,())
		if mode == 3:
			try:
				input = int(input)
				input = input - 1
			except:
				thread.start_new_thread(feedbacksoundfailure,())
				continue
			if input in setlist:
				input = str(input)
				online = servercheck(server)
				if online == True:
					changefromstoremode = 1
					thread.start_new_thread(feedbacksoundok,())
					thread.start_new_thread(setcamerapostion,(username,password,server,httpport,input))
				else:
					thread.start_new_thread(feedbacksoundfailure,())
			else:
				thread.start_new_thread(feedbacksoundfailure,())