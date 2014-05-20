//
//  ViewController.m
//  MBAssetSeederExample
//
//  Created by Matthew Baker on 5/19/14.
//  Copyright (c) 2014 Matthew Baker. All rights reserved.
//

#import "ViewController.h"
#import <MBAssetSeeder.h>
#import <AddressBook.h>

@interface ViewController () <MBAssetSeederDelegate>

@property MBAssetSeeder *seeder;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.seeder = [[MBAssetSeeder alloc] initWithDelegate:self];
    [[RHAddressBook new] requestAuthorizationWithCompletion:^(bool granted, NSError *error){ }];
}

#pragma mark - IBActions

- (IBAction)add10Contacts:(id)sender {
    [self.seeder seedContacts:10];
}

- (IBAction)deleteAllContacts:(id)sender {
    [self.seeder deleteAllContacts];
}

- (IBAction)add10Photos:(id)sender {
    [self.seeder seedPhotos:10];
}

#pragma mark - MBAssetSeederDelegate

- (void) createContactsFinished {
    [self presentAlertWithText:[NSString stringWithFormat:@"Created %d new contacts.", 10]];
}

- (void) deleteContactsFinished {
    [self presentAlertWithText:@"All contacts are now deleted."];
}

- (void) createPhotosFinished {
    [self presentAlertWithText:[NSString stringWithFormat:@"Created %d new photos.", 10]];
}

- (void) photoCreationFailed {
    [self presentAlertWithText:@"Photo creation failed."];
}

- (void) presentAlertWithText:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Asset Seeder"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    });
}

@end
