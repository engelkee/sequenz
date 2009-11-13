//
//  URLFormatter.m
//  Sequenz
//
//  Created by Dominik Gwosdek on 11.11.09.
//  Copyright 2009 Dominik Gwosdek. All rights reserved.
//

#import "URLFormatter.h"


@implementation URLFormatter

- (NSString *)stringForObjectValue:(id)anObject {
	return [anObject description];
}

- (BOOL)getObjectValue:(id *)anObject forString:(NSString *)string errorDescription:(NSString **)error {
	NSString *err = nil;
	*anObject = nil;
	if ([string length] == 0) {
	} else {
		NSURL *url = [NSURL	URLWithString:string];
		NSString *scheme = [url scheme];
		if( url && scheme == nil ) {
			if( [string rangeOfString: @"."].length > 0 ) {
				string = [@"ftp://" stringByAppendingString: string];
				url = [NSURL URLWithString: string];
				scheme = [url scheme];
			} else {
				url = nil;
			}
		}
		if(!url || url.host.length == 0) {
			err = @"Invalid URL";
		}
		*anObject = [url absoluteString];
	}
	if( error ) *error = err;
	return (err == nil);
}

@end
