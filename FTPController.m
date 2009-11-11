//
//  FTPController.m
//  Sequenz
//
//  Created by Dominik Gwosdek on 09.11.09.
//  Copyright 2009 Dominik Gwosdek. All rights reserved.
//

#import "FTPController.h"

#define kMyBufferSize  32768

@implementation FTPController

@synthesize usePassiveMode, delegate;

typedef struct MyStreamInfo {
	
    CFWriteStreamRef  writeStream;
    CFReadStreamRef   readStream;
    CFDictionaryRef   proxyDict;
    SInt64            fileSize;
    UInt32            totalBytesWritten;
    UInt32            leftOverByteCount;
    UInt8             buffer[kMyBufferSize];
	
} MyStreamInfo;

static const CFOptionFlags kNetworkEvents = 
kCFStreamEventOpenCompleted
| kCFStreamEventHasBytesAvailable
| kCFStreamEventEndEncountered
| kCFStreamEventCanAcceptBytes
| kCFStreamEventErrorOccurred;

/* MyStreamInfoCreate creates a MyStreamInfo 'object' with the specified read and write stream. */
static void
MyStreamInfoCreate(MyStreamInfo ** info, CFReadStreamRef readStream, CFWriteStreamRef writeStream)
{
    MyStreamInfo * streamInfo;
	
    assert(info != NULL);
    assert(readStream != NULL);
    // writeStream may be NULL (this is the case for the directory list operation)
    
    streamInfo = malloc(sizeof(MyStreamInfo));
    assert(streamInfo != NULL);
    
    streamInfo->readStream        = readStream;
    streamInfo->writeStream       = writeStream;
    streamInfo->proxyDict         = NULL;           // see discussion of <rdar://problem/3745574> below
    streamInfo->fileSize          = 0;
    streamInfo->totalBytesWritten = 0;
    streamInfo->leftOverByteCount = 0;
	
    *info = streamInfo;
}


/* MyStreamInfoDestroy destroys a MyStreamInfo 'object', cleaning up any resources that it owns. */                                       
static void
MyStreamInfoDestroy(MyStreamInfo * info)
{
    assert(info != NULL);
    
    if (info->readStream) {
        CFReadStreamUnscheduleFromRunLoop(info->readStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
        (void) CFReadStreamSetClient(info->readStream, kCFStreamEventNone, NULL, NULL);
        
        /* CFReadStreamClose terminates the stream. */
        CFReadStreamClose(info->readStream);
        CFRelease(info->readStream);
    }
	
    if (info->writeStream) {
        CFWriteStreamUnscheduleFromRunLoop(info->writeStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
        (void) CFWriteStreamSetClient(info->writeStream, kCFStreamEventNone, NULL, NULL);
        
        /* CFWriteStreamClose terminates the stream. */
        CFWriteStreamClose(info->writeStream);
        CFRelease(info->writeStream);
    }
	
    if (info->proxyDict) {
        CFRelease(info->proxyDict);             // see discussion of <rdar://problem/3745574> below
    }
    
    free(info);
}

/* MyUploadCallBack is the stream callback for the CFFTPStream during an upload operation. 
 Its main purpose is to wait for space to become available in the FTP stream (the write stream), 
 and then read bytes from the file stream (the read stream) and write them to the FTP stream. */
static void
MyUploadCallBack(CFWriteStreamRef writeStream, CFStreamEventType type, void * clientCallBackInfo)
{
    MyStreamInfo     *info = (MyStreamInfo *)clientCallBackInfo;
    CFIndex          bytesRead = 0;
    CFIndex          bytesAvailable = 0;
    CFIndex			bytesWritten = 0;
    CFErrorRef		error;
    
    assert(writeStream != NULL);
    assert(info        != NULL);
    assert(info->writeStream == writeStream);
	
    switch (type) {
			
        case kCFStreamEventOpenCompleted:
            fprintf(stderr, "Open complete\n");
            break;
        case kCFStreamEventCanAcceptBytes:
			
            /* The first thing we do is check to see if there's some leftover data that we read
			 in a previous callback, which we were unable to upload for whatever reason. */
            if (info->leftOverByteCount > 0) {
                bytesRead = 0;
                bytesAvailable = info->leftOverByteCount;
            } else {
                /* If not, we try to read some more data from the file.  CFReadStreamRead will 
				 return the number of bytes read, or -1 if an error occurs preventing 
				 any bytes from being read, or 0 if the stream's end was encountered. */
                bytesRead = CFReadStreamRead(info->readStream, info->buffer, kMyBufferSize);
                if (bytesRead < 0) {
                    fprintf(stderr, "CFReadStreamRead returned %ld\n", bytesRead);
                    goto exit;
                }
                bytesAvailable = bytesRead;
            }
            bytesWritten = 0;
            
            if (bytesAvailable == 0) {
                /* We've hit the end of the file being uploaded.  Shut everything down. 
				 Previous versions of this sample would terminate the upload stream 
				 by writing zero bytes to the stream.  After discussions with CF engineering, 
				 we've decided that it's better to terminate the upload stream by just 
				 closing the stream. */
                fprintf(stderr, "\nEnd up uploaded file; closing down\n");
                goto exit;
            } else {
				
                /* CFWriteStreamWrite returns the number of bytes successfully written, -1 if an error has
				 occurred, or 0 if the stream has been filled to capacity (for fixed-length streams).
				 If the stream is not full, this call will block until at least one byte is written. 
				 However, as we're in the kCFStreamEventCanAcceptBytes callback, we know that at least 
				 one byte can be written, so we won't block. */
				
                bytesWritten = CFWriteStreamWrite(info->writeStream, info->buffer, bytesAvailable);
                if (bytesWritten > 0) {
					
                    info->totalBytesWritten += bytesWritten;
                    
                    /* If we couldn't upload all the data that we read, we temporarily store the data in our MyStreamInfo
					 context until our CFWriteStream callback is called again with a kCFStreamEventCanAcceptBytes event. 
					 Copying the data down inside the buffer is not the most efficient approach, but it makes the code 
					 significantly easier. */
                    if (bytesWritten < bytesAvailable) {
                        info->leftOverByteCount = bytesAvailable - bytesWritten;
                        memmove(info->buffer, info->buffer + bytesWritten, info->leftOverByteCount);
                    } else {
                        info->leftOverByteCount = 0;
                    }
                } else if (bytesWritten < 0) {
                    fprintf(stderr, "CFWriteStreamWrite returned %ld\n", bytesWritten);
                    /* If CFWriteStreamWrite failed, the write stream is dead.  We will clean up 
					 when we get kCFStreamEventErrorOccurred. */
                }
            }
            
            /* Print a status update if we made any forward progress. */
            if ( (bytesRead > 0) || (bytesWritten > 0) ) {
                fprintf(stderr, "\rRead %7ld bytes; Wrote %8ld bytes", bytesRead, info->totalBytesWritten);
            }
            break;
        case kCFStreamEventErrorOccurred:
            error = CFWriteStreamCopyError(info->writeStream);
            fprintf(stderr, "CFWriteStreamCopyError returned ( %ld )\n", CFErrorGetCode(error));
            goto exit;
        case kCFStreamEventEndEncountered:
            fprintf(stderr, "\nUpload complete\n");
            goto exit;
        default:
            fprintf(stderr, "Received unexpected CFStream event (%d)", type);
            break;
    }
    return;
    
exit:
    MyStreamInfoDestroy(info);
    CFRunLoopStop(CFRunLoopGetCurrent());
    return;
}



/* MySimpleUpload implements the upload command.  It sets up a MyStreamInfo 'object' 
 with the read stream being a file stream of the file to upload and the write stream being 
 an FTP stream of the destination file.  It then returns, and the real work happens 
 asynchronously in the runloop.  The function returns true if the stream setup succeeded, 
 and false if it failed. */
static Boolean
MySimpleUpload(CFStringRef uploadDirectory, const UInt8 *bytes, CFIndex length, CFStringRef username, CFStringRef password)
{
    CFWriteStreamRef       writeStream;
    CFReadStreamRef        readStream;
    CFStreamClientContext  context = { 0, NULL, NULL, NULL, NULL };
    CFURLRef               uploadURL, destinationURL;
    CFStringRef            fileName;
    Boolean                success = true;
    MyStreamInfo           *streamInfo;
	
    assert(uploadDirectory != NULL);
    //assert(fileURL != NULL);
    assert( (username != NULL) || (password == NULL) );
    
    /* Create a CFURL from the upload directory string */
    destinationURL = CFURLCreateWithString(kCFAllocatorDefault, uploadDirectory, NULL);
    assert(destinationURL != NULL);
	
    /* Copy the end of the file path and use it as the file name. */
    fileName = CFURLCopyLastPathComponent(destinationURL);
    assert(fileName != NULL);
	NSLog(@"fileName: %@", fileName);
    /* Create the destination URL by taking the upload directory and appending the file name. */
    //uploadURL = CFURLCreateCopyAppendingPathComponent(kCFAllocatorDefault, destinationURL, fileName, false);
    uploadURL = CFURLCopyAbsoluteURL(destinationURL);
	assert(uploadURL != NULL);
	NSLog(@"uploadURL: %@", uploadURL);
    CFRelease(destinationURL);
    CFRelease(fileName);
    
    /* Create a CFReadStream from the local file being uploaded. */
    //readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault, fileURL);
    readStream = CFReadStreamCreateWithBytesNoCopy(kCFAllocatorDefault, bytes, length, kCFAllocatorNull);
	assert(readStream != NULL);
    
    /* Create an FTP write stream for uploading operation to a FTP URL. If the URL specifies a
	 directory, the open will be followed by a close event/state and the directory will have been
	 created. Intermediary directory structure is not created. */
    writeStream = CFWriteStreamCreateWithFTPURL(kCFAllocatorDefault, uploadURL);
    assert(writeStream != NULL);
    CFRelease(uploadURL);
    
    /* Initialize our MyStreamInfo structure, which we use to store some information about the stream. */
    MyStreamInfoCreate(&streamInfo, readStream, writeStream);
    context.info = (void *)streamInfo;
	
    /* CFReadStreamOpen will return success/failure.  Opening a stream causes it to reserve all the
	 system resources it requires.  If the stream can open non-blocking, this will always return TRUE;
	 listen to the run loop source to find out when the open completes and whether it was successful. */
    success = CFReadStreamOpen(readStream);
    if (success) {
        
        /* CFWriteStreamSetClient registers a callback to hear about interesting events that occur on a stream. */
        success = CFWriteStreamSetClient(writeStream, kNetworkEvents, MyUploadCallBack, &context);
        if (success) {
			
            /* Schedule a run loop on which the client can be notified about stream events.  The client
			 callback will be triggered via the run loop.  It's the caller's responsibility to ensure that
			 the run loop is running. */
            CFWriteStreamScheduleWithRunLoop(writeStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
            
            //MyCFStreamSetUsernamePassword(writeStream, username, password);
            //MyCFStreamSetFTPProxy(writeStream, &streamInfo->proxyDict);
			
			CFWriteStreamSetProperty(writeStream, kCFStreamPropertyFTPUserName, username);
			CFWriteStreamSetProperty(writeStream, kCFStreamPropertyFTPPassword, password);
            
            /* CFWriteStreamOpen will return success/failure.  Opening a stream causes it to reserve all the
			 system resources it requires.  If the stream can open non-blocking, this will always return TRUE;
			 listen to the run loop source to find out when the open completes and whether it was successful. */
            success = CFWriteStreamOpen(writeStream);
            if (success == false) {
                fprintf(stderr, "CFWriteStreamOpen failed\n");
                MyStreamInfoDestroy(streamInfo);
            }
        } else {
            fprintf(stderr, "CFWriteStreamSetClient failed\n");
            MyStreamInfoDestroy(streamInfo);
        }
    } else {
        fprintf(stderr, "CFReadStreamOpen failed\n");
        MyStreamInfoDestroy(streamInfo);
    }
	
    return success;
}

- (BOOL)uploadData:(NSData	*)data toURL:(NSURL *)url username:(NSString *)user password:(NSString *)pass {
	[data retain];
	const UInt8 *bytes = [data bytes];
	CFIndex length = [data length];
	NSString *urlString = [url absoluteString];
	// Start uploading a file to the specified URL destination.
	BOOL status = MySimpleUpload((CFStringRef)urlString, bytes, length, (CFStringRef)user, (CFStringRef)pass);
	if (!status) fprintf(stderr, "MySimpleUpload failed\n");
	[data release];
	return status;
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
