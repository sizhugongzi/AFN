//
//  User.m
//  XLTestDemo
//
//  Created by 甘延娇 on 2021/12/28.
//

#import "User.h"

@implementation User

@end


@implementation Card

- (NSString *)info {
    return [NSString stringWithFormat:@"%@/%lu",_user.name,(unsigned long)_user.age];
}

- (void)setInfo:(NSString *)info {
    NSArray *array = [info componentsSeparatedByString:@"/"];
    _user.name = array[0];
    _user.age = [array[1] integerValue];
}

+ (NSSet<NSString *> *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    NSSet * keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    NSArray * moreKeyPaths = nil;
    if ([key isEqualToString:@"info"]) {
        moreKeyPaths = [NSArray arrayWithObjects:@"user.name", @"user.age", nil];
    }
    if (moreKeyPaths) {
        keyPaths = [keyPaths setByAddingObjectsFromArray:moreKeyPaths];
    }
    return keyPaths;
}

@end
