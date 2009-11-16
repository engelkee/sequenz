//
//  Camera.h
//  Sequenz
//
//  Created by Dominik Gwosdek on 13.11.09.
//  Copyright 2009 Dominik Gwosdek. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>


@interface Camera : NSObject {
	QTCaptureSession *mCaptureSession;
	QTCaptureDeviceInput *mCaptureDeviceInput;
	QTCaptureDecompressedVideoOutput *mCaptureDecompressedVideoOutput;
	CVImageBufferRef mCurrentImageBuffer;
}

@property (retain) QTCaptureSession *mCaptureSession;

- (NSData *)takePictureWithFileType:(NSBitmapImageFileType)type quality:(NSNumber *)qual;

@end
