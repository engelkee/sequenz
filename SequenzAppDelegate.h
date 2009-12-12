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

@class FTPController;
@class PrefsController;
@class SideBarPaneView;
@class CameraSuspendedView;
@class CameraController;

@interface SequenzAppDelegate : NSObject <NSApplicationDelegate> {

	FTPController *ftpController;
	PrefsController *prefController;
	NSUserDefaults *userDefaults;
	CameraController *camController;
	
    NSWindow *window;
	
	IBOutlet NSButton *startStopButton;
	IBOutlet NSMenu *camMenu;
	
	IBOutlet QTCaptureView *mCaptureView;
	IBOutlet NSView *qtSwapView;
	IBOutlet NSView *sideBarView;
	IBOutlet CameraSuspendedView *suspendedView;
	IBOutlet SideBarPaneView *recPane;
	IBOutlet SideBarPaneView *ftpPane;
	
	IBOutlet NSTextField *intervalTextField;
	IBOutlet NSPopUpButton *intervalUnitPopUp;
	IBOutlet NSSlider *qualityPopUp;
	IBOutlet NSTextField *filenameTextField;
	
	IBOutlet NSTextField *serverTextField;
	IBOutlet NSTextField *usernameTextField;
	IBOutlet NSTextField *passwordTextField;
	IBOutlet NSTextField *pathTextField;
	
	NSTimer *sequenceTimer;
	
	BOOL isRecording;
	BOOL isCameraOn;
	
	float topMargin;
}

@property (assign) IBOutlet NSWindow *window;
@property BOOL isRecording;
@property BOOL isCameraOn;
@property (readonly) CameraController *camController;

- (void)startRecording;
- (void)stopRecording;

- (IBAction)toggleRecording:(id)sender;
- (IBAction)showPrefsWindow:(id)sender;
- (IBAction)setServerAdress:(id)sender;
- (IBAction)setInterval:(id)sender;
- (IBAction)setIntervalUnit:(id)sender;
- (IBAction)openWebsite:(id)sender;
- (IBAction)openDonate:(id)sender;



@end
