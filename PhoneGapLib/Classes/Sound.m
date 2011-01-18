/*
 * PhoneGap is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 * 
 * Copyright (c) 2005-2010, Nitobi Software Inc.
 */

#import "Sound.h"
#import "PhonegapDelegate.h"

#define DOCUMENTS_SCHEME_PREFIX @"documents://"
#define HTTP_SCHEME_PREFIX @"http://"

@implementation Sound

- (void) prepare:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
  AudioFile* audioFile = [self audioFileFor:arguments];

  if (audioFile == nil) {
    return; // TODO this should call error callback!
  }
  
  [self addToSoundCache: audioFile];
  
  NSLog(@"Prepared audio sample '%@' for playback.", audioFile.resourcePath);
  if (audioFile.downloadCompleteCallback) {
    NSString* jsString = [NSString stringWithFormat:@"(%@)();", audioFile.downloadCompleteCallback];
    [super writeJavascript:jsString];
  }
  
  audioFile.player.delegate = audioFile;
  [audioFile.player prepareToPlay];
}

- (void) play:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
  AudioFile* audioFile = [self getFromSoundCache:[arguments objectAtIndex:0]];

  if (audioFile == nil) {
    return;
  }

  NSNumber* loopOption = [options objectForKey:@"numberOfLoops"];
  NSInteger numberOfLoops = 0;
  if (loopOption != nil) {
    numberOfLoops = [loopOption intValue] - 1;
  }
        
  audioFile.player.numberOfLoops = numberOfLoops;
  
  [audioFile play];
}

- (void) pause:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
  AudioFile* audioFile = [self getFromSoundCache:[arguments objectAtIndex:0]];
	
  if (audioFile == nil) {
    return;
  }

  [audioFile pause];
}

- (void) stop:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
  AudioFile* audioFile = [self getFromSoundCache:[arguments objectAtIndex:0]];
	
	if (audioFile == nil)
		return;
	
  [audioFile stop];
}

- (void) playAndFadeIn:(NSMutableArray*)arguments withDict:(NSMutableArray*)options {
	AudioFile* audioFile = [self getFromSoundCache:[arguments objectAtIndex:0]];
	float duration = [[arguments objectAtIndex:1] floatValue];

	if (audioFile == nil)
		return;
	
	[audioFile playAndFadeInAfter:duration];
}

- (void) fadeOutAndStop:(NSMutableArray*)arguments withDict:(NSMutableArray*)options {
	AudioFile* audioFile = [self getFromSoundCache:[arguments objectAtIndex:0]];
	float duration = [[arguments objectAtIndex:1] floatValue];

	if (audioFile == nil) 
		return; 
	
	[audioFile fadeOutAndStopAfter:duration]; 
}

- (AudioFile*) audioFileFor:(NSMutableArray*)arguments {
  AudioFile* audioFile = [self audioFileForResource:[arguments objectAtIndex:0]];
  
  if (audioFile == nil) {
    return nil;
  }

	return [self setCallbacksFor: audioFile from:arguments];
}

// Creates audio file resource object
- (AudioFile*) audioFileForResource:(NSString*)resourcePath {
  NSURL* resourceURL = [self urlForResource:resourcePath];
  if([resourcePath isEqualToString:@""]){
    NSLog(@"Cannot play empty URI");
    return nil;
  }
	
  if (resourceURL == nil) {
    NSLog(@"Cannot use audio file from resource '%@'", resourcePath);
    return nil;
  }
	
  NSError *error;
  AudioFile* audioFile = [[[AudioFile alloc] init] autorelease];;
  audioFile.resourcePath = resourcePath;
  audioFile.resourceURL = resourceURL;
		
  if ([resourceURL isFileURL]) {
    audioFile.player = [[ AVAudioPlayer alloc ] initWithContentsOfURL:resourceURL error:&error];
  } else {
    NSData* data = [NSData dataWithContentsOfURL:resourceURL];
    audioFile.player = [[ AVAudioPlayer alloc ] initWithData:data error:&error];
  }
	
  if (error != nil) {
    NSLog(@"Failed to initialize AVAudioPlayer: %@\n", error);
    audioFile.player = nil;
  }
		
  return audioFile;
}

// Maps a url to the original resource path
- (NSString*) resourceForUrl:(NSURL*)url {
    NSBundle* mainBundle = [NSBundle mainBundle];
	NSString* urlString = [url description];
	NSString* retVal = @"";
	
	NSString* wwwPath = [mainBundle pathForResource:[PhoneGapDelegate wwwFolderName] ofType:@"" inDirectory:@""];
	NSString* wwwUrl = [[NSURL fileURLWithPath:wwwPath] description];
	NSString* documentsUrl = [[NSURL fileURLWithPath:[PhoneGapDelegate applicationDocumentsDirectory]] description];
	
	if ([urlString hasPrefix:wwwUrl]) {
		retVal = [urlString substringFromIndex:[wwwUrl length]];
	} else if ([urlString hasPrefix:HTTP_SCHEME_PREFIX]) {
		retVal = urlString;
	} else if ([urlString hasPrefix:documentsUrl]) {
		retVal = [NSString stringWithFormat:@"%@%@", DOCUMENTS_SCHEME_PREFIX, [urlString substringFromIndex:[documentsUrl length]]];
	} else {
		NSLog(@"Cannot map url '%@' to a resource path.", urlString);
	}

	return retVal;
}

// Maps a url for a resource path
// "Naked" resource paths are assumed to be from the www folder as its base
- (AudioFile*) setCallbacksFor:(AudioFile*)audioFile from:(NSMutableArray*)arguments { 
  NSUInteger argc = [arguments count];
  if (argc > 1) {
    audioFile.successCallback = [arguments objectAtIndex:1];
  }
  if (argc > 2) {
    audioFile.errorCallback = [arguments objectAtIndex:2];
  }
  if (argc > 3) {
    audioFile.downloadCompleteCallback = [arguments objectAtIndex:3];
  }
	return audioFile;
}


// Maps a url for a resource path
// "Naked" resource paths are assumed to be from the www folder as its base
- (NSURL*) urlForResource:(NSString*)resourcePath {
  NSURL* resourceURL = nil;
	
  // attempt to find file path
  NSString* filePath = [PhoneGapDelegate pathForResource:resourcePath];
	
  if (filePath == nil) {
    // if it is a http url, use it
    if ([resourcePath hasPrefix:HTTP_SCHEME_PREFIX]){
      NSLog(@"Will use resource '%@' from the Internet.", resourcePath);
      resourceURL = [NSURL URLWithString:resourcePath];
    } else if ([resourcePath hasPrefix:DOCUMENTS_SCHEME_PREFIX]) {
      NSLog(@"Will use resource '%@' from the documents folder.", resourcePath);
      resourceURL = [NSURL URLWithString:resourcePath];
			
      NSString* recordingPath = [NSString stringWithFormat:@"%@/%@", [PhoneGapDelegate applicationDocumentsDirectory], [resourceURL host]];
      resourceURL = [NSURL fileURLWithPath:recordingPath];
    } else {
      NSLog(@"Unknown resource '%@'", resourcePath);
    }
  }
  else {
    NSLog(@"Found resource '%@' in the web folder.", resourcePath);
    // it's a file url, use it
    resourceURL = [NSURL fileURLWithPath:filePath];
  }
	
  return resourceURL;
}

- (void) addToSoundCache:(AudioFile*)audioFile {
  [self createSoundCache];
  [soundCache setObject:audioFile forKey:audioFile.resourcePath];
}

- (AudioFile*) getFromSoundCache:(NSString*)resourcePath {
  if (soundCache == nil) {
    return nil;
  }
  return [soundCache objectForKey: resourcePath];
}

- (void) removeFromSoundCache:(AudioFile*)audioFile {
  [soundCache removeObjectForKey:audioFile.resourcePath];
}

- (void) createSoundCache {
  if (soundCache == nil) {
    soundCache = [[NSMutableDictionary alloc] initWithCapacity:4];
  }
}

- (void) clearCaches {
  [super clearCaches];
}

@end
