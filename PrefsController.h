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

@interface PrefsController : NSWindowController {

	IBOutlet NSButton *captureWithTimestamp;
	IBOutlet NSTextField *fontExample;
	
	NSUserDefaults *userDefaults;
	
	//IBOutlet NSView *imagePrefView;
	//IBOutlet NSView *uploadPrefView;
}

//- (IBAction)setPrefsView:(id)sender;

@end
