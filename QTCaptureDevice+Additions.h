//
//  QTCaptureDevice+Additions.h
//  Sequenz
//
//  Created by Dominik Gwosdek on 10.12.09.
//  Copyright 2009 Dominik Gwosdek. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>


@interface QTCaptureDevice (SQAdditions)

+ (BOOL)hasCamerasAvailable;
@property (readonly) BOOL isSuspended;

@end
