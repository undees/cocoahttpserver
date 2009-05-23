//
//  This class was created by Nonnus,
//  who graciously decided to share it with the CocoaHTTPServer community.
//

#import "MyHTTPConnection.h"
#import "HTTPServer.h"
#import "HTTPResponse.h"

@implementation MyHTTPConnection

static NSObject *ourObserver = nil;

+ (void)setSharedObserver:(NSObject*)observer
{
	if (observer == ourObserver)
		return;

	[ourObserver release];
	ourObserver = [observer retain];
}

+ (id)sharedObserver
{
	return ourObserver;
}

/**
 * Returns whether or not the server will accept POSTs.
 * That is, whether the server will accept uploaded data for the given URI.
**/
- (BOOL)supportsPOST:(NSString *)path withSize:(UInt64)contentLength
{
//	NSLog(@"POST:%@", path);
	
	dataStartIndex = 0;
	multipartData = [[NSMutableData alloc] init];
	postHeaderOK = FALSE;
	
	return YES;
}

/**
 * This method is called to get a response for a request.
 * You may return any object that adopts the HTTPResponse protocol.
 * The HTTPServer comes with two such classes: HTTPFileResponse and HTTPDataResponse.
 * HTTPFileResponse is a wrapper for an NSFileHandle object, and is the preferred way to send a file response.
 * HTTPDataResopnse is a wrapper for an NSData object, and may be used to send a custom response.
**/
- (NSObject<HTTPResponse> *)httpResponseForURI:(NSString *)path
{
	if (postContentLength > 0)		//process POST data
	{
		NSLog(@"processing post data: %i", postContentLength);
		NSString *contents = [[[NSString alloc] initWithData:multipartData encoding:NSUTF8StringEncoding] autorelease];
		NSLog(contents);

		NSObject *observer = [MyHTTPConnection sharedObserver];
		if (observer)
		{
			[observer performSelector:@selector(runCommandStep:) withObject:multipartData];
			NSString *result = [observer performSelector:@selector(response)];

			NSData *browseData = [result dataUsingEncoding:NSUTF8StringEncoding];
			return [[[HTTPDataResponse alloc] initWithData:browseData] autorelease];
		}
		else
		{
			return nil;
		}

		[multipartData release];
		postContentLength = 0;
	}
	
	return nil;
}

/**
 * This method is called to handle data read from a POST.
 * The given data is part of the POST body.
**/
- (void)processPostDataChunk:(NSData *)postDataChunk
{
	[multipartData appendData:postDataChunk];
}

@end
