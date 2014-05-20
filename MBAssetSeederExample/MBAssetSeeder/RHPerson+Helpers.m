//
//  RHPerson+Helpers.m
//  MBAssetSeederExample
//
//  Created by Matthew Baker on 5/19/14.
//  Copyright (c) 2014 Matthew Baker. All rights reserved.
//

#import "RHPerson+Helpers.h"

@implementation RHPerson (Helpers)

- (void) addPhone:(NSString *)phoneNumber label:(NSString *)label {
    RHMultiStringValue *values = [self phoneNumbers];
    RHMutableMultiStringValue *mutableValues = [values mutableCopy];
    if (!mutableValues) {
        mutableValues = [[RHMutableMultiStringValue alloc] initWithType:kABMultiStringPropertyType];
    }
    if (label==nil) {
        label = [@[RHPersonPhoneMobileLabel,
                   RHPersonPhoneIPhoneLabel,
                   RHPersonPhoneMainLabel,
                   RHPersonPhoneHomeFAXLabel,
                   RHPersonPhoneWorkFAXLabel,
                   RHPersonPhoneOtherFAXLabel,
                   RHPersonPhonePagerLabel] objectAtIndex:arc4random()%7];
    }
    [mutableValues addValue:phoneNumber withLabel:label];
    self.phoneNumbers = mutableValues;
}

- (void) addEmail:(NSString *)email label:(NSString *)label {
    RHMultiStringValue *values = [self emails];
    RHMutableMultiStringValue *mutableValues = [values mutableCopy];
    if (!mutableValues) {
        mutableValues = [[RHMutableMultiStringValue alloc] initWithType:kABMultiStringPropertyType];
    }
    if (label==nil) {
        label = [@[RHWorkLabel, RHHomeLabel, RHOtherLabel] objectAtIndex:arc4random()%3];
    }
    [mutableValues addValue:email withLabel:label];
    self.emails = mutableValues;
}

@end
