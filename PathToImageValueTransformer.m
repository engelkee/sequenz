//
//  PathToImageValueTransformer.m
//  Sequenz
//
//  Created by Dominik Gwosdek on 21.12.09.
//  Copyright 2009 Dominik Gwosdek. All rights reserved.
//

#import "PathToImageValueTransformer.h"


@implementation PathToImageValueTransformer

+ (Class)transformedValueClass {
	return [NSImage class];
}

+ (BOOL)allowsReverseTransformation {
	return NO;
}

- (id)transformedValue:(id)value {	
	if (value == nil) {
		return nil;
	}

	NSImage *image = [[NSWorkspace sharedWorkspace] iconForFile:[value stringByExpandingTildeInPath]];
	[image setSize:NSMakeSize(16.0, 16.0)];
	return image;
}

@end
