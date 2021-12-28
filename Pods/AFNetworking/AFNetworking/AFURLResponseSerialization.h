// AFURLResponseSerialization.h
// Copyright (c) 2011–2016 Alamofire Software Foundation ( http://alamofire.org/ )


#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT id AFJSONObjectByRemovingKeysWithNullValues(id JSONObject, NSJSONReadingOptions readingOptions);

@protocol AFURLResponseSerialization <NSObject, NSSecureCoding, NSCopying>

- (nullable id)responseObjectForResponse:(nullable NSURLResponse *)response
                                    data:(nullable NSData *)data
                                   error:(NSError * _Nullable __autoreleasing *)error NS_SWIFT_NOTHROW;

@end

#pragma mark - AFHTTPResponseSerializer

@interface AFHTTPResponseSerializer : NSObject <AFURLResponseSerialization>

- (instancetype)init;

+ (instancetype)serializer;

@property (nonatomic, copy, nullable) NSIndexSet *acceptableStatusCodes;
@property (nonatomic, copy, nullable) NSSet <NSString *> *acceptableContentTypes;

- (BOOL)validateResponse:(nullable NSHTTPURLResponse *)response
                    data:(nullable NSData *)data
                   error:(NSError * _Nullable __autoreleasing *)error;

@end

#pragma mark - AFJSONResponseSerializer

@interface AFJSONResponseSerializer : AFHTTPResponseSerializer

- (instancetype)init;

@property (nonatomic, assign) NSJSONReadingOptions readingOptions;
@property (nonatomic, assign) BOOL removesKeysWithNullValues;

+ (instancetype)serializerWithReadingOptions:(NSJSONReadingOptions)readingOptions;

@end

#pragma mark - AFXMLParserResponseSerializer

@interface AFXMLParserResponseSerializer : AFHTTPResponseSerializer

@end

#pragma mark - AFXMLDocumentResponseSerializer  这个是mac版可以不看
#ifdef __MAC_OS_X_VERSION_MIN_REQUIRED
@interface AFXMLDocumentResponseSerializer : AFHTTPResponseSerializer
- (instancetype)init;
@property (nonatomic, assign) NSUInteger options;
+ (instancetype)serializerWithXMLDocumentOptions:(NSUInteger)mask;
@end
#endif

#pragma mark - AFPropertyListResponseSerializer

@interface AFPropertyListResponseSerializer : AFHTTPResponseSerializer

- (instancetype)init;

@property (nonatomic, assign) NSPropertyListFormat format;
@property (nonatomic, assign) NSPropertyListReadOptions readOptions;

+ (instancetype)serializerWithFormat:(NSPropertyListFormat)format
                         readOptions:(NSPropertyListReadOptions)readOptions;

@end

#pragma mark - AFImageResponseSerializer

@interface AFImageResponseSerializer : AFHTTPResponseSerializer

#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
@property (nonatomic, assign) CGFloat imageScale;
@property (nonatomic, assign) BOOL automaticallyInflatesResponseImage;
#endif

@end

#pragma mark - AFCompoundResponseSerializer

@interface AFCompoundResponseSerializer : AFHTTPResponseSerializer

@property (readonly, nonatomic, copy) NSArray <id<AFURLResponseSerialization>> *responseSerializers;

+ (instancetype)compoundSerializerWithResponseSerializers:(NSArray <id<AFURLResponseSerialization>> *)responseSerializers;

@end

FOUNDATION_EXPORT NSString * const AFURLResponseSerializationErrorDomain;
FOUNDATION_EXPORT NSString * const AFNetworkingOperationFailingURLResponseErrorKey;
FOUNDATION_EXPORT NSString * const AFNetworkingOperationFailingURLResponseDataErrorKey;

NS_ASSUME_NONNULL_END
