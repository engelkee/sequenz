//
//  ShadowBox.m
//  Sequenz
//
//  Created by Dominik Gwosdek on 23.11.09.
//  Copyright 2009 Dominik Gwosdek. All rights reserved.
//

#import "ShadowBox.h"


@implementation ShadowBox

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
	/*
	[[NSColor windowBackgroundColor] set];
	NSRectFill(dirtyRect);
	
	
	
	[NSGraphicsContext saveGraphicsState];
	
	NSBezierPath *path = [NSBezierPath bezierPathWithRect:[self bounds]];
	[path setLineWidth:1.0];
	
	// Create the shadow below and to the right of the shape.
	NSShadow* theShadow = [[NSShadow alloc] init];
	[theShadow setShadowOffset:NSMakeSize(-5.0, 5.0)];
	[theShadow setShadowBlurRadius:1.5];
	
	// Use a partially transparent color for shapes that overlap.
	[theShadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:0.6]];
	
	//[theShadow set];
	
	[[NSColor controlShadowColor] set];
	[path stroke];
	
	// Draw your custom content here. Anything you draw
	// automatically has the shadow effect applied to it.
	
	[NSGraphicsContext restoreGraphicsState];
	[theShadow release];
	*/
	
}

@end
