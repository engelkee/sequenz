//
//  SuspendedCameraViewController.m
//  Sequenz
//
//  Created by Dominik Gwosdek on 15.12.09.
//  Copyright 2009 Dominik Gwosdek. All rights reserved.
//

#import "SuspendedCameraViewController.h"
#import "CameraSuspendedView.h"

@implementation SuspendedCameraViewController

- (void)loadView {
	[super loadView];
	[(CameraSuspendedView *)[self view] setAttrString:NSLocalizedString(@"Camera turned off", @"camera suspended status string")];
}

@end
