#!/usr/bin/python
# -*- coding: utf-8 -*-

# Import der notwendigen Bibliotheken
import os
import time
import socket
import subprocess as sub

# Hilfsvariablen erstellen
port = 50000
program = "keypad4x4.py"
device = None
process_id = None

# Funktion zum Prüfen ob übergebens Programm läuft
def process_running(name):
	try:
		name = name[:15]
		pid = sub.check_output("pgrep %s" %name, shell=True)
		pid = int(pid)
		return pid
	except:
		return 0

# Funktion zum Prüfen ob Gerät angeschlossen ist
def detectdevice():
	device = os.path.exists("/dev/keypad")
	if device == True:
		return 1
	else:
		return 0

# Hauptprogramm
while True:
	process_id = process_running(program)
	if process_id == 0:
		device = detectdevice()
		if device == 1:
			if os.path.exists("/opt/keypad/%s" %program):
				sub.call (["/opt/keypad/%s &" %(program)], shell=True)
	process_id = None
	device = None
	time.sleep(1)