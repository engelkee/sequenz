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
        [self setStartColor:[NSColor colorWithCalibratedRed:0.81 green:0.81 blue:0.81 alpha:1.0]];
		[self setEndColor:[NSColor colorWithCalibratedRed:0.65 green:0.65 blue:0.65 alpha:1.0]];
		[self setAngle:270];
    }
    return self;
}

- (void)awakeFromNib {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeGradient:) name:NSWindowDidResignKeyNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeGradient:) name:NSWindowDidBecomeKeyNotification object:nil];
}

- (void)changeGradient:(NSNotification *)notification {

	if ([[notification name] isEqualToString:NSWindowDidResignKeyNotification]) {
		[self setStartColor:[NSColor colorWithCalibratedRed:0.93 green:0.93 blue:0.93 alpha:1.0]];
		[self setEndColor:[NSColor colorWithCalibratedRed:0.85 green:0.85 blue:0.85 alpha:1.0]];
		NSLog(@"NSWindowDidResignKeyNotification");
	} else {
		[self setStartColor:[NSColor colorWithCalibratedRed:0.81 green:0.81 blue:0.81 alpha:1.0]];
		[self setEndColor:[NSColor colorWithCalibratedRed:0.65 green:0.65 blue:0.65 alpha:1.0]];
	}
	[self setNeedsDisplay:YES];
}

- (BOOL)mouseDownCanMoveWindow {
	return YES;
}

- (BOOL)isFlipped {
	return NO;
}

- (void)drawRect:(NSRect)dirtyRect {
    NSRect rect = [self bounds];
	NSRect fillRect = NSMakeRect(rect.origin.x, rect.origin.y + 1.0, rect.size.width, rect.size.height - 3.0);
	
	NSBezierPath *path = [NSBezierPath bezierPath];

	[[NSColor colorWithCalibratedRed:0.32 green:0.32 blue:0.32 alpha:1.0] set];
	[path moveToPoint:NSMakePoint(rect.origin.x, rect.origin.y + rect.size.height)];
	[path lineToPoint:NSMakePoint(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height)];

	[path moveToPoint:NSMakePoint(rect.origin.x, rect.origin.y)];
	[path lineToPoint:NSMakePoint(rect.origin.x + rect.size.width, rect.origin.y)];
	[path closePath];
	[path stroke];
	
	[path removeAllPoints];
	[path moveToPoint:NSMakePoint(rect.origin.x, rect.origin.y + (rect.size.height - 1.0))];
	[path lineToPoint:NSMakePoint(rect.origin.x + rect.size.width, rect.origin.y + (rect.size.height - 1.0))];
	[[NSColor colorWithCalibratedRed:0.87 green:0.87 blue:0.87 alpha:1.0] set];
	[path closePath];
	[path stroke];
	
	NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:startColor endingColor:endColor];
	[gradient drawInRect:fillRect angle:angle];
	[gradient release];
	
}

@end
