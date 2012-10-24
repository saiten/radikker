//
//  NetworkInformation.m
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

#import "NetworkInformation.h"
#import <sys/ioctl.h>
#import <sys/types.h>
#import <sys/socket.h>
#import <sys/sockio.h>
#import <unistd.h>		// for close(), etc etc... perhaps ioctl() is included in this header
#import <net/if.h>		// for struct ifconf, struct ifreq
#import <net/if_dl.h>	// for struct sockaddr_dl, LLADDR
#import <netinet/in.h>	// for some reason... I have no idea. Without this inet_ntoa call causes compile error
#import <net/ethernet.h>// for either_ntoa()
#import <arpa/inet.h>	// for inet_ntoa()


#define NetworkInformation_IFCONF_BUFFER_LENGTH	4000
const int NetworkInformationInterfaceTypeIPv4 = AF_INET;
const int NetworkInformationInterfaceTypeMAC = AF_LINK;
const NSString *NetworkInformationInterfaceAddressKey = @"address";


static NetworkInformation *__sharedNetworkInformationInstance;
@implementation NetworkInformation


#pragma mark Properties


- (NSArray *)allInterfaceNames {
	if (!allInterfaces) {
		[self refresh];
	}
	
	return [allInterfaces allKeys];
}

- (NSString *)primaryIPv4Address {
	if (!allInterfaces) {
		[self refresh];
	}
	
	// Select primary IPv4 Address by following formula:
	// - Consider "en0" as primary Ethernet and "en1"/"en2" as secondary Ethernet
	// - In iPhone, "pdp_ip0" ~ "pdp_ip3" are Cellphone network IP thus we should take them into account
	// - If primary Ethernet has IPv4 address, return it
	//   Else, return secondary Ethernet IPv4 address
	// - Return nil if no Ethernet/Cellphone network have address
	if ([self IPv4AddressForInterfaceName:@"en0"]) {
		return [self IPv4AddressForInterfaceName:@"en0"];
	} else if ([self IPv4AddressForInterfaceName:@"en1"]) {
		return [self IPv4AddressForInterfaceName:@"en1"];
	} else if ([self IPv4AddressForInterfaceName:@"en2"]) {
		return [self IPv4AddressForInterfaceName:@"en2"];
	} else if ([self IPv4AddressForInterfaceName:@"pdp_ip0"]) {
		return [self IPv4AddressForInterfaceName:@"pdp_ip0"];
	} else if ([self IPv4AddressForInterfaceName:@"pdp_ip1"]) {
		return [self IPv4AddressForInterfaceName:@"pdp_ip1"];
	} else if ([self IPv4AddressForInterfaceName:@"pdp_ip2"]) {
		return [self IPv4AddressForInterfaceName:@"pdp_ip2"];
	} else if ([self IPv4AddressForInterfaceName:@"pdp_ip3"]) {
		return [self IPv4AddressForInterfaceName:@"pdp_ip3"];
	} else {
		return nil;
	}
}

- (NSString *)primaryMACAddress {
	if (!allInterfaces) {
		[self refresh];
	}
	
	// Select primary MAC Address by following formula:
	// - Consider "en0" as primary Ethernet and "en1"/"en2" as secondary Ethernet
	// - Always return the address of "en0" Ethernet because:
	//   * en0 should always have MAC address
	//   * en0 should always be on any device
	//   * en0 should be used when Wi-Fi is available
	//   * pdp_ip0, which is used as Cellphone network, doesn't have a valid MAC address to use so we have to use en0 even if Wi-Fi is not active
	return [self MACAddressForInterfaceName:@"en0"];
}


#pragma mark Init/dealloc


- (id)init {
	if (self = [super init]) {
		allInterfaces = nil;
	}
	return self;
}

- (void) dealloc {
	[allInterfaces release];
	[super dealloc];
}

+ (NetworkInformation *)sharedInformation {
	if (!__sharedNetworkInformationInstance) {
		__sharedNetworkInformationInstance = [[NetworkInformation alloc] init];
	}
	return __sharedNetworkInformationInstance;
}


#pragma mark Other methods


- (void)refresh {
	
	// Release Obj-C ivar data first
	if (allInterfaces) {
		[allInterfaces release];
		allInterfaces = nil;
	}
	
	// Open socket
	int sockfd = socket(AF_INET, SOCK_DGRAM, 0);
	if (sockfd < 0) {
		NSLog(@"NetworkInformation refresh failed: socket could not be opened");
		return;
	}
	
	// Use ioctl to gain information about the socket
	// - Set ifconf buffer before executing ioctl
	// - SIOCGIFCONF command retrieves ifnet list and put it into struct ifconf
	char buffer[NetworkInformation_IFCONF_BUFFER_LENGTH];
	struct ifconf ifc;
	ifc.ifc_len = NetworkInformation_IFCONF_BUFFER_LENGTH;
	ifc.ifc_buf = buffer;
	if (ioctl(sockfd, SIOCGIFCONF, &ifc) < 0) {
		NSLog(@"NetworkInformation refresh failed: ioctl execution failed");
		close(sockfd);
		return;
	}
	
	// Prepare Obj-C ivar here
	// - Should do this after all error check has been finished to prevent immature setup
	allInterfaces = [[NSMutableDictionary alloc] init];
	
	// Loop through ifc to access struct ifreq
	// - ifc.ifc_buf now contains multiple struct ifreq, but we don't have any clue of where are those pointers are
	// - We have to calculate the next pointer location in order to loop...
	struct ifreq *p_ifr;
	for (char *p_index=ifc.ifc_buf; p_index < ifc.ifc_buf+ifc.ifc_len; ) {
		p_ifr = (struct ifreq *)p_index;
		
		NSString *interfaceName = [NSString stringWithCString:p_ifr->ifr_name encoding:NSASCIIStringEncoding];
		NSNumber *family = [NSNumber numberWithInt:p_ifr->ifr_addr.sa_family];
		NSString *address = nil;
		NSMutableDictionary *interfaceDict = nil;
		NSMutableDictionary *interfaceTypeDetailDict = nil;
		char temp[80];
		
		// Switch by sa_family
		// - Do nothing if sa_family is not one of supported types (like MAC or IPv4)
		switch (p_ifr->ifr_addr.sa_family) {
			case AF_LINK:
				// MAC address
				
				interfaceDict = [allInterfaces objectForKey:interfaceName];
				if (!interfaceDict) {
					interfaceDict = [NSMutableDictionary dictionary];
					[allInterfaces setObject:interfaceDict forKey:interfaceName];
				}
				
				interfaceTypeDetailDict = [interfaceDict objectForKey:family];
				if (!interfaceTypeDetailDict) {
					interfaceTypeDetailDict = [NSMutableDictionary dictionary];
					[interfaceDict setObject:interfaceTypeDetailDict forKey:family];
				}
				
				struct sockaddr_dl *sdl = (struct sockaddr_dl *) &(p_ifr->ifr_addr);
				int a,b,c,d,e,f;
				
				strcpy(temp, ether_ntoa((const struct ether_addr *)LLADDR(sdl)));
				sscanf(temp, "%x:%x:%x:%x:%x:%x", &a, &b, &c, &d, &e, &f);
				sprintf(temp, "%02X:%02X:%02X:%02X:%02X:%02X",a,b,c,d,e,f);
				
				address = [NSString stringWithCString:temp encoding:NSASCIIStringEncoding];
				[interfaceTypeDetailDict setObject:address forKey:NetworkInformationInterfaceAddressKey];
				
				break;
				
			case AF_INET:
				// IPv4 address
				
				interfaceDict = [allInterfaces objectForKey:interfaceName];
				if (!interfaceDict) {
					interfaceDict = [NSMutableDictionary dictionary];
					[allInterfaces setObject:interfaceDict forKey:interfaceName];
				}
				
				interfaceTypeDetailDict = [interfaceDict objectForKey:family];
				if (!interfaceTypeDetailDict) {
					interfaceTypeDetailDict = [NSMutableDictionary dictionary];
					[interfaceDict setObject:interfaceTypeDetailDict forKey:family];
				}
				
				struct sockaddr_in *sin = (struct sockaddr_in *) &p_ifr->ifr_addr;
				
				strcpy(temp, inet_ntoa(sin->sin_addr));
				
				address = [NSString stringWithCString:temp encoding:NSASCIIStringEncoding];
				[interfaceTypeDetailDict setObject:address forKey:NetworkInformationInterfaceAddressKey];
				
				break;
				
			default:
				// Anything else
				break;
				
		}
		
		// Don't forget to calculate loop pointer!
		p_index += sizeof(p_ifr->ifr_name) + MAX(sizeof(p_ifr->ifr_addr), p_ifr->ifr_addr.sa_len);
	}
	
	NSLog(@"allInterfaces = %@", allInterfaces);
	
	// Don't forget to close socket!
	close(sockfd);
}

- (NSString *)IPv4AddressForInterfaceName:(NSString *)interfaceName {
	NSNumber *interfaceType = [NSNumber numberWithInt:NetworkInformationInterfaceTypeIPv4];
	return [[[allInterfaces objectForKey:interfaceName] objectForKey:interfaceType] objectForKey:NetworkInformationInterfaceAddressKey];
}

- (NSString *)MACAddressForInterfaceName:(NSString *)interfaceName {
	NSNumber *interfaceType = [NSNumber numberWithInt:NetworkInformationInterfaceTypeMAC];
	return [[[allInterfaces objectForKey:interfaceName] objectForKey:interfaceType] objectForKey:NetworkInformationInterfaceAddressKey];
}

@end
