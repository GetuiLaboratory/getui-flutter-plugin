#import "GetuiflutPlugin.h"
#import <GTSDK/GeTuiSdk.h>
#import <PushKit/PushKit.h>

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif

@interface  GetuiflutPlugin()<GeTuiSdkDelegate> {
    NSDictionary *_launchNotification;
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
  } else if([@"resume" isEqualToString:call.method]) {
//        [GeTuiSdk resume];
  } else if([@"getLaunchNotification" isEqualToString:call.method]) {
      result(_launchNotification ?: @{});
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)startSdk:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *ConfigurationInfo = call.arguments;
    [GeTuiSdk startSdkWithAppId:ConfigurationInfo[@"appId"] appKey:ConfigurationInfo[@"appKey"] appSecret:ConfigurationInfo[@"appSecret"] delegate:self];
    
    // 注册远程通知
    [GeTuiSdk registerRemoteNotification: (UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge)];
}

/// MARK: - AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if (launchOptions != nil) {
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
    NSLog(@"\n>>>[DeviceToken(NSString)]: %@\n\n", token);
    [_channel invokeMethod:@"onRegisterDeviceToken" arguments:token];
}

/** 远程通知注册失败委托 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError");
}

/// MARK: - APP运行中接收到通知(推送)处理 - iOS 10以下版本收到推送

/// MARK: - GeTuiSdkDelegate

/** SDK启动成功返回cid */
- (void)GeTuiSdkDidRegisterClient:(NSString *)clientId {
    // [ GTSdk ]：个推SDK已注册，返回clientId
    NSLog(@">>[GTSDK RegisterClient]:%@", clientId);
    if ([clientId isEqualToString:@""]) {
        return;
    }
    
    [_channel invokeMethod:@"onReceiveClientId" arguments:clientId];
}

/// 通知展示（iOS10及以上版本）
/// @param center center
/// @param notification notification
/// @param completionHandler completionHandler
- (void)GeTuiSdkNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification completionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSLog(@"willPresentNotification :%@", notification.request.content.userInfo);
    // 根据APP需要，判断是否要提示用户Badge、Sound、Alert
    completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
    [_channel invokeMethod:@"onWillPresentNotification" arguments:notification.request.content.userInfo];
}

- (void)GeTuiSdkDidReceiveNotification:(NSDictionary *)userInfo notificationCenter:(UNUserNotificationCenter *)center response:(UNNotificationResponse *)response fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSDate *time = response.notification.date;
//    NSDictionary *userInfo = response.notification.request.content.userInfo;
    NSLog(@"\n%@\nTime:%@\n%@", NSStringFromSelector(_cmd), time, userInfo);
    [_channel invokeMethod:@"onReceiveNotificationResponse" arguments:userInfo];
    if (completionHandler) {
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

- (void)GeTuiSdkNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(UNNotification *)notification {
    NSLog(@"openSettingsForNotification :%@", notification.request.content.userInfo);
    [_channel invokeMethod:@"onOpenSettingsForNotification" arguments:notification.request.content.userInfo];
}

- (void)GeTuiSdkDidReceiveSlience:(NSDictionary *)userInfo fromGetui:(BOOL)fromGetui offLine:(BOOL)offLine appId:(NSString *)appId taskId:(NSString *)taskId msgId:(NSString *)msgId fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSString *payloadMsg = userInfo[@"payload"];
    NSDictionary *payloadMsgDic = @{ @"taskId": taskId ?: @"", @"messageId": msgId ?: @"", @"payloadMsg" : payloadMsg, @"offLine" : @(offLine), @"fromGetui": @(fromGetui)};
    NSLog(@"GeTuiSdkDidReceiveSlience:%@", payloadMsgDic);
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
            NSLog(@"个推APPLink中携带的透传payload信息: %@,URL : %@", payload, webUrl);
            //TODO:用户可根据具体 payload 进行业务处理
            [_channel invokeMethod:@"onAppLinkPayload" arguments:payload];
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
    NSUInteger value = [ConfigurationInfo[@"badge"] integerValue];
    [UIApplication sharedApplication].applicationIconBadgeNumber = value;
    
}

/** SDK设置推送模式回调 */
- (void)GeTuiSdkDidSetPushMode:(BOOL)isModeOff error:(NSError *)error {
    NSLog(@"GeTuiSdkDidSetPushMode isModeOff:%@ error:%@", @(isModeOff), error);
    NSDictionary *dic = @{@"result": @(isModeOff), @"error": error ? [error localizedDescription] : @""};
    [_channel invokeMethod:@"onPushModeResult" arguments:dic];
}

- (void)GeTuiSdkDidSetTagsAction:(NSString *)sequenceNum result:(BOOL)isSuccess error:(NSError *)aError {
    NSLog(@"GeTuiSdkDidSetTagsAction sn:%@ result:%@ error:%@", sequenceNum, @(isSuccess), aError);
    NSDictionary *dic = @{@"sn": sequenceNum?:@"", @"result": @(isSuccess), @"error": aError ? [aError localizedDescription] : @""};
    [_channel invokeMethod:@"onSetTagResult" arguments:dic];
}

- (void)GeTuiSdkDidAliasAction:(NSString *)action result:(BOOL)isSuccess sequenceNum:(NSString *)aSn error:(NSError *)aError {
    NSLog(@"GeTuiSdkDidAliasAction action: %@ sn:%@ result:%@ error:%@",[kGtResponseBindType isEqualToString:action] ? @"绑定" : @"解绑", aSn, @(isSuccess), aError);
    NSDictionary *dic = @{@"action": action, @"sn": aSn?:@"", @"result": @(isSuccess), @"error": aError ? [aError localizedDescription] : @""};
    [_channel invokeMethod:@"onAliasResult" arguments:dic];
    //akak test
    {
        NSArray*aTags = @[@"aa",@"bb",@"cc"];
    NSDictionary *dic = @{@"tags": aTags, @"sn": aSn?:@"", @"error": aError ? [aError localizedDescription] : @""};
    [_channel invokeMethod:@"onQueryTagResult" arguments:dic];
    }
}

- (void)GetuiSdkDidQueryTag:(NSArray *)aTags sequenceNum:(NSString *)aSn error:(NSError *)aError {
    NSLog(@"GetuiSdkDidQueryTag : %@, SN : %@, error :%@", aTags, aSn, aError);
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
//    NSLog(@"\n>>[VoipToken(NSString)]: %@", token);
//    [_channel invokeMethod:@"onRegisterVoipToken" arguments:token];
//}
//
///** 接收VOIP推送中的payload进行业务逻辑处理（一般在这里调起本地通知实现连续响铃、接收视频呼叫请求等操作），并执行个推VOIP回执统计 */
//- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(NSString *)type {
//    // 个推VOIP回执统计
//    [GeTuiSdk handleVoipNotification:payload.dictionaryPayload];
//
//    // TODO:接受VOIP推送中的payload内容进行具体业务逻辑处理
//    NSLog(@"[Voip Payload]:%@,%@", payload, payload.dictionaryPayload);
//    [_channel invokeMethod:@"onReceiveVoipPayLoad" arguments:payload.dictionaryPayload];
//}

@end
