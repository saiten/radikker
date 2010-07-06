//
//  FLVConverter.h
//  radikker
//
//  Created by saiten on 10/03/27.
//

#import <Foundation/Foundation.h>

@interface FLVConverter : NSObject {
	id delegate;
	
	NSFileHandle *inputHandle;
	NSFileHandle *outputHandle;
}

@property (nonatomic, assign) id delegate;

- (id)initWithFileAtPath:(NSString*)path;
- (id)initWithFileHandle:(NSFileHandle*)handle;

- (void)convertToFileAtPath:(NSString*)path;
- (void)convertToFileHandle:(NSFileHandle*)handle;

- (void)stopConvert;

@end

@interface NSObject(FLVConverterDelegate)
- (void)flvConverterDidStartConvert:(FLVConverter *)converter;
- (void)flvConverterDidFinishConvert:(FLVConverter*)converter;
- (void)flvConverterDidFailed:(FLVConverter *)converter;
@end