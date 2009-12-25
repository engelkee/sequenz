//
//  SequenzAppDelegate.m
//  Sequenz
//
//  Created by Dominik Gwosdek on 03.11.09.
//  Copyright 2009 Dominik Gwosdek. All rights reserved.
//

#import "SequenzAppDelegate.h"
#import "MainWindowController.h"
#import "PrefsController.h"

@implementation SequenzAppDelegate

+ (void)initialize {
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	[defaultValues setObject:[NSNumber numberWithInt:10] forKey:SQRecordingInterval];
	[defaultValues setObject:[NSNumber numberWithInt:0] forKey:SQIntervalUnit];
	[defaultValues setObject:[NSNumber numberWithFloat:0.5] forKey:SQImageQuality];
	[defaultValues setObject:@"CaptureImage" forKey:SQImageFilename];
	[defaultValues setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSFont fontWithName:@"Times-Roman" size:12.0]] forKey:SQTimestampFont];
	[defaultValues setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSColor blackColor]] forKey:SQTimestampColor];
	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:@"SUEnableAutomaticChecks"];
	
	NSString *downloadsDirectory;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, NSUserDomainMask, YES);
	if ([paths count] > 0)  {
		downloadsDirectory = [paths objectAtIndex:0];
	}
	
	[defaultValues setObject:[downloadsDirectory stringByAbbreviatingWithTildeInPath] forKey:SQSaveToDiskPath];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	mMainWindowController = [[MainWindowController alloc] initWithWindowNibName:@"MainWindow"];
	[[mMainWindowController window] makeMainWindow];
	[[mMainWindowController window] makeKeyAndOrderFront:self];
	[cameraMenu setDelegate:mMainWindowController];
	
}

- (void)dealloc {
	[mMainWindowController release];
	[super dealloc];
}

- (IBAction)showPrefsWindow:(id)sender {
	if(!mPrefsController) {
		mPrefsController = [[PrefsController alloc] init];
	}
	NSWindow *prefWindow = [mPrefsController window];
	[prefWindow makeKeyAndOrderFront:nil];
}

- (IBAction)openWebsite:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://gwosdek.net/sequenz"]];
}

- (IBAction)openDonate:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_xclick&business=dom@gwosdek.net&item_name=Sequenz&no_shipping=1&cn=Comments&tax=0&currency_code=EUR&lc=US"]];
}
	
@end
