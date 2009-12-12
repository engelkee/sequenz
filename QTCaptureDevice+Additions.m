//
//  QTCaptureDevice+Additions.m
//  Sequenz
//
//  Created by Dominik Gwosdek on 10.12.09.
//  Copyright 2009 Dominik Gwosdek. All rights reserved.
//

#import "QTCaptureDevice+Additions.h"


@implementation QTCaptureDevice (SQAdditions)

- (BOOL)isSuspended {
	return [[self attributeForKey:QTCaptureDeviceSuspendedAttribute] boolValue];
}

+ (BOOL)hasCamerasAvailable {
	int count = [[QTCaptureDevice inputDevicesWithMediaType:QTMediaTypeVideo] count];
	return (count > 0);
}

@end
