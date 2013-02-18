#!/usr/bin/env python2
#
# weather.py by Neil Isaac
# http://neilisaac.ca
#
# - this requires pyusb 1.0
# - find your WOEID at http://woeid.rosselliot.co.nz

import sys
import time
import re
import urllib
import xml.dom.minidom

import usbdevice

REFRESH = 120
WOEID = 4118
URL = "http://weather.yahooapis.com/forecastrss?w={:d}&u=c"
NS = "http://xml.weather.yahoo.com/ns/rss/1.0"

def lcd_write(device, first, second):
	device.write(256)

	for c in first:
		device.write(ord(c))

	device.write(ord("\n"))

	for c in second:
		device.write(ord(c))

	device.write(0)

def yahoo_weather(woeid):
	url = urllib.urlopen(URL.format(woeid))
	dom = xml.dom.minidom.parse(url)

	condition = dom.getElementsByTagNameNS(NS, 'condition')[0]
	temp = condition.getAttribute("temp")
	text = condition.getAttribute("text")
	
	forecast = dom.getElementsByTagNameNS(NS, 'forecast')[0]
	low = forecast.getAttribute("low")
	high = forecast.getAttribute("high")

	return (temp, low, high, text)

device = None
weather = None
counter = 0

while True:
	if device is None:
		try:
			device = usbdevice.ArduinoUsbDevice(idVendor=0x16c0, idProduct=0x27db)
			print "connected: {:04x} {:04x} {:s} {:s}".format(device.idVendor, device.idProduct, device.productName, device.manufacturer)
		except:
			print "usb device is not connected"

	while device is not None:
		d = time.strftime("%a %d %b")
		t = re.sub("^0", "", time.strftime("%I:%M"))

		if weather is None or counter >= REFRESH:
			temp, low, high, text = yahoo_weather(WOEID)
			weather = "{:s} {:s}".format(temp, text)
			counter = 0

		line1 = d + " " * (16 - len(d) - len(t)) + t + "\n" + ""
		line2 = weather

		try:
			lcd_write(device, line1, line2)
		except:
			device = None	

		time.sleep(1)
		counter += 1
	
	time.sleep(5)
	counter += 5

