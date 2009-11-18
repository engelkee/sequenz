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
								
- (void)switchSubViews;

@end



@implementation SequenzAppDelegate

@synthesize window, isRecording;

#pragma mark Initializing & Terminating

+ (void)initialize {
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	
	[defaultValues setObject:[NSNumber numberWithInt:10] forKey:SQRecordingInterval];
	[defaultValues setObject:[NSNumber numberWithInt:0] forKey:SQIntervalUnit];
	[defaultValues setObject:[NSNumber numberWithInt:1] forKey:SQImageQuality];
	[defaultValues setObject:[NSNumber numberWithInt:0] forKey:SQImageFormat];
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
	[ftpController release];
	[super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	
}

- (void)applicationWillTerminate:(NSNotification *)notification {

}

- (void)awakeFromNib {
	[self switchSubViews];
	//[serverTextField setStringValue:[userDefaults stringForKey:@"server"]];
}

#pragma mark Private methods

- (void)switchSubViews {
	NSView *currentView, *newView;
	NSArray *currentSubViews = [swapView subviews];
	if ([currentSubViews containsObject:recordingView]) {
		currentView = recordingView;
		newView = settingsView;
	} else if ([currentSubViews containsObject:settingsView]) {
		currentView = settingsView;
		newView = recordingView;
	} else {
		currentView = nil;
		newView = settingsView;
	}

	
	NSRect windowRect = [window frame];
    float dy = ([newView frame].size.height - [[window contentView] frame].size.height + 50) * [window userSpaceScaleFactor];
    windowRect.origin.y -= dy;
    windowRect.size.height += dy;
	float dx = ([newView frame].size.width - [[window contentView] frame].size.width) * [window userSpaceScaleFactor];
    //windowRect.origin.x -= dx;
    windowRect.size.width += dx;
	
	[newView setHidden: YES];
    //[window setContentView: theView];
	
	if ([[swapView subviews] count] == 0) {
		[swapView addSubview:newView];
	} else {
		[swapView replaceSubview:currentView with:newView];
	}
	
    [window setFrame: windowRect display:YES animate:YES];
    [newView setHidden:NO];
}

- (NSURL *)composedUploadURL {
	NSURL *url = [NSURL URLWithString:[serverTextField objectValue]];
	url = [url URLByAppendingPathComponent:[pathTextField stringValue]];
	url = [url URLByAppendingPathComponent:[filenameTextField stringValue]];
	
	NSString *extention;

	switch ([userDefaults integerForKey:SQImageFormat]) {
		case 0:
			extention = @"jpg";				
			break;
		case 1:
			extention = @"png";
			break;
		case 2:
			extention = @"gif";
			break;
		default:
			extention = @"noext";
			break;
	}
	
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
	[self switchSubViews];
}

- (void)startRecording {
	[self setIsRecording:YES];
	mCamera = [[Camera alloc] init];
	[mCaptureView setCaptureSession:[mCamera mCaptureSession]];
	[[mCamera mCaptureSession] startRunning];

	sequenceTimer = [NSTimer scheduledTimerWithTimeInterval:[self convertedInterval]
													 target:self 
												   selector:@selector(capturePic:) 
												   userInfo:nil 
													repeats:YES];
}

- (void)stopRecording {
	
	[sequenceTimer invalidate];
	[[mCamera mCaptureSession] stopRunning];
	[mCamera release];
	[self setIsRecording:NO];
	
	/*
	QTCaptureDevice *device = [mCaptureDeviceInput device];
	if ([device isOpen]) {
		[device close];
	}
	*/ 
}

- (void)capturePic:(NSTimer *)aTimer {

	float factor;
	switch ([userDefaults integerForKey:SQImageQuality]) {
		case 0:
			factor = 0.5;
			break;
		case 1:
			factor = 0.75;
			break;
		case 2:
			factor = 1.0;
			break;
		default:
			factor = 0.5;
			break;
	}
	
	NSBitmapImageFileType type;
	switch ([userDefaults integerForKey:SQImageFormat]) {
		case 0:
			type = NSJPEGFileType;
			break;
		case 1:
			type = NSPNGFileType;
			break;
		case 2:
			type = NSGIFFileType;
			break;
		default:
			type = NSJPEGFileType;
			break;
	}
	
	NSData *imageData = [mCamera takePictureWithFileType:type quality:[NSNumber numberWithFloat:factor]];

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
	[self switchSubViews];
	[startStopButton setState:NSOffState];
}

- (void)sheetDidDismiss:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo {
	//[self switchSubViews];
}

@end
