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

struct MemoryStruct
{
	char *memory;
	size_t size;
};

static size_t ReadMemoryCallback(void *ptr, size_t size, size_t nmemb, void *pMem)
{
	struct MemoryStruct *pRead = (struct MemoryStruct *)pMem; 
    size_t ReadLength = size * nmemb; 
    if (pRead->size >= ReadLength) 
    { 
        memcpy((char *)ptr, &pRead->memory[0], ReadLength); 
        pRead->memory += ReadLength; 
        pRead->size -= ReadLength; 
        return ReadLength; 
    } 
    else if ((pRead->size < ReadLength) && (pRead->size > 0)) 
    { 
        size_t ReturnSize = pRead->size; 
        memcpy((char *)ptr, &pRead->memory[0], pRead->size); 
        pRead->memory += pRead->size; 
        pRead->size = 0; 
        return(ReturnSize); 
    } 
    else 
        return 0; 
}

@interface SequenzAppDelegate (Private) 

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
	[serverTextField setStringValue:[userDefaults stringForKey:@"server"]];
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

- (IBAction)setServerAdress:(id)sender {
	[userDefaults setObject:[sender stringValue] forKey:@"server"];
}

- (IBAction)setInterval:(id)sender {
	[userDefaults setObject:[NSNumber numberWithInt:[sender intValue]] forKey:@"recordingInterval"];
}

- (IBAction)setIntervalUnit:(id)sender {
	[userDefaults setObject:[NSNumber numberWithInt:[sender indexOfSelectedItem]] forKey:@"intervalUnit"];
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
	
	sequenceTimer = [NSTimer scheduledTimerWithTimeInterval:7.0 target:self selector:@selector(capturePic:) userInfo:nil repeats:YES];
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
											properties:[NSDictionary dictionaryWithObject:[NSDecimalNumber numberWithFloat:factor] forKey:NSImageCompressionFactor]];
	
		
		//BOOL success = [ftpController uploadData:bitmapData toURL:[self composedUploadURL] username:[usernameTextField stringValue] password:[passwordTextField stringValue]];
		
		
		CURL *curl;
		CURLcode res;
		double dUploadSpeed, dTotalTime;
		
		struct MemoryStruct sData;
		
		sData.memory = (char *)[bitmapData bytes];
		sData.size = [bitmapData length];
		
		/* In windows, this will init the winsock stuff */ 
		curl_global_init(CURL_GLOBAL_ALL);
		
		/* get a curl handle */ 
		curl = curl_easy_init();
		if(curl) {
			
			/* we want to use our own read function */ 
			curl_easy_setopt(curl, CURLOPT_READFUNCTION, ReadMemoryCallback);
			
			/* enable uploading */ 
			curl_easy_setopt(curl, CURLOPT_UPLOAD, 1L);
			
			/* specify target */ 
			curl_easy_setopt(curl, CURLOPT_URL, [[[self composedUploadURL] absoluteString] UTF8String]);
			curl_easy_setopt(curl, CURLOPT_USERNAME, [[usernameTextField stringValue] UTF8String]);
			curl_easy_setopt(curl, CURLOPT_PASSWORD, [[passwordTextField stringValue] UTF8String]);
			/* now specify which file to upload */ 
			curl_easy_setopt(curl, CURLOPT_READDATA, (void *)&sData);
			
			/* Set the size of the file to upload (optional).  If you give a *_LARGE
			 option you MUST make sure that the type of the passed-in argument is a
			 curl_off_t. If you use CURLOPT_INFILESIZE (without _LARGE) you must
			 make sure that to pass in a type 'long' argument. */ 
			curl_easy_setopt(curl, CURLOPT_INFILESIZE_LARGE, (curl_off_t)sData.size);
			
			/* Now run off and do what you've been told! */ 
			res = curl_easy_perform(curl);

			fprintf(stderr, "Fehlercode: %i\n", res);
			curl_easy_getinfo(curl, CURLINFO_SPEED_UPLOAD, &dUploadSpeed);
			curl_easy_getinfo(curl, CURLINFO_TOTAL_TIME, &dTotalTime);
			fprintf(stderr, "Speed: %.3f bytes/sec during %.3f seconds\n", dUploadSpeed, dTotalTime);
			
			/* always cleanup */ 
			curl_easy_cleanup(curl);
		}
		
		curl_global_cleanup();
		
		[imageRep release];

        CVBufferRelease(imageBuffer);
    }
}

- (void)uploadDidFinish {
	NSLog(@"Delegate called: Upload did finish");
}

- (void)uploadDidNotFinishWithError:(NSError *)error {
	NSRunAlertPanel((@"Connection Error: %@", [error localizedDescription]), @"foo", @"ok", nil, nil);	
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
