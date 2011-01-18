/*
 * PhoneGap is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 * 
 * Copyright (c) 2005-2010, Nitobi Software Inc.
 */


#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVFoundation.h>

#import "AudioFile.h"
#import "PhoneGapCommand.h"

@class AudioFile;

@interface Sound : PhoneGapCommand 
{
	NSMutableDictionary* soundCache;
}

- (void) play:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) pause:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) stop:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) playAndFadeIn:(NSMutableArray*)arguments withDict:(NSMutableArray*)options;
- (void) fadeOutAndStop:(NSMutableArray*)arguments withDict:(NSMutableArray*)options;
- (NSURL*) urlForResource:(NSString*)resourcePath;
- (AudioFile*) audioFileForResource:(NSString*) resourcePath;

- (void) addToSoundCache:(AudioFile*)audioFile;
- (AudioFile*) getFromSoundCache:(NSString*)resourcePath;
- (void) removeFromSoundCache:(AudioFile*)audioFile;
- (void) createSoundCache;

- (AudioFile*) audioFileFor:(NSMutableArray*)arguments;
- (AudioFile*) audioFileForResource:(NSString*)resourcePath;
- (NSString*) resourceForUrl:(NSURL*)url;
- (AudioFile*) setCallbacksFor:(AudioFile*)audioFile from:(NSMutableArray*)arguments;

@end

