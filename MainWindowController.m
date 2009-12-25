//
//  MainWindowController.m
//  Sequenz
//
//  Created by Dominik Gwosdek on 15.12.09.
//  Copyright 2009 Dominik Gwosdek. All rights reserved.
//

#import "SequenzAppDelegate.h"
#import "MainWindowController.h"
#import "FTPController.h"
#import "PrefsController.h"
#import "SideBarPaneView.h"
#import "CameraController.h"
#import "QTCaptureDevice+Additions.h"
#import "SuspendedCameraViewController.h"
#import "NoCameraViewController.h"
#import "CaptureViewController.h"

#define INTERVAL_UNIT_SEC 0
#define INTERVAL_UNIT_MIN 1
#define QUALITY_LOW 0
#define QUALITY_MID 1
#define QUALITY_HIGH 2
#define FORMAT_JPG 0
#define FORMAT_PNG 1
#define FORMAT_GIF 2

NSString *SQRecordingInterval = @"SQRecordingInterval";
NSString *SQIntervalUnit = @"SQIntervalUnit";
NSString *SQImageQuality = @"SQImageQuality";
NSString *SQImageFormat = @"SQImageFormat";
NSString *SQImageFilename = @"SQImageFilename";
NSString *SQFTPServerAddress = @"SQFTPServerAddress";
NSString *SQFTPUsername = @"SQFTPUsername";
NSString *SQFTPPath = @"SQFTPPath";

NSString *kSuspendedView = @"SuspendedView";
NSString *kNoCameraView = @"NoCameraView";
NSString *kCaptureView = @"CaptureView";


@interface MainWindowController (Private) 

- (void)repositionViewsIgnoringView:(NSView*)viewToIgnore;
- (NSRect)windowFrameForNewContentViewSize:(NSSize)newSize;
- (void)startRecording;
- (void)stopRecording;
- (void)changeViewControllers:(NSString *)title;
- (NSString *)imageWithSequence:(BOOL)yn;

@end

@implementation MainWindowController

@synthesize recEnabled;
@synthesize filenameCounter;
@synthesize camController;
@synthesize isRecording;
@synthesize isCameraOn;
@synthesize currentViewController = mCurrentViewController;

#pragma mark Initializing & Terminating

+ (NSSet *)keyPathsForValuesAffectingRecEnabled {
	return [NSSet setWithObjects:@"isCameraOn", @"userDefaults.SQSaveToDiskFlag", @"userDefaults.SQFTPServerAddress", nil];
}

- (id)initWithWindowNibName:(NSString *)windowNibName {
	self = [super initWithWindowNibName:windowNibName];
	if (self != nil) {
		userDefaults = [NSUserDefaults standardUserDefaults];
		camController = [CameraController sharedCameraController];
		ftpController = [[FTPController alloc] init];
		[ftpController setDelegate:self];
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[camController release];
	[ftpController release];
	[super dealloc];
}

- (void)awakeFromNib {
	topMargin = NSHeight([[sideBarView superview] frame]) - NSMaxY([sideBarView frame]);
	[sideBarView addSubview:recPane];
	[recPane setPostsFrameChangedNotifications:YES];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustSubview:) name:NSViewFrameDidChangeNotification object:recPane];
	[sideBarView addSubview:ftpPane];
	[recPane setPostsFrameChangedNotifications:YES];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustSubview:) name:NSViewFrameDidChangeNotification object:ftpPane];
	[self repositionViewsIgnoringView:nil];
	
	[[self window] setMovableByWindowBackground:YES];
	
	[self changeViewControllers:kCaptureView];
	
	[camController addObserver:self forKeyPath:@"cameraSuspended" options:NSKeyValueObservingOptionNew context:nil];
	[camController addObserver:self forKeyPath:@"devicesDict" options:NSKeyValueObservingOptionNew context:nil];	
	[camController addAnyCaptureDevice];
	
}

#pragma mark Private methods

- (BOOL)recEnabled {
	return [self isCameraOn] && ([userDefaults boolForKey:@"SQSaveToDiskFlag"] || [userDefaults objectForKey:@"SQFTPServerAddress"]);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
#ifndef NDEBUG
	NSLog(@"dict: %@ keypath: %@", change, keyPath);
#endif
	if ([keyPath isEqual:@"cameraSuspended"]) {
		if ([[change objectForKey:NSKeyValueChangeNewKey] isEqual:[NSNumber numberWithUnsignedInt:1]]) {
			if ([self isRecording]) {
				[self stopRecording];
			}
#ifndef NDEBUG
			NSLog(@"change to suspended mode");
#endif
			[self setIsCameraOn:NO];
			[self changeViewControllers:kSuspendedView];
		} else if ([[change objectForKey:NSKeyValueChangeNewKey] isEqual:[NSNumber numberWithUnsignedInt:0]]) {
			[self setIsCameraOn:YES];
			[self changeViewControllers:kCaptureView];
		}

	} else if ([keyPath isEqual:@"devicesDict"]) {
		if ([[object valueForKey:keyPath] count] == 0) {
			[self setIsCameraOn:NO];
			[self changeViewControllers:kNoCameraView];
		} /*else {
			[self setIsCameraOn:YES];
			[self changeViewControllers:kCaptureView];
		}*/
	}
}

- (void)changeViewControllers:(NSString *)title {
	[self willChangeValueForKey:@"viewController"];
	
	if ([[self currentViewController] view] != nil) {
		[[[self currentViewController] view] removeFromSuperview];
	}
	
	if ([self currentViewController] != nil) {
		[mCurrentViewController release];
	}
	
	if ([title isEqual:kSuspendedView]) {
		SuspendedCameraViewController *suspCamViewController = [[SuspendedCameraViewController alloc] initWithNibName:kSuspendedView bundle:nil];
		if (suspCamViewController != nil) {
			[self setCurrentViewController:suspCamViewController];
			[[self currentViewController] setTitle:title];
		}
	} else if ([title isEqual:kNoCameraView]) {
		NoCameraViewController *noCamViewController = [[NoCameraViewController alloc] initWithNibName:kNoCameraView bundle:nil];
		if (noCamViewController != nil) {
			[self setCurrentViewController:noCamViewController];
			[[self currentViewController] setTitle:title];
		}
	} else if ([title isEqual:kCaptureView]) {
		CaptureViewController *capViewController = [[CaptureViewController alloc] initWithNibName:kCaptureView bundle:nil];
		if (capViewController != nil) {
			[self setCurrentViewController:capViewController];
			[[self currentViewController] setTitle:title];
			[(QTCaptureView *)[[self currentViewController] view] setCaptureSession:[camController mCaptureSession]];
		}
	}
	
	[qtSwapView addSubview:[[self currentViewController] view]];
	[[[self currentViewController] view] setFrame:[qtSwapView bounds]];
	[[self currentViewController] setRepresentedObject:[NSNumber numberWithUnsignedInt:[[[[self currentViewController] view] subviews] count]]];
	
	[self didChangeValueForKey:@"viewController"];
}

- (void)adjustSubview:(NSNotification *)notification {
	[self repositionViewsIgnoringView:[notification object]];
}

- (void)repositionViewsIgnoringView:(NSView*)viewToIgnore {
	float top = 0.0;
	for (NSView *view in [[sideBarView subviews] objectEnumerator]) {
		NSRect newFrame = [view frame];
		newFrame.origin.y = [sideBarView frame].size.height - (newFrame.size.height + top);
		
		if (view == viewToIgnore)
			[view setPostsFrameChangedNotifications:NO];
		
		[view setFrame:newFrame];
		
		if (view == viewToIgnore)
			[view setPostsFrameChangedNotifications:YES];
		
		top += newFrame.size.height;
	}
	
	NSView *contentView = [[self window] contentView];
	NSRect newSideBarFrame = [sideBarView bounds];
	newSideBarFrame.origin.y = [contentView frame].size.height - newSideBarFrame.size.height - topMargin;
	newSideBarFrame.size.height = top;
	[sideBarView setFrame:newSideBarFrame];
	
	NSSize contentViewSize = newSideBarFrame.size;
	contentViewSize.height += topMargin;
	
	NSRect newWindowFrame = [self windowFrameForNewContentViewSize:contentViewSize];
	[[self window] setFrame:newWindowFrame display:YES];
	
	
}

- (NSRect)windowFrameForNewContentViewSize:(NSSize)newSize {
	NSRect windowFrame = [[self window] frame];
	
	windowFrame.size.width = newSize.width;
	
	float titlebarAreaHeight = windowFrame.size.height - [[[self window] contentView] frame].size.height;
	float newHeight = newSize.height + titlebarAreaHeight + 22.0;
	float heightDifference = windowFrame.size.height - newHeight;
	windowFrame.size.height = newHeight;
	windowFrame.origin.y += heightDifference;
	
	return windowFrame;
}

- (NSURL *)composedUploadURL {
	NSURL *url = [NSURL URLWithString:[serverTextField objectValue]];
	url = [url URLByAppendingPathComponent:[pathTextField stringValue]];
	url = [url URLByAppendingPathComponent:[self imageWithSequence:[userDefaults boolForKey:SQSaveSequenceFlag]]];
	/*
	url = [url URLByAppendingPathComponent:[filenameTextField stringValue]];
	NSString *extention = @"jpg";
	url = [url URLByAppendingPathExtension:extention];
	*/
	return url;
}

- (NSString *)composedSaveToDiskPath {
	NSString *path = [userDefaults objectForKey:SQSaveToDiskPath];
	path = [path stringByExpandingTildeInPath];
	path = [path stringByAppendingPathComponent:[self imageWithSequence:[userDefaults boolForKey:SQSaveSequenceFlag]]];
#ifndef NDEBUG
	NSLog(@"save path: %@", path);
#endif
	return path;
}

- (NSString *)imageWithSequence:(BOOL)yn {
	NSString *filename;
	if (yn) {
		filename = [userDefaults objectForKey:SQImageFilename];
		filename = [filename stringByAppendingString:[NSString stringWithFormat:@"%i", [self filenameCounter]]];
	} else {
		filename = [userDefaults objectForKey:SQImageFilename];
	}
	filename = [filename stringByAppendingPathExtension:@"jpg"];
	return filename;
}

- (void)resetCounter {
	[self setFilenameCounter:0];
}

- (float)convertedInterval {
	return ([intervalUnitPopUp indexOfSelectedItem] == INTERVAL_UNIT_SEC) ? [intervalTextField floatValue] : [intervalTextField floatValue] * 60;
}

- (void)startRecording {
	[self setIsRecording:YES];
	[self resetCounter];
	[startStopButton setState:NSOnState];
	sequenceTimer = [NSTimer scheduledTimerWithTimeInterval:[self convertedInterval]
													 target:self 
												   selector:@selector(capturePic:) 
												   userInfo:nil 
													repeats:YES];
}

- (void)stopRecording {
	if ([self isRecording]) {
		[sequenceTimer invalidate];
		[self setIsRecording:NO];
		[startStopButton setState:NSOffState];
	}
}

- (void)capturePic:(NSTimer *)aTimer {
#ifndef NDEBUG
	NSLog(@"#######capture pic#########");
#endif
	NSNumber *factor = [userDefaults objectForKey:SQImageQuality];
	
	NSData *imageData = [camController takePictureWithFileType:NSJPEGFileType quality:factor];
	
	if ([userDefaults boolForKey:SQSaveToDiskFlag]) {
		[imageData writeToFile:[self composedSaveToDiskPath] atomically:YES];
	}
	
	if ([userDefaults objectForKey:SQFTPServerAddress]) {
		[ftpController uploadData:imageData 
							toURL:[self composedUploadURL] 
						 username:[usernameTextField stringValue] 
						 password:[passwordTextField stringValue]];
	}
	
	filenameCounter++;
	
}

#pragma mark UI actions

- (IBAction)setInterval:(id)sender {
	[userDefaults setObject:[NSNumber numberWithInt:[sender intValue]] forKey:SQRecordingInterval];
}

- (IBAction)setIntervalUnit:(id)sender {
	[userDefaults setObject:[NSNumber numberWithInt:[sender indexOfSelectedItem]] forKey:SQIntervalUnit];
}

- (IBAction)toggleRecording:(id)sender {
	if (![self isRecording]) {
		[self startRecording];
	} else {
		[self stopRecording];
	}
}

- (void)chooseCameraFromMenu:(id)sender {
	[camController changeDevice:[sender title]];
}

#pragma mark Delegates

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
	if ([menuItem action] == @selector(toggleRecording:)) {
#ifndef NDEBUG
		NSLog(@"validateMenuItem for Record");
#endif
		return [self recEnabled] && ![self isRecording];
	} else if ([menuItem action] == @selector(chooseCameraFromMenu:)) {
		return YES;
	} else {
		return YES;
	}
}

- (void)menuNeedsUpdate:(NSMenu *)menu {
	[menu removeAllItems];
	if ([QTCaptureDevice hasCamerasAvailable]) {
		for (NSString *s in [[camController devicesDict] allKeys]) {
			NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:s action:@selector(chooseCameraFromMenu:) keyEquivalent:@""];
			if ([s isEqualToString:[[camController userDevice] localizedDisplayName]]) {
				[item setState:NSOnState];
			}
			[menu addItem:item];
			[item release];
		}
	} else {
		NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"No camera available", @"no camera status string") action:nil keyEquivalent:@""];
		[menu addItem:item];
		[item release];
	}
	
}

- (void)uploadDidFinish {
#ifndef NDEBUG
	NSLog(@"Delegate called: Upload did finish");
#endif
}

- (void)uploadDidNotFinishWithError:(NSError *)error {
	NSBeginAlertSheet(NSLocalizedString(@"A FTP error occured", @"FTP error alert sheet title"), nil, nil, nil, [self window], 
					  self, @selector(alertDidEnd:returnCode:contextInfo:), 
					  @selector(sheetDidDismiss:returnCode:contextInfo:), nil, 
					  NSLocalizedString(@"Server message: %@", @"FTP error alert sheet message text"),[error localizedDescription]);
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	[self stopRecording];
}

- (void)sheetDidDismiss:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo {
}

@end
