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
NSString *SQSaveSequenceFlag = @"SQSaveSequenceFlag";
NSString *SQSequenceNumber = @"SQSequenceNumber";
NSString *SQSaveToDiskFlag = @"SQSaveToDiskFlag";
NSString *SQSaveToDiskPath = @"SQSaveToDiskPath";

@implementation PrefsController

- (id)init {
	self = [super initWithWindowNibName:@"Prefs"];
	if (self != nil) {
		userDefaults = [NSUserDefaults standardUserDefaults];
	}
	return self;
}

- (void)awakeFromNib {
	[[NSFontPanel sharedFontPanel] setPanelFont:[NSKeyedUnarchiver unarchiveObjectWithData:[userDefaults objectForKey:SQTimestampFont]] isMultiple:NO];
}

- (void)windowDidLoad {
	NSFont *font = [NSKeyedUnarchiver unarchiveObjectWithData:[userDefaults objectForKey:SQTimestampFont]];
	[fontExample setTextColor:[NSKeyedUnarchiver unarchiveObjectWithData:[userDefaults objectForKey:SQTimestampColor]]];
	[fontExample setFont:font];
	[fontExample setStringValue:[NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterFullStyle]];
	[[NSColorPanel sharedColorPanel] setColor:[NSKeyedUnarchiver unarchiveObjectWithData:[userDefaults objectForKey:SQTimestampColor]]];
}
	 
- (void)changeFont:(id)sender {
	//NSFont *oldFont = [fontExample font];
    NSFont *newFont = [sender convertFont:[NSKeyedUnarchiver unarchiveObjectWithData:[userDefaults objectForKey:SQTimestampFont]]];
	[userDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:newFont] forKey:SQTimestampFont];
    [fontExample setFont:newFont];
	[fontExample setTextColor:[NSKeyedUnarchiver unarchiveObjectWithData:[userDefaults objectForKey:SQTimestampColor]]];
}

- (void)changeColor:(id)sender {
	//NSLog(@"changeColor called");
}

- (void)changeAttributes:(id)sender {
	NSColor *newColor = [[NSColorPanel sharedColorPanel] color];
	[userDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:newColor] forKey:SQTimestampColor];
	//NSLog(@"new color: %@", newColor);
	[fontExample setTextColor:[NSKeyedUnarchiver unarchiveObjectWithData:[userDefaults objectForKey:SQTimestampColor]]];
	
}

- (IBAction)chooseSaveFolder:(id)sender {
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setCanCreateDirectories:YES];
	[openPanel setCanChooseFiles:NO];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
		if (result == NSOKButton) {
			[userDefaults setObject:[[[openPanel URL] path] stringByAbbreviatingWithTildeInPath] forKey:SQSaveToDiskPath];
		}
	}];
	[saveFolderPopUp selectItemAtIndex:0];
}
	 
@end
