adctest: main.swift SwiftyGPIO.swift HD44780CharacterLCD.swift /usr/lib/libMCP3008.so
	@~/usr/bin/swiftc main.swift SwiftyGPIO.swift HD44780CharacterLCD.swift -I ./CMCP3008 -L. -o adctest

/usr/lib/libMCP3008.so: ./CMCP3008/MCP3008.c
	clang -shared ./CMCP3008/MCP3008.c -o ./libMCP3008.so
	sudo cp libMCP3008.so /usr/lib

HD44780CharacterLCD.swift: 
	@wget https://raw.githubusercontent.com/uraimo/HD44780CharacterLCD.swift/master/Sources/HD44780CharacterLCD.swift

SwiftyGPIO.swift:
	@wget https://raw.githubusercontent.com/uraimo/SwiftyGPIO/master/Sources/SwiftyGPIO.swift

