//
//  SequenzAppDelegate.m
//  Sequenz
//
//  Created by Dominik Gwosdek on 03.11.09.
//  Copyright 2009 Dominik Gwosdek. All rights reserved.
//

#import "SequenzAppDelegate.h"
#import "PrefsController.h"
#import "FTPController.h"


#define INTERVAL_UNIT_SEC 0
#define INTERVAL_UNIT_MIN 1
#define QUALITY_LOW 0
#define QUALITY_MID 1
#define QUALITY_HIGH 2
#define FORMAT_JPG 0
#define FORMAT_PNG 1
#define FORMAT_GIF 2


@interface SequenzAppDelegate (Private) 
								
- (void)setSubView:(NSView *)theView;

@end



@implementation SequenzAppDelegate

@synthesize window, isRecording;

#pragma mark Initializing & Terminating

+ (void)initialize {
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	
	[defaultValues setObject:[NSNumber numberWithInt:10] forKey:@"recordingInterval"];
	[defaultValues setObject:[NSNumber numberWithInt:0] forKey:@"intervalUnit"];
	[defaultValues setObject:[NSNumber numberWithInt:1] forKey:@"quality"];
	[defaultValues setObject:[NSNumber numberWithInt:0] forKey:@"format"];
	[defaultValues setObject:@"CaptureImage" forKey:@"filename"];
	
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
	[serverTextField setStringValue:[userDefaults stringForKey:@"server"]];
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
	NSURL *url = [serverTextField objectValue];
	url = [url URLByAppendingPathComponent:[pathTextField stringValue]];
	url = [url URLByAppendingPathComponent:[filenameTextField stringValue]];
	
	NSString *extention;
	NSLog(@"index: %i", [userDefaults integerForKey:@"format"]);
	switch ([userDefaults integerForKey:@"format"]) {
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
	[userDefaults setObject:[sender stringValue] forKey:@"server"];
}

- (IBAction)setInterval:(id)sender {
	[userDefaults setObject:[NSNumber numberWithInt:[sender intValue]] forKey:@"recordingInterval"];
}

- (IBAction)setIntervalUnit:(id)sender {
	[userDefaults setObject:[NSNumber numberWithInt:[sender indexOfSelectedItem]] forKey:@"intervalUnit"];
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
	NSError *error = nil;
	if (!mCaptureSession) {
		BOOL success;
		
		mCaptureSession = [[QTCaptureSession alloc] init];
		
		QTCaptureDevice *device = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeVideo];
		success = [device open:&error];
		if (!success) {
			[[NSAlert alertWithError:error] runModal];
			return;
		}
		mCaptureDeviceInput = [[QTCaptureDeviceInput alloc] initWithDevice:device];
		success = [mCaptureSession addInput:mCaptureDeviceInput error:&error];
		if (!success) {
			[[NSAlert alertWithError:error] runModal];
			return;
		} 
		
		mCaptureDecompressedVideoOutput = [[QTCaptureDecompressedVideoOutput alloc] init];
        [mCaptureDecompressedVideoOutput setDelegate:self];
        success = [mCaptureSession addOutput:mCaptureDecompressedVideoOutput error:&error];
        if (!success) {
            [[NSAlert alertWithError:error] runModal];
            return;
        }
		
	}
	
	[mCaptureView setCaptureSession:mCaptureSession];
	[mCaptureSession startRunning];
	NSLog(@"Interval: %f", [self convertedInterval]);
	sequenceTimer = [NSTimer scheduledTimerWithTimeInterval:[self convertedInterval]
													 target:self 
												   selector:@selector(capturePic:) 
												   userInfo:nil 
													repeats:YES];
}

- (void)stopRecording {
	
	[sequenceTimer invalidate];
	[mCaptureSession stopRunning];
	[self setIsRecording:NO];
	[startStopButton setState:NSOffState];
	
	/*
	QTCaptureDevice *device = [mCaptureDeviceInput device];
	if ([device isOpen]) {
		[device close];
	}
	*/ 
}

- (void)capturePic:(NSTimer *)aTimer {
	
	CVImageBufferRef imageBuffer;
	
    @synchronized (self) {
        imageBuffer = CVBufferRetain(mCurrentImageBuffer);
    }
	
    if (imageBuffer) {
		float factor;
		switch ([userDefaults integerForKey:@"quality"]) {
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
		NSLog(@"factor: %f", factor);
		
		NSBitmapImageFileType type;
		switch ([userDefaults integerForKey:@"format"]) {
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
		
		NSBitmapImageRep *imageRep;
		imageRep = [[NSBitmapImageRep alloc] initWithCIImage:[CIImage imageWithCVImageBuffer:imageBuffer]];
		NSData *bitmapData;
		bitmapData = [imageRep representationUsingType:type 
											properties:[NSDictionary dictionaryWithObject:[NSDecimalNumber numberWithFloat:factor] 
																				   forKey:NSImageCompressionFactor]];
	
		
		BOOL success = [ftpController uploadData:bitmapData 
										   toURL:[self composedUploadURL] 
										username:[usernameTextField stringValue] 
										password:[passwordTextField stringValue]];

		[imageRep release];

        CVBufferRelease(imageBuffer);
    }
}

#pragma mark Delegates

- (void)uploadDidFinish {
	NSLog(@"Delegate called: Upload did finish");
}

- (void)uploadDidNotFinishWithError:(NSError *)error {
	NSBeginAlertSheet(@"A FTP error occured", nil, nil, nil, window, self, @selector(alertDidEnd:returnCode:contextInfo:), @selector(sheetDidDismiss:returnCode:contextInfo:), nil, @"Server message: %@",[error localizedDescription]);
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	[self stopRecording];
}

- (void)sheetDidDismiss:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo {
	[self switchSubViews];
}

- (void)captureOutput:(QTCaptureOutput *)captureOutput didOutputVideoFrame:(CVImageBufferRef)videoFrame 
	 withSampleBuffer:(QTSampleBuffer *)sampleBuffer fromConnection:(QTCaptureConnection *)connection {
	CVImageBufferRef imageBufferToRelease;
	
    CVBufferRetain(videoFrame);
	
    @synchronized (self) {
        imageBufferToRelease = mCurrentImageBuffer;
        mCurrentImageBuffer = videoFrame;
    }
    CVBufferRelease(imageBufferToRelease);
	
}

@end
