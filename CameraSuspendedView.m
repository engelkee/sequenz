//
//  CameraSuspendedView.m
//  Sequenz
//
//  Created by Dominik Gwosdek on 26.11.09.
//  Copyright 2009 Dominik Gwosdek. All rights reserved.
//

#import "CameraSuspendedView.h"


@implementation CameraSuspendedView

@synthesize attrString, attrDict;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        attrDict = [[NSMutableDictionary alloc] init];
		[attrDict setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
		[attrDict setObject:[NSFont fontWithName:@"Lucida Grande" size:13] forKey:NSFontAttributeName];
		[self setAttrString:NSLocalizedString(@"Camera turned off", @"camera suspended status string")];
    }
    return self;
}

- (void)dealloc {
	[attrString release];
	[attrDict release];
	[super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect {
    NSRect bounds = [self bounds];
	[[NSColor colorWithCalibratedWhite:0.0 alpha:1.0] set];
	[NSBezierPath fillRect:bounds];
	NSPoint stringOrigin;
	NSSize stringSize;
	
	stringSize = [attrString sizeWithAttributes:attrDict];
	stringOrigin.x = bounds.origin.x + (bounds.size.width - stringSize.width)/2;
	stringOrigin.y = bounds.origin.y + (bounds.size.height - stringSize.height)/2;
	[attrString drawAtPoint:stringOrigin withAttributes:attrDict];
}

@end
