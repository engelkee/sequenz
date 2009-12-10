//
//  CameraController.h
//  Sequenz
//
//  Created by Dominik Gwosdek on 09.12.09.
//  Copyright 2009 Dominik Gwosdek. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>

@interface CameraController : NSObject {
	QTCaptureSession *mCaptureSession;
	QTCaptureDecompressedVideoOutput *mCaptureDecompressedVideoOutput;
	QTCaptureDevice *defaultDevice;
	QTCaptureDevice *userDevice;
	CVImageBufferRef mCurrentImageBuffer;
	NSArray *devices;
	NSMutableDictionary *devicesDict;
	BOOL camerasAvailable;
}

+ (id)sharedCameraController;

@property (retain, readonly) QTCaptureSession *mCaptureSession;
@property (retain, readonly) QTCaptureDevice *defaultDevice;
@property (retain, readonly) QTCaptureDevice *userDevice;
@property (retain) NSArray *devices;
@property (retain) NSMutableDictionary *devicesDict;
@property BOOL camerasAvailable;

- (NSData *)takePictureWithFileType:(NSBitmapImageFileType)type quality:(NSNumber *)qual;
- (void)changeDevice:(NSString *)deviceName;

@end
