//
//  SequenzAppDelegate.h
//  Sequenz
//
//  Created by Dominik Gwosdek on 03.11.09.
//  Copyright 2009 Dominik Gwosdek. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MainWindowController;
@class PrefsController;

@interface SequenzAppDelegate : NSObject {
	MainWindowController *mMainWindowController;
	PrefsController *mPrefsController;
	IBOutlet NSMenu *cameraMenu;
}

- (IBAction)showPrefsWindow:(id)sender;
- (IBAction)openWebsite:(id)sender;
- (IBAction)openDonate:(id)sender;

@end
