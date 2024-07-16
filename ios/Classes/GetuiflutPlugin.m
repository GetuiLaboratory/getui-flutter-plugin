#import "GetuiflutPlugin.h"
#import <GTSDK/GeTuiSdk.h>
#import <PushKit/PushKit.h>

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif

@interface GtSdkManager : NSObject
+ (GtSdkManager *)sharedInstance;
//用于上报回执&回调
- (void)Getui_didReceiveRemoteNotificationInner:(NSDictionary*)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;
@end

@interface GetuiflutPlugin()<GeTuiSdkDelegate> {
    BOOL _started; 
    NSDictionary *_launchNotification;
    NSDictionary *_apnsSlienceUserInfo;
}
@end

@implementation GetuiflutPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"getuiflut"
                                     binaryMessenger:[registrar messenger]];
    GetuiflutPlugin *instance = [[GetuiflutPlugin alloc] init];
    instance.channel = channel;
    [registrar addApplicationDelegate:instance];
    [registrar addMethodCallDelegate:instance channel:channel];
    //  [instance registerRemoteNotification];
}

- (id)init {
    self = [super init];
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    } else if([@"startSdk" isEqualToString:call.method]) {
        [self startSdk:call result:result];
    } else if([@"startSdkSimple" isEqualToString:call.method]) {
        [self onlyStartSdk:call result:result];
    } else if([@"registerRemoteNotification" isEqualToString:call.method]) {
        [self registerRemoteNotification:call result:result];
    } else if([@"bindAlias" isEqualToString:call.method]) {
        [self bindAlias:call result:result];
    } else if([@"unbindAlias" isEqualToString:call.method]) {
        [self unbindAlias:call result:result];
    } else if([@"setTag" isEqualToString:call.method]) {
        [self setTag:call result:result];
    } else if([@"getClientId" isEqualToString:call.method]) {
        result([GeTuiSdk clientId]);
    } else if([@"setBadge" isEqualToString:call.method]) {
        [self setBadge:call result:result];
    } else if([@"resetBadge" isEqualToString:call.method]) {
        [GeTuiSdk resetBadge];
    } else if([@"setLocalBadge" isEqualToString:call.method]) {
        [self setLocalBadge:call result:result];
    } else if([@"setPushMode" isEqualToString:call.method]) {
        [self setPushMode:call result:result];
    } else if([@"resume" isEqualToString:call.method]) {
        //        [GeTuiSdk resume];
    } else if([@"getLaunchNotification" isEqualToString:call.method]) {
        result(_launchNotification ?: @{});
    } else if([@"sdkVersion" isEqualToString:call.method]) {
        result([GeTuiSdk version]);
    } else if([@"registerLiveActivity" isEqualToString:call.method]) {
        [self registerLiveActivity:call result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)startSdk:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSLog(@"\n>>>GTSDK startSdk");
    _started = YES;
    NSDictionary *ConfigurationInfo = call.arguments;
    [GeTuiSdk startSdkWithAppId:ConfigurationInfo[@"appId"] appKey:ConfigurationInfo[@"appKey"] appSecret:ConfigurationInfo[@"appSecret"] delegate:self launchingOptions:_launchNotification ?: @{}];
    
    // 注册远程通知
    [GeTuiSdk registerRemoteNotification: (UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge)];
}

- (void)onlyStartSdk:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSLog(@"\n>>>GTSDK onlyStartSdk");
    _started = YES;
    NSDictionary *ConfigurationInfo = call.arguments;
    [GeTuiSdk startSdkWithAppId:ConfigurationInfo[@"appId"] appKey:ConfigurationInfo[@"appKey"] appSecret:ConfigurationInfo[@"appSecret"] delegate:self launchingOptions:_launchNotification ?: @{}];
}

- (void)registerRemoteNotification:(FlutterMethodCall*)call result:(FlutterResult)result {
    [GeTuiSdk registerRemoteNotification: (UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge)];
}

/// MARK: - AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if (launchOptions != nil) {
        NSLog(@"\n>>>GTSDK didFinishLaunchingWithOptions %@", launchOptions);
        _launchNotification = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    }
    return YES;
}

/// MARK: - 远程通知(推送)回调

/** 远程通知注册成功委托 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // [3]:向个推服务器注册deviceToken 为了方便开发者，建议使用新方法
    //    [GeTuiSdk registerDeviceTokenData:deviceToken];
    NSString *token = [self getHexStringForData:deviceToken];
    NSLog(@"\n>>>GTSDK [DeviceToken(NSString)]: %@\n\n", token);
    [_channel invokeMethod:@"onRegisterDeviceToken" arguments:token];
}

/** 远程通知注册失败委托 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"\n>>>GTSDK didFailToRegisterForRemoteNotificationsWithError");
}

- (BOOL)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"\n>>>GTSDK didReceiveRemoteNotification %@ _started:%@", userInfo, @(_started));
    if (_started) {
        /*
         注释下面代码，因为开发者在appdelegate.m中重写application:didReceiveRemoteNotification:fetchCompletionHandler后，个推hook就正常了。此处不需要再转发给个推
         */
        //sdk已启动，收到APNs静默, 回执&回调
        //[[GtSdkManager sharedInstance] Getui_didReceiveRemoteNotificationInner:userInfo fetchCompletionHandler:completionHandler];
    } else {
        //sdk未启动，收到APNs静默后启动sdk。记录到内存，等cid在线后，回执&回调
        _apnsSlienceUserInfo = userInfo;
        //completionHandler(UIBackgroundFetchResultNewData); //注释，因为会导致flutter日志打印多份。
    }
    return YES;
}

/// MARK: - APP运行中接收到通知(推送)处理 - iOS 10以下版本收到推送

/// MARK: - GeTuiSdkDelegate
- (void)GetuiSdkGrantAuthorization:(BOOL)granted error:(NSError *)error {
    NSLog(@"\n>>>GTSDK GetuiSdkGrantAuthorization: granted:%@ error:%@", @(granted), error);

    [_channel invokeMethod:@"onGrantAuthorization" arguments:[NSString stringWithFormat:@"%@",@(granted)]];
}
/** SDK启动成功返回cid */
- (void)GeTuiSdkDidRegisterClient:(NSString *)clientId {
    // [ GTSdk ]：个推SDK已注册，返回clientId
    NSLog(@"\n>>>GTSDK RegisterClient:%@", clientId);
    if ([clientId isEqualToString:@""]) {
        return;
    }
    
    [_channel invokeMethod:@"onReceiveClientId" arguments:clientId];
    
    if (_apnsSlienceUserInfo) {
        [[GtSdkManager sharedInstance] Getui_didReceiveRemoteNotificationInner:_apnsSlienceUserInfo fetchCompletionHandler:nil];
        _apnsSlienceUserInfo = nil;
    }
}

/// 通知展示（iOS10及以上版本）
/// @param center center
/// @param notification notification
/// @param completionHandler completionHandler
- (void)GeTuiSdkNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification completionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSLog(@"\n>>>GTSDK willPresentNotification :%@", notification.request.content.userInfo);
    // 根据APP需要，判断是否要提示用户Badge、Sound、Alert
    completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
    [_channel invokeMethod:@"onWillPresentNotification" arguments:notification.request.content.userInfo];
}

- (void)GeTuiSdkDidReceiveNotification:(NSDictionary *)userInfo notificationCenter:(UNUserNotificationCenter *)center response:(UNNotificationResponse *)response fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSDate *time = response.notification.date;
    //    NSDictionary *userInfo = response.notification.request.content.userInfo;
    NSLog(@"\n>>>GTSDK %@\nTime:%@\n%@", NSStringFromSelector(_cmd), time, userInfo);
    [_channel invokeMethod:@"onReceiveNotificationResponse" arguments:userInfo];
    if (completionHandler) {
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

- (void)GeTuiSdkNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(UNNotification *)notification {
    NSLog(@"\n>>>GTSDK openSettingsForNotification :%@", notification.request.content.userInfo);
    [_channel invokeMethod:@"onOpenSettingsForNotification" arguments:notification.request.content.userInfo];
}

- (void)GeTuiSdkDidReceiveSlience:(NSDictionary *)userInfo fromGetui:(BOOL)fromGetui offLine:(BOOL)offLine appId:(NSString *)appId taskId:(NSString *)taskId msgId:(NSString *)msgId fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSString *payloadMsg = userInfo[@"payload"];
    NSDictionary *payloadMsgDic = @{ @"taskId": taskId ?: @"", @"messageId": msgId ?: @"", @"payloadMsg" : payloadMsg, @"offLine" : @(offLine), @"fromGetui": @(fromGetui)};
    NSLog(@"\n>>>GTSDK GeTuiSdkDidReceiveSlience:%@", payloadMsgDic);
    [_channel invokeMethod:@"onReceivePayload" arguments:payloadMsgDic];
    
}

/// MARK: - AppLink

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nonnull))restorationHandler {
    //系统用 NSUserActivityTypeBrowsingWeb 表示对应的 universal HTTP links 触发
    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        NSURL* webUrl = userActivity.webpageURL;
        
        //处理个推APPLink回执统计
        //APPLink url 示例：https://link.applk.cn/getui?n=payload&p=mid， 其中 n=payload 字段存储下发的透传信息，可以根据透传内容进行业务操作。
        NSString *payload = [GeTuiSdk handleApplinkFeedback:webUrl];
        if (payload) {
            NSLog(@"\n>>>GTSDK 个推APPLink中携带的透传payload信息: %@,URL : %@", payload, webUrl);
            //TODO:用户可根据具体 payload 进行业务处理
            [_channel invokeMethod:@"onAppLinkPayload" arguments:payload];
            return YES;
        }
    }
    return NO;
}


/// MARK: - GTSDKfunction

- (void)bindAlias:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *ConfigurationInfo = call.arguments;
    [GeTuiSdk bindAlias:ConfigurationInfo[@"alias"] andSequenceNum:ConfigurationInfo[@"aSn"]];
}

- (void)unbindAlias:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *ConfigurationInfo = call.arguments;
    [GeTuiSdk unbindAlias:ConfigurationInfo[@"alias"] andSequenceNum:ConfigurationInfo[@"aSn"] andIsSelf:ConfigurationInfo[@"isSelf"]];
}

- (void)setTag:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *ConfigurationInfo = call.arguments;
    [GeTuiSdk setTags:ConfigurationInfo[@"tags"]];
}

- (void)setBadge:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *ConfigurationInfo = call.arguments;
    NSUInteger value = [ConfigurationInfo[@"badge"] integerValue];
    [GeTuiSdk setBadge:value];
}

- (void)setLocalBadge:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *ConfigurationInfo = call.arguments;
    NSInteger value = [ConfigurationInfo[@"badge"] integerValue];
    [UIApplication sharedApplication].applicationIconBadgeNumber = value;
}

- (void)setPushMode:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *ConfigurationInfo = call.arguments;
    BOOL value = [ConfigurationInfo[@"mode"] boolValue];
    [GeTuiSdk setPushModeForOff:value];
}

- (void)registerLiveActivity:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *ConfigurationInfo = call.arguments;
//  NSLog(@"GeTuiSdkDidRegisterLiveActivity %@", ConfigurationInfo);
    [GeTuiSdk registerLiveActivity:ConfigurationInfo[@"liveActivityId"] activityToken:ConfigurationInfo[@"token"] sequenceNum:ConfigurationInfo[@"sequenceNum"]];
}

- (void)GeTuiSdkDidRegisterLiveActivity:(NSString *)sequenceNum result:(BOOL)isSuccess error:(NSError *)error {
    NSLog(@"GeTuiSdkDidRegisterLiveActivity SN: %@, isSuccess : %@, error :%@", sequenceNum, @(isSuccess), error);
}

/** SDK设置推送模式回调 */
- (void)GeTuiSdkDidSetPushMode:(BOOL)isModeOff error:(NSError *)error {
    NSLog(@"\n>>>GTSDK GeTuiSdkDidSetPushMode isModeOff:%@ error:%@", @(isModeOff), error);
    NSDictionary *dic = @{@"result": @(isModeOff), @"error": error ? [error localizedDescription] : @""};
    [_channel invokeMethod:@"onPushModeResult" arguments:dic];
}

- (void)GeTuiSdkDidSetTagsAction:(NSString *)sequenceNum result:(BOOL)isSuccess error:(NSError *)aError {
    NSLog(@"\n>>>GTSDK GeTuiSdkDidSetTagsAction sn:%@ result:%@ error:%@", sequenceNum, @(isSuccess), aError);
    NSDictionary *dic = @{@"sn": sequenceNum?:@"", @"result": @(isSuccess), @"error": aError ? [aError localizedDescription] : @""};
    [_channel invokeMethod:@"onSetTagResult" arguments:dic];
}

- (void)GeTuiSdkDidAliasAction:(NSString *)action result:(BOOL)isSuccess sequenceNum:(NSString *)aSn error:(NSError *)aError {
    NSLog(@"\n>>>GTSDK GeTuiSdkDidAliasAction action: %@ sn:%@ result:%@ error:%@",[kGtResponseBindType isEqualToString:action] ? @"绑定" : @"解绑", aSn, @(isSuccess), aError);
    NSDictionary *dic = @{@"action": action, @"sn": aSn?:@"", @"result": @(isSuccess), @"error": aError ? [aError localizedDescription] : @""};
    [_channel invokeMethod:@"onAliasResult" arguments:dic];
}

- (void)GetuiSdkDidQueryTag:(NSArray *)aTags sequenceNum:(NSString *)aSn error:(NSError *)aError {
    NSLog(@"\n>>>GTSDK GetuiSdkDidQueryTag : %@, SN : %@, error :%@", aTags, aSn, aError);
    NSDictionary *dic = @{@"tags": aTags, @"sn": aSn?:@"", @"error": aError ? [aError localizedDescription] : @""};
    [_channel invokeMethod:@"onQueryTagResult" arguments:dic];
}


/// MARK: - Private

- (NSString *)getHexStringForData:(NSData *)data {
    NSUInteger len = [data length];
    char *chars = (char *) [data bytes];
    NSMutableString *hexString = [[NSMutableString alloc] init];
    for (NSUInteger i = 0; i < len; i++) {
        [hexString appendString:[NSString stringWithFormat:@"%0.2hhx", chars[i]]];
    }
    return hexString;
}

///// MARK: - VOIP接入

/** 注册VOIP服务 */
//- (void)voipRegistration {
//    dispatch_queue_t mainQueue = dispatch_get_main_queue();
//    PKPushRegistry *voipRegistry = [[PKPushRegistry alloc] initWithQueue:mainQueue];
//    voipRegistry.delegate = self;
//    // Set the push type to VoIP
//    voipRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
//}
//
//// 实现 PKPushRegistryDelegate 协议方法
//
///** 系统返回VOIPToken，并提交个推服务器 */
//- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)credentials forType:(NSString *)type {
//    //向个推服务器注册 VoipToken 为了方便开发者，建议使用新方法
//    [GeTuiSdk registerVoipTokenCredentials:credentials.token];
//
//    NSString *token = [self getHexStringForData:credentials.token];
//    NSLog(@"\n>>>GTSDK [VoipToken(NSString)]: %@", token);
//    [_channel invokeMethod:@"onRegisterVoipToken" arguments:token];
//}
//
///** 接收VOIP推送中的payload进行业务逻辑处理（一般在这里调起本地通知实现连续响铃、接收视频呼叫请求等操作），并执行个推VOIP回执统计 */
//- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(NSString *)type {
//    // 个推VOIP回执统计
//    [GeTuiSdk handleVoipNotification:payload.dictionaryPayload];
//
//    // TODO:接受VOIP推送中的payload内容进行具体业务逻辑处理
//    NSLog(@"\n>>>GTSDK [Voip Payload]:%@,%@", payload, payload.dictionaryPayload);
//    [_channel invokeMethod:@"onReceiveVoipPayLoad" arguments:payload.dictionaryPayload];
//}

@end
