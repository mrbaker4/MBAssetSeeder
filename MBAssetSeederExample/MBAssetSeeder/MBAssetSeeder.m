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

@end

@implementation MBAssetSeeder

- (instancetype) initWithDelegate:(id)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
        self.addressBook = [[RHAddressBook alloc] init];
        self.library = [[ALAssetsLibrary alloc] init];
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
                                                   [self.delegate photoCreationFailed];
                                                   return;
                                               }

                                               if ([self.delegate respondsToSelector:@selector(addedPhotoWithHash:)]) {
                                                   [self reportPhotoHashForAsset:assetURL withPhotoCount:count];
                                               } else {
                                                   [self seedPhotos:(count-1)];
                                               }
                                           }];
        } else {
            [self.delegate photoCreationFailed];
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
                     [self.delegate photoCreationFailed];
                 }];
}

@end
