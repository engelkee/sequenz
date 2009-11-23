//
//  SideBarPaneView.h
//  Sequenz
//
//  Created by Dominik Gwosdek on 22.11.09.
//  Copyright 2009 Dominik Gwosdek. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ShadowBox;

@interface SideBarPaneView : NSView {
	IBOutlet NSBox *box;
	IBOutlet NSButton *collapseButton;
}

- (IBAction)toggleCollapsed:(id)sender;

@end
