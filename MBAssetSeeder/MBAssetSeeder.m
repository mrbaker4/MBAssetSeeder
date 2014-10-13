//
//  MBAssetSeeder.m
//  MBAssetSeederExample
//
//  Created by Matthew Baker on 5/19/14.
//  Copyright (c) 2014 Matthew Baker. All rights reserved.
//

#import "MBAssetSeeder.h"
#import "ALAsset+SHA256.h"
#import "RHPerson+Helpers.h"
#import <AddressBook.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MBFaker.h>

@interface MBAssetSeeder ()

@property id delegate;
@property RHAddressBook *addressBook;
@property ALAssetsLibrary *library;
@property NSInteger retryCount;

@end

@implementation MBAssetSeeder

- (instancetype) initWithDelegate:(id)delegate {
    return [self initWithDelegate:delegate andRetryCount:0];
}

- (instancetype) initWithDelegate:(id<MBAssetSeederDelegate>)delegate
                    andRetryCount:(NSInteger)retryCount {
    if (self = [super init]) {
        self.delegate = delegate;
        self.addressBook = [[RHAddressBook alloc] init];
        self.library = [[ALAssetsLibrary alloc] init];
        self.retryCount = retryCount;
    }

    return self;
}

- (void) seedContacts:(NSInteger)count {
    if (count == 0) {
        if ([self.addressBook hasUnsavedChanges]) {
            [self.addressBook save];
        }
        [self.delegate createContactsFinished];
        return;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self createNewPerson];
        [self seedContacts:(count-1)];
    });
}

- (BOOL) addPerson:(RHPerson *)person {
    [self.addressBook addPerson:person];
    return [self.addressBook save];
}

- (void) createNewPerson {
    RHPerson *person = [self.addressBook newPersonInDefaultSource];
    person.kind = RHPersonKindPerson;
    person.firstName = [MBFakerName firstName];
    person.lastName = [MBFakerName lastName];
    [person addPhone:[MBFakerPhoneNumber phoneNumber] label:RHPersonPhoneIPhoneLabel];
    [person addEmail:[MBFakerInternet safeEmail] label:RHHomeLabel];
}

- (void) deleteAllContacts {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        for (RHPerson *person in [self.addressBook people]) {
            [self.addressBook removePerson:person];
        }
        [self.addressBook save];
        [self.delegate deleteContactsFinished];
    });
}

- (void) seedPhotosFromURLs:(NSArray *)urls {
    if ([urls count] == 0) {
        [self.delegate createPhotosFinished];
        return;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:[urls firstObject]];
        if (imageData) {
            [self.library writeImageDataToSavedPhotosAlbum:imageData
                                                  metadata:nil
                                           completionBlock:^(NSURL *assetURL, NSError *error) {
                                               if (error) {
                                                   [self handleFailureWithRemainingCount:[urls count]
                                                                                forError:error];
                                                   return;
                                               }

                                               [self seedPhotosFromURLs:[urls subarrayWithRange:NSMakeRange(1, [urls count]-1)]];
                                           }];
        } else {
            [self handleFailureWithRemainingCount:[urls count]
                                         forError:nil];
        }
    });
}

- (void) seedPhotos:(NSInteger)count {
    if (count == 0) {
        [self.delegate createPhotosFinished];
        return;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *urlString = [NSString stringWithFormat:@"http://lorempixel.com/240/320/abstract/%@", [MBFakerName firstName]];
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        if (imageData) {
            [self.library writeImageDataToSavedPhotosAlbum:imageData
                                                  metadata:nil
                                           completionBlock:^(NSURL *assetURL, NSError *error) {
                                               if (error) {
                                                   [self handleFailureWithRemainingCount:count
                                                                                forError:error];
                                                   return;
                                               }

                                               if ([self.delegate respondsToSelector:@selector(addedPhotoWithHash:)]) {
                                                   [self reportPhotoHashForAsset:assetURL withPhotoCount:count];
                                               } else {
                                                   [self seedPhotos:(count-1)];
                                               }
                                           }];
        } else {
            [self handleFailureWithRemainingCount:count
                                         forError:nil];
        }
    });
}

- (void) reportPhotoHashForAsset:(NSURL *)assetURL withPhotoCount:(NSInteger)photoCount {
    [self.library assetForURL:assetURL
                  resultBlock:^(ALAsset *asset){
                      [self.delegate addedPhotoWithHash:[asset sha256]];
                      [self seedPhotos:(photoCount-1)];
                  }
                 failureBlock:^(NSError *error){
                     [self handleFailureWithRemainingCount:photoCount
                                                  forError:error];
                 }];
}

- (void) handleFailureWithRemainingCount:(NSInteger)count
                                forError:(NSError *)error {
    if (self.retryCount > 0) {
        self.retryCount -= 1;
        [self seedPhotos:count];
    } else {
        [self.delegate photoCreationFailed];
    }
}

@end
