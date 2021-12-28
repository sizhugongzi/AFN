// AFNetworkReachabilityManager.m
// Copyright (c) 2011–2016 Alamofire Software Foundation ( http://alamofire.org/ )

#import "AFNetworkReachabilityManager.h"
#if !TARGET_OS_WATCH

#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

NSString * const AFNetworkingReachabilityDidChangeNotification = @"com.alamofire.networking.reachability.change";
NSString * const AFNetworkingReachabilityNotificationStatusItem = @"AFNetworkingReachabilityNotificationStatusItem";

typedef void (^AFNetworkReachabilityStatusBlock)(AFNetworkReachabilityStatus status);
typedef AFNetworkReachabilityManager * (^AFNetworkReachabilityStatusCallback)(AFNetworkReachabilityStatus status);

//根据状态获取字符串
//NSLocalizedStringFromTable
//如果创建.strings文件是自定义的名字的话，如当前我起名为 Internation.strings,那么调用的方式为：
NSString * AFStringFromNetworkReachabilityStatus(AFNetworkReachabilityStatus status) {
    switch (status) {
        case AFNetworkReachabilityStatusNotReachable:
            return NSLocalizedStringFromTable(@"Not Reachable", @"AFNetworking", nil);
        case AFNetworkReachabilityStatusReachableViaWWAN:
            return NSLocalizedStringFromTable(@"Reachable via WWAN", @"AFNetworking", nil);
        case AFNetworkReachabilityStatusReachableViaWiFi:
            return NSLocalizedStringFromTable(@"Reachable via WiFi", @"AFNetworking", nil);
        case AFNetworkReachabilityStatusUnknown:
        default:
            return NSLocalizedStringFromTable(@"Unknown", @"AFNetworking", nil);
    }
}

//根据系统的SCNetworkReachabilityFlags获取网络状态转成枚举
static AFNetworkReachabilityStatus AFNetworkReachabilityStatusForFlags(SCNetworkReachabilityFlags flags) {
    BOOL isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
    BOOL canConnectionAutomatically = (((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) || ((flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0));
    BOOL canConnectWithoutUserInteraction = (canConnectionAutomatically && (flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0);
    BOOL isNetworkReachable = (isReachable && (!needsConnection || canConnectWithoutUserInteraction));
    
    AFNetworkReachabilityStatus status = AFNetworkReachabilityStatusUnknown;
    if (isNetworkReachable == NO) {
        status = AFNetworkReachabilityStatusNotReachable;
    }
#if	TARGET_OS_IPHONE
    else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {
        status = AFNetworkReachabilityStatusReachableViaWWAN;
    }
#endif
    else {
        status = AFNetworkReachabilityStatusReachableViaWiFi;
    }
    
    return status;
}

static void AFPostReachabilityStatusChange(SCNetworkReachabilityFlags flags, AFNetworkReachabilityStatusCallback block) {
    AFNetworkReachabilityStatus status = AFNetworkReachabilityStatusForFlags(flags);
    dispatch_async(dispatch_get_main_queue(), ^{
        AFNetworkReachabilityManager *manager = nil;
        if (block) {
            manager = block(status);
        }
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        NSDictionary *userInfo = @{ AFNetworkingReachabilityNotificationStatusItem: @(status) };
        [notificationCenter postNotificationName:AFNetworkingReachabilityDidChangeNotification object:manager userInfo:userInfo];
    });
}

static void AFNetworkReachabilityCallback(SCNetworkReachabilityRef __unused target, SCNetworkReachabilityFlags flags, void *info) {
    AFPostReachabilityStatusChange(flags, (__bridge AFNetworkReachabilityStatusCallback)info);
}

static const void * AFNetworkReachabilityRetainCallback(const void *info) {
    return Block_copy(info);
}

static void AFNetworkReachabilityReleaseCallback(const void *info) {
    if (info) {
        Block_release(info);
    }
}

@interface AFNetworkReachabilityManager ()
@property (readonly, nonatomic, assign) SCNetworkReachabilityRef networkReachability;
@property (readwrite, nonatomic, assign) AFNetworkReachabilityStatus networkReachabilityStatus;
@property (readwrite, nonatomic, copy) AFNetworkReachabilityStatusBlock networkReachabilityStatusBlock;
@end

@implementation AFNetworkReachabilityManager

+ (instancetype)sharedManager {
    static AFNetworkReachabilityManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [self manager];
    });
    
    return _sharedManager;
}

+ (instancetype)managerForDomain:(NSString *)domain {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [domain UTF8String]);
    
    AFNetworkReachabilityManager *manager = [[self alloc] initWithReachability:reachability];
    
    CFRelease(reachability);
    
    return manager;
}

//通过一个socket地址来初始化。 首先新建 SCNetworkReachabilityRef 对象，
//然后调用initWithReachability: 方法。记得手动管理内存。
+ (instancetype)managerForAddress:(const void *)address {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)address);
    AFNetworkReachabilityManager *manager = [[self alloc] initWithReachability:reachability];
    
    CFRelease(reachability);
    
    return manager;
}

//根据不同的系统环境，来定义socket地址。然后调用managerForAddress继续下一步。
//iOS9或者macOS10.11.0，使用ipv6的网络，sockaddr_in6结构体
//低版本使用ipv4网络，sockaddr_in结构体
+ (instancetype)manager {
    //获取具体的address创建
#if (defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && __IPHONE_OS_VERSION_MIN_REQUIRED >= 90000) || (defined(__MAC_OS_X_VERSION_MIN_REQUIRED) && __MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)
    struct sockaddr_in6 address;
    bzero(&address, sizeof(address));
    address.sin6_len = sizeof(address);
    address.sin6_family = AF_INET6;
#else
    struct sockaddr_in address;
    bzero(&address, sizeof(address));
    address.sin_len = sizeof(address);
    address.sin_family = AF_INET;
#endif
    return [self managerForAddress:&address];
}

//这个是最终的初始化方法
- (instancetype)initWithReachability:(SCNetworkReachabilityRef)reachability {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _networkReachability = CFRetain(reachability);
    self.networkReachabilityStatus = AFNetworkReachabilityStatusUnknown;
    
    return self;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:NSGenericException
                                   reason:@"`-init` unavailable. Use `-initWithReachability:` instead"
                                 userInfo:nil];
    return nil;
}

- (void)dealloc {
    [self stopMonitoring];
    
    if (_networkReachability != NULL) {
        CFRelease(_networkReachability);
    }
}

#pragma mark -
//@property (readonly, nonatomic, assign, getter = isReachable) BOOL reachable;
- (BOOL)isReachable {
    return [self isReachableViaWWAN] || [self isReachableViaWiFi];
}

//@property (readonly, nonatomic, assign, getter = isReachableViaWWAN) BOOL reachableViaWWAN;
- (BOOL)isReachableViaWWAN {
    return self.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN;
}

//@property (readonly, nonatomic, assign, getter = isReachableViaWiFi) BOOL reachableViaWiFi;
- (BOOL)isReachableViaWiFi {
    return self.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi;
}

#pragma mark - 添加主运行循环中执行SCNetworkReachabilityScheduleWithRunLoop
- (void)startMonitoring {
    // 先停止之前的网络监控
    [self stopMonitoring];
    
    // 如果没有传入或者生成SCNetworkReachabilityRef对象就直接返回
    if (!self.networkReachability) {
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    //收到callback调用后，将status通过networkReachabilityStatusBlock回调出去
    AFNetworkReachabilityStatusCallback callback = ^(AFNetworkReachabilityStatus status) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        strongSelf.networkReachabilityStatus = status;
        // 回调网络状态
        if (strongSelf.networkReachabilityStatusBlock) {
            strongSelf.networkReachabilityStatusBlock(status);
        }
        
        return strongSelf;
    };
    
    /**
     typedef struct {
         CFIndex        version;
         void *        __nullable info;
         const void    * __nonnull (* __nullable retain)(const void *info);
         void        (* __nullable release)(const void *info);
         CFStringRef    __nonnull (* __nullable copyDescription)(const void *info);
     } SCNetworkReachabilityContext;
     1. 第一个参数接受一个signed long 的参数
     2. 第二个参数接受一个void * 类型的值，相当于oc的id类型，void * 可以指向任何类型的参数
     3. 第三个参数 是一个函数 目的是对info做retain操作，
     4. 第四个参数是一个函数，目的是对info做release操作
     5. 第五个参数是 一个函数，根据info获取Description字符串
     */
    
    // 声明SCNetworkReachabilityContext结构体  生成网络监控上下文
    SCNetworkReachabilityContext context = {0, (__bridge void *)callback, AFNetworkReachabilityRetainCallback, AFNetworkReachabilityReleaseCallback, NULL};
    // 设置回调
    SCNetworkReachabilitySetCallback(self.networkReachability, AFNetworkReachabilityCallback, &context);
    // 加到Main runloop里面对其进行监测
    SCNetworkReachabilityScheduleWithRunLoop(self.networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
    
    // 获取当前的网络状态，调用callback
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(self.networkReachability, &flags)) {
            //重要!!! 当状态改变了就调用该方法
            AFPostReachabilityStatusChange(flags, callback);
        }
    });
}

- (void)stopMonitoring {
    if (!self.networkReachability) {
        return;
    }
    
    SCNetworkReachabilityUnscheduleFromRunLoop(self.networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
}

#pragma mark -

- (NSString *)localizedNetworkReachabilityStatusString {
    return AFStringFromNetworkReachabilityStatus(self.networkReachabilityStatus);
}

#pragma mark -

- (void)setReachabilityStatusChangeBlock:(void (^)(AFNetworkReachabilityStatus status))block {
    self.networkReachabilityStatusBlock = block;
}

#pragma mark - NSKeyValueObserving
//注册键值依赖，这个可能大家平时用的比较少。可以了解一下
+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    if ([key isEqualToString:@"reachable"] || [key isEqualToString:@"reachableViaWWAN"] || [key isEqualToString:@"reachableViaWiFi"]) {
        return [NSSet setWithObject:@"networkReachabilityStatus"];
    }
    
    return [super keyPathsForValuesAffectingValueForKey:key];
}

@end
#endif
