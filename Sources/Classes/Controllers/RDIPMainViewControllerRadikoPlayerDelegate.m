//
//  RDIPMainViewControllerRadikoPlayerDelegate.m
//  radikker
//
//  Created by saiten on 10/07/15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDIPMainViewController.h"
#import "StatusBarAlert.h"
#import "RDIPStationViewController.h"

@implementation RDIPMainViewController(RadikoPlayerDelegate)

- (void)playRadikoAtSelectStation
{
	if(stations.count <= 0)
		return;
	
	RDIPStation *station = [stations objectAtIndex:selectedStationIndex];
	if(station.tuning) {
		mainView.tunerView.tunedIndex = selectedStationIndex;
		tunedStationIndex = selectedStationIndex;
	}
	
	[self playRadiko];
}

- (void)playRadiko 
{
	RDIPStation *station = [stations objectAtIndex:tunedStationIndex];
	if(station) {
		[radikoPlayer setChannel:station.stationId];
		
		if(radikoPlayer.status == RADIKOPLAYER_STATUS_PLAY || 
		   radikoPlayer.status == RADIKOPLAYER_STATUS_CONNECT) {
			[radikoPlayer stop];
			replay = YES;
		} if(radikoPlayer.status == RADIKOPLAYER_STATUS_STOP) {
			[radikoPlayer play];
		}
	}
}

- (void)stopRadiko
{
	[radikoPlayer stop];
}

- (void)radikoPlayerDidStartAuthentication:(RadikoPlayer *)radikoPlayer
{
  if(!radikoPlayer.authOnly) {
    [[StatusBarAlert sharedInstance] showStatus:@"Authenticating.." 
                                       animated:YES];  
  }
}

- (void)radikoPlayerDidFinishedAuthentication:(RadikoPlayer *)radikoPlayer
{
  if(radikoPlayer.authOnly) {
    [self loadStations];
  }
}

- (void)radikoPlayerWillPlay:(RadikoPlayer *)aRadikoPlayer
{
	[[StatusBarAlert sharedInstance] showStatus:[NSString stringWithFormat:@"Connecting.. %@", radikoPlayer.channel] 
									   animated:YES];
}

- (void)radikoPlayerDidPlay:(RadikoPlayer *)aRadikoPlayer
{
	[[StatusBarAlert sharedInstance] hideStatusAnimated:YES];
	replay = NO;
	
	if([currentViewController isKindOfClass:[RDIPStationViewController class]])
		[(RDIPStationViewController*)currentViewController nowOnAir];
  [self setToolbar:YES];
}

- (void)radikoPlayerWillStop:(RadikoPlayer *)aRadikoPlayer
{
	[[StatusBarAlert sharedInstance] showStatus:@"Disconnecting.." 
									   animated:YES];
}

- (void)radikoPlayerDidStop:(RadikoPlayer *)aRadikoPlayer
{
	if(replay)
		[radikoPlayer play];
	else
		[[StatusBarAlert sharedInstance] hideStatusAnimated:YES];
  [self setToolbar:NO];
}

- (void)radikoPlayerDidEmptyBuffer:(RadikoPlayer *)aRadikoPlayer
{
	[[StatusBarAlert sharedInstance] showStatus:[NSString stringWithFormat:@"Buffering.. %@", radikoPlayer.channel] 
									   animated:YES];
}


- (void)radikoPlayerDidConnectRTMPStream:(RadikoPlayer*)aRadikoPlayer
{
	[[StatusBarAlert sharedInstance] showStatus:[NSString stringWithFormat:@"Buffering.. %@", radikoPlayer.channel] 
									   animated:YES];
}

- (void)radikoPlayerDidDisconnectRTMPStream:(RadikoPlayer*)aRadikoPlayer
{
	[[StatusBarAlert sharedInstance] showStatus:@"Disconnected."
									   animated:YES];
}

@end
