//
//  FLVConverter.m
//  radikker
//
//  Created by saiten on 10/03/27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FLVConverter.h"
#import "endian.h"
#import "byte_stream.h"

typedef struct {
	uint8_t tag_type;
	uint32_t data_size;
	uint32_t timestamp;
	uint8_t timestamp_extended;
	uint32_t stream_id;
} flv_tag_header;

typedef struct {
	uint8_t audio_object_type;
	uint8_t frequency_index;
	uint8_t channel;
	uint16_t frame_length;
} aac_simple_header;

@interface FLVConverter(private)
- (void)run:(id)param;
@end

static BOOL active = NO;

@implementation FLVConverter

@synthesize delegate;

- (id)initWithFileAtPath:(NSString *)path
{
	NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];
	return [self initWithFileHandle:handle];
}

- (id)initWithFileHandle:(NSFileHandle *)handle
{
	if((self = [super init])) {
		inputHandle = [handle retain];
	}
	return self;
}

- (void)convertToFileAtPath:(NSString *)path
{
	NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:path];
	[self convertToFileHandle:handle];
}

- (void)convertToFileHandle:(NSFileHandle*)handle
{
	if(active)
		return;
	
	outputHandle = [handle retain];
	
	active = YES;
	[NSThread detachNewThreadSelector:@selector(run:) toTarget:self withObject:self];
}

- (void)stopConvert
{
	active = NO;
}

static void output_aac_header(int ofh, aac_simple_header *aac_header)
{
	uint8_t header[7];
	memset(header, 0, 7);
    
	uint8_t profile = 5;
	uint8_t private_bit = 0;
	
	header[0] = 0xff;
	header[1] = 0xf1;
	header[2] = ((profile & 0x03) << 6) |
                ((aac_header->frequency_index & 0x0f) << 2) |
                ((private_bit & 0x01) << 1) |
                ((aac_header->channel & 0x04));
	header[3] = ((aac_header->channel & 0x03) << 6) |
                ((aac_header->frame_length & 0x1800) >> 11);
	header[4] = ((aac_header->frame_length & 0x07f8) >> 3);
	header[5] = ((aac_header->frame_length & 0x0007) << 5) | 0x1f;
	header[6] = 0x0c;
	
	write(ofh, header, 7);
}

static int read_through(int fh, int size)
{
	uint8_t c;
	int read_size = 0;
	while(size - read_size > 0) {
		int ret = read_ui8(fh, &c);
		if(ret == 0) {
			DLog(@"read_through read_size == 0");
			active = NO;
			break;
		}
		read_size += ret;
	}
	return read_size;
}

static int read_aac(int fh, flv_tag_header *tag_header, aac_simple_header *aac_header, int ofh)
{
	//DLog(@"   FLVConverter read_aac");
    
	int read_size = 0;
    
	uint8_t type = 0;
	read_size += read_ui8(fh, &type);
    
	int data_size = tag_header->data_size - 2;
    
	if(type == 0) {
		//DLog(@"   FLVConverter aac header setting : %d", data_size);
		if(data_size >= 2) {
			uint8_t val[2];
			read_size += read_ui8(fh, val);
			read_size += read_ui8(fh, val+1);
            
			aac_header->audio_object_type = (val[0] & 0xf8) >> 3;
			aac_header->frequency_index   = ((val[0] & 0x07) << 1) | ((val[1] & 0x80) >> 3);
			aac_header->channel           = (val[1] & 0x78) >> 3;
            
			data_size -= 2;
		}
		
		read_size += read_through(fh, data_size);
		return read_size;
	}
    
	aac_header->frame_length = data_size + 7;
	output_aac_header(ofh, aac_header);
    
	//DLog(@"   FLVConverter output aac raw : %d", data_size);
    
	uint8_t c = 0;
	int size = 0;
	while(data_size > 0) {
		size = read(fh, &c, 1);
		if(size == 0) {
			DLog(@"break raw writing");
			active = NO;
			break;
		}
        
		write(ofh, &c, 1);
		data_size -= size;
		read_size += size;
	} ;
	
	return read_size;
}

static int read_audio(int fh, flv_tag_header *tag_header, aac_simple_header *aac_header, int ofh)
{
	//DLog(@"  FLVConverter read_audio");
	
	int read_size = 0;
	uint8_t head = 0;
	read_size += read_ui8(fh, &head);
	
	//uint8_t streo = head & 0x01;
	//uint8_t size = (head & 0x02) >> 1;
	//uint8_t rate = (head & 0x0c) >> 2;
	uint8_t format = (head & 0xf0) >> 4;
	
	if(format == 0x0A) {
		read_size += read_aac(fh, tag_header, aac_header, ofh);
	} else {
		read_size += read_through(fh, tag_header->data_size - 1);
	}
	
	return read_size;
}

static int read_tag(int fh, flv_tag_header *tag_header)
{
	//DLog(@" FLVConverter read_tag");
	
	int read_size = 0;
	uint32_t tmp32;
	read_size += read_ui32(fh, &tmp32); // previous tag size
    
	read_size += read_ui8(fh, &(tag_header->tag_type));
	read_size += read_ui24(fh, &(tag_header->data_size));
	read_size += read_ui24(fh, &(tag_header->timestamp));
	read_size += read_ui8(fh, &(tag_header->timestamp_extended));
	read_size += read_ui24(fh, &(tag_header->stream_id));
	
	return read_size;
}

static int read_header(int fh)
{
	//DLog(@" FLVConverter read_header");
	
	int read_size = 0;
	char sig[3];
	
	read_size = read(fh, sig, 3);
	if(read_size == 3) { // signature
		if(sig[0] = 'F' && sig[1] == 'L' && sig[2] == 'V') {
			uint8_t tmp8;
			uint32_t tmp32;
			read_size += read_ui8(fh, &tmp8);   // version
			read_size += read_ui8(fh, &tmp8);   // flag
			read_size += read_ui32(fh, &tmp32); // offset
		}
	}
    
	return read_size;
}

static void _convert(int fh, int ofh)
{
	aac_simple_header aac_header = {0};
	
	if(read_header(fh))
		active = YES;
	else
		active = NO;
	
	while(active) {
		flv_tag_header tag_header = { 0 };
		
		if(read_tag(fh, &tag_header) <= 0)
			break;
		
		if(tag_header.tag_type == 0x08) { // audio tag
			if(read_audio(fh, &tag_header, &aac_header, ofh) <= 0)
				break;
		} else { // other tag
			read_through(fh, tag_header.data_size);
		}
	}
}

- (void)run:(id)param
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	DLog(@"FLVConverter start.");
	
	int fh = [inputHandle fileDescriptor];
	int ofh = [outputHandle fileDescriptor];
    
	if(delegate && [delegate respondsToSelector:@selector(flvConverterDidStartConvert:)]) {
		[delegate performSelector:@selector(flvConverterDidStartConvert:)
						 onThread:[NSThread mainThread]
					   withObject:self
					waitUntilDone:NO];
	}
	
	_convert(fh, ofh);
	
	if(delegate && [delegate respondsToSelector:@selector(flvConverterDidFinishConvert:)]) {
		[delegate performSelector:@selector(flvConverterDidFinishConvert:)
						 onThread:[NSThread mainThread]
					   withObject:self
					waitUntilDone:NO];
	}
	
    active = NO;
    
	DLog(@"FLVConverter end.");
    
	[pool release];
	[NSThread exit];
}

- (void)dealloc
{
	[inputHandle release];
	[outputHandle release];
	[super dealloc];
}

@end
