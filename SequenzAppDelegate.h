//
//  SequenzAppDelegate.h
//  Sequenz
//
//  Created by Dominik Gwosdek on 03.11.09.
//  Copyright 2009 Dominik Gwosdek. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>
#import <QuartzCore/CoreAnimation.h>

@class Camera;
@class FTPController;
@class PrefsController;
@class SideBarPaneView;

@interface SequenzAppDelegate : NSObject <NSApplicationDelegate> {
	Camera *mCamera;
	FTPController *ftpController;
	PrefsController *prefController;
	NSUserDefaults *userDefaults;
	
    NSWindow *window;
	
	IBOutlet NSButton *startStopButton;
	
	IBOutlet QTCaptureView *mCaptureView;

	IBOutlet NSView *sideBarView;
	IBOutlet NSScrollView *sideBarScrollView;
	IBOutlet SideBarPaneView *recPane;
	IBOutlet SideBarPaneView *ftpPane;
	
	IBOutlet NSTextField *intervalTextField;
	IBOutlet NSPopUpButton *intervalUnitPopUp;
	IBOutlet NSPopUpButton *qualityPopUp;
	IBOutlet NSPopUpButton *formatPopUp;
	IBOutlet NSTextField *filenameTextField;
	
	IBOutlet NSTextField *serverTextField;
	IBOutlet NSTextField *usernameTextField;
	IBOutlet NSTextField *passwordTextField;
	IBOutlet NSTextField *pathTextField;
	
	NSTimer *sequenceTimer;
	
	BOOL isRecording;
	
	float topMargin;
}

@property (assign) IBOutlet NSWindow *window;
@property BOOL isRecording;

- (void)startRecording;
- (void)stopRecording;

- (IBAction)toggleRecording:(id)sender;
- (IBAction)showPrefsWindow:(id)sender;
- (IBAction)setServerAdress:(id)sender;
- (IBAction)setInterval:(id)sender;
- (IBAction)setIntervalUnit:(id)sender;



@end
