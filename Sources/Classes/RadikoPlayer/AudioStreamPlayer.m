//
//  AudioStreamPlayer.m
//  radikker
//
//  Created by saiten on 10/03/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AudioStreamPlayer.h"

@interface AudioStreamPlayer(private)
- (void)_openAudioFileStream;
- (void)_closeAudioFileStream;

- (void)_interruptionListener:(UInt32)inInterruption;

- (void)_audioQueueOutputCallback:(AudioQueueRef)aAudioQueue audioQueueBuffer:(AudioQueueBufferRef)aAudioBuffer;

- (void)_propertyListenerCallback:(AudioFileStreamID)inAudioFileStream 
		audioFileStreamPropertyId:(AudioFileStreamPropertyID)inPropertyID 
						  ioFlags:(UInt32*)ioFlags;

- (void)_packetsCallback:(UInt32)inNumberBytes numberPackets:(UInt32)inNumberPackets 
			   inputData:(const void *)inInputData audioStreamPacketDescription:(AudioStreamPacketDescription*)inPacketDescription;

- (void)_enqueueBuffer;
@end

static void _interruptionListener(void *inUserData, UInt32 inInterruption)
{
	[(AudioStreamPlayer*)inUserData _interruptionListener:(UInt32)inInterruption];
}

static void _audio_queue_output_callback(void *userData, AudioQueueRef aAudioQueue, AudioQueueBufferRef aAudioBuffer)
{
	[(AudioStreamPlayer*)userData _audioQueueOutputCallback:aAudioQueue audioQueueBuffer:aAudioBuffer];
}

static void _property_Listener_callback(void *inClientData, AudioFileStreamID inAudioFileStream, 
										AudioFileStreamPropertyID inPropertyID, UInt32 *ioFlags)
{
	[(AudioStreamPlayer*)inClientData _propertyListenerCallback:inAudioFileStream 
							 audioFileStreamPropertyId:inPropertyID 
											   ioFlags:ioFlags];
}

static void _packets_proc(void *inClientData, UInt32 inNumberBytes, UInt32 inNumberPackets, 
						  const void *inInputData, AudioStreamPacketDescription *inPacketDescription)
{
	[(AudioStreamPlayer*)inClientData _packetsCallback:inNumberBytes 
								numberPackets:inNumberPackets 
									inputData:inInputData
				 audioStreamPacketDescription:inPacketDescription];
}

static BOOL active = NO, buffering;

@implementation AudioStreamPlayer

@synthesize delegate, inputHandle;

- (id)initWithDelegate:(id)aDelegate bufferSize:(UInt32)size
{
	if((self = [super init])) {
		delegate = aDelegate;

		bufferSize = AUDIOBUFFER_SIZE;
		bufferCount = size / bufferSize;

		if(bufferCount < 3)
			bufferCount = 3;
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (UInt32)calculateBufferSizePerTime:(NSTimeInterval)interval
{
	UInt32 maxPacketSize = 0;
	Float64 numPacketPerTime = 0.0;
	
	UInt32 dataSize = sizeof(maxPacketSize);
	AudioFileStreamGetProperty(audioStreamId, kAudioFileStreamProperty_PacketSizeUpperBound, 
							   &dataSize, &maxPacketSize);
	
	numPacketPerTime = audioBasicDesc.mSampleRate / audioBasicDesc.mFramesPerPacket;
	return numPacketPerTime * maxPacketSize * interval;
}


- (void)_propertyListenerCallback:(AudioFileStreamID)inAudioFileStream 
		audioFileStreamPropertyId:(AudioFileStreamPropertyID)inPropertyID 
						  ioFlags:(UInt32*)ioFlags
{
	OSStatus oStatus = 0;
	
#ifdef DEBUG
	NSLog(@"found property '%c%c%c%c'\n", 
		  (inPropertyID>>24)&255, 
		  (inPropertyID>>16)&255, 
		  (inPropertyID>>8)&255,
		  inPropertyID&255
		  );
#endif
	
	if (kAudioFileStreamProperty_ReadyToProducePackets) {
		UInt32 dataSize = sizeof(audioBasicDesc);
		AudioFileStreamGetProperty(inAudioFileStream, kAudioFileStreamProperty_DataFormat, &dataSize, &audioBasicDesc);
		
		oStatus = AudioQueueNewOutput(&audioBasicDesc, _audio_queue_output_callback, self, 
									  NULL, NULL, 0, &audioQueue);
		if(oStatus)
			NSLog(@"failed AudioQueueNewOutput : %d", oStatus);
		
		//bufferSize = AUDIOBUFFER_SIZE;
		targetBufferIndex = 0;
		fillBufferSize = 0;
		fillPacketDescIndex = 0;
		fillQueueBufferCount = 0;
		
		for(int i = 0; i < bufferCount; i++) {
			oStatus = AudioQueueAllocateBuffer(audioQueue, bufferSize, &audioBuffers[i]);
			useBuffer[i] = NO;
		}
	}
}

- (void)_packetsCallback:(UInt32)inNumberBytes numberPackets:(UInt32)inNumberPackets 
			   inputData:(const void *)inInputData audioStreamPacketDescription:(AudioStreamPacketDescription*)inPacketDescription
{
	for(int i = 0; i < inNumberPackets; i++) {
		SInt64 packetOffset = inPacketDescription[i].mStartOffset;
		SInt64 packetSize   = inPacketDescription[i].mDataByteSize;

		size_t remainCount = bufferSize - fillBufferSize;
		if(remainCount < packetSize)
			[self _enqueueBuffer];
		
		AudioQueueBufferRef buffer = audioBuffers[targetBufferIndex];
		memcpy((uint8_t*)buffer->mAudioData + fillBufferSize, 
			   (uint8_t*)inInputData + packetOffset, packetSize);
		packetDescs[fillPacketDescIndex] = inPacketDescription[i];
		packetDescs[fillPacketDescIndex].mStartOffset = fillBufferSize;
		fillBufferSize += packetSize;
		fillPacketDescIndex++;
		
		size_t remainDescCount = PACKET_DESC_COUNT - fillPacketDescIndex;
		if(remainDescCount == 0) {
			//NSLog(@"packet remain is zero.");
			[self _enqueueBuffer];
		}
	}
}

- (void)_enqueueBuffer
{
	OSStatus oStatus;
	
#ifdef DEBUG
	NSLog(@"enqeueBuffer : %d", targetBufferIndex);
#endif
	useBuffer[targetBufferIndex] = YES;
	fillQueueBufferCount++;

	AudioQueueBufferRef buffer = audioBuffers[targetBufferIndex];
	buffer->mAudioDataByteSize = fillBufferSize;
	
	oStatus = AudioQueueEnqueueBuffer(audioQueue, buffer, fillPacketDescIndex, packetDescs);
	if(oStatus)
		NSLog(@"failed AudioQueueEnqueueBuffer : %d", oStatus);
	
	if(buffering && fillQueueBufferCount == bufferCount) {
		oStatus = AudioQueueStart(audioQueue, NULL);
		if(oStatus)
			NSLog(@"failed AudioQueueStart : %d", oStatus);
		buffering = NO;
		NSLog(@"AudioStreamPlayer play start.");

		if(delegate && [delegate respondsToSelector:@selector(audioStreamPlayerDidPlay:)]) {
			[delegate performSelector:@selector(audioStreamPlayerDidPlay:) 
							 onThread:[NSThread mainThread]
						   withObject:self 
						waitUntilDone:NO];
		}
	}
	
	if(++targetBufferIndex >= bufferCount)
		targetBufferIndex = 0;
	fillBufferSize = 0;
	fillPacketDescIndex = 0;
	
#ifdef DEBUG
	NSLog(@"next fill buffer : %d", targetBufferIndex);
#endif

	while(useBuffer[targetBufferIndex] && active)
		[NSThread sleepForTimeInterval:0.1];
}

- (int)findAudioQueueBuffer:(AudioQueueBufferRef)inAudioBuffer
{
	for(int i = 0; i < bufferCount; i++) {
		if(inAudioBuffer == audioBuffers[i])
			return i;
	}
	return -1;
}

- (void)_audioQueueOutputCallback:(AudioQueueRef)inAudioQueue audioQueueBuffer:(AudioQueueBufferRef)inAudioBuffer
{
	int index = [self findAudioQueueBuffer:inAudioBuffer];
#ifdef DEBUG
	NSLog(@"unUse. : %d", index);
#endif
	
	useBuffer[index] = NO;
	fillQueueBufferCount--;
#ifdef DEBUG
	NSLog(@"fillQueueBufferCount : %d", fillQueueBufferCount);
#endif
	
	if(fillQueueBufferCount < 1) {
#ifdef DEBUG
		NSLog(@"empty buffer.");
#endif
		//AudioQueuePause(audioQueue);
		//buffering = YES;

		if(delegate && [delegate respondsToSelector:@selector(audioStreamPlayerDidEmptyBuffer:)]) {
			[delegate performSelector:@selector(audioStreamPlayerDidEmptyBuffer:) 
							 onThread:[NSThread mainThread]
						   withObject:self 
						waitUntilDone:NO];
		}
	}
	
}

- (void)_openAudioFileStream
{
	AudioFileStream_PropertyListenerProc listenerProc = _property_Listener_callback;
	AudioFileStream_PacketsProc packetsProc = _packets_proc;
	OSStatus oStatus = 0;
	
	oStatus = AudioFileStreamOpen(self, listenerProc, packetsProc, kAudioFileAAC_ADTSType, &audioStreamId);
	if(oStatus)
		NSLog(@"failed AudioFileStreamOpen : %d", oStatus);
}

- (void)_interruptionListener:(UInt32)inInterruption
{
	if(inInterruption == kAudioSessionEndInterruption) {
		AudioSessionSetActive(true);
	} else if(inInterruption == kAudioSessionBeginInterruption) {
		
	}
}

- (void)_startAudioSession
{
	AudioSessionInitialize(NULL, NULL, _interruptionListener, self);
	
	UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
	AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
	AudioSessionSetActive(true);
}

- (void)_endAudioSession
{
	AudioSessionSetActive(false);
}

- (void)_closeAudioFileStream
{
	AudioFileStreamClose(audioStreamId);
}

- (void)play
{
	if(active)
		return;
	
	active = YES;
	buffering = YES;
	
	[self _openAudioFileStream];
	
	[NSThread detachNewThreadSelector:@selector(run:) toTarget:self withObject:self];	
}

- (void)stop
{
	if(!active)
		return;
	
	active = NO;	
	AudioQueueStop(audioQueue, true);
}

static void _read_stream(int fh, AudioFileStreamID audioStreamId)
{
	OSStatus oStatus;
	
	uint8_t buf[1024];
	UInt64 total = 0;
	UInt32 sz;
	
	UInt32 count = 0;
	NSAutoreleasePool *subPool = [[NSAutoreleasePool alloc] init];
	
	while((sz = read(fh, buf, 1024)) > 0) {
		
		oStatus = AudioFileStreamParseBytes(audioStreamId, sz, (const void*)buf, 0);
		if(oStatus) {
			NSLog(@"failed AudioFileStreamParseBytes : %d", oStatus);
			break;
		}
		
		total += sz;
		
		count++;
		if(count > 100) {
			[subPool release];
			subPool = [[NSAutoreleasePool alloc] init];
			count = 0;
		}
	}
	
	AudioFileStreamParseBytes(audioStreamId, 0, NULL, kAudioFileStreamParseFlag_Discontinuity);
	[subPool release];
}

- (void)run:(id)param
{
#ifdef DEBUG
	NSLog(@"AudioStreamPlayer start");
#endif
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

 	int fh = [inputHandle fileDescriptor];
	
	_read_stream(fh, audioStreamId);

#ifdef DEBUG
	NSLog(@"AudioStreamPlayer end");
#endif
	
	AudioFileStreamClose(audioStreamId);
	for(int i=0; i<bufferCount; i++)
		AudioQueueFreeBuffer(audioQueue, audioBuffers[i]);
	AudioQueueDispose(audioQueue, true);
	
	if(delegate && [delegate respondsToSelector:@selector(audioStreamPlayerDidStop:)]) {
		[delegate performSelector:@selector(audioStreamPlayerDidStop:) 
						 onThread:[NSThread mainThread]
					   withObject:self 
					waitUntilDone:NO];
	}
	
	[pool release];
	[NSThread exit];
}

@end
