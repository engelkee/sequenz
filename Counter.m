//
//  Counter.m
//  Sequenz
//
//  Created by Dominik Gwosdek on 07.01.10.
//  Copyright 2010 Dominik Gwosdek. All rights reserved.
//

#import "Counter.h"


@implementation Counter

@synthesize count;

- (id)init {
	self = [super init];
	if (self != nil) {
		[self initWithValue:0];
	}
	return self;
}

- (id)initWithValue:(int)value {
	count = value;
}


- (void)dealloc {
	[super dealloc];
}

- (void)reset {
	count = 0;
}

- (void)increment {
	count++;
}

@end
