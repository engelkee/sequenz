//
//  FTPController.h
//  Sequenz
//
//  Created by Dominik Gwosdek on 09.11.09.
//  Copyright 2009 Dominik Gwosdek. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSObject (FTPController)

- (void)uploadDidFinish;
- (void)uploadDidNotFinishWithError:(NSError *)error;

@end

@interface FTPController : NSObject {
	BOOL usePassiveMode;
	CFWriteStreamRef writeStream;
	id delegate;
}

- (BOOL)uploadData:(NSData	*)data toURL:(NSURL *)url;

@property BOOL usePassiveMode;
@property CFWriteStreamRef writeStream;
@property(assign) id delegate;

@end
