// AFSecurityPolicy.h
// Copyright (c) 2011–2016 Alamofire Software Foundation ( http://alamofire.org/ )

#import <Foundation/Foundation.h>
#import <Security/Security.h>

typedef NS_ENUM(NSUInteger, AFSSLPinningMode) {
    AFSSLPinningModeNone,//代表无条件信任服务器的证书
    AFSSLPinningModePublicKey,//代表会对服务器返回的证书中的PublicKey进行验证，通过则通过，否则不通过
    AFSSLPinningModeCertificate,//代表会对服务器返回的证书同本地证书全部进行校验，通过则通过，否则不通过
};

NS_ASSUME_NONNULL_BEGIN

@interface AFSecurityPolicy : NSObject <NSSecureCoding, NSCopying>

//返回SSL Pinning的类型。默认的是AFSSLPinningModeNone。
@property (readonly, nonatomic, assign) AFSSLPinningMode SSLPinningMode;
//这个属性保存着所有的可用做校验的证书的集合。
//注意： 只要在证书集合中任何一个校验通过，evaluateServerTrust:forDomain: 就会返回true，即通过校验。
@property (nonatomic, strong, nullable) NSSet <NSData *> *pinnedCertificates;
//使用允许无效或过期的证书，默认是不允许。
@property (nonatomic, assign) BOOL allowInvalidCertificates;
//是否验证证书中的域名domain,默认是YES
@property (nonatomic, assign) BOOL validatesDomainName;

+ (NSSet <NSData *> *)certificatesInBundle:(NSBundle *)bundle;
+ (instancetype)defaultPolicy;
+ (instancetype)policyWithPinningMode:(AFSSLPinningMode)pinningMode;
+ (instancetype)policyWithPinningMode:(AFSSLPinningMode)pinningMode withPinnedCertificates:(NSSet <NSData *> *)pinnedCertificates;
- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust
                  forDomain:(nullable NSString *)domain;
//使用无效证书或过期证书 

@end

NS_ASSUME_NONNULL_END
