//
//  PrefsController.h
//  Sequenz
//
//  Created by Dominik Gwosdek on 05.11.09.
//  Copyright 2009 Dominik Gwosdek. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define IMG_QUAL_LOW 0.5
#define IMG_QUAL_MID 0.75
#define IMG_QUAL_HIGH 1.0
#define INTERVALL_UNIT_SEC 0
#define INTERVALL_UNIT_MIN 1


@interface PrefsController : NSWindowController {

	IBOutlet NSTextField *ftpServerName;
	IBOutlet NSTextField *ftpUserName;
	IBOutlet NSTextField *ftpPassword;
	IBOutlet NSTextField *ftpPath;
	IBOutlet NSTextField *ftpPort;
	
	IBOutlet NSTextField *captureIntervallValue;
	IBOutlet NSPopUpButton *captureIntervallUnit;
	IBOutlet NSPopUpButton *imageQuality;
	
	IBOutlet NSView *imagePrefView;
	IBOutlet NSView *uploadPrefView;
}

- (IBAction)setPrefsView:(id)sender;
- (IBAction)setCaptureIntervallValue:(id)sender;
- (IBAction)setCaptureIntervallUnit:(id)sender;
- (IBAction)setImageQuality:(id)sender; 

@end
