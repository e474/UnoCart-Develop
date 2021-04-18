#ifndef ACE8BIT_H
#define ACE8BIT_H

// This header must exist at the beginning of every valid ace file

#define ACE_MAGIC_NUMBER_STRING_LENGTH	8
#define ACE_DRIVER_NAME_STRING_LENGTH 16
#define ACE_MAX_ROM_SIZE	448 * 1024

typedef struct __attribute__((packed)) {
	uint8_t magic_number[ACE_MAGIC_NUMBER_STRING_LENGTH]; // Always ascii "ACE-8BIT"
	uint8_t driver_name[ACE_DRIVER_NAME_STRING_LENGTH]; // emulators care about this
	uint32_t driver_version; // emulators care about this
	uint32_t rom_size;		 // size of ROM to be copied to flash, 448KB max
	uint32_t rom_checksum;	 // used to verify if flash already contains valid image
	uint32_t entry_point;	 // where to begin executing
} ACEFileHeader;

#endif // ACE8BIT_H
