//
//  MiddleBarBorder.h
//  Sequenz
//
//  Created by Dominik Gwosdek on 24.11.09.
//  Copyright 2009 Dominik Gwosdek. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MiddleBarBorder : NSView {
	NSColor *startColor;
	NSColor *endColor;
	int angle;
}

@property(nonatomic, retain) NSColor *startColor;
@property(nonatomic, retain) NSColor *endColor;
@property(assign) int angle;

@end
