//
//  CameraController.m
//  Sequenz
//
//  Created by Dominik Gwosdek on 09.12.09.
//  Copyright 2009 Dominik Gwosdek. All rights reserved.
//

#import "CameraController.h"
#import "PrefsController.h"

@interface CameraController (Private)

- (void)drawCaptureDate:(NSDate *)date toImageRep:(NSBitmapImageRep *)rep;
- (void)updateCameras:(NSNotification *)notification;

@end


@implementation CameraController

@synthesize mCaptureSession, userDevice, defaultDevice, devices, devicesDict, camerasAvailable;

static CameraController *gCameraController;

+ (void)initialize {
	if (self == [CameraController class]) {
		gCameraController = [[self alloc] init];
	}
}

+ (id)sharedCameraController {
	return gCameraController;
}

- (id)init
{
	self = [super init];
	if (self != nil) {
		mCaptureSession = [[QTCaptureSession alloc] init];
		devicesDict = [[NSMutableDictionary alloc] init];
		[self updateCameras:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCameras:) name:QTCaptureDeviceWasConnectedNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCameras:) name:QTCaptureDeviceWasDisconnectedNotification object:nil];
	}
	return self;
}

- (void)dealloc {
	[mCaptureSession release];
	[mCaptureDecompressedVideoOutput release];
	[devicesDict release];
	[super dealloc];
}

- (void)updateCameras:(NSNotification *)notification {
	[self setDevices:[QTCaptureDevice inputDevicesWithMediaType:QTMediaTypeVideo]];
	defaultDevice = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeVideo];
	[[self devicesDict] removeAllObjects];
	for (QTCaptureDevice *d in [self devices]) {
		[[self devicesDict] setValue:[d uniqueID] forKey:[d localizedDisplayName]];
	}

	if ([devicesDict count] > 0) {
		[self setCamerasAvailable:YES];
	} else {
		[self setCamerasAvailable:NO];
	}
#ifndef NDEBUG
	NSLog(@"are CamerasAvaiable: %i", camerasAvailable);
#endif
}

- (void)changeDevice:(NSString *)deviceName {
	if ([mCaptureSession isRunning]) {
		[mCaptureSession stopRunning];
	}
	
	for (QTCaptureDeviceInput *oldInput in [mCaptureSession inputs]) {
		[mCaptureSession removeInput:oldInput];
	}
	
	if ([userDevice isOpen]) {
		[userDevice close];
	}
	
	NSError *err = nil;
	BOOL success;
	
	userDevice = [QTCaptureDevice deviceWithUniqueID:[[self devicesDict] valueForKey:deviceName]];
	success = [userDevice open:&err];
	if (!success) {
		//[[NSAlert alertWithError:err] runModal];
		return;
	}
	
	QTCaptureDeviceInput *mCaptureDeviceInput = [[QTCaptureDeviceInput alloc] initWithDevice:userDevice];
	success = [mCaptureSession addInput:mCaptureDeviceInput error:&err];
	if (!success) {
		[[NSAlert alertWithError:err] runModal];
		return;
	} 
	
	if (!mCaptureDecompressedVideoOutput) {
		mCaptureDecompressedVideoOutput = [[QTCaptureDecompressedVideoOutput alloc] init];
		[mCaptureDecompressedVideoOutput setDelegate:self];
		success = [mCaptureSession addOutput:mCaptureDecompressedVideoOutput error:&err];
		if (!success) {
			[[NSAlert alertWithError:err] runModal];
			return;
		}
	}
	
	[mCaptureSession startRunning];
}

- (NSData *)takePictureWithFileType:(NSBitmapImageFileType)type quality:(NSNumber *)qual {
	CVImageBufferRef imageBuffer;
	NSData *bitmapData = nil;
    @synchronized (self) {
        imageBuffer = CVBufferRetain(mCurrentImageBuffer);
    }
	if (imageBuffer) {
		NSBitmapImageRep *imageRep;
		imageRep = [[NSBitmapImageRep alloc] initWithCIImage:[CIImage imageWithCVImageBuffer:imageBuffer]];
		
		if ([[NSUserDefaults standardUserDefaults] boolForKey:SQInsertTimestampFlag]) {
			[self drawCaptureDate:[NSDate date] toImageRep:imageRep];
		}
		
		bitmapData = [imageRep representationUsingType:type 
											properties:[NSDictionary dictionaryWithObject:qual 
																				   forKey:NSImageCompressionFactor]];
		//NSLog(@"bitmapData : %i bytes", [bitmapData length]);
		[imageRep release];
		CVBufferRelease(imageBuffer);
	}
	return bitmapData;
}

// This delegate method is called whenever the QTCaptureDecompressedVideoOutput receives a frame
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

- (void)drawCaptureDate:(NSDate *)date toImageRep:(NSBitmapImageRep *)rep {
	[NSGraphicsContext saveGraphicsState];
	NSGraphicsContext *gc = [NSGraphicsContext graphicsContextWithBitmapImageRep:rep];
	[NSGraphicsContext setCurrentContext:gc];
	NSString *dateString = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterFullStyle];
	
	NSColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] valueForKey:SQTimestampColor]];
	NSFont *font = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] valueForKey:SQTimestampFont]];
	NSMutableDictionary *attrsDictionary = [NSMutableDictionary dictionary];
	[attrsDictionary setObject:font forKey:NSFontAttributeName];
	[attrsDictionary setObject:color forKey:NSForegroundColorAttributeName];
	[dateString drawAtPoint:NSMakePoint(10.0, 10.0) withAttributes:attrsDictionary];
	[NSGraphicsContext restoreGraphicsState];
}

@end
