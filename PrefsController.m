//
//  PrefsController.m
//  Sequenz
//
//  Created by Dominik Gwosdek on 05.11.09.
//  Copyright 2009 Dominik Gwosdek. All rights reserved.
//

#import "PrefsController.h"

@implementation PrefsController

- (id)init {
	self = [super initWithWindowNibName:@"Prefs"];
	if (self != nil) {
		NSLog(@"Init PrefsController");
	}
	return self;
}

- (void)awakeFromNib {
	NSLog(@"awake");
	//[self setPrefsView:nil];
}
/*
- (IBAction)setPrefsView:(id)sender {
	NSString * identifier;
    if (sender)
    {
        identifier = [sender itemIdentifier];
        //[[NSUserDefaults standardUserDefaults] setObject: identifier forKey: @"SelectedPrefView"];
    }
    else
        //identifier = [[NSUserDefaults standardUserDefaults] stringForKey: @"SelectedPrefView"];
		identifier = @"Image";
		
	NSLog(@"Identifier: %@", identifier);
    
    NSView *view;
    if ([identifier isEqualToString: @"Image"])
        view = imagePrefView;
    else if ([identifier isEqualToString: @"Upload"])
        view = uploadPrefView;
    else
    {
        identifier = @"Image"; //general view is the default selected
        view = imagePrefView;
    }
    
	
    [[[self window] toolbar] setSelectedItemIdentifier: identifier];

	NSWindow *window = [self window];
    NSRect windowRect = [window frame];
    float difference = ([view frame].size.height - [[window contentView] frame].size.height) * [window userSpaceScaleFactor];
    windowRect.origin.y -= difference;
    windowRect.size.height += difference;
	float dx = ([view frame].size.width - [[window contentView] frame].size.width) * [window userSpaceScaleFactor];
    //windowRect.origin.x -= dx;
    windowRect.size.width += dx;
    
	[view setHidden:YES];
    [window setContentView:view];
	[window setFrame: windowRect display: YES animate: YES];
	[view setHidden:NO];

	//set title label
	
    if (sender) {
		NSLog(@"Label: %@", [sender label]);
        [window setTitle: [sender label]];
	} else
    {
        NSToolbar * toolbar = [window toolbar];
        NSString * itemIdentifier = [toolbar selectedItemIdentifier];
        for (NSToolbarItem * item in [toolbar items])
            if ([[item itemIdentifier] isEqualToString: itemIdentifier])
            {
                [window setTitle: [item label]];
                break;
            }
    }
	NSLog(@"bis hier");
	 
}
*/

@end
