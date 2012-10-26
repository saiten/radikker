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
#import <MediaPlayer/MediaPlayer.h>

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
        if([station isKindOfClass:[RDIPRadiruStation class]]) {
            [radikoPlayer setService:RADIKOPLAYER_SERVICE_RADIRU];
        } else {
            [radikoPlayer setService:RADIKOPLAYER_SERVICE_RADIKO];
        }
        
        [radikoPlayer setChannel:station.stationId];
        
        if(radikoPlayer.status == RADIKOPLAYER_STATUS_STOP) {
            [radikoPlayer play];
        } else {
            [radikoPlayer stop];
            replay = YES;
        }
	}
}

- (void)stopRadiko
{
	[radikoPlayer stop];
}

- (void)radikoPlayerDidStartAuthentication:(RadikoPlayer *)aRadikoPlayer
{
  if(!radikoPlayer.authOnly) {
    [[StatusBarAlert sharedInstance] showStatus:@"Authenticating.." 
                                       animated:YES];  
    [self setToolbarPlaying:YES];    
  }
}

- (void)radikoPlayerDidFinishedAuthentication:(RadikoPlayer *)aRadikoPlayer
{
  if(radikoPlayer.authOnly) {
    [self loadStations:NO];
  }
}

- (void)radikoPlayerWillPlay:(RadikoPlayer *)aRadikoPlayer
{
	[[StatusBarAlert sharedInstance] showStatus:[NSString stringWithFormat:@"Connecting.. %@", radikoPlayer.channel] 
									   animated:YES];
  [self setToolbarPlaying:YES];
}

- (void)radikoPlayerDidPlay:(RadikoPlayer *)aRadikoPlayer
{
	[[StatusBarAlert sharedInstance] hideStatusAnimated:YES];
	replay = NO;

	[updateTimer invalidate];
	updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                   target:self
                                                 selector:@selector(checkNowOnAir)
                                                 userInfo:nil
                                                  repeats:YES];
    
	if([currentViewController isKindOfClass:[RDIPStationViewController class]])
		[(RDIPStationViewController*)currentViewController nowOnAir];
}

- (void)radikoPlayerWillStop:(RadikoPlayer *)aRadikoPlayer
{
	[[StatusBarAlert sharedInstance] showStatus:@"Disconnecting.." 
									   animated:YES];
}

- (void)radikoPlayerDidStop:(RadikoPlayer *)aRadikoPlayer
{
	[updateTimer invalidate];
	updateTimer = nil;
    
	[self setToolbarPlaying:NO];
    
	if(replay) {
		[radikoPlayer play];
	} else {
		[[StatusBarAlert sharedInstance] hideStatusAnimated:YES];
    }
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

- (void)radikoPlayerDidFailed:(RadikoPlayer *)aRadikoPlayer withError:(NSError *)error
{
  [[StatusBarAlert sharedInstance] hideStatusAnimated:YES];
  [self setToolbarPlaying:NO];
  UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Error"
                                                       message:[error localizedDescription]
                                                      delegate:nil
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil] autorelease];
  [alertView show];
    
  if(radikoPlayer.authOnly) {
      [self unavailableTuner];
  }
}

- (void)checkNowOnAir
{
  RDIPProgram *program = [[RDIPEPG sharedInstance] programForStationAtNow:radikoPlayer.channel];
  if(nowOnAir != program) {
    [nowOnAir release];
    nowOnAir = [program retain];
      
    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
    if(playingInfoCenter) {
      MPNowPlayingInfoCenter *center = [MPNowPlayingInfoCenter defaultCenter];
      NSDictionary *playingInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   radikoPlayer.channel, MPMediaItemPropertyAlbumTitle,
                                   program.title, MPMediaItemPropertyTitle,
                                   program.performer, MPMediaItemPropertyArtist, nil];
      center.nowPlayingInfo = playingInfo;
    }
  }
}

@end
