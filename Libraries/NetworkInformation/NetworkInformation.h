//
//  NetworkInformation.h
//
//  Created by akisute on 10/10/07.
//  Copyright 2010 株式会社ビープラウド.
/*
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

#import <Foundation/Foundation.h>


UIKIT_EXTERN const int NetworkInformationInterfaceTypeIPv4;
UIKIT_EXTERN const int NetworkInformationInterfaceTypeMAC;
UIKIT_EXTERN const NSString *NetworkInformationInterfaceAddressKey;


/*!
 @class			NetworkInformation
 @abstract		A singleton class to retrieve network (especially Ethernet) information such as IP address or MAC address.
 @discussion	This class internally uses <sys/ioctl.h> to retrieve network information.
 */
@interface NetworkInformation : NSObject {
	/*
	 This dictionary should be like this:
	 
	 allInterfaces = {
	 en0 =     {
	 18 =         {
	 address = "AA:AA:AA:AA:AA:AA";
	 };
	 };
	 en1 =     {
	 18 =         {
	 address = "BB:BB:BB:BB:BB:BB";
	 };
	 2 =         {
	 address = "192.168.100.20";
	 };
	 };
	 fw0 =     {
	 18 =         {
	 address = "CC:CC:CC:CC:CC:CC";
	 };
	 };
	 gif0 =     {
	 18 =         {
	 address = "00:00:00:00:00:00";
	 };
	 };
	 lo0 =     {
	 18 =         {
	 address = "00:00:00:00:00:00";
	 };
	 2 =         {
	 address = "127.0.0.1";
	 };
	 };
	 stf0 =     {
	 18 =         {
	 address = "00:00:00:00:00:00";
	 };
	 };
	 vboxnet0 =     {
	 18 =         {
	 address = "DD:DD:DD:DD:DD:DD";
	 };
	 };
	 }
	 
	 */
	NSMutableDictionary *allInterfaces;
}

/*!
 @property		allInterfaceNames
 @abstract		All existing network interface names.
 @discussion	Returns NSArray instance which contains NSString objects that represents all exsiting network interface names.
 refresh is called if the shared instance have not retrieved network information yet.
 */
@property (nonatomic, readonly) NSArray *allInterfaceNames;

/*!
 @property		primaryIPv4Address
 @abstract		IPv4 address of the primary network interface.
 @discussion	This property automatically determines which interface is the primary interface and returns its IPv4 address.
 refresh is called if the shared instance have not retrieved network information yet.
 */
@property (nonatomic, readonly) NSString *primaryIPv4Address;

/*!
 @property		primaryMACAddress
 @abstract		MAC address of the primary network interface.
 @discussion	This property automatically determines which interface is the primary interface and returns its MAC address.
 refresh is called if the shared instance have not retrieved network information yet.
 */
@property (nonatomic, readonly) NSString *primaryMACAddress;


+ (NetworkInformation *)sharedInformation;


- (void)refresh;
- (NSString *)IPv4AddressForInterfaceName:(NSString *)interfaceName;
- (NSString *)MACAddressForInterfaceName:(NSString *)interfaceName;

@end