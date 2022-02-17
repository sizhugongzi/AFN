//
//  OneViewController.m
//  XLTestDemo
//
//  Created by Silence.L on 2021/12/29.
//

// 1. 上传文件类型的数据
//- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
//fromFile:(NSURL *)fileURL
//progress:(NSProgress * __autoreleasing *)progress
//completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler
/**
* fileURL：所要上传文件的路径
*/

// 2. 上传NSData类型的数据
//- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
//fromData:(NSData *)bodyData
//progress:(NSProgress * __autoreleasing *)progress
//completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler
/**
* bodyData：所要上传的文件数据
*/

// 3. 上传流数据
//- (NSURLSessionUploadTask *)uploadTaskWithStreamedRequest:(NSURLRequest *)request
//progress:(NSProgress * __autoreleasing *)progress
//completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler
/**
* request：通过流数据初始化的请求对象
*/


// 1. 普通下载任务
//- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request
//progress:(NSProgress * __autoreleasing *)progress
//destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
//completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler
/**
* progress：管理下载进度
* destination：保存数据调用的Block
    * targetPath：数据的保存路径
    * 服务器的响应信息
*/

// 2. 支持断点下载的下载任务
//- (NSURLSessionDownloadTask *)downloadTaskWithResumeData:(NSData *)resumeData
//progress:(NSProgress * __autoreleasing *)progress
//destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
//completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler
/**
* progress：管理下载进度
* resumeData：断点下载时的断点信息
*/


#import "OneViewController.h"
#import <AFNetworking/AFNetworking.h>

@interface OneViewController ()<NSXMLParserDelegate>

@end

@implementation OneViewController

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self trust];
}

- (void)trust {
    //01 创建会话管理者对象
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //修改对响应的序列化方式
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //设置AFN中的安全配置
    manager.securityPolicy.allowInvalidCertificates = YES;  //01 允许接收无效的证书
    manager.securityPolicy.validatesDomainName = NO;        //02 不做域名验证
    //03 修改info.plist文件ATS
    //02 发送请求
    [manager GET:@"https://kyfw.12306.cn/otn/" parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",[[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding]);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error---%@",error);
    }];
}

- (void)post {
    //01 创建会话管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //02 发送请求
    //http://120.25.226.186:32812/login?username=&pwd=&type=JSON
    NSDictionary *dict = @{
        @"username":@"520it",
        @"pwd":@"520it",
        @"type":@"JSON"
    };
    [manager POST:@"http://120.25.226.186:32812/login" parameters:dict headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"success--%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failure--%@",error);
    }];
}

- (void)download {
    //01 创建会话管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //02 创建请求对象
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://e.hiphotos.baidu.com/image/pic/item/908fa0ec08fa513d72ad82da3f6d55fbb2fbd9ab.jpg"]];
    //03 创建下载请求任务
    /* 参数说明
     *
     * 第一个参数:请求对象
     * 第二个参数:progress进度回调
     * 第三个参数:destination回调 需要在该回调中告诉方法应该把下载的文件保存到哪里
     *           targetPath:默认写入的临时存储路径(tmp)
     *           response:响应头信息
     *           返回值:文件应该保存的路径
     * 第四个参数:completionHandler 完成后调用
     */
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        //监听文件的下载进度 = 已经下载的数据大小/总大小
        NSLog(@"%f",1.0 * downloadProgress.completedUnitCount /downloadProgress.totalUnitCount);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        //拼接文件的存储路径给AFN,内部会自动的完成剪切处理
        NSString *fullPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:response.suggestedFilename];
        NSLog(@"targetPath == %@",targetPath);
        NSLog(@"fullPath == %@",fullPath);
        return [NSURL fileURLWithPath:fullPath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        //filePath 文件路径 ==destination回调的返回值
        NSLog(@"filePath---%@",filePath);
    }];
    //04 执行下载任务
    [downloadTask resume];
}

- (void)upload {
    //01 创建会话管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSDictionary *dict = @{
        @"username":@"abcdef"
    };
    //02 发送请求上传
    /* 参数说明
     *
     * 第一个参数:请求路径String
     * 第二个参数:非文件参数
     * 第三个参数:constructingBodyWithBlock 处理要上传的文件参数的
     * 第四个参数:progress进度回调
     * 第五个参数:success成功后的回调
     *          responseObject 响应体信息(内部已经完成了JSON解析)
     * 第六个参数:失败后的回调
     */
    [manager POST:@"" parameters:dict headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //文件上传的第一种方法
        //NSData *imageData = [NSData dataWithContentsOfFile:@"/Users/xiaomage/Desktop/Snip20161127_246.png"];
        //处理要上传的文件
        /* 参数说明
         *
         * 第一个参数:要上传文件的二进制数据
         * 第二个参数:具体参数值  file
         * 第三个参数:文件的名称
         * 第四个参数:文件的二进制数据类型
         */
        //[formData appendPartWithFileData:imageData name:@"file" fileName:@"123.png" mimeType:@"image/png"];
        //第二种方式
        //[formData appendPartWithFileURL:[NSURL fileURLWithPath:@"/Users/xiaomage/Desktop/Snip20161127_246.png"] name:@"file" fileName:@"1234.png" mimeType:@"image/png" error:nil];
        //第三种方式
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:@"/Users/xiaomage/Desktop/Snip20161127_246.png"] name:@"file" error:nil];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        //计算进度信息
        NSLog(@"%f",1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"success--%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error---%@",error);
    }];
}

- (void)JSON {
    //01 创建会话管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //内部默认已经对服务器返回的数据进行了JSON解析操作 AFJSONResponseSerializer
    //02 发送请求
    //http://120.25.226.186:32812/video?type=JSON
    [manager GET:@"http://120.25.226.186:32812/video" parameters:@{@"type":@"JSON"} headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"success--%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error-%@",error);
    }];
}

- (void)xml {
    //01 创建会话管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //内部默认已经对服务器返回的数据进行了JSON解析操作 AFJSONResponseSerializer
    //如果返回的数据是XML类型:那么需要调整manager对响应的解析方式为:AFXMLParserResponseSerializer
    manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    //02 发送请求
    [manager GET:@"http://120.25.226.186:32812/video" parameters:@{@"type":@"XML"} headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"success--%@",responseObject);
        //使用NSXMLparser解析数据
        //01 创建解析器
        NSXMLParser *parser = (NSXMLParser *)responseObject;
        //02 设置代理
        parser.delegate = self;
        //03 开始解析
        [parser parse];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error-%@",error);
    }];
}

//text/html ~~~~~~~~ 一般情况下是这种
- (void)httpData {
    //01 创建会话管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //内部默认已经对服务器返回的数据进行了JSON解析操作 AFJSONResponseSerializer
    //如果返回的数据是XML类型:那么需要调整manager对响应的解析方式为:AFXMLParserResponseSerializer
    //如果返回的数据既不是JSON也不是XML:AFHTTPResponseSerializer
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    /*
     (1)如果返回的是JSON:不需要处理,默认就是JSON解析
     (2)如果返回的是XML:       manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
     (3)如果不是XML也不是JSON: manager.responseSerializer = [AFHTTPResponseSerializer serializer];
     */
    [manager GET:@"http://www.baidu.com" parameters:nil headers:nil progress:nil  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"success--%@",[[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding]);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error-%@",error);
    }];
}

//网络状态监听
- (void)change {
    //01 创建网络监听管理者对象
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    //02 监听
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        //当监听到网络状态改变的时候就会调用该block,并且把当前的网络状态作为参数传给block
        /*
         AFNetworkReachabilityStatusUnknown          = -1,
         AFNetworkReachabilityStatusNotReachable     = 0,
         AFNetworkReachabilityStatusReachableViaWWAN = 1,
         AFNetworkReachabilityStatusReachableViaWiFi = 2,
         */
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"网络状态未知");
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"没有网络");
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"蜂窝网络 3G|4G");
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WIFI");
                break;
                
            default:
                break;
        }
    }];
    //03 开始监听
    [manager startMonitoring];
}

#pragma mark NSXMLParserDelegate
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict {
    NSLog(@"%@-\n-%@",elementName,attributeDict);
}

@end
