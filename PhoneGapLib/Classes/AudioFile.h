//
//  AudioFile.h
//  PhoneGapLib
//
//  Created by normal on 18.01.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Sound.h"

@class Sound;

@interface AudioFile : NSObject
<AVAudioPlayerDelegate>
{
	NSString* resourcePath;
	NSURL* resourceURL;
	AVAudioPlayer* player;
	float numberOfSteps; 
	float step; 
	Sound* sound;
}

@property (nonatomic, copy) NSString* resourcePath;
@property (nonatomic, copy) NSURL* resourceURL;
@property (nonatomic, retain) AVAudioPlayer* player;
@property (nonatomic, assign) Sound* sound;

- (id)initWithSound:(Sound*)theSound;
- (void)play;
- (void)stop;
- (void)pause;
- (void)fadeOutAndStopAfter:(float)duration;
- (void)playAndFadeInAfter:(float)duration;
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer*)player successfully:(BOOL)flag;

@end