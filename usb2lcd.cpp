/* usb2lcd by Neil Isaac */

#include <Arduino.h>
#include <TinyWireM.h>
#include <LiquidCrystal_I2C.h>
#include <DigiUSB.h>

LiquidCrystal_I2C lcd(0x27, 16, 2);

void setup(){
	TinyWireM.begin();

	DigiUSB.begin();

	lcd.init();
	lcd.backlight();
	lcd.clear();
}

void write(char c) {
	char str[2];
	str[0] = c;
	str[1] = '\0';

	lcd.print(str);
}

void loop() {

	while (DigiUSB.available()) {
		int val = DigiUSB.read();

		if (val == 0) {
			lcd.setCursor(0, 0);
			break;
		}

		else if (val == 256) {
			lcd.clear();
		}
		
		else if (val == '\n') {
			lcd.setCursor(0, 1);
		}

		else {
			write(val);
		}
	}

	DigiUSB.refresh();
}

