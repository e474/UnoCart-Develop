/*
 * --------------------------------------
 * UNOCart Firmware (c)2016 Robin Edwards
 * --------------------------------------
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#define _GNU_SOURCE

#include "defines.h"
#include "stm32f4xx.h"
#include "tm_stm32f4_fatfs.h"
#include "tm_stm32f4_delay.h"
#include <stdio.h>
#include <string.h>

#include "cart16K.h"

#include "ace8bit.h"

extern void Reset_Handler();

extern int __file_size;

extern ACEFileHeader AceHeader;

ACEFileHeader AceHeader __attribute__ ((section (".file_header"))) __attribute__ ((__used__)) =
{
	.magic_number = "ACE-8BIT",
	.driver_name = "ACE Default",
	.driver_version = 1,
	.rom_size = (int)&__file_size,
	.rom_checksum = 0,
	.entry_point = (uint32_t)Reset_Handler
};


unsigned char cart_ram1[64*1024];
unsigned char cart_ram2[64*1024] __attribute__((section(".ccmram")));
unsigned char cart_d5xx[256] = {0};
char errorBuf[40];

#define CART_CMD_OPEN_ITEM			0x00
#define CART_CMD_READ_CUR_DIR		0x01
#define CART_CMD_GET_DIR_ENTRY		0x02
#define CART_CMD_UP_DIR				0x03
#define CART_CMD_ROOT_DIR			0x04
#define CART_CMD_SEARCH				0x05
#define CART_CMD_LOAD_SOFT_OS		0x10
#define CART_CMD_SOFT_OS_CHUNK		0x11
#define CART_CMD_MOUNT_ATR			0x20	// unused, done automatically by firmware
#define CART_CMD_READ_ATR_SECTOR	0x21
#define CART_CMD_WRITE_ATR_SECTOR	0x22
#define CART_CMD_ATR_HEADER			0x23
#define CART_CMD_NO_CART			0xFE
#define CART_CMD_ACTIVATE_CART  	0xFF

#define CART_TYPE_NONE				0
#define CART_TYPE_8K				1	// 8k
#define CART_TYPE_16K				2	// 16k
#define CART_TYPE_XEGS_32K			3	// 32k
#define CART_TYPE_XEGS_64K			4	// 64k
#define CART_TYPE_XEGS_128K			5	// 128k
#define CART_TYPE_SW_XEGS_32K		6	// 32k
#define CART_TYPE_SW_XEGS_64K		7	// 64k
#define CART_TYPE_SW_XEGS_128K		8	// 128k
#define CART_TYPE_MEGACART_16K		9	// 16k
#define CART_TYPE_MEGACART_32K		10	// 32k
#define CART_TYPE_MEGACART_64K		11	// 64k
#define CART_TYPE_MEGACART_128K		12	// 128k
#define CART_TYPE_BOUNTY_BOB		13	// 40k
#define CART_TYPE_ATARIMAX_1MBIT	14	// 128k
#define CART_TYPE_WILLIAMS_64K		15	// 32k/64k
#define CART_TYPE_OSS_16K_TYPE_B	16	// 16k
#define CART_TYPE_OSS_8K			17	// 8k
#define CART_TYPE_OSS_16K_034M		18	// 16k
#define CART_TYPE_OSS_16K_043M		19	// 16k
#define CART_TYPE_SIC_128K			20	// 128k
#define CART_TYPE_SDX_64K			21	// 64k
#define CART_TYPE_SDX_128K			22	// 128k
#define CART_TYPE_DIAMOND_64K		23	// 64k
#define CART_TYPE_EXPRESS_64K		24	// 64k
#define CART_TYPE_BLIZZARD_16K		25	// 16k
#define CART_TYPE_ACE				253 // ARM Cartridge Executable
#define CART_TYPE_ATR				254
#define CART_TYPE_XEX				255

typedef struct {
	char isDir;
	char filename[13];
	char long_filename[32];
	char full_path[210];
} DIR_ENTRY;	// 256 bytes = 256 entries in 64k

int num_dir_entries = 0; // how many entries in the current directory

// single FILINFO structure
FILINFO fno;
char lfn[_MAX_LFN + 1];   /* Buffer to store the LFN */

void init() {
	// this seems to be required for this version of FAT FS
	fno.lfname = lfn;
	fno.lfsize = sizeof lfn;
}


FATFS FatFs;
int doneFatFsInit = 0;

#define RD5_LOW GPIOB->BSRRH = GPIO_Pin_2;
#define RD4_LOW GPIOB->BSRRH = GPIO_Pin_4;
#define RD5_HIGH GPIOB->BSRRL = GPIO_Pin_2;
#define RD4_HIGH GPIOB->BSRRL = GPIO_Pin_4;

#define CONTROL_IN GPIOC->IDR
#define ADDR_IN GPIOD->IDR
#define DATA_IN GPIOE->IDR
#define DATA_OUT GPIOE->ODR

#define PHI2_RD (GPIOC->IDR & 0x0001)
#define S5_RD (GPIOC->IDR & 0x0002)
#define S4_RD (GPIOC->IDR & 0x0004)
#define S4_AND_S5_HIGH (GPIOC->IDR & 0x0006) == 0x6

#define PHI2	0x0001
#define S5		0x0002
#define S4		0x0004
#define CCTL	0x0010
#define RW		0x0020

#define SET_DATA_MODE_IN GPIOE->MODER = 0x00000000;
#define SET_DATA_MODE_OUT GPIOE->MODER = 0x55550000;

#define GREEN_LED_OFF GPIOB->BSRRH = GPIO_Pin_0;
#define RED_LED_OFF GPIOB->BSRRH = GPIO_Pin_1;
#define GREEN_LED_ON GPIOB->BSRRL = GPIO_Pin_0;
#define RED_LED_ON GPIOB->BSRRL = GPIO_Pin_1;

GPIO_InitTypeDef  GPIO_InitStructure;

/* Green LED -> PB0, Red LED -> PB1, RD5 -> PB2, RD4 -> PB4 */
void config_gpio_leds_RD45()
{
	/* GPIOB Periph clock enable */
	RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOB, ENABLE);
	/* Configure PB0, PB1in output pushpull mode */
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_0 | GPIO_Pin_1 | GPIO_Pin_2 | GPIO_Pin_4;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_OUT;
	GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_25MHz;
	GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_NOPULL;
	GPIO_Init(GPIOB, &GPIO_InitStructure);
}

/* Input Signals GPIO pins on CLK -> PC0, /S5 -> PC1, /S4 ->PC2, CCTL -> PC4, R/W -> PC5 */
void config_gpio_sig(void) {
	/* GPIOC Periph clock enable */
	RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOC, ENABLE);

	/* Configure GPIO Settings */
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_0 | GPIO_Pin_1 | GPIO_Pin_2 | GPIO_Pin_4 | GPIO_Pin_5;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IN;
	GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_100MHz;
	GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_DOWN;
	GPIO_Init(GPIOC, &GPIO_InitStructure);
}

/* Input/Output data GPIO pins on PE{8..15} */
void config_gpio_data(void) {
	/* GPIOE Periph clock enable */
	RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOE, ENABLE);

	/* Configure GPIO Settings */
	GPIO_InitStructure.GPIO_Pin =
		GPIO_Pin_8 | GPIO_Pin_9 | GPIO_Pin_10 | GPIO_Pin_11 |
		GPIO_Pin_12 | GPIO_Pin_13 | GPIO_Pin_14 | GPIO_Pin_15;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IN;
	GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_25MHz;	// avoid sharp edges
	GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_DOWN;
	GPIO_Init(GPIOE, &GPIO_InitStructure);
}

/* Input Address GPIO pins on PD{0..15} */
void config_gpio_addr(void) {
	/* GPIOD Periph clock enable */
	RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOD, ENABLE);

	/* Configure GPIO Settings */
	GPIO_InitStructure.GPIO_Pin =
		GPIO_Pin_0 | GPIO_Pin_1 | GPIO_Pin_2 | GPIO_Pin_3 |
		GPIO_Pin_4 | GPIO_Pin_5 | GPIO_Pin_6 | GPIO_Pin_7 |
		GPIO_Pin_8 | GPIO_Pin_9 | GPIO_Pin_10 | GPIO_Pin_11 |
		GPIO_Pin_12 | GPIO_Pin_13 | GPIO_Pin_14 | GPIO_Pin_15;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IN;
	GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_100MHz;
	GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_DOWN;
	GPIO_Init(GPIOD, &GPIO_InitStructure);
}

/*
 Theory of Operation
 -------------------
 Atari sends command to mcu on cart by writing to $D5DF ($D5E0-$D5FF = SDX)
 (extra paramters for the command in $D500-$D5DE)
 Atari must be running from RAM when it sends a command, since the mcu on the cart will
 go away at that point.
 Atari polls $D500 until it reads $11. At this point it knows the mcu is back
 and it is safe to rts back to code in cartridge ROM again.
 Results of the command are in $D501-$D5DF

 This function serves up cartridge data from cart16K.h onto the 8-bit bus, or
 returns the command code written to $D5DF by the 8-bit, for further processing by
 the MCU
*/

int emulate_default_cartridge(int atrMode) {
	__disable_irq();	// Disable interrupts
	//if (atrMode) RD5_LOW else RD5_HIGH
	RD4_HIGH
	RD5_HIGH
	cart_d5xx[0x00] = 0x11;	// signal that we are here

	uint16_t addr, data, c;
	while (1)
	{
		// wait for phi2 high
		while (!((c = CONTROL_IN) & PHI2)) ;

		if (!(c & CCTL)) {
			// CCTL low
			if (c & RW) {
				// read
				SET_DATA_MODE_OUT
				addr = ADDR_IN;
				DATA_OUT = ((uint16_t)cart_d5xx[addr&0xFF])<<8;
				// wait for phi2 low
				while (CONTROL_IN & PHI2) ;
				SET_DATA_MODE_IN
			}
			else {
				// write
				addr = ADDR_IN;
				data = DATA_IN;
				// read data bus on falling edge of phi2
				while (CONTROL_IN & PHI2)
					data = DATA_IN;
				cart_d5xx[addr&0xFF] = data>>8;
				if ((addr&0xFF) == 0xDF)	// write to $D5DF, that is, cartridge command sent,
											// so return command to calling code
					break;
			}
		}
		if (!(c & S5)) {
			// normal cartridge read, so serve up data from firmware boot rom image in rom.h
			SET_DATA_MODE_OUT
			addr = ADDR_IN;
			DATA_OUT = ((uint16_t)(cart16K_rom[0x2000|addr]))<<8;  /* read from cart8K.h array */
			// wait for phi2 low
			while (CONTROL_IN & PHI2) ;
			SET_DATA_MODE_IN
		} else if (!(c & S4)) {
			// normal cartridge read, so serve up data from firmware boot rom image in rom.h
			SET_DATA_MODE_OUT
			addr = ADDR_IN;
			DATA_OUT = ((uint16_t)(cart16K_rom[addr]))<<8;  /* read from cart8K.h array */
			// wait for phi2 low
			while (CONTROL_IN & PHI2) ;
			SET_DATA_MODE_IN

		}
	}
	__enable_irq();
	return data>>8;
}

void emulate_standard_16k() {
	// 16k
	RD4_HIGH
	RD5_HIGH
	uint16_t addr;
	while (1)
	{
		// wait for either s4 or s5 low
		while (S4_AND_S5_HIGH) ;
		SET_DATA_MODE_OUT
		if (!S4_RD) {
			// while s4 low
			while (!S4_RD) {
				addr = ADDR_IN;
				DATA_OUT = ((uint16_t)cart16K_rom[addr])<<8;
			}
		}
		else {
			// while s5 low
			while (!S5_RD) {
				addr = ADDR_IN;
				DATA_OUT = ((uint16_t)cart16K_rom[0x2000|addr])<<8;
			}
		}
		SET_DATA_MODE_IN
	}
}


int main(void) {

	/* Ouptut: LEDS - PB{0..1}, RD5 - PB2, RD4 - PB4 */
	config_gpio_leds_RD45();
	/* InOut: Data - PE{8..15} */
	config_gpio_data();
	/* In: Address - PD{0..15} */
	config_gpio_addr();
	/* In: Other Cart Input Sigs - PC{0..2, 4..5} */
	config_gpio_sig();

	RED_LED_ON
	int atrMode = 0;
	init();

	GREEN_LED_OFF

//	cart_d5xx[0x01] = 0x01;	// signal that cartridge has been loaded,
							// that is, user selected ACE file, cartridge
							// has been loaded, and the UnoCart menu
							// can reboot to get the 8-bit OS to run this
							// cartridge

	while (1) {

		/*
		 * loop
		 *  emulate boot rom until Atari sends command by writing command to $D5DF,
		 *  then process that command, and loop back and emulate boot rom until next
		 *  command written to $D5DF
		 */

		int cmd = emulate_default_cartridge(atrMode);

		//emulate_standard_16k();

		// process whatever the command is from the code in the
		// default Atari 8-bit ROM

		cmd++;

	//	GREEN_LED_ON

	}

}
