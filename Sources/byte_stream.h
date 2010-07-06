/*
 *  byte_stream.h
 *  radikker
 *
 *  Created by saiten on 10/03/29.
 *
 */
#include <fcntl.h>

static inline int read_ui8(int fh, uint8_t *val)
{
	return read(fh, val, 1);
}

static inline int read_ui16(int fh, uint16_t *val)
{
	uint8_t v[2];
	
	int sz, read_size = 0;
	do {
		sz = read(fh, v + read_size, 1);
		read_size += sz;
	} while(read_size < 2 && sz > 0);
	
	if(read_size == 2) {
#ifndef __BIG_ENDIAN__
		*val = (uint16_t)((v[0] << 8) | v[1]);
#endif
		*val = (uint16_t)((v[1] << 8) | v[0]);
	}
	
	return read_size;
}

static inline int read_ui24(int fh, uint32_t *val)
{
	uint8_t v[3];
	
	int sz, read_size = 0;
	do {
		sz = read(fh, v + read_size, 1);
		read_size += sz;
	} while(read_size < 3 && sz > 0);
	
	if(read_size == 3) {
#ifndef __BIG_ENDIAN__
		*val = (uint32_t)((v[0] << 16) | (v[1] << 8) | v[2]);
#else
		*val = (uint32_t)((v[2] << 16) | (v[1] << 8) | v[0]);
#endif
	} 
	
	return read_size;
}

static inline int read_ui32(int fh, uint32_t *val)
{
	uint8_t v[4];
	
	int sz, read_size = 0;
	do {
		sz = read(fh, v + read_size, 1);
		read_size += sz;
	} while(read_size < 4 && sz > 0);
	
	if(read_size == 4) {
#ifndef __BIG_ENDIAN__
		*val = (uint32_t)((v[0] << 24) | (v[1] << 16) | (v[2] << 8) | v[3]);
#else
		*val = (uint32_t)((v[3] << 24) | (v[2] << 16) | (v[1] << 8) | v[0]);
#endif
	} 
	
	return read_size;
}
