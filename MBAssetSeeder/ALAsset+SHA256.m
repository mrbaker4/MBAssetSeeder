//
//  ALAsset+SHA256.m
//  MBAssetSeederExample
//
//  Created by Matthew Baker on 5/19/14.
//  Copyright (c) 2014 Matthew Baker. All rights reserved.
//

#import "ALAsset+SHA256.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation ALAsset (SHA256)

- (NSString *)sha256 {
    ALAssetRepresentation *rep = [self defaultRepresentation];
    Byte *buffer = (Byte *)malloc((unsigned long)rep.size);
    NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:(NSUInteger)rep.size error:nil];
    NSData *photoData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
    return [self sha256ForData:photoData];
}

#pragma mark - Helper

- (NSString *)sha256ForData:(NSData *)photoData {
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];

    if (photoData.length == 0) {
        return nil;
    }

    CC_SHA256(photoData.bytes, (int)photoData.length, digest);

    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];

    // Parse through the CC_SHA256 results (stored inside of digest[]).
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }

    return output;
}

@end
