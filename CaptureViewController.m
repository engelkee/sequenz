//
//  CaptureViewController.m
//  Sequenz
//
//  Created by Dominik Gwosdek on 16.12.09.
//  Copyright 2009 Dominik Gwosdek. All rights reserved.
//

#import "CaptureViewController.h"


@implementation CaptureViewController

@synthesize backgroundImage;

- (void)dealloc
{
	[backgroundImage release];
	backgroundImage = nil;

	[super dealloc];
}

- (void)awakeFromNib {
	[(QTCaptureView *)[self view] setDelegate:self];
}

- (CIImage *)view:(QTCaptureView *)view willDisplayImage:(CIImage *)image {
	
	NSAffineTransform* flipTransform = [NSAffineTransform transform];
	CIFilter* flipFilter;
	CIImage* flippedImage;
	[flipTransform scaleXBy:-1.0 yBy:1.0]; //horizontal flip
	flipFilter = [CIFilter filterWithName:@"CIAffineTransform"];
	[flipFilter setValue:flipTransform forKey:@"inputTransform"];
	[flipFilter setValue:image forKey:@"inputImage"];
	flippedImage = [flipFilter valueForKey:@"outputImage"];
	
	return flippedImage;

	/* Motion Detection stuff
	if (backgroundImage == nil) {
		[self setBackgroundImage:[self bwImage:image]];
	}
	CIImage *bwImage = [self bwImage:image];
	
	CIImage *newImage = [self whitePixelsFromImage:bwImage bgImage:[self backgroundImage]];
	
	[self setBackgroundImage:bwImage];
	
	return newImage;
	 */
}

/*
- (CIImage *)whitePixelsFromImage:(CIImage *)image bgImage:(CIImage *)bg {
	CIFilter *bgFilter = [CIFilter filterWithName:@"CIDifferenceBlendMode"];
	[bgFilter setDefaults];
	
	[bgFilter setValue:bg forKey:@"inputBackgroundImage"];
	[bgFilter setValue:image forKey:@"inputImage"];
	return [bgFilter valueForKey:@"outputImage"];
}
	 
- (CIImage *)bwImage:(CIImage *)input {
	CIFilter *monoFilter = [CIFilter filterWithName:@"CIMaximumComponent"];
	[monoFilter setDefaults];
	CIFilter *smoothFilter = [CIFilter filterWithName:@"CINoiseReduction"];
	[smoothFilter setValue:[NSNumber numberWithFloat:0.5] forKey:@"inputNoiseLevel"];
	
	[monoFilter setValue:input forKey:@"inputImage"];
	[smoothFilter setValue:[monoFilter valueForKey:@"outputImage"] forKey:@"inputImage"];
	return [smoothFilter valueForKey:@"outputImage"];
}
*/

@end
