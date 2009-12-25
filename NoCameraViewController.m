//
//  NoCameraViewController.m
//  Sequenz
//
//  Created by Dominik Gwosdek on 15.12.09.
//  Copyright 2009 Dominik Gwosdek. All rights reserved.
//

#import "NoCameraViewController.h"
#import "CameraSuspendedView.h"

@implementation NoCameraViewController

- (void)loadView {
	[super loadView];
	[(CameraSuspendedView *)[self view] setAttrString:NSLocalizedString(@"No camera available", @"no camera status string")];
}
	
@end
