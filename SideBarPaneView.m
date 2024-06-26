//
//  SideBarPaneView.m
//  Sequenz
//
//  Created by Dominik Gwosdek on 22.11.09.
//  Copyright 2009 Dominik Gwosdek. All rights reserved.
//

#import "SideBarPaneView.h"


@implementation SideBarPaneView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
	/*
	NSRect rect = [self bounds];
	NSBezierPath *path = [NSBezierPath bezierPath];
	[path moveToPoint:NSMakePoint(rect.origin.x, rect.origin.y + rect.size.height)];
	[path lineToPoint:NSMakePoint(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height)];
	[path setLineWidth:1.0];
	[[NSColor colorWithCalibratedWhite:0.18 alpha:1.0] set];
	[path stroke];
	 */
}

- (BOOL)mouseDownCanMoveWindow {
	return NO;
}

- (IBAction)toggleCollapsed:(id)sender {
    NSRect frame = [self frame];
    // The extra +14 accounts for the space between the box and its neighboring views
    CGFloat sizeChange = [box frame].size.height + 14;
    switch ([sender state]) {
        case NSOnState:
            // Show the extra box.
            //[box setHidden:NO];
            // Make the window bigger.
            frame.size.height += sizeChange;
            // Move the origin.
            frame.origin.y -= sizeChange;
            break;
        case NSOffState:
            // Make the window smaller.
            frame.size.height -= sizeChange;
            // Move the origin.
            frame.origin.y += sizeChange;
			// Hide the extra box.
            //[box setHidden:YES];
            break;
        default:
            break;
    }
    [[self animator] setFrame:frame];
	//[self setFrame:frame];
}

@end
