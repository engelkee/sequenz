//
//  MiddleBarBorder.m
//  Sequenz
//
//  Created by Dominik Gwosdek on 24.11.09.
//  Copyright 2009 Dominik Gwosdek. All rights reserved.
//

#import "MiddleBarBorder.h"


@implementation MiddleBarBorder

@synthesize startColor;
@synthesize endColor;
@synthesize angle;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setStartColor:[NSColor colorWithCalibratedWhite:0.81 alpha:1.0]];
		[self setEndColor:[NSColor colorWithCalibratedWhite:0.65 alpha:1.0]];
		[self setAngle:270];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    NSRect rect = [self bounds];
	NSRect fillRect = NSMakeRect(rect.origin.x, rect.origin.y + 1.0, rect.size.width, rect.size.height - 3.0);
	
	NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:startColor endingColor:endColor];
	[gradient drawInRect:fillRect angle:angle];
	[gradient release];
	
	NSBezierPath *path = [NSBezierPath bezierPath];
	[path setLineWidth:1.0];
	[path moveToPoint:NSMakePoint(rect.origin.x, rect.origin.y + rect.size.height)];
	[path lineToPoint:NSMakePoint(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height)];
	[[NSColor colorWithCalibratedRed:0.22 green:0.22 blue:0.22 alpha:1.0] set];
	//[[NSColor blueColor] set];
	[path stroke];
	
	
	[path removeAllPoints];
	[path moveToPoint:NSMakePoint(rect.origin.x, rect.origin.y)];
	[path lineToPoint:NSMakePoint(rect.origin.x + rect.size.width, rect.origin.y)];
	[[NSColor colorWithCalibratedRed:0.22 green:0.22 blue:0.22 alpha:1.0] set];
	//[[NSColor disabledControlTextColor] set];
	[path stroke];
	
	[path removeAllPoints];
	[path moveToPoint:NSMakePoint(rect.origin.x, (rect.origin.y + rect.size.height) - 1.0)];
	[path lineToPoint:NSMakePoint(rect.origin.x + rect.size.width, (rect.origin.y + rect.size.height) - 1.0)];
	[[NSColor colorWithCalibratedRed:0.87 green:0.87 blue:0.87 alpha:1.0] set];
	//[[NSColor redColor] set];
	[path stroke];
	
}

@end
