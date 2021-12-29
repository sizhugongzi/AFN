//
//  ViewController.m
//  XLTestDemo
//
//  Created by apple on 2021/6/5.
//

#import "ViewController.h"
#import "OneViewController.h"
#import <AFNetworking/AFNetworking.h>

@interface ViewController ()<NSURLSessionDelegate>

@end

@implementation ViewController

- (void)oneVC {
    OneViewController *vc = [[OneViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(oneVC) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0 , 0, 44, 44);
    button.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:button];
    
    // 设置rightBarButtonItem
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self multipleRequests];
}

#pragma mark - iOS实现多个网络请求ABC执行完再执行D























#pragma mark - iOS中多个有依赖的网络请求的顺序执行
- (void)multipleRequests {
    //创建串行队列
    dispatch_queue_t customQuue = dispatch_queue_create("com.wumeng.network", DISPATCH_QUEUE_SERIAL);
    //创建信号量并初始化总量为1
    dispatch_semaphore_t semaphoreLock = dispatch_semaphore_create(0);
    //添加任务
    dispatch_async(customQuue, ^{
        //发送第一个请求
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
        
        [manager GET:@"https://www.baidu.com" parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"第一个请求完成");
            //dispatch_semaphore_signal发送一个信号，让信号总量加1,相当于解锁
            dispatch_semaphore_signal(semaphoreLock);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            dispatch_semaphore_signal(semaphoreLock);
        }];
        
        // 相当于加锁
        dispatch_semaphore_wait(semaphoreLock, DISPATCH_TIME_FOREVER);
        //发送第二个请求
        [manager GET:@"https://www.baidu.com" parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"第二个请求完成");
            //dispatch_semaphore_signal发送一个信号，让信号总量加1,相当于解锁
            dispatch_semaphore_signal(semaphoreLock);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            dispatch_semaphore_signal(semaphoreLock);
        }];
        
        // 相当于加锁
        dispatch_semaphore_wait(semaphoreLock, DISPATCH_TIME_FOREVER);
        //发送第三个请求
        [manager GET:@"http://www.baidu.com" parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"第三个请求完成");
            //dispatch_semaphore_signal发送一个信号，让信号总量加1,相当于解锁
            dispatch_semaphore_signal(semaphoreLock);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            dispatch_semaphore_signal(semaphoreLock);
        }];
        
        // 相当于加锁
        dispatch_semaphore_wait(semaphoreLock, DISPATCH_TIME_FOREVER);
        //发送第四个请求
        [manager GET:@"https://www.baidu.com" parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"第四个请求完成");
            //dispatch_semaphore_signal发送一个信号，让信号总量加1,相当于解锁
            dispatch_semaphore_signal(semaphoreLock);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            dispatch_semaphore_signal(semaphoreLock);
        }];
        
        dispatch_semaphore_wait(semaphoreLock, DISPATCH_TIME_FOREVER);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"任务完成");
        });
    });
}

- (void)session {
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:Nil];
    NSURLSessionTask *task = [session dataTaskWithURL:[NSURL URLWithString:@"https://www.baidu.com/"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"error:%@",error);
        NSLog(@"data:%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
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

//三：上传图片操作：
- (void)test5 {
    UIImage *image = [UIImage imageNamed:@"one.png"];
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@", str];
    NSLog(@"fileName == %@",fileName);
    NSDictionary *parameters = @{@"filename":fileName};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //申明请求的数据是json类型
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    //如果报接受类型不一致请替换一致text/html或别的
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:@"https://www.baidu.com" parameters:parameters headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
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

//一:提交数据是JSON格式
- (void)test2 {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@"apple" forKey:@"brand"];
    NSString *url = @"https://www.baidu.com/";
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
