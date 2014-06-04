//
//  MBAssetSeeder.h
//  MBAssetSeederExample
//
//  Created by Matthew Baker on 5/19/14.
//  Copyright (c) 2014 Matthew Baker. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MBAssetSeederDelegate

- (void) createContactsFinished;
- (void) deleteContactsFinished;
- (void) createPhotosFinished;
- (void) photoCreationFailed;

@optional
- (void) addedPhotoWithHash:(NSString *)hash;

@end

@interface MBAssetSeeder : NSObject

- (instancetype) init UNAVAILABLE_ATTRIBUTE;
- (instancetype) initWithDelegate:(id <MBAssetSeederDelegate>)delegate;
- (instancetype) initWithDelegate:(id <MBAssetSeederDelegate>)delegate
                    andRetryCount:(NSInteger)retryCount;

- (void) deleteAllContacts;
- (void) seedContacts:(NSInteger)count;
- (void) seedPhotos:(NSInteger)count;

@end
