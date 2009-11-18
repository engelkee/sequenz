//
//  PrefsController.h
//  Sequenz
//
//  Created by Dominik Gwosdek on 05.11.09.
//  Copyright 2009 Dominik Gwosdek. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *SQInsertTimestampFlag;
extern NSString *SQTimestampColor;
extern NSString *SQTimestampFont;
extern NSString *SQRecordingInterval;
extern NSString *SQIntervalUnit;
extern NSString *SQImageQuality;
extern NSString *SQImageFormat;
extern NSString *SQImageFilename;
extern NSString *SQFTPServerAddress;
extern NSString *SQFTPUsername;
extern NSString *SQFTPPath;

@interface PrefsController : NSWindowController {

	IBOutlet NSButton *captureWithTimestamp;
	IBOutlet NSTextField *fontExample;
	
	NSUserDefaults *userDefaults;
	
	//IBOutlet NSView *imagePrefView;
	//IBOutlet NSView *uploadPrefView;
}

//- (IBAction)setPrefsView:(id)sender;

@end
