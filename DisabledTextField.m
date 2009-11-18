//
//  DisabledTextField.m
//  Sequenz
//
//  Created by Dominik Gwosdek on 18.11.09.
//  Copyright 2009 Dominik Gwosdek. All rights reserved.
//

#import "DisabledTextField.h"


@implementation DisabledTextField

- (void)awakeFromNib {
	[self setEnabled:[self isEnabled]];
}

- (void)setEnabled:(BOOL)flag {
	[super setEnabled:flag];
	NSColor *color = flag ? [NSColor controlTextColor] : [NSColor disabledControlTextColor];
	[self setTextColor:color];
}

@end
