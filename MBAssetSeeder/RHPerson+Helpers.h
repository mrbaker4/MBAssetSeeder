//
//  RHPerson+Helpers.h
//  MBAssetSeederExample
//
//  Created by Matthew Baker on 5/19/14.
//  Copyright (c) 2014 Matthew Baker. All rights reserved.
//

#import "RHPerson.h"

@interface RHPerson (Helpers)

- (void) addEmail:(NSString *)email label:(NSString *)label;
- (void) addPhone:(NSString *)email label:(NSString *)label;

@end
