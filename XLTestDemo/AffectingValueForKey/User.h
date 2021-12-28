//
//  User.h
//  XLTestDemo
//
//  Created by 甘延娇 on 2021/12/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface User : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSUInteger age;

@end

@interface Card : NSObject

@property (nonatomic, copy) NSString *info;
@property (nonatomic, strong) User *user;

@end

NS_ASSUME_NONNULL_END
