//
//  CaptureViewController.h
//  Sequenz
//
//  Created by Dominik Gwosdek on 16.12.09.
//  Copyright 2009 Dominik Gwosdek. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>


@interface CaptureViewController : NSViewController {
	CIImage *backgroundImage;
}

@property (nonatomic, retain) CIImage *backgroundImage;

@end
