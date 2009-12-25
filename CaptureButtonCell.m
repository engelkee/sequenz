//
//  CaptureButtonCell.m
//  Sequenz
//
//  Created by Dominik Gwosdek on 17.12.09.
//  Copyright 2009 Dominik Gwosdek. All rights reserved.
//

#import "CaptureButtonCell.h"


@implementation CaptureButtonCell

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	NSString *imageName = nil;

	if ([self state] == NSOffState && [self isEnabled]) {
		imageName = @"media-record_sw";
	}
	if ([self state] == NSOnState && [self isEnabled]) {
		imageName = @"media-record";
	} 
	if (![self isEnabled]) {
		imageName = @"media-record_disabled";
	}
	if ([self isHighlighted]) {
#ifndef NDEBUG
		NSLog(@"button highlighted");
#endif
		imageName = @"media-record_pressed";
	}

	
	NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:imageName ofType:@"png"];
#ifndef NDEBUG
	NSLog(@"button path: %@", filePath);
#endif
	NSImage *image = [[[NSImage alloc] initByReferencingFile:filePath] autorelease];
	[image setFlipped:YES];
	[image drawInRect:cellFrame fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
}

@end
