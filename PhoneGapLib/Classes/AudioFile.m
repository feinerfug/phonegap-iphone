//
//  AudioFile.m
//  PhoneGapLib
//
//  Created by normal on 18.01.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AudioFile.h"

@implementation AudioFile

@synthesize resourcePath;
@synthesize resourceURL;
@synthesize successCallback;
@synthesize errorCallback;
@synthesize downloadCompleteCallback;
@synthesize player;
@synthesize sound;

- (id) initWithSound:(Sound*)theSound {
	[super init];
	self.sound = theSound;
	return self;
}

- (void) play {
	// If audio player is already playing reset it!
	if(self.player.isPlaying){
		[self.player stop];
		self.player.currentTime = 0;
	}
	
	[self.player play];
	
	NSLog(@"Playing audio sample '%@'", self.resourcePath);
}

- (void) stop {
	[self.player stop];
	self.player.currentTime = 0;
	NSLog(@"Stopped playing audio sample '%@'", self.resourcePath);
}

- (void) pause { 
	[self.player pause];
	NSLog(@"Paused playing audio sample '%@'", self.resourcePath);
}

- (void)performFadeOut {
	if (numberOfSteps > 0) { 
		self.player.volume -= step; 
		numberOfSteps -= 1;
		[self performSelector:@selector(performFadeOut) withObject:nil afterDelay:0.1];	
	} else {
		[self stop];
		[sound writeJavascript:[NSString stringWithFormat:@"Media.fadeOutCallbacks['%@']();", self.resourcePath]];
	}		
}

- (void)fadeOutAndStopAfter:(float)duration {
	if (self.player.volume == 0 || duration == 0) {
		[self stop];
	}
	
	numberOfSteps = duration * 10.0;
	step = self.player.volume / numberOfSteps;
	[self performSelector:@selector(performFadeOut) withObject:nil afterDelay:0.1];	
}

- (void)performFadeIn {
	if (numberOfSteps > 0) {
		self.player.volume += step; 
		numberOfSteps -= 1; 
		[self performSelector:@selector(performFadeIn) withObject:nil afterDelay:0.1];
	} else {
		self.player.volume = 1.0;
		[sound writeJavascript:[NSString stringWithFormat:@"Media.fadeInCallbacks['%@']();", self.resourcePath]];
	}

}

- (void)playAndFadeInAfter:(float)duration {
	[self play];
	
	self.player.volume = 0;
	
	numberOfSteps = duration * 10; 
	step = 1.0 / numberOfSteps;
	[self performSelector:@selector(performFadeIn) withObject:nil afterDelay: 0.1];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer*)player successfully:(BOOL)flag 
{
	NSLog(@"Finished playing audio sample '%@'", resourcePath);
	
	if (flag){
		if (self.successCallback) {
			NSString* jsString = [NSString stringWithFormat:@"(%@)(\"%@\");", self.successCallback, resourcePath];
			[sound writeJavascript:jsString];
		}
	} else {
		if (self.errorCallback) {
			NSString* jsString = [NSString stringWithFormat:@"(%@)(\"%@\");", self.errorCallback, resourcePath];
			[sound writeJavascript:jsString];
		}		
	}
}

- (void) dealloc
{
	self.player = nil;
	self.successCallback = nil;
	self.errorCallback = nil;
	self.downloadCompleteCallback = nil;
	self.sound = nil;
	
	[super dealloc];
}

@end
