//
//  PrefsController.m
//  Sequenz
//
//  Created by Dominik Gwosdek on 05.11.09.
//  Copyright 2009 Dominik Gwosdek. All rights reserved.
//

#import "PrefsController.h"

NSString *SQInsertTimestampFlag = @"SQInsertTimestampFlag";
NSString *SQTimestampColor = @"SQTimestampColor";
NSString *SQTimestampFont = @"SQTimestampFont";

@implementation PrefsController

- (id)init {
	self = [super initWithWindowNibName:@"Prefs"];
	if (self != nil) {
		NSLog(@"Init PrefsController");
		userDefaults = [NSUserDefaults standardUserDefaults];
	}
	return self;
}

- (void)awakeFromNib {
	NSLog(@"awake");
	[[NSFontPanel sharedFontPanel] setPanelFont:[NSKeyedUnarchiver unarchiveObjectWithData:[userDefaults objectForKey:SQTimestampFont]] isMultiple:NO];
	//[self setPrefsView:nil];
}

- (void)windowDidLoad {
	NSFont *font = [NSKeyedUnarchiver unarchiveObjectWithData:[userDefaults objectForKey:SQTimestampFont]];
	[fontExample setTextColor:[NSKeyedUnarchiver unarchiveObjectWithData:[userDefaults objectForKey:SQTimestampColor]]];
	[fontExample setFont:font];
	[fontExample setStringValue:[[NSDate date] descriptionWithLocale:[NSLocale currentLocale]]];
	[[NSColorPanel sharedColorPanel] setColor:[NSKeyedUnarchiver unarchiveObjectWithData:[userDefaults objectForKey:SQTimestampColor]]];
}
	 
- (void)changeFont:(id)sender {
	NSLog(@"Font changed!");
	//NSFont *oldFont = [fontExample font];
    NSFont *newFont = [sender convertFont:[NSKeyedUnarchiver unarchiveObjectWithData:[userDefaults objectForKey:SQTimestampFont]]];
	[userDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:newFont] forKey:SQTimestampFont];
    [fontExample setFont:newFont];
	[fontExample setTextColor:[NSKeyedUnarchiver unarchiveObjectWithData:[userDefaults objectForKey:SQTimestampColor]]];
	NSLog(@"new font: %@", newFont);
}

- (void)changeColor:(id)sender {
	NSLog(@"changeColor called");
}

- (void)changeAttributes:(id)sender {
	NSLog(@"color: %@", [[NSColorPanel sharedColorPanel] color]);
	/*
	NSFont *oldFont = [fontExample font];
	NSFontDescriptor *fDesc	= [oldFont fontDescriptor];
	NSDictionary *oldAttr = [fDesc fontAttributes];
	*/
	//NSDictionary *oldAttr = [NSDictionary dictionaryWithObject:[fontExample textColor] forKey:@"NSColor"];
	/*
	NSAttributedString *oldString = [fontExample attributedStringValue];
	NSMutableAttributedString *newString = [oldString mutableCopy];
	NSRange range = NSMakeRange(0, [oldString length]);
	 */
	/*
	NSDictionary *oldAttributes = [[fontExample attributedStringValue] fontAttributesInRange:range];
	NSLog(@"old attributes: %@", oldAttributes);
	 */
    //NSDictionary *newAttributes = [sender convertAttributes:oldAttr];
	/*
	[newString setAttributes:newAttributes range:range];
	[fontExample setAttributedStringValue:newString];
	*/
	/*
	NSColor *newColor = [newAttributes valueForKey:@"NSColor"];
	*/
	NSColor *newColor = [[NSColorPanel sharedColorPanel] color];
	[userDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:newColor] forKey:SQTimestampColor];
	NSLog(@"new color: %@", newColor);
	[fontExample setTextColor:[NSKeyedUnarchiver unarchiveObjectWithData:[userDefaults objectForKey:SQTimestampColor]]];
	/*
	[newString release];
	 */
	
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
