//
//  SurespotConstants.m
//  surespot
//
//  Created by Adam on 11/18/13.
//  Copyright (c) 2013 2fours. All rights reserved.
//

#import "SurespotConstants.h"

@implementation NSString (Utils)

- (NSString*)stringWithSentenceCapitalization {
    NSString *firstCharacterInString = [[self substringToIndex:1] capitalizedString];
    return [self stringByReplacingCharactersInRange:NSMakeRange(0,1) withString: firstCharacterInString];
}

@end

@implementation SurespotConstants

#ifdef DEBUG
    BOOL const serverSecure = NO;
    NSString * const serverBaseIPAddress = @"178.62.32.152";
    NSInteger const serverPort = 8080;

    NSString * const serverPublicKeyString =  @"-----BEGIN PUBLIC KEY-----\nMIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBufIPRb1T1LaMn4yKPibtQ+FHVzL9\n4/JXzD1Q14yv178cSAx1N2TJlrAQSM9sEKVYvWc4H7PtMTB8q2HPanMpAwQBqRne\nvXv0dmtZ2p4+YTUgDzVwlJ/oqiePgR1Mc9+UWM+eCsXIz/1JqlR980O/8yn+fpn6\niR9AYS9XjK9Lwp3GLnQ=\n-----END PUBLIC KEY-----"; //local
#else
    BOOL const serverSecure = NO;
    NSString * const serverBaseIPAddress = @"dedivps-42122.dedicloud.co.uk";
    NSInteger const serverPort = 8080;
    NSString * const serverPublicKeyString = @"-----BEGIN PUBLIC KEY-----\nMIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBoN3bmLNv8dh8PrXbkaOWuYfYo0y4\nk5HIJFmbRsgf6rY1rt4ztfpCX47yJgto95i4107wrPCT5OHHVhAXC4tGYKcA3+vg\nLjbLJp4gTihnrceHEoXScTmMnkVfuOEytbnuNxgvekUcB4sMIjnmGNstzOi4vsjc\n44X0idf8z0FT6iN6hjM=\n-----END PUBLIC KEY-----"; //prod
#endif

NSInteger const SAVE_MESSAGE_COUNT = 50;
NSString * const MIME_TYPE_IMAGE = @"image/";
NSString * const MIME_TYPE_TEXT = @"text/plain";
NSString * const MIME_TYPE_M4A = @"audio/mp4";
NSInteger const MAX_IDENTITIES = 3;

NSString * const FACEBOOK_APP_ID = @"585893814798693";

NSString * const TUMBLR_CONSUMER_KEY = @"odlgStMAIPzomPy0uaymdh9uggO5pF31Sv25ZBvXR3HDEwfs7s";
NSString * const TUMBLR_SECRET = @"rEB7QNBpycr5OZQdIdT4lQQ3ZowyoGIuoWtvgMC2IIePTkFFIA";
NSString * const TUMBLR_CALLBACK_URL = @"https://tumblr.surespot.me";

NSString *const GOOGLE_CLIENT_ID = @"1049372133805-ov5fcqqu5o6ig3ho4r85m8eugevf7c13.apps.googleusercontent.com";
NSString *const GOOGLE_CLIENT_SECRET = @"vwZJHzCtUcXzqkD36Z9XxPwr";

NSString * const BITLY_TOKEN = @"4d80112e45e7c6c32d055e2ea9e0ceb87c593374";

NSString * const NAVBAR_COLOR = @"#2c3e50";


@end
