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
NSString *SQFTPServerAddress = @"SQFTPServerAddress";
NSString *SQFTPUsername = @"SQFTPUsername";
NSString *SQFTPPath = @"SQFTPPath";


@interface SequenzAppDelegate (Private) 
								
- (void)repositionViewsIgnoringView:(NSView*)viewToIgnore;
- (NSRect)windowFrameForNewContentViewSize:(NSSize)newSize;

@end



@implementation SequenzAppDelegate

@synthesize window, isRecording;

#pragma mark Initializing & Terminating

+ (void)initialize {
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	
	[defaultValues setObject:[NSNumber numberWithInt:10] forKey:SQRecordingInterval];
	[defaultValues setObject:[NSNumber numberWithInt:0] forKey:SQIntervalUnit];
	[defaultValues setObject:[NSNumber numberWithFloat:0.5] forKey:SQImageQuality];
	[defaultValues setObject:@"CaptureImage" forKey:SQImageFilename];
	[defaultValues setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSFont fontWithName:@"Times-Roman" size:12.0]] forKey:SQTimestampFont];
	[defaultValues setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSColor blackColor]] forKey:SQTimestampColor];
	//[defaultValues setObject:@"" forKey:@"server"];
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
	//[serverTextField setStringValue:[userDefaults stringForKey:@"server"]];

	
	mCamera = [[Camera alloc] init];
	[mCaptureView setCaptureSession:[mCamera mCaptureSession]];
	[[mCamera mCaptureSession] startRunning];
	
}

#pragma mark Private methods

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
	
	/* // von mir
	NSRect windowRect = [window frame];
    float dy = (windowRect.size.height - contentViewSize.height);
    windowRect.origin.y += dy;
    windowRect.size.height = contentViewSize.height + 50.0 + 22.0;
	NSLog(@"window rect origin y: %f + window rect height: %f = %f", windowRect.origin.y, windowRect.size.height, (windowRect.origin.y + windowRect.size.height));
    [window setFrame: windowRect display:YES animate:NO];
	*/
	NSRect newWindowFrame = [self windowFrameForNewContentViewSize:contentViewSize];
	[window setFrame:newWindowFrame display:YES];

	
}

- (NSRect)windowFrameForNewContentViewSize:(NSSize)newSize {
	NSRect windowFrame = [window frame];
	
	windowFrame.size.width = newSize.width;
	
	float titlebarAreaHeight = windowFrame.size.height - [[window contentView] frame].size.height;
	float newHeight = newSize.height + titlebarAreaHeight + 50.0;
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

- (IBAction)setServerAdress:(id)sender {
	//[userDefaults setObject:[sender stringValue] forKey:@"server"];
	//[[sender stringValue] length] > 0 ? [startStopButton setEnabled:YES] : [startStopButton setEnabled:NO];
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
		NSLog(@"Record pressed");
	} else {
		[self stopRecording];
	}
}

- (void)startRecording {
	[self setIsRecording:YES];
	/*
	mCamera = [[Camera alloc] init];
	[mCaptureView setCaptureSession:[mCamera mCaptureSession]];
	[[mCamera mCaptureSession] startRunning];
	 */
	sequenceTimer = [NSTimer scheduledTimerWithTimeInterval:[self convertedInterval]
													 target:self 
												   selector:@selector(capturePic:) 
												   userInfo:nil 
													repeats:YES];
}

- (void)stopRecording {
	
	[sequenceTimer invalidate];
	//[[mCamera mCaptureSession] stopRunning];
	//[mCamera release];
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
	NSLog(@"Delegate called: Upload did finish");
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
	//[self switchSubViews];
}

@end
