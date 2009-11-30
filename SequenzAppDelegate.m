//
//  SequenzAppDelegate.m
//  Sequenz
//
//  Created by Dominik Gwosdek on 03.11.09.
//  Copyright 2009 Dominik Gwosdek. All rights reserved.
//

#import "SequenzAppDelegate.h"
#import "Camera.h"
#import "FTPController.h"
#import "PrefsController.h"
#import "SideBarPaneView.h"


#define INTERVAL_UNIT_SEC 0
#define INTERVAL_UNIT_MIN 1
#define QUALITY_LOW 0
#define QUALITY_MID 1
#define QUALITY_HIGH 2
#define FORMAT_JPG 0
#define FORMAT_PNG 1
#define FORMAT_GIF 2

NSString *SQRecordingInterval = @"SQRecordingInterval";
NSString *SQIntervalUnit = @"SQIntervalUnit";
NSString *SQImageQuality = @"SQImageQuality";
NSString *SQImageFormat = @"SQImageFormat";
NSString *SQImageFilename = @"SQImageFilename";
NSString *SQFTPServerAddress = @"≥	";
NSString *SQFTPUsername = @"SQFTPUsername";
NSString *SQFTPPath = @"SQFTPPath";


@interface SequenzAppDelegate (Private) 
								
- (void)repositionViewsIgnoringView:(NSView*)viewToIgnore;
- (NSRect)windowFrameForNewContentViewSize:(NSSize)newSize;

@end



@implementation SequenzAppDelegate

@synthesize window, isRecording, isCameraOn;

#pragma mark Initializing & Terminating

+ (void)initialize {
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	
	[defaultValues setObject:[NSNumber numberWithInt:10] forKey:SQRecordingInterval];
	[defaultValues setObject:[NSNumber numberWithInt:0] forKey:SQIntervalUnit];
	[defaultValues setObject:[NSNumber numberWithFloat:0.5] forKey:SQImageQuality];
	[defaultValues setObject:@"CaptureImage" forKey:SQImageFilename];
	[defaultValues setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSFont fontWithName:@"Times-Roman" size:12.0]] forKey:SQTimestampFont];
	[defaultValues setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSColor blackColor]] forKey:SQTimestampColor];
	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:@"SUEnableAutomaticChecks"];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}

- (id)init {
	self = [super init];
	if (self != nil) {
		userDefaults = [NSUserDefaults standardUserDefaults];
		ftpController = [[FTPController alloc] init];
		[ftpController setDelegate:self];
	}
	return self;
}

- (void)dealloc {
	[mCamera release];
	[ftpController release];
	[super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	
}

- (void)applicationWillTerminate:(NSNotification *)notification {
	[[mCamera mCaptureSession] stopRunning];
}

- (void)awakeFromNib {
	topMargin = NSHeight([[sideBarView superview] frame]) - NSMaxY([sideBarView frame]);
	[sideBarView addSubview:recPane];
	[recPane setPostsFrameChangedNotifications:YES];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustSubview:) name:NSViewFrameDidChangeNotification object:recPane];
	[sideBarView addSubview:ftpPane];
	[recPane setPostsFrameChangedNotifications:YES];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustSubview:) name:NSViewFrameDidChangeNotification object:ftpPane];
	[self repositionViewsIgnoringView:nil];

	[window setMovableByWindowBackground:YES];
	
	
	
	mCamera = [[Camera alloc] init];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cameraAttributeChanged:) name:QTCaptureDeviceAttributeDidChangeNotification object:nil];
	
	[mCaptureView setCaptureSession:[mCamera mCaptureSession]];
	[[mCamera mCaptureSession] startRunning];
	
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cameraAttributeChanged:) name:QTCaptureDeviceAttributeWillChangeNotification object:nil];
	
	[qtSwapView addSubview:mCaptureView];
	
	[self checkCameraSuspended];
}

#pragma mark Private methods

- (void)cameraAttributeChanged:(NSNotification *)notification {
	[self checkCameraSuspended];
}

- (void)checkCameraSuspended {
	NSNumber *value = [[mCamera device] attributeForKey:QTCaptureDeviceSuspendedAttribute];
	//NSLog(@"value : %@", [value stringValue]);
	if (!value) {
		value = [NSNumber numberWithBool:YES];
	}
	
	[self setIsCameraOn:[value boolValue]];

	if ([self isCameraOn]) {
		if ([self isRecording]) {
			[self stopRecording];
		}
		[qtSwapView	replaceSubview:mCaptureView with:suspendedView];
	} else {
		
		[qtSwapView replaceSubview:suspendedView with:mCaptureView];
	}
}

- (void)adjustSubview:(NSNotification *)notification {
	[self repositionViewsIgnoringView:[notification object]];
}

- (void)repositionViewsIgnoringView:(NSView*)viewToIgnore {
	float top = 0.0;
	for (NSView *view in [[sideBarView subviews] objectEnumerator]) {
		NSRect newFrame = [view frame];
		newFrame.origin.y = [sideBarView frame].size.height - (newFrame.size.height + top);
		
		if (view == viewToIgnore)
			[view setPostsFrameChangedNotifications:NO];
		
		[view setFrame:newFrame];
		
		if (view == viewToIgnore)
			[view setPostsFrameChangedNotifications:YES];
		
		top += newFrame.size.height;
	}
	
	NSView *contentView = [window contentView];
	NSRect newSideBarFrame = [sideBarView bounds];
	newSideBarFrame.origin.y = [contentView frame].size.height - newSideBarFrame.size.height - topMargin;
	newSideBarFrame.size.height = top;
	[sideBarView setFrame:newSideBarFrame];
	
	NSSize contentViewSize = newSideBarFrame.size;
	contentViewSize.height += topMargin;

	NSRect newWindowFrame = [self windowFrameForNewContentViewSize:contentViewSize];
	[window setFrame:newWindowFrame display:YES];

	
}

- (NSRect)windowFrameForNewContentViewSize:(NSSize)newSize {
	NSRect windowFrame = [window frame];
	
	windowFrame.size.width = newSize.width;
	
	float titlebarAreaHeight = windowFrame.size.height - [[window contentView] frame].size.height;
	float newHeight = newSize.height + titlebarAreaHeight + 22.0;
	float heightDifference = windowFrame.size.height - newHeight;
	windowFrame.size.height = newHeight;
	windowFrame.origin.y += heightDifference;
	
	return windowFrame;
}

- (NSURL *)composedUploadURL {
	NSURL *url = [NSURL URLWithString:[serverTextField objectValue]];
	url = [url URLByAppendingPathComponent:[pathTextField stringValue]];
	url = [url URLByAppendingPathComponent:[filenameTextField stringValue]];
	
	NSString *extention = @"jpg";
	
	url = [url URLByAppendingPathExtension:extention];
	return url;
}

- (float)convertedInterval {
	return ([intervalUnitPopUp indexOfSelectedItem] == INTERVAL_UNIT_SEC) ? [intervalTextField floatValue] : [intervalTextField floatValue] * 60;
}

#pragma mark UI actions

- (IBAction)openWebsite:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://gwosdek.net/sequenz"]];
}

- (IBAction)openDonate:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://paypal.com"]];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
	NSString *selectorString = NSStringFromSelector([menuItem action]);
	if ([menuItem action] == @selector(toggleRecording:)) {
		return (!isCameraOn && !isRecording);
	} else {
		return YES;
	}
}

- (IBAction)setServerAdress:(id)sender {
}

- (IBAction)setInterval:(id)sender {
	[userDefaults setObject:[NSNumber numberWithInt:[sender intValue]] forKey:SQRecordingInterval];
}

- (IBAction)setIntervalUnit:(id)sender {
	[userDefaults setObject:[NSNumber numberWithInt:[sender indexOfSelectedItem]] forKey:SQIntervalUnit];
}

- (IBAction)showPrefsWindow:(id)sender {
	if(!prefController) {
		prefController = [[PrefsController alloc] init];
	}
	NSWindow *prefWindow = [prefController window];
	[prefController showWindow:prefWindow];
}

- (IBAction)toggleRecording:(id)sender {	
	NSInteger state = [sender state];
	if (state == NSOnState) {
		[self startRecording];
	} else {
		[self stopRecording];
	}
}

- (void)startRecording {
	[self setIsRecording:YES];
	sequenceTimer = [NSTimer scheduledTimerWithTimeInterval:[self convertedInterval]
													 target:self 
												   selector:@selector(capturePic:) 
												   userInfo:nil 
													repeats:YES];
}

- (void)stopRecording {
	
	[sequenceTimer invalidate];
	[self setIsRecording:NO];
	
	/*
	QTCaptureDevice *device = [mCaptureDeviceInput device];
	if ([device isOpen]) {
		[device close];
	}
	*/ 
}

- (void)capturePic:(NSTimer *)aTimer {
	NSNumber *factor = [userDefaults objectForKey:SQImageQuality];
	
	NSData *imageData = [mCamera takePictureWithFileType:NSJPEGFileType quality:factor];

	BOOL success = [ftpController uploadData:imageData 
									   toURL:[self composedUploadURL] 
									username:[usernameTextField stringValue] 
									password:[passwordTextField stringValue]];

}

#pragma mark Delegates

- (void)uploadDidFinish {
	//NSLog(@"Delegate called: Upload did finish");
}

- (void)uploadDidNotFinishWithError:(NSError *)error {
	NSBeginAlertSheet(@"A FTP error occured", nil, nil, nil, window, 
					  self, @selector(alertDidEnd:returnCode:contextInfo:), 
					  @selector(sheetDidDismiss:returnCode:contextInfo:), nil, 
					  @"Server message: %@",[error localizedDescription]);
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	[self stopRecording];
	[startStopButton setState:NSOffState];
}

- (void)sheetDidDismiss:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo {
}

@end
