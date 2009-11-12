//
//  FTPController.m
//  Sequenz
//
//  Created by Dominik Gwosdek on 09.11.09.
//  Copyright 2009 Dominik Gwosdek. All rights reserved.
//

#import "FTPController.h" 

@implementation FTPController

@synthesize usePassiveMode, delegate;


- (BOOL)uploadData:(NSData	*)data toURL:(NSURL *)url username:(NSString *)user password:(NSString *)pass {

}

- (void)completeUpload {
	if (delegate != nil && [delegate respondsToSelector:@selector(uploadDidFinish)]) {
		[delegate uploadDidFinish];
	}
}

- (void)uploadError:(NSError *)error {
	if (delegate != nil && [delegate respondsToSelector:@selector(uploadDidNotFinishWithError:)]) {
		[delegate uploadDidNotFinishWithError:error];
	}	
}

@end
