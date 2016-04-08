#include <stdint.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/types.h>
#include <linux/spi/spidev.h>

static void pabort(const char *s)
{
	perror(s);
	abort();
}

static uint8_t bits = 8;
static uint32_t speed = 500000;
static uint16_t delay;

// based on the spidev_test code here: https://www.raspberrypi.org/documentation/hardware/raspberrypi/spi/README.md
int readInput(const char *device, int adcnum)
{
	int fd = open(device, O_RDWR);
	if (fd < 0)
		pabort("can't open device");

	int ret;
	uint8_t tx[] = {
		1,(8+adcnum)<<4,0
	};
	uint8_t rx[3] = {0, };
	struct spi_ioc_transfer tr = {
		.tx_buf = (unsigned long)tx,
		.rx_buf = (unsigned long)rx,
		.len = 3,
		.delay_usecs = delay,
		.speed_hz = speed,
		.bits_per_word = bits,
	};

	ret = ioctl(fd, SPI_IOC_MESSAGE(1), &tr);
	if (ret < 1)
		pabort("can't send spi message");

	return ((rx[1]&3) << 8) + rx[2];
}
