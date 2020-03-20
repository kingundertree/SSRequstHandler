### 概述
1. SSRequestHandler基于AFNetWorking二次开发
2. 结合从业以来大部分IT公司现状，灵活实现业务定制。包括host、method、queries、requestSerializer、responseSerializer定制
3. 通过response处理，block回调，简化请求处理
4. 这里还没有完全验证，更多的是提供了一个框架，可以根据不同的公司业务进一步定制和完善
5. 上传下载业务的流程也是一致的，但需要业务验证

### 请求范例(swift 版本见另外一篇博客)
1. 提供SSBaseApi继承类，并初始化
2. 提供请求参数
3. 触发requestWithCompletionBlock即可
4. 通过返回SSResponse、error，处理业务
```
NSDictionary *bizContent = @{@"UserId":[NSNumber numberWithInteger:0]};
NSDictionary *initDic = @{@"method" : @"*******",
                          @"bizContent" : [NSString jsonStringWithDictionary:bizContent],
                          @"module": @"appguide",
                          @"version": @"3.0",
                          @"clientVersion": @"6.4.2",
};
// OC 模式 GET Request
FFHomeApi *homeApi = [[FFHomeApi alloc] initWithPath:@"/gateway" queries:initDic];
__weak typeof(self) this = self;
[homeApi requestWithCompletionBlock:^(SSResponse * _Nonnull response, NSError * _Nonnull error) {
    if (!error) {
        [this responseHandler:response];
    } else {
        // todo
    }
}];
```

### 核心类
#### SSBaseApi
1. 通过SSBaseApi作为触发网络请求的实例对象
2. 通过SSBaseApi实现request的基本配置，实现host、path、params、serializer、mapCode、callback等
3. 绑定NSURLSessionTask对象，SSBaseApi会存储在SSRequestHandlerManager的mutDicForSaveBaseApiWithIdentify，以NSURLSessionTask.taskIdentifier为标识。request结束会释放

![ssbaseapi.png](http://note.youdao.com/yws/res/10267/WEBRESOURCE28019d45aa84827fc09248d6ed4b0a68)

#### SSRequestHandlerManager
1. 单例对象，负责request的创建和执行。暴露方法比较少
2. 通过SSBaseApi调用
3. 持有AFHTTPSessionManager，可以自行添加，新增TSP证书支持
4. 通过SSBaseApi配置，生成NSURLRequest
5. 通过AFHTTPSessionManager和NSURLRequest，生成NSURLSessionTask
6. 最后通过AFNetWorking的downloadTaskWithRequest实现NSURLSessionDataTask创建
7. 通过SSBaseApi和NSURLSessionDataTask.taskIdentifier作为value和key，实现存储和删除
8. 自定义SSResponse，处理JSON和NSDictionary、SSRequestError

```
- (void)doRequestOnQueue:(SSBaseApi *)baseApi;
- (void)cancleRequest:(SSBaseApi *)baseApi;
- (void)cancleAllRequest;
```

```
// By AFNetWorking
// AFNetWorking的源代码解读可以看另外一篇之前写的博客
- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request
                                             progress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                                          destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                    completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler {
                                    }
```

#### SSRequestProtocol
1. SSRequestProtocal是SSRequestHandlerManager中拦截创建NSULRequest和SSResponse的Protocol
2. SSRequestProtocal比较灵活，包括NSULRequest创建前、即将创建、创建后、请求结束的各种协议。可以灵活的处理SSBaseApi、NSURLRequest、SSResponse，而且不需要浸入代码
3. 这里实现了token、sign、errorFilter协议。可以根据需要创建更多的协议，比如header自定义、SSBaseApi扩展功能、SSResponse业务处理和数据格式校验等


```
/*
 请求前预处理,SSBaseApi数据预处理
 */
- (void)willPrepareRequestForBaseApi:(SSBaseApi *_Nullable)baseApi;

/*
 请求前处理,NSURLRequest 进一步处理
 */
- (NSURLRequest *)prepareRequestForBaseApi:(NSURLRequest *)reqeust baseApi:(SSBaseApi *)baseApi;

/*
 请求发送前,提供给插件进行UI处理
*/
- (void)willSendRequestForBaseApi:(SSBaseApi *)baseApi;

/*
 返回结果处理，比如token 检查，统一error处理
 */
- (void)didReceiveResponseHandler:(id)responseOb baseApi:(SSBaseApi *)baseApi error:(NSError * _Nullable __autoreleasing *)error;

/*
 response 校验，比如数据格式，根据不同业务check
 */
- (BOOL)processionResponse:(SSResponse *)response baseApi:(SSBaseApi *)baseApi error:(NSError * _Nullable __autoreleasing *)error;
```


#### SSRequestSettingConfig
1. 基本的全局配置，比如SSRequestService、appid、deviceId、token、签名公钥、日志开关、plugins等
2. 也可以基于此实现更多类型的host定制、甚至TSP Authentication

```
[SSRequestSettingConfig defaultSettingConfig].appId = @"100001";
[SSRequestSettingConfig defaultSettingConfig].deviceId = @"mnsdnjenrjkjke38dajdjwejd";
[SSRequestSettingConfig defaultSettingConfig].token = @"dskjjjjdj3dsjs";
[SSRequestSettingConfig defaultSettingConfig].secret = @"eiifs9wesdfsjes";
[SSRequestSettingConfig defaultSettingConfig].plugins = @[[SSRequestTokenPlugin new], [SSRequestSignPlugin new], [SSRequestErrorFilterPlugin new]];
[SSRequestSettingConfig defaultSettingConfig].isShowDebugInfo = true;
[SSRequestSettingConfig defaultSettingConfig].service = [[SSRequestService alloc] initWithBaseUrl:@"https://wx.freshfresh.com"];
```

#### SSRequestDebugLog
1. 通过request发出前、请求结束的日志打印。方便debug，可以根据需要提供更多的业务信息


```
// 请求发出前日志
**************************************************************
*                    SSRequest Request Start                 *
**************************************************************

Service:		https://**.********.com
API Name:		/gateway
Method:			GET
HeaderField:
{
    "Accept-Language" = "zh-Hans-US;q=1, en;q=0.9";
    Authorization = "Bearer dskjjjjdj3dsjs";
    "User-Agent" = "SSRequestDirectDemo/1.0 (iPhone; iOS 12.1; Scale/3.00)";
}
Params:
{
    bizContent = "{\"UserId\":0}";
    clientVersion = "6.4.2";
    method = "*********";
    module = appguide;
    version = "3.0";
}
FullRequest:
https://**.********.com/gateway?appId=100001&appVersion=1.0&device=iOS&deviceId=mnsdnjenrjkjke38dajdjwejd&lang=zh-cn&region=cn&timeStamp=20200319174603&bizContent=%7B%22UserId%22%3A0%7D&clientVersion=6.4.2&method=*********&module=appguide&version=3.0&sign=99bc3ea55d28dc5c2f7a8ed0c458e9d7

Body Data:

**************************************************************
*                    SSRequest Request End                    *
**************************************************************

```


```
// 请求结束后日志
**************************************************************
*                  SSRequest Response Start                  *
**************************************************************

Service:		https://**.********.com
API Name:		/gateway
Method:			GET
HeaderField:
{
    "Access-Control-Allow-Origin" = "*";
    Connection = "keep-alive";
    "Content-Length" = 92;
    "Content-Type" = "application/json; charset=UTF-8";
    Date = "Thu, 19 Mar 2020 09:46:04 GMT";
    Server = "nginx/1.4.6 (Ubuntu)";
}
Params:
{
    bizContent = "{\"UserId\":0}";
    clientVersion = "6.4.2";
    method = "HomePageManager.GetHomePageInfo";
    module = appguide;
    version = "3.0";
}
FullRequest:
https://**.********.com/gateway?appId=100001&appVersion=1.0&device=iOS&deviceId=mnsdnjenrjkjke38dajdjwejd&lang=zh-cn&region=cn&timeStamp=20200319174603&bizContent=%7B%22UserId%22%3A0%7D&clientVersion=6.4.2&method=**.********&module=appguide&version=3.0&sign=99bc3ea55d28dc5c2f7a8ed0c458e9d7

Body Data:

Response Data:

**************************************************************
*                 SSRequest Response End                     *
**************************************************************
```

### 锁
1. 通过mutDicForSaveBaseApiWithIdentify是SSBaseApi和task.taskIdentifier的绑定，便于SSBAseApi寻址，实现请求结果回调
2. NSMutableDictionary是非线程安全对象
3. 频繁触发请求，mutDicForSaveBaseApiWithIdentify的调用非常频繁，通过pthread_mutex_t实现数据一致性
4. pthread_mutex_t比NSLock的性能要好一些，推荐


```
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
```


### 主流程
1. SSRequestHandler处理的核心,以单例形式存在 负责NSURLRequest和NSURLSessionTask生成
2. 核心是通过downloadTaskWithRequest触发task并resume()
3. SSBaseApi和SSResponse等都是业务支持需要的自定义实现

![ssrequesthandler.jpg](http://note.youdao.com/yws/res/10376/WEBRESOURCE20e5fd5334a2964327c7cdf1d801df5e)