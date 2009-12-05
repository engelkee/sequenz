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
@class CameraSuspendedView;

#if (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_5)
@interface SequenzAppDelegate : NSObject {
#else
@interface SequenzAppDelegate : NSObject <NSApplicationDelegate> {
#endif
	Camera *mCamera;
	FTPController *ftpController;
	PrefsController *prefController;
	NSUserDefaults *userDefaults;
	
    NSWindow *window;
	
	IBOutlet NSButton *startStopButton;
	
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
