//
//  Counter.h
//  Sequenz
//
//  Created by Dominik Gwosdek on 07.01.10.
//  Copyright 2010 Dominik Gwosdek. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Counter : NSObject {
	int count;
}

@property (nonatomic, assign, readonly) int count;

- (id)initWithValue:(int)value;
- (void)reset;
- (void)increment;

@end
