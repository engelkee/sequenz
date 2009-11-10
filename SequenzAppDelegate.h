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

@class PrefsController;
@class FTPController;

@interface SequenzAppDelegate : NSObject <NSApplicationDelegate> {
	PrefsController *prefController;
	FTPController *ftpController;
	NSUserDefaults *userDefaults;
	
    NSWindow *window;
	
	IBOutlet QTCaptureView *mCaptureView;
	IBOutlet NSView *settingsView;
	IBOutlet NSView *recordingView;
	IBOutlet NSView *swapView;
	
	IBOutlet NSTextField *intervalTextField;
	IBOutlet NSPopUpButton *intervalUnitPopUp;
	IBOutlet NSPopUpButton *qualityPopUp;
	IBOutlet NSPopUpButton *formatPopUp;
	IBOutlet NSTextField *filenameTextField;
	
	IBOutlet NSTextField *serverTextField;
	IBOutlet NSTextField *usernameTextField;
	IBOutlet NSTextField *passwordTextField;
	IBOutlet NSTextField *pathTextField;
	IBOutlet NSTextField *portTextField;

	QTCaptureSession *mCaptureSession;
	QTCaptureDeviceInput *mCaptureDeviceInput;
	QTCaptureDecompressedVideoOutput *mCaptureDecompressedVideoOutput;
	
	CVImageBufferRef mCurrentImageBuffer;
	
	NSTimer *sequenceTimer;
	NSString *saveFolderPath;
}

@property (assign) IBOutlet NSWindow *window;

- (void)startRecording;
- (void)stopRecording;

- (IBAction)toggleRecording:(id)sender;
- (IBAction)showPrefsWindow:(id)sender;
- (IBAction)setServerAdress:(id)sender;



@end
