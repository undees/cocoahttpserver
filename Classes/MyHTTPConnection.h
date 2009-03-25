//
//  This class was created by Nonnus,
//  who graciously decided to share it with the CocoaHTTPServer community.
//

#import <Foundation/Foundation.h>
#import "HTTPConnection.h"

@interface MyHTTPConnection : HTTPConnection
{
	int dataStartIndex;
	NSMutableData* multipartData;
	BOOL postHeaderOK;
}

@end
