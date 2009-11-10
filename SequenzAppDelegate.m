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

- (NSString *)simplifyServerAdress:(NSString *)URLString;
- (void)setSubView:(NSView *)theView;

@end



@implementation SequenzAppDelegate

@synthesize window;

+ (void)initialize {
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	
	[defaultValues setObject:[NSNumber numberWithInt:5] forKey:@"recordingInterval"];
	[defaultValues setObject:[NSNumber numberWithInt:0] forKey:@"intervalUnit"];
	[defaultValues setObject:[NSNumber numberWithInt:1] forKey:@"quality"];
	[defaultValues setObject:[NSNumber numberWithInt:0] forKey:@"format"];
	[defaultValues setObject:@"CaptureImage" forKey:@"filename"];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
	NSLog(@"registered defaults: %@", defaultValues);
}

- (id)init {
	self = [super init];
	if (self != nil) {
		userDefaults = [NSUserDefaults standardUserDefaults];
	}
	return self;
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	
}

- (void)applicationWillTerminate:(NSNotification *)notification {

}

- (void)awakeFromNib {
	[self setSubView:settingsView];
}

- (void)setSubView:(NSView *)theView {
	NSRect windowRect = [window frame];
    float dy = ([theView frame].size.height - [[window contentView] frame].size.height + 50) * [window userSpaceScaleFactor];
    windowRect.origin.y -= dy;
    windowRect.size.height += dy;
	float dx = ([theView frame].size.width - [[window contentView] frame].size.width) * [window userSpaceScaleFactor];
    //windowRect.origin.x -= dx;
    windowRect.size.width += dx;
	
    [theView setHidden: YES];
    //[window setContentView: theView];

	if ([[swapView subviews] count] == 0) {
		[swapView addSubview:theView];
	} else if (theView == recordingView) {
		[swapView replaceSubview:settingsView  with:recordingView];
	} else {
		[swapView replaceSubview:recordingView  with:settingsView];
	}
	
    [window setFrame: windowRect display: YES animate: YES];
    [theView setHidden: NO];

}
/*
- (IBAction)chooseSaveFolder:(id)sender {
	NSOpenPanel *op = [NSOpenPanel openPanel];
	[op setCanChooseFiles:NO];
	[op setCanChooseDirectories:YES];
    if ([op runModal] == NSOKButton)
    {
        saveFolderPath = [op filename];
		[pathMenuItem setTitle:saveFolderPath];
		NSLog(@"Save Path: %@", saveFolderPath);
		
    }
}
*/

- (IBAction)setServerAdress:(id)sender {
	NSString *adress = [sender stringValue];
	[userDefaults setObject:[self simplifyServerAdress:adress] forKey:@"server"];
	NSLog(@"adress: %@", [self simplifyServerAdress:adress]);
			
}

- (NSString *)simplifyServerAdress:(NSString *)URLString {
	NSURL *url = [NSURL	URLWithString:URLString];
	if (url) {
		NSString *scheme = [url scheme];
		if (scheme == nil) {
			URLString = [@"ftp://" stringByAppendingString:URLString];
			url = [NSURL URLWithString:URLString];
            scheme = [url scheme];
		}
		if ([[url host] length]) {
			return URLString;
		}
	}
	return nil;
}

- (NSURL *)composedUploadURL {
	NSString *urlString = [NSString stringWithFormat:@"%@://%@:%@@%@%@/%@", [[NSURL URLWithString:[userDefaults stringForKey:@"server"]] scheme],
						   [userDefaults stringForKey:@"username"],
						   [passwordTextField stringValue],
						   [[NSURL URLWithString:[userDefaults stringForKey:@"server"]] host],
						   [pathTextField stringValue],
						   [userDefaults stringForKey:@"filename"]];

	switch ([userDefaults integerForKey:@"format"]) {
		case FORMAT_JPG:
			urlString = [urlString stringByAppendingString:@".jpg"];				
			break;
		case FORMAT_PNG:
			urlString = [urlString stringByAppendingString:@".png"];
			break;
		case FORMAT_GIF:
			urlString = [urlString stringByAppendingString:@".gif"];
			break;
		default:
			urlString = [urlString stringByAppendingString:@".jpg"];
			break;
	}
	return [NSURL URLWithString:urlString];
}

- (IBAction)showPrefsWindow:(id)sender {
	if(!prefController) {
		prefController = [[PrefsController alloc] init];
	}
	NSWindow *prefWindow = [prefController window];
	[prefController showWindow:prefWindow];
}

- (IBAction)toggleRecording:(id)sender {	
	NSView *view;
	NSInteger state = [sender state];
	if (state == NSOnState) {
		[self startRecording];
		view = recordingView;
		NSLog(@"Record pressed");
	} else {
		[self stopRecording];
		view = settingsView;
	}
	[self setSubView:view];
}

- (void)startRecording {
	if (!ftpController) {
		ftpController = [[FTPController alloc] init];
		[ftpController setDelegate:self];
	}
	
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
	
	sequenceTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(capturePic:) userInfo:nil repeats:YES];
}

- (void)stopRecording {
	
	[sequenceTimer invalidate];
	[mCaptureSession stopRunning];
	[ftpController release];
	/*
	QTCaptureDevice *device = [mCaptureDeviceInput device];
	if ([device isOpen]) {
		[device close];
	}
	*/ 
}

- (void)capturePic:(NSTimer *)aTimer {

	NSLog(@"url: %@", [self composedUploadURL]);
	
	CVImageBufferRef imageBuffer;
	
    @synchronized (self) {
        imageBuffer = CVBufferRetain(mCurrentImageBuffer);
    }
	
    if (imageBuffer) {

		NSBitmapImageRep *imageRep;
		imageRep = [[NSBitmapImageRep alloc] initWithCIImage:[CIImage imageWithCVImageBuffer:imageBuffer]];
		NSData *bitmapData;
		bitmapData = [imageRep representationUsingType:NSJPEGFileType 
											properties:[NSDictionary dictionaryWithObject:[NSDecimalNumber numberWithFloat:0.7] forKey:NSImageCompressionFactor]];
	
		//[bitmapData writeToFile:saveFilePath atomically:YES];
		
		BOOL success = [ftpController uploadData:bitmapData toURL:[NSURL URLWithString:@"ftp://gwosdek.net/capture.jpg"]];
		
		/*
		CFErrorRef error;
		//CFURLRef URL = CFURLCreateWithString(NULL, (CFStringRef)@"capture.jpg", (CFURLRef)[NSURL URLWithString:@"ftp://gwosdek.net"]);
		CFWriteStreamRef writeStream = CFWriteStreamCreateWithFTPURL(NULL,(CFURLRef)[self composedUploadURL]);
		error = CFWriteStreamCopyError(writeStream);
		CFWriteStreamSetProperty(writeStream, kCFStreamPropertyFTPUsePassiveMode, [NSNumber numberWithBool:YES]);
		CFWriteStreamSetProperty(writeStream, kCFStreamPropertyFTPAttemptPersistentConnection, [NSNumber numberWithBool:YES]);
		if (!CFWriteStreamOpen(writeStream)) {
			NSLog(@"An error %@ occured while sending file\n %@", error, [(NSError *)error userInfo]);
		}

		NSLog(@"data to upload: %i", [bitmapData length]);
		
		const void *cur = [bitmapData bytes];
		const void *end = [bitmapData bytes] + [bitmapData length];
		NSLog(@"%i %i %i",cur,end,end-cur);
		BOOL done = FALSE;
	
		do {
			int l = CFWriteStreamWrite(writeStream,cur,end-cur);
			
			if (l < 0) {
				CFErrorRef error = CFWriteStreamCopyError(writeStream);
				//NSLog(@"An error %@ occured while writing file\n %@", error, [(NSError *)error userInfo]);
				[self handleFTPError:(NSError *)error];
				return;
			} else if (l == 0) {
				if (CFWriteStreamGetStatus(writeStream) == kCFStreamStatusAtEnd)
				{
					done = TRUE;
					NSLog(@"done!");
				}
			} else if (l != [bitmapData length]) {
				cur += l;
			}
			
		} while (cur < end);
		
		CFWriteStreamClose(writeStream);
		*/
		[imageRep release];
		
        CVBufferRelease(imageBuffer);
	
		
    }
}

- (void)uploadDidFinished {
	NSLog(@"Delegate called: Upload did finished");
}

- (void)handleFTPError:(NSError *)err {
	if (err) {
		[self stopRecording];
		//NSRunCriticalAlertPanel((@"Connection Error: %@", [err localizedDescription]), @"Bla", @"sorry", nil, nil, [err localizedDescription]);
		NSRunAlertPanel((@"Connection Error: %@", [err localizedDescription]), @"foo", @"ok", nil, nil);
	}
}

- (void) alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	[self stopRecording];
}

- (void)captureOutput:(QTCaptureOutput *)captureOutput didOutputVideoFrame:(CVImageBufferRef)videoFrame withSampleBuffer:(QTSampleBuffer *)sampleBuffer fromConnection:(QTCaptureConnection *)connection {
	CVImageBufferRef imageBufferToRelease;
	
    CVBufferRetain(videoFrame);
	
    @synchronized (self) {
        imageBufferToRelease = mCurrentImageBuffer;
        mCurrentImageBuffer = videoFrame;
    }
    CVBufferRelease(imageBufferToRelease);
	
}

@end
