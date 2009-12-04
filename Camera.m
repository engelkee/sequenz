//
//  Camera.m
//  Sequenz
//
//  Created by Dominik Gwosdek on 13.11.09.
//  Copyright 2009 Dominik Gwosdek. All rights reserved.
//

#import "Camera.h"
#import "PrefsController.h"

@interface Camera (Private)

- (void)drawCaptureDate:(NSDate *)date toImageRep:(NSBitmapImageRep *)rep;
- (void)openShutter;

@end


@implementation Camera

@synthesize mCaptureSession, device;

- (id)init {
	self = [super init];
	if (self != nil) {
		mCaptureSession = [[QTCaptureSession alloc] init];
		[self openShutter];
	}
	return self;
}

- (void)dealloc {
	[mCaptureSession release];
	[mCaptureDeviceInput release];
    [mCaptureDecompressedVideoOutput release];
	[super dealloc];
}

- (void)openShutter {
	NSError *err = nil;
	NSAlert *alert;
	BOOL success;
	
	device = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeVideo];
	success = [device open:&err];
	if (!success) {
#ifndef NDEBUG
		NSLog(@"error: %@", [err localizedDescription]);
#endif
		alert = [NSAlert alertWithMessageText:@"Could not connect to iSight camera" 
								defaultButton:@"Quit" 
							  alternateButton:nil 
								  otherButton:nil 
					informativeTextWithFormat:@"Your camera seems to be in use exclusively by an other application.\nPlease quit the other application and try again."];
		[alert setAlertStyle:NSCriticalAlertStyle];
		if ([alert runModal] == NSAlertDefaultReturn) {;
			[[NSApplication sharedApplication] terminate:nil];
		}
		return;
	}
	
	mCaptureDeviceInput = [[QTCaptureDeviceInput alloc] initWithDevice:device];
	success = [mCaptureSession addInput:mCaptureDeviceInput error:&err];
	if (!success) {
		[[NSAlert alertWithError:err] runModal];
		return;
	} 

	mCaptureDecompressedVideoOutput = [[QTCaptureDecompressedVideoOutput alloc] init];
	[mCaptureDecompressedVideoOutput setDelegate:self];
	success = [mCaptureSession addOutput:mCaptureDecompressedVideoOutput error:&err];
	if (!success) {
		[[NSAlert alertWithError:err] runModal];
		return;
	}
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
