//
//  FTPController.m
//  Sequenz
//
//  Created by Dominik Gwosdek on 09.11.09.
//  Copyright 2009 Dominik Gwosdek. All rights reserved.
//

#import "FTPController.h" 

struct MemoryStruct
{
	char *memory;
	size_t size;
};

static size_t ReadMemoryCallback(void *ptr, size_t size, size_t nmemb, void *pMem)
{
	struct MemoryStruct *pRead = (struct MemoryStruct *)pMem; 
    size_t ReadLength = size * nmemb; 
    if (pRead->size >= ReadLength) 
    { 
        memcpy((char *)ptr, &pRead->memory[0], ReadLength); 
        pRead->memory += ReadLength; 
        pRead->size -= ReadLength; 
        return ReadLength; 
    } 
    else if ((pRead->size < ReadLength) && (pRead->size > 0)) 
    { 
        size_t ReturnSize = pRead->size; 
        memcpy((char *)ptr, &pRead->memory[0], pRead->size); 
        pRead->memory += pRead->size; 
        pRead->size = 0; 
        return(ReturnSize); 
    } 
    else 
        return 0; 
}

@interface FTPController (Private)

- (void)completeUpload;
- (void)uploadError:(NSError *)error;

@end


@implementation FTPController

@synthesize usePassiveMode, delegate;


- (BOOL)uploadData:(NSData	*)data toURL:(NSURL *)url username:(NSString *)user password:(NSString *)pass {
	CURL *curl;
	CURLcode res;
	double dUploadSpeed, dTotalTime;
	char errorBuffer[CURL_ERROR_SIZE];
	
	struct MemoryStruct sData;
	sData.memory = (char *)[data bytes];
	sData.size = [data length];
	
	/* In windows, this will init the winsock stuff */ 
	curl_global_init(CURL_GLOBAL_ALL);
	
	/* get a curl handle */ 
	curl = curl_easy_init();
	if(curl) {
		
		/* we want to use our own read function */ 
		curl_easy_setopt(curl, CURLOPT_READFUNCTION, ReadMemoryCallback);
		
		/* enable uploading */ 
		curl_easy_setopt(curl, CURLOPT_UPLOAD, 1L);
#ifndef NDEBUG
		char *version = curl_version();
		fprintf(stderr, "curl version: %s\n", version);
		/* enable debug info */
		curl_easy_setopt(curl, CURLOPT_VERBOSE, 1);
#endif		
		/* specify target */ 
		curl_easy_setopt(curl, CURLOPT_URL, [[url absoluteString] UTF8String]);
		
		/* enable TLS/SSL transfer */
		curl_easy_setopt(curl, CURLOPT_USE_SSL, CURLUSESSL_TRY);
		curl_easy_setopt(curl, CURLOPT_FTPSSLAUTH, CURLFTPAUTH_DEFAULT);
		
		/* set username & password */
		curl_easy_setopt(curl, CURLOPT_USERNAME, [user UTF8String]);
		curl_easy_setopt(curl, CURLOPT_PASSWORD, [pass UTF8String]);
		
		/* set error buffer */
		curl_easy_setopt(curl, CURLOPT_ERRORBUFFER, errorBuffer);
		curl_easy_setopt(curl, CURLOPT_FAILONERROR, 1);
		
		/* now specify which file to upload */ 
		curl_easy_setopt(curl, CURLOPT_READDATA, (void *)&sData);
		
		/* Set the size of the file to upload (optional).  If you give a *_LARGE
		 option you MUST make sure that the type of the passed-in argument is a
		 curl_off_t. If you use CURLOPT_INFILESIZE (without _LARGE) you must
		 make sure that to pass in a type 'long' argument. */ 
		curl_easy_setopt(curl, CURLOPT_INFILESIZE_LARGE, (curl_off_t)sData.size);
		
		/* Now run off and do what you've been told! */ 
		res = curl_easy_perform(curl);
		
		curl_easy_getinfo(curl, CURLINFO_SPEED_UPLOAD, &dUploadSpeed);
		curl_easy_getinfo(curl, CURLINFO_TOTAL_TIME, &dTotalTime);
#ifndef NDEBUG
		fprintf(stderr, "Speed: %.3f bytes/sec during %.3f seconds\n", dUploadSpeed, dTotalTime);
#endif
		/* always cleanup */ 
		curl_easy_cleanup(curl);
		
		if (res != 0) {
			[self uploadError:[NSError errorWithDomain:@"CurlErrorDomain" 
												  code:res 
											  userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithUTF8String:curl_easy_strerror(res)] 
																				   forKey:NSLocalizedDescriptionKey]]];
			return NO;
		}
	}

	curl_global_cleanup();
	[self completeUpload];
	return YES;
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
