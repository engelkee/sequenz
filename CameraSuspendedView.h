//
//  CameraSuspendedView.h
//  Sequenz
//
//  Created by Dominik Gwosdek on 26.11.09.
//  Copyright 2009 Dominik Gwosdek. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CameraSuspendedView : NSView {
	NSString *attrString;
	NSMutableDictionary *attrDict;
}

@property (retain) NSString *attrString;

@end
