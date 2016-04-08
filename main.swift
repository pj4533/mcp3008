import Glibc
import Foundation
import CMCP3008

func initLCD() -> HD44780LCD {
	let gpios = SwiftyGPIO.getGPIOsForBoard(.RaspberryPiRev2)
	let lcd = HD44780LCD(rs:gpios[.P25]!,e:gpios[.P24]!,d7:gpios[.P22]!,d6:gpios[.P27]!,d5:gpios[.P17]!,d4:gpios[.P23]!,width:20,height:2)
	return lcd	
}

// This uses a module i made to take advantage of the hardware SPI.  I couldn't get it working with regular reading 
// of the files, so I had to put ioctl in a C module and import that.
//  here is a good tutorial on wiring the hardware spi:
//    http://jeremyblythe.blogspot.com/2012/09/raspberry-pi-hardware-spi-analog-inputs.html
func readadc(adcnum: Int32) -> Int32 {
	return readInput(strdup("/dev/spidev0.0"), adcnum)
}

// this is the bitbanged software version, translated from Python -- can use it with 
// the adafruit tutorial: https://learn.adafruit.com/reading-a-analog-in-and-controlling-audio-volume-with-the-raspberry-pi
func readadc(adcnum: Int, clockpin: GPIO, mosipin: GPIO, misopin: GPIO, cspin: GPIO) -> Int {
	clockpin.direction = .OUT
	mosipin.direction = .OUT
	misopin.direction = .IN
	cspin.direction = .OUT

	cspin.value = 1
	clockpin.value = 0
	cspin.value = 0

	var commandout = adcnum
	commandout |= 0x18 // start bit + single-ended bit
	commandout <<= 3 // we only need to send 5 bits here

	for _ in 0...4 {
		if ((commandout & 0x80) != 0) {
			mosipin.value = 1
		} else {
			mosipin.value = 0
		}
		commandout <<= 1
		clockpin.value = 1
		clockpin.value = 0
	}
	var adcout = 0

	// read in one empty bit, one null bit and 10 ADC bitmapRepresentation
	for _ in 0...11 {
		clockpin.value = 1
		clockpin.value = 0
		adcout <<= 1
		if (misopin.value == 1) {
			adcout |= 0x1
		}
	}
	cspin.value = 1

	adcout >>= 1  // first bit is null so drop it
	return adcout
}

let gpios = SwiftyGPIO.getGPIOsForBoard(.RaspberryPiRev2)

let lcd = initLCD()
lcd.cursorHome()

while (true) {
	lcd.clearScreen()
	
	// let adcvalue = readadc(0, clockpin:gpios[.P18]!, mosipin:gpios[.P9]!, misopin:gpios[.P10]!, cspin:gpios[.P11]!)
	let adcvalue = readadc(0)

	lcd.printString(0,y:0,what:"ADC0: \(adcvalue)",usCharSet:true)	

	usleep(500000)
}

