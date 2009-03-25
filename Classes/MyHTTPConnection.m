//
//  This class was created by Nonnus,
//  who graciously decided to share it with the CocoaHTTPServer community.
//

#import "MyHTTPConnection.h"
#import "HTTPServer.h"
#import "HTTPResponse.h"

#ifdef BROMINE_ENABLED
#import "ScriptRunner.h"
#endif

@implementation MyHTTPConnection

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

#ifdef BROMINE_ENABLED
		ScriptRunner *runner = [[ScriptRunner alloc] init];
		
		[runner runCommandStep:multipartData];
		
		[runner release];
		
//		NSData *resultData =
//		[NSPropertyListSerialization
//		 dataFromPropertyList:keyWindowDescription
//		 format:NSPropertyListXMLFormat_v1_0
//		 errorDescription:nil];
		
//		NSMutableString *result = [[[NSMutableString alloc] initWithData:resultData encoding:NSUTF8StringEncoding] autorelease];
//		[result replaceOccurrencesOfString: @"<" withString: @"&lt;" options: 0 range: NSMakeRange (0, [result length])];
		NSMutableString *result = @"Fancy scripting mode";
#else
		NSMutableString *result = @"Not running in the fancy scripting mode";
#endif

		NSMutableString *outdata = [NSMutableString new];
		
		[outdata appendString:@"<html><head>"];
		[outdata appendFormat:@"<title>Hello from %@</title>", server.name];
		[outdata appendString:@"<style>html {background-color:#FFFFFF} body { background-color:#FFFFFF; font-family:Tahoma,Arial,Helvetica,sans-serif; font-size:18x; margin-left:15%; margin-right:15%; padding:15px; } </style>"];
		[outdata appendString:@"</head><body>"];
		[outdata appendFormat:@"<h1>Hello from %@</h1>", server.name];
		[outdata appendString:@"<pre>"];
		[outdata appendString:result];
		[outdata appendString:@"</pre></body></html>"];
		
		[outdata autorelease];
		
		[multipartData release];
		postContentLength = 0;

		NSData *browseData = [outdata dataUsingEncoding:NSUTF8StringEncoding];
		return [[[HTTPDataResponse alloc] initWithData:browseData] autorelease];
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
