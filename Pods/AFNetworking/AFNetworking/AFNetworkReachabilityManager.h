// AFNetworkReachabilityManager.h
// Copyright (c) 2011–2016 Alamofire Software Foundation ( http://alamofire.org/ )


#import <Foundation/Foundation.h>

#if !TARGET_OS_WATCH
#import <SystemConfiguration/SystemConfiguration.h>

//具体的使用方法
//AFNetworkReachabilityManager *networkReachManager = [AFNetworkReachabilityManager sharedManager];
//[networkReachManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
//    NSLog(@"%zd", status);
//}];
//开始监测网络
//[networkReachManager startMonitoring];

typedef NS_ENUM(NSInteger, AFNetworkReachabilityStatus) {
    AFNetworkReachabilityStatusUnknown          = -1,
    AFNetworkReachabilityStatusNotReachable     = 0,
    AFNetworkReachabilityStatusReachableViaWWAN = 1,
    AFNetworkReachabilityStatusReachableViaWiFi = 2,
};

NS_ASSUME_NONNULL_BEGIN

@interface AFNetworkReachabilityManager : NSObject

@property (readonly, nonatomic, assign) AFNetworkReachabilityStatus networkReachabilityStatus;
//获取网络是否具体的状态,只读属性
@property (readonly, nonatomic, assign, getter = isReachable) BOOL reachable;
@property (readonly, nonatomic, assign, getter = isReachableViaWWAN) BOOL reachableViaWWAN;
@property (readonly, nonatomic, assign, getter = isReachableViaWiFi) BOOL reachableViaWiFi;

//这个是单例调用manager创建
+ (instancetype)sharedManager;
//具体创建实例方法
+ (instancetype)manager;
//通过domain创建实例
+ (instancetype)managerForDomain:(NSString *)domain;
//通过address创建实例  监听某个socket地址的网络状态
+ (instancetype)managerForAddress:(const void *)address;
//====NS_DESIGNATED_INITIALIZER====当有多个初始化方法时 为了确保能够正确初始化 最终都会调用designed initializer
//通过reachability创建实例
- (instancetype)initWithReachability:(SCNetworkReachabilityRef)reachability NS_DESIGNATED_INITIALIZER;

//不能使用的初始化
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

//开始监听
- (void)startMonitoring;
//停止监听
- (void)stopMonitoring;
//获取网络状态文字
- (NSString *)localizedNetworkReachabilityStatusString;
//获取状态的回调方法
//监听网络状态的改变有两种方法:1.是实现这个block 2.是监听通知
- (void)setReachabilityStatusChangeBlock:(nullable void (^)(AFNetworkReachabilityStatus status))block;

@end

//ps： FOUNDATION_EXPORT 和#define 都能定义常量。FOUNDATION_EXPORT 能够使用==进行判断，效率略高。而且能够隐藏定义细节(就是实现部分不在.中)
//网络状态改变时 发送的通知
FOUNDATION_EXPORT NSString * const AFNetworkingReachabilityDidChangeNotification;
FOUNDATION_EXPORT NSString * const AFNetworkingReachabilityNotificationStatusItem;
//这个是定义的一个C语言函数, 返回本地化的status字符串
FOUNDATION_EXPORT NSString * AFStringFromNetworkReachabilityStatus(AFNetworkReachabilityStatus status);

NS_ASSUME_NONNULL_END
#endif
