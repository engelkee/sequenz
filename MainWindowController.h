//
//  MainWindowController.h
//  Sequenz
//
//  Created by Dominik Gwosdek on 15.12.09.
//  Copyright 2009 Dominik Gwosdek. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>
#import <QuartzCore/CoreAnimation.h>

@class FTPController;
@class PrefsController;
@class SideBarPaneView;
@class CameraController;


@interface MainWindowController : NSWindowController {

	CameraController *camController;
	FTPController *ftpController;
	PrefsController *prefController;
	NSUserDefaults *userDefaults;
	NSViewController *mCurrentViewController;
	
	IBOutlet NSButton *startStopButton;
	IBOutlet NSView *qtSwapView;
	IBOutlet NSView *sideBarView;
	IBOutlet SideBarPaneView *recPane;
	IBOutlet SideBarPaneView *ftpPane;
	
	IBOutlet NSTextField *intervalTextField;
	IBOutlet NSPopUpButton *intervalUnitPopUp;
	IBOutlet NSTextField *filenameTextField;
	IBOutlet NSTextField *serverTextField;
	IBOutlet NSTextField *usernameTextField;
	IBOutlet NSTextField *passwordTextField;
	IBOutlet NSTextField *pathTextField;
	
	NSTimer *sequenceTimer;
	
	BOOL isRecording;
	BOOL isCameraOn;
	BOOL recEnabled;
	
	int filenameCounter;
	
	float topMargin;
}

@property (nonatomic, assign, readonly) BOOL recEnabled;
@property (nonatomic, assign) int filenameCounter;
@property (retain, readonly) CameraController *camController;
@property (retain) NSViewController *currentViewController;
@property BOOL isRecording;
@property BOOL isCameraOn;

- (IBAction)setInterval:(id)sender;
- (IBAction)setIntervalUnit:(id)sender;
- (IBAction)toggleRecording:(id)sender;

@end
