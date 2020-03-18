//
//  SSRequestHandler.m
//  AFNetworking
//
//  Created by ixiazer on 2020/3/11.
//

#import "SSRequestHandlerManager.h"
#import <pthread/pthread.h>
#import "NSString+SSRequest.h"
#import "NSObject+SSRequest.h"
#import "SSRequestProtocal.h"
#import "SSRequestSerializer.h"
#import "NSError+SSRequest.h"
#import "NSHTTPURLResponse+SSRequest.h"
#import "SSRequestDebugLog.h"
#import "SSRequestSettingConfig.h"

// block parmas
/*
 强制主线程执行
 */
void runOnMainQueue(void (^block)(void)) {
    if ([NSThread isMainThread]){
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
};

@interface SSRequestHandlerManager ()
@property (nonatomic, strong) NSMutableDictionary *mutDicForSaveBaseApiWithIdentify;

@property (nonatomic, strong) AFHTTPSessionManager *defaultSessionManager;
@property (nonatomic, strong) AFHTTPSessionManager *authenticationSessionManager;
@property (nonatomic, strong) AFJSONResponseSerializer *jsonResponseSerializer;
@property (nonatomic, strong) AFXMLParserResponseSerializer *xmlParserResponseSerialzier;
@end

@implementation SSRequestHandlerManager {
    pthread_mutex_t m_lock; // 代替NSLock，锁性能高一些
}

// MARK: - life event
+ (SSRequestHandlerManager *)defaultHandler {
    static SSRequestHandlerManager *defaultHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultHandler = [[SSRequestHandlerManager alloc] init];
    });
    
    return defaultHandler;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.mutDicForSaveBaseApiWithIdentify;
        pthread_mutex_init(&m_lock, NULL);
    }
    return self;
}

// MARK:- reqeust method
- (void)doRequestOnQueue:(SSBaseApi *)baseApi {
    // 非空判断
    NSParameterAssert(baseApi != nil);

    // 创建task，并resume
    NSError *error;
    [self _sessionTaskFor:baseApi error:&error];
    
    if (error) {
        SSRequestHandlerCallback requestHandlerCallback = baseApi.requestHandlerCallback;
        if (requestHandlerCallback) {
            runOnMainQueue(^{
                requestHandlerCallback(nil, error);
            });
        }
    }
}

- (void)cancleRequest:(SSBaseApi *)baseApi {
    // 非空判断
    NSParameterAssert(baseApi != nil);
    
    [self _doRequestUntying:baseApi];
}

- (void)cancleAllRequest {
    pthread_mutex_lock(&m_lock);
    NSArray *allKey = _mutDicForSaveBaseApiWithIdentify.allKeys;
    pthread_mutex_unlock(&m_lock);
    
    if (allKey && allKey.count > 0) {
        NSArray *copyKey = [allKey copy];
        for (NSString *key in copyKey) {
            pthread_mutex_lock(&m_lock);
            SSBaseApi *baseApi = [_mutDicForSaveBaseApiWithIdentify objectForKey:key];
            pthread_mutex_unlock(&m_lock);

            [self cancleRequest:baseApi];
        }
    }
}

// MARK:- _标记内内部实现方法
// MARK:- 通过SSBaseApi创建Task
/*
 NSURLSessionTask创建，需要处理插件的SSRequestProtocal
 */
- (NSURLSessionDataTask *)_sessionTaskFor:(SSBaseApi *)baseApi error:(NSError *_Nullable __autoreleasing *)error {
    // 1. SSBaseApi 预处理
    [self.plugins enumerateObjectsUsingBlock:^(id <SSRequestProtocal> onePlugin, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([onePlugin respondsToSelector:@selector(willPrepareRequestForBaseApi:)]) {
            [onePlugin willPrepareRequestForBaseApi:baseApi];
        }
    }];
    
    // 2. 创建NSURLRequest
    NSURLRequest *request = [self _prepareForRequest:baseApi error:error];
    
    if (!request || *error) {
        return nil;
    }

    // 3. NSURLRequest通过SSRequestProtocal，进一步处理,包括header、token、公共参数、sign等
    __block NSURLRequest *blockRequest = request;
    [self.plugins enumerateObjectsUsingBlock:^(id <SSRequestProtocal> onePlugin, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([onePlugin respondsToSelector:@selector(prepareRequestForBaseApi:baseApi:)]) {
            blockRequest = [onePlugin prepareRequestForBaseApi:blockRequest baseApi:baseApi];
        }
    }];
    
    // 4. 创建NSURLSessionTask，并resumem，区分普通request和download request
    NSURLSessionTask *task;
    AFURLSessionManager *sesson = [self _sesionForBaseApi:baseApi];
    if (baseApi.downloadPath) {
        // 下载request task
        task = [self _requestForDownloadTask:sesson request:blockRequest downloadPath:baseApi.downloadPath processBlock:baseApi.progressCallback error:error];
    } else {
        // 普通request task
        task = [self _requestForDataTask:sesson request:blockRequest error:error];
    }
    // 请求前日志
    [[SSRequestDebugLog sharedInstance] showReponseStartInfo:baseApi request:blockRequest];
    
    [task resume];
    baseApi.requestTask = task;
    [self _doRequsetBind:baseApi];
    
    return nil;
}

// MARK:- 创建NSURLRequest
- (NSURLRequest *)_prepareForRequest:(SSBaseApi *)baseApi error:(NSError *_Nullable __autoreleasing *)error {
    // 1. request 序列化
    AFHTTPRequestSerializer *reqeustSerializer = [SSRequestSerializer requestSerizlizerForAPI:baseApi];
    
    // SerializationBlock 解读todo
    if (self.queryStringSerializationBlock) {
        [reqeustSerializer setQueryStringSerializationWithBlock:self.queryStringSerializationBlock];
    }
    
    // 2. 获取urlString
    NSString *baseApiString = [NSString requestUrlStringForBaseApi:baseApi];
    // 3. 获取method
    NSString *methodString = [NSString methodMap:baseApi.mehod];
    // 4. 获取参数
    id params = [baseApi requestArgument];
    // 5. 是否通过block组装数据
    SSRequestConstructingBlock constructingBlock = baseApi.constructingBlock;
    // 6. 创建request
    NSMutableURLRequest *mutableURLRequest;
    if (constructingBlock) {
        mutableURLRequest = [reqeustSerializer multipartFormRequestWithMethod:methodString
                                                                    URLString:baseApiString
                                                                   parameters:params
                                                    constructingBodyWithBlock:constructingBlock
                                                                        error:&error];
    } else {
        mutableURLRequest = [reqeustSerializer requestWithMethod:methodString
                                                       URLString:baseApiString
                                                      parameters:params
                                                           error:&error];
    }
    
    return mutableURLRequest;
}

// MARK:- 创建NSURLSessionTask
- (NSURLSessionDataTask *)_requestForDataTask:(AFURLSessionManager *)sessionManager
                                      request:(NSURLRequest *)request
                                        error:(NSError *_Nullable __autoreleasing *)error {
    __weak typeof(self) this = self;
    __block NSURLSessionDataTask *dataTask;
    dataTask = [sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error) {
        [this _handSSResponseForTask:dataTask
                     sessionManager:sessionManager
                     responseObject:responseObject
                             request:request
                               error:error];
    }];
    
    return dataTask;
}

// 下载成功前，resume data会指定到缓存目录，SSRequestHandler会自定义缓存目录，用户下载任务的重启和续传、续存，用户不需要关心
- (NSURLSessionDownloadTask *)_requestForDownloadTask:(AFHTTPSessionManager *)sessionManager
                                              request:(NSURLRequest *)request
                                         downloadPath:(NSString *)downloadPath
                                         processBlock:(SSRequestHandlerProgressBlock)processBlock
                                                error:(NSError *_Nullable __autoreleasing *)error {

    NSString *finaleDownloadPath;
    // 检查下载路径是否存在
    BOOL isDirectory;
    if (![[NSFileManager defaultManager] fileExistsAtPath:downloadPath isDirectory:&isDirectory]) {
        isDirectory = NO;
    }
    
    if (isDirectory) {
        // 组合最终地址
        NSString *fileName = [request.URL lastPathComponent];
        finaleDownloadPath = [NSString pathWithComponents:@[downloadPath, fileName]];
    } else {
        // 自定义随机机制
        finaleDownloadPath = downloadPath;
    }
    
    // 检查是否有下载的缓存数据
    NSString *resumeDataPathUrl = [self _fullDownloadCachePathUrl:downloadPath];
    BOOL isResumeDataExists = [[NSFileManager defaultManager] fileExistsAtPath:resumeDataPathUrl];
    NSData *resumeData = [NSData dataWithContentsOfFile:resumeDataPathUrl];
    
    // 检查resume data的合法性
    BOOL isResumeDataValid = [NSObject validateResumeData:resumeData];
    // 是否可采用恢复数据方式下载
    BOOL canBeResumed = isResumeDataExists && isResumeDataValid;
    
    __block NSURLSessionDownloadTask *downloadTask;
    BOOL isResumeDataSuc = NO;
    // 可以恢复数据，则先try。try失败，则直接下载
    if (canBeResumed) {
        @try {
            __weak typeof(self) this = self;
            downloadTask = [sessionManager downloadTaskWithResumeData:resumeData
                                              progress:processBlock
                                           destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                return [NSURL fileURLWithPath:finaleDownloadPath isDirectory:NO];
            } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                [this _handSSResponseForTask:downloadTask
                             sessionManager:sessionManager
                             responseObject:response
                                     request:request
                                       error:error];
            }];
            
            isResumeDataSuc = YES;
        } @catch (NSException *exception) {
            isResumeDataSuc = NO;
        }
    }
    
    if (isResumeDataSuc == NO) {
        // 包括不需要resume data 和resume data失败 2种case
        __weak typeof(self) this = self;
        downloadTask = [sessionManager downloadTaskWithRequest:request
                                       progress:processBlock
                                    destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            return [NSURL fileURLWithPath:finaleDownloadPath isDirectory:NO];
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            [this _handSSResponseForTask:downloadTask
                         sessionManager:sessionManager
                         responseObject:response
                                 request:request
                                  error:error];
        }];
    }
    
    return downloadTask;
}

// MARK:- response handler method
- (void)_handSSResponseForTask:(NSURLSessionTask *)task
               sessionManager:(AFURLSessionManager *)sessionManager
               responseObject:(id)responseObject
                      request:(NSURLRequest *)request
                        error:(NSError *)error {
    SSBaseApi *baseApi = [self _taskForBaseApi:task session:sessionManager];
    if (!baseApi) {
        return;
    }
    
    // 预处理基础response
    for (id <SSRequestProtocal>plugin in self.plugins) {
        if ([plugin respondsToSelector:@selector(didReceiveResponseHandler:baseApi:error:)]) {
            [plugin didReceiveResponseHandler:responseObject baseApi:baseApi error:&error];
        }
    }
    
    NSURLResponse *response = task.response;
    NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
    if (!error && ![[baseApi acceptStatusCode] containsIndex:statusCode]) {
        // 无但statusCode不符合要求，需要自定义error
        error = [NSError errorWithDescription:[NSString stringWithFormat:@"Incorrect Status Code: %@", @(statusCode)]];
    }
    
    id resultObject;
    NSString *responseString;
    if (!error && [responseObject isKindOfClass:[NSData class]]) {
        // 无error，且responseObject为NSData类型，可正常序列化
        responseString = [self _responseString:responseObject urlResponse:response];
        
        // error 入参 todo check
        resultObject = [self _responseObjectSerializer:response responseObject:responseObject responseSerializerType:baseApi.responseSerializerType error:&error];
    } else {
        // 下载类todo
    }
    
    if (!error) {
        // response 后续check，根据业务定制，比如特定的数据结构，resultObject选型不好，不过方便前置处理
        error = [baseApi validateResponse:resultObject];
    }
    
    // resultObject 转SSResponse
    SSResponse *ssResponse = [[SSResponse alloc] initWithURLResponse:response
                                                        responseData:responseObject
                                                        resultObject:resultObject
                                                      responseString:responseString
                                                               error:&error];

    [self _doResponseFinish:baseApi response:ssResponse request:request error:error];
}

// response callback
- (void)_doResponseFinish:(SSBaseApi *)baseApi response:(SSResponse *)response request:(NSURLRequest *)request error:(NSError *)error {
    SSRequestHandlerCallback requestHandlerCallback = baseApi.requestHandlerCallback;
    if (requestHandlerCallback) {
        for (id <SSRequestProtocal>plugin in self.plugins) {
            if ([plugin respondsToSelector:@selector(processionResponse:baseApi:error:)]) {
                [plugin processionResponse:response baseApi:baseApi error:&error];
            }
        }
        
        runOnMainQueue(^{
            // 打印请求结束信息
            [[SSRequestDebugLog sharedInstance] showReponseEndInfo:baseApi response:response request:request];
            requestHandlerCallback(response, error);
        });
    
        [self _doRequestUntying:baseApi];
    }
}

// MARK:- responseSerial 处理
- (id)_responseObjectSerializer:(NSURLResponse *)response responseObject:(id)responseObject  responseSerializerType:(SSResponseSerializerType)responseSerializerType error:(NSError * _Nullable __autoreleasing *)error {
    id resultObject;
    switch (responseSerializerType) {
        case SSResponseSerializerTypeJSON:
            return [self.jsonResponseSerializer responseObjectForResponse:response data:responseObject error:&error];
            
        case SSResponseSerializerTypeXML:
            return [self.xmlParserResponseSerialzier responseObjectForResponse:response data:responseObject error:&error];
        default:
            return nil;
            break;
    }
}

- (NSString *)_responseString:(id)responseObject urlResponse:(NSURLResponse *)urlResponse {
    NSString *responseString;
    
    NSStringEncoding encoding = NSUTF8StringEncoding;
    if ([urlResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        encoding = [(NSHTTPURLResponse *)urlResponse stringEncoding];
    }
    
    responseString = [[NSString alloc] initWithData:responseObject
                                           encoding:encoding];

    return responseString;
}

// MARK:- SSBaseApi和identity的绑定和解绑
/*
 绑定request，创建的时候存入
 */
- (void)_doRequsetBind:(SSBaseApi *)baseApi {
    if (!baseApi || !baseApi.requestTask) {
        return;
    }

    pthread_mutex_lock(&m_lock);
    [_mutDicForSaveBaseApiWithIdentify setObject:baseApi forKey:[self _keyForBaseApi:baseApi]];
    pthread_mutex_unlock(&m_lock);
}

/*
 通过task寻找SSBaseApi
 */
- (SSBaseApi *)_taskForBaseApi:(NSURLSessionTask *)task session:(AFHTTPSessionManager *)session {
    if (!task) {
        return nil;
    }
    
    SSRequestHandlerSessionType sessionType = SSRequestHandlerSessionTypeDefault;
    if (session == self.authenticationSessionManager) {
        sessionType = SSRequestHandlerSessionTypeAuthentication;
    }
    
    NSString *sesstionKey = [self _combineBaseApiKey:sessionType identifier:task.taskIdentifier];
    
    SSBaseApi *baseApi = nil;
    pthread_mutex_lock(&m_lock);
    if (_mutDicForSaveBaseApiWithIdentify[sesstionKey]) {
        baseApi = _mutDicForSaveBaseApiWithIdentify[sesstionKey];
    }
    pthread_mutex_unlock(&m_lock);
    
    return baseApi;
}

/*
 取消request，包括主动取消和网络请求结束
*/
- (void)_doRequestUntying:(SSBaseApi *)baseApi {
    if (baseApi && baseApi.requestTask) {
        pthread_mutex_lock(&m_lock);
        
        if (_mutDicForSaveBaseApiWithIdentify) {
            NSURLSessionTask *task = baseApi.requestTask;
            NSURL *resumeDataPathUrl;
            if (baseApi.downloadPath) {
                // 考虑下载request处理
                resumeDataPathUrl = [self _fullDownloadCachePathUrl:baseApi.downloadPath];
            }
            
            [self _canleOneTask:baseApi.requestTask resumeDataPath:resumeDataPathUrl];
            
            [_mutDicForSaveBaseApiWithIdentify removeObjectForKey:[self _keyForBaseApi:baseApi]];
        }
        
        pthread_mutex_unlock(&m_lock);
    }
}

/*
 NSURLSessionTask cancle，包括NSURLSessionDataTask和NSURLSessionDownloadTask 2类task
 */
- (void)_canleOneTask:(NSURLSessionTask *)task resumeDataPath:(NSURL *)resumeDataPath {
    if (task && task.state != NSURLSessionTaskStateCompleted) {
        if ([task isKindOfClass:[NSURLSessionDataTask class]]) {
            [task cancel];
        }
        
        if ([task isKindOfClass:[NSURLSessionDownloadTask class]]) {
            NSURLSessionDownloadTask *downloadTask = task;
            if (resumeDataPath) {
                [downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                    [resumeData writeToURL:resumeDataPath atomically:true];
                }];
            } else {
                [downloadTask cancel];
            }
        }
    }
}

/*
 获取SSBaseApi的sessionManager
 */
- (AFURLSessionManager *)_sesionForBaseApi:(SSBaseApi *)baseApi {
    switch (baseApi.sessionType) {
        case SSRequestHandlerSessionTypeAuthentication:
            return self.authenticationSessionManager;
            
        default:
            return self.defaultSessionManager;
    }
}

/*
 获取_mutDicForSaveBaseApiWithIdentify缓存的baseApi key, 考虑后期兼容不同业务类型的session 配置
 */
- (NSString *)_keyForBaseApi:(SSBaseApi *)baseApi {
    return [self _combineBaseApiKey:baseApi.sessionType identifier:baseApi.requestTask.taskIdentifier ?: 0];
}

- (NSString *)_combineBaseApiKey:(NSInteger)sessionType identifier:(NSInteger)identifier {
    return [NSString stringWithFormat:@"%@-%@", @(sessionType), @(identifier ?: 0)];
}

// MARK:- request host + path


// MARK:- 下载缓存路径
/*
 获取完整的下载缓存路径
 */
- (NSURL *)_fullDownloadCachePathUrl:(NSString *)downloadPath {
    NSString *md5PathString = [downloadPath md5StringFromCString];
    NSString *fullPathString = [[NSString defaultDownloadTempCacheFolder] stringByAppendingString:md5PathString];
    NSURL *resumeDataPathUrl = [NSURL fileURLWithPath:fullPathString];
    
    return resumeDataPathUrl;
}


#pragma mark - get method
- (NSArray *)plugins {
    return [SSRequestSettingConfig defaultSettingConfig].plugins;
}

// 默认sessionManager
- (AFHTTPSessionManager *)defaultSessionManager {
    if (!_defaultSessionManager) {
        _defaultSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:nil sessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        _defaultSessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _defaultSessionManager.securityPolicy = [AFSecurityPolicy defaultPolicy];;
    }
    
    return _defaultSessionManager;
}

- (AFHTTPSessionManager *)authenticationSessionManager {
    if (!_authenticationSessionManager) {
        _authenticationSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:nil sessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        _authenticationSessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        // 待实现验证 todo
//        AFSecurityPolicy *tspSlecialSecurityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
//        NSMutableSet *certSetSpecial = [[NSMutableSet alloc]init];
//        #if (defined DEBUG) || (defined TEST)
//                [certSetSpecial addObjectsFromArray:[MQTTCer pinnedCertificatesForEnv: MQTTCerEvnDev]];
//                [certSetSpecial addObjectsFromArray:[MQTTCer pinnedCertificatesForEnv: MQTTCerEvnTest]];
//                [certSetSpecial addObjectsFromArray:[MQTTCer pinnedCertificatesForEnv: MQTTCerEvnStaging]];
//        #endif
//        [certSetSpecial addObjectsFromArray:[MQTTCer pinnedCertificatesForEnv: MQTTCerEvnProduct]];
//        [tspSlecialSecurityPolicy setPinnedCertificates:certSetSpecial];
//        [tspSlecialSecurityPolicy setAllowInvalidCertificates:YES];
//        [tspSlecialSecurityPolicy setValidatesDomainName:YES];
//        [self setTspSpecialTwoWayAuthSecurityPolicy:tspSlecialSecurityPolicy];
//        [self setGetTspSpecialP12InfoBlock:^SecIdentityRef(NSString *host) {
//            NSArray *cers = [MQTTCer p12CertificateForEnv:[NIONetKitConfig mqttCerEnv]];
//            for (id cer in cers) {
//                SecIdentityRef ref = (__bridge SecIdentityRef)(cer);
//                if (ref) {
//                    return ref;
//                }
//            }
//            return nil;
//        }];
//        _authenticationSessionManager.securityPolicy = tspSlecialSecurityPolicy;
    }
    
    return _authenticationSessionManager;
}

- (NSMutableDictionary *)mutDicForSaveBaseApiWithIdentify {
    if (!_mutDicForSaveBaseApiWithIdentify) {
        _mutDicForSaveBaseApiWithIdentify = [NSMutableDictionary new];
    }
    return _mutDicForSaveBaseApiWithIdentify;
}

- (AFJSONResponseSerializer *)jsonResponseSerializer {
    if (!_jsonResponseSerializer) {
        _jsonResponseSerializer = [AFJSONResponseSerializer serializer];
        _jsonResponseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/x-www-form-urlencoded", @"application/json", @"text/plain", nil];
        _jsonResponseSerializer.acceptableStatusCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(100, 500)];
    }
    return _jsonResponseSerializer;
}

- (AFXMLParserResponseSerializer *)xmlParserResponseSerialzier {
    if (!_xmlParserResponseSerialzier) {
        _xmlParserResponseSerialzier = [AFXMLParserResponseSerializer serializer];
        _xmlParserResponseSerialzier.acceptableStatusCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(100, 500)];
    }
    return _xmlParserResponseSerialzier;
}

@end
