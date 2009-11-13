//
//  FTPController.h
//  Sequenz
//
//  Created by Dominik Gwosdek on 09.11.09.
//  Copyright 2009 Dominik Gwosdek. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <curl/curl.h>

@interface NSObject (FTPController)

- (void)uploadDidFinish;
- (void)uploadDidNotFinishWithError:(NSError *)error;

@end

@interface FTPController : NSObject {
	BOOL usePassiveMode;
	id delegate;
}

- (BOOL)uploadData:(NSData	*)data toURL:(NSURL *)url username:(NSString *)user password:(NSString *)pass;

@property BOOL usePassiveMode;
@property(assign) id delegate;

@end
