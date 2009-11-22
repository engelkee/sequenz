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
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
}

- (IBAction)toggleCollapsed:(id)sender {
	//NSWindow *window = [sender window];
    NSRect frame = [self frame];
    // The extra +14 accounts for the space between the box and its neighboring views
    CGFloat sizeChange = [box frame].size.height;
    switch ([sender state]) {
        case NSOnState:
            // Show the extra box.
            [box setHidden:NO];
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
            [box setHidden:YES];
            break;
        default:
            break;
    }
    [self setFrame:frame];
}

@end
