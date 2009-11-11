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
	if (![anObject isKindOfClass:[NSURL class]]) {
		return @"";
	} else {
		return [anObject absoluteString];
	}

}

- (BOOL)getObjectValue:(id *)anObject forString:(NSString *)string errorDescription:(NSString **)error {
	NSURL *url = [NSURL	URLWithString:string];
	NSString *scheme = [url scheme];
	NSString *err = nil;
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
		if (error != NULL) {
			*error = err;
		}
	}
	*anObject = url;
	return (err == nil);
}

@end
