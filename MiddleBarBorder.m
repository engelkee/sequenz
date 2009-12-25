//
//  MiddleBarBorder.m
//  Sequenz
//
//  Created by Dominik Gwosdek on 24.11.09.
//  Copyright 2009 Dominik Gwosdek. All rights reserved.
//

#import "MiddleBarBorder.h"


@implementation MiddleBarBorder

@synthesize becomeKeyStartColor;
@synthesize becomeKeyEndColor;
@synthesize resignKeyStartColor;
@synthesize resignKeyEndColor;
@synthesize startColor;
@synthesize endColor;
@synthesize angle;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		[self setBecomeKeyStartColor:[NSColor colorWithCalibratedWhite:0.765 alpha:1.0]];
		[self setBecomeKeyEndColor:[NSColor colorWithCalibratedWhite:0.588 alpha:1.0]];
		[self setResignKeyStartColor:[NSColor colorWithCalibratedRed:0.93 green:0.93 blue:0.93 alpha:1.0]];
		[self setResignKeyEndColor:[NSColor colorWithCalibratedRed:0.85 green:0.85 blue:0.85 alpha:1.0]];
		[self setAngle:270];
    }
    return self;
}

- (void)awakeFromNib {
	[self setStartColor:becomeKeyStartColor];
	[self setEndColor:becomeKeyEndColor];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeGradient:) name:NSWindowDidResignKeyNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeGradient:) name:NSWindowDidBecomeKeyNotification object:nil];
}

- (void)changeGradient:(NSNotification *)notification {
	if ([[notification name] isEqualToString:NSWindowDidResignKeyNotification]) {
		[self setStartColor:resignKeyStartColor];
		[self setEndColor:resignKeyEndColor];
	} else if ([[notification name] isEqualToString:NSWindowDidBecomeKeyNotification]) {
		[self setStartColor:becomeKeyStartColor];
		[self setEndColor:becomeKeyEndColor];
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

	//[[NSColor colorWithCalibratedRed:0.32 green:0.32 blue:0.32 alpha:1.0] set];
	[[NSColor colorWithCalibratedWhite:0.251 alpha:1.0] set];
	[path moveToPoint:NSMakePoint(rect.origin.x, rect.origin.y + rect.size.height)];
	[path lineToPoint:NSMakePoint(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height)];

	[path moveToPoint:NSMakePoint(rect.origin.x, rect.origin.y)];
	[path lineToPoint:NSMakePoint(rect.origin.x + rect.size.width, rect.origin.y)];
	[path closePath];
	[path stroke];
	
	[path removeAllPoints];
	[path moveToPoint:NSMakePoint(rect.origin.x, rect.origin.y + (rect.size.height - 1.0))];
	[path lineToPoint:NSMakePoint(rect.origin.x + rect.size.width, rect.origin.y + (rect.size.height - 1.0))];
	//[[NSColor colorWithCalibratedRed:0.87 green:0.87 blue:0.87 alpha:1.0] set];
	[[NSColor colorWithCalibratedWhite:0.859 alpha:1.0] set];
	[path closePath];
	[path stroke];
	
	NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:startColor endingColor:endColor];
	[gradient drawInRect:fillRect angle:angle];
	[gradient release];
	
}

@end
