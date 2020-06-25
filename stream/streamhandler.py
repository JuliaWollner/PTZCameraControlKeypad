#!/usr/bin/python
# -*- coding: utf-8 -*-

# Import der notwendigen Bibliotheken
import os
import json
import time
import signal
import socket
import subprocess as sub

# Zugangsdaten importieren
with open("YOURS") as creds:
	credentials = json.load(creds)

# Setzen der Logindaten
username = credentials['benutzername']
password = credentials['passwort']
server = credentials['server']
rtspport = credentials['rtspport']
httpport = credentials['httpport']

# Hilfsvariablen anlegen
program = 'vlc'
pid = None
online = None
quality = '11'

# Funktion zum prüfen ob Kamera erreichbar
def servercheck(ip,httpport):
	try:
		s = socket.create_connection((ip,httpport),0.1)
		s.close()
		return True
	except:
		return False

# Hauptprogramm
while True:
	online = servercheck(server,int(httpport))
	try:
		program = program[:15]
		pid = sub.check_output("pgrep %s" %program, shell=True)
		if online == False:
			pid = int(pid)
			os.kill(pid, signal.SIGKILL)
		else:
			pass
	except:
		if online == True:
			sub.call (["DISPLAY=:0 vlc rtsp://%s:%s@%s:%s/%s --quiet --rtsp-tcp --noaudio --fullscreen --no-qt-privacy-ask --no-video-title --network-caching=500 --sout-mux-caching=500 vlc://quit &" %(username,password,server,rtspport,quality)], shell=True)
		else:
			pass
	time.sleep(1)