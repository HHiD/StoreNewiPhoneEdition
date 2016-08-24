//
//  TestServer.h
//  TestingStoreiPhoneEdition
//
//  Created by HongDi Huang on 8/23/16.
//  Copyright © 2016 HongDi Huang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Server : NSObject
typedef enum {
    kServerNoSocketsAvailable = 1,
    kServerNoSpaceOnOutputStream = 2,
    kServerOutputStreamReachedCapacity = 3 // should be able to try again 'later'
} ServerErrorCode;

- (void)startWithName:(NSString *)name error:(NSError **)error;

@end
