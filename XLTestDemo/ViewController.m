//
//  ViewController.m
//  XLTestDemo
//
//  Created by apple on 2021/6/5.
//

#import "ViewController.h"
#import <AFNetworking/AFNetworking.h>

@interface ViewController ()<NSURLSessionDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    //是否支持非法的证书（例如自签名证书）
//    @property (nonatomic, assign) BOOL allowInvalidCertificates;
    //是否去验证证书域名是否匹配
//    @property (nonatomic, assign) BOOL validatesDomainName;
    //Https单向认证和双向认证。Https单向认证和双向认证
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self session];
}

- (void)session {
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:Nil];
    NSURLSessionTask *task = [session dataTaskWithURL:[NSURL URLWithString:@"https://www.baidu.com/"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        NSLog(@"error:%@",error);
//        NSLog(@"data:%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"NSURLResponse");
    }];
    [task resume];
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {
    NSLog(@"didReceiveChallenge method of NSURLSessionDelegate called successfully");
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    }
}

- (void)test6 {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:@"https://www.baidu.com"]];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", dataStr);
    }];
    [task resume];
}



//如果接口返回的 Content-Type 和实际情况不合时，有时候是因为后端开发人员不规范，更有遇到一套接口中大多都是JSON返回，还有个别方法返回纯文本，如：“YES”，这些都是接口开发人员不规范导致的问题，作为iOS端，解决方案：
//
//responseSerializer 使用 AFHTTPResponseSerializer，这样就不能享受 AFNetworking 自带的JSON解析功能了，拿到 responseObject 就是一个　Data 对象，需要自己根据需要进行反序列化。
#pragma mark - Public Method
- (void)postWithManager:(id)requestOperationManager
                success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    [manager POST:@"hhts://www.baidu.com" parameters:nil headers:nil
         progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //成功
        if (success) {
            success(task,responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if(failure) {
            failure(task,error);
        }
    }];
}

- (void)test5 {
    //三：上传图片操作：
    UIImage *image = [UIImage imageNamed:@"one.png"];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@", str];
    NSLog(@"fileName == %@",fileName);
    NSDictionary *parameters = @{@"filename":fileName};
    
    //申明请求的数据是json类型
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    //如果报接受类型不一致请替换一致text/html或别的
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:@"http://XXX" parameters:parameters headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        // 上传图片，以文件流的格式
        [formData appendPartWithFileData:imageData name:@"img" fileName:fileName mimeType:@"image/png"];
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failure");
    }];
}

//四：下载图片
- (void)test4 {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:@"http://pic2.ooopic.com/13/70/05/91b1OOOPIC59.jpg"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSLog(@"File downloaded to: %@", filePath);
    }];
    [downloadTask resume];
}

- (void)test2 {
    //一:提交数据是JSON格式
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setObject:@"apple" forKey:@"brand"];
    NSString *url=@"http://xxxxx";
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//申明返回的结果是json类型
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];//如果报接受类型不一致请替换一致text/html或别的
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//申明请求的数据是json类型
    [manager POST:url parameters:dict headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"success");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failure");
    }];
}

- (void)test {
    NSURL *originalURL = [NSURL URLWithString:@"http://hello.com/news"];
    NSLog(@"%@", [originalURL URLByAppendingPathComponent:@""]);
    //http://hello.com/news/
    NSLog(@"%@", [originalURL URLByAppendingPathComponent:@"local"]);
    //http://hello.com/news/local
    NSLog(@"%@", [originalURL URLByAppendingPathExtension:@"local"]);
    //http://hello.com/news.local
}

- (void)test1 {
    NSURL *baseURL = [NSURL URLWithString:@"http://example.com/v1/"];
    [NSURL URLWithString:@"foo" relativeToURL:baseURL];
    // http://example.com/v1/foo
    [NSURL URLWithString:@"/foo" relativeToURL:baseURL];
    // 如果相对路径以/开始，根据规则，URL 最终会拼装为http://example.com/foo
    [NSURL URLWithString:@"http://example2.com/" relativeToURL:baseURL];
    // http://example2.com/，因为 URLString 并不是相对的 path 部分，而是完整的 URL，所以最终的值会忽略掉 baseURL。
}

- (void)func1 {
    NSString *userAgent = @"中华人民共和国";
    NSMutableString *mutableUserAgent = [userAgent mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)(mutableUserAgent), NULL, (__bridge CFStringRef)@"Any-Latin", false);
    NSLog(@"%@",mutableUserAgent);
    NSLog(@"%@",userAgent);
}

- (void)func2 {
    NSString *userAgent = @"中华人民共和国";
    NSMutableString *mutableUserAgent = [userAgent mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)(mutableUserAgent), NULL, (__bridge CFStringRef)@"Any-Latin; Latin-ASCII", false);
    NSLog(@"%@",mutableUserAgent);
    NSLog(@"%@",userAgent);
}

@end
