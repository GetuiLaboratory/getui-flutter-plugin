#import "SceneDelegate.h"
#import <Flutter/Flutter.h>
#import "GeneratedPluginRegistrant.h"
#import <GTSDK/GetuiSdk.h>
#import "GetuiflutPlugin.h"

@interface SceneDelegate () <GeTuiSdkDelegate>

@end
  
@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    // 配置窗口场景
    if (@available(iOS 13.0, *)) {
        UIWindowScene *windowScene = (UIWindowScene *)scene;
        self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
    } else {
        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    
    // 创建并设置 Flutter 视图控制器
    FlutterViewController *flutterViewController = [FlutterViewController new];
    self.window.rootViewController = flutterViewController;
    
    // 注册 Flutter 插件
    [GeneratedPluginRegistrant registerWithRegistry:flutterViewController];
    
    // 处理连接选项中的通知
    UNNotification *note = connectionOptions.notificationResponse.notification;
    NSDictionary *userInfo = note.request.content.userInfo;
    UNNotificationTrigger *trigger = note.request.trigger;
    NSLog(@">>>GTSDK [ TestDemo ] willConnectToSession %@", userInfo);
    if (note && userInfo) {
        if ([trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
            NSLog(@">>>GTSDK [ TestDemo ] 远程通知");
        } else {
            NSLog(@">>>GTSDK [ TestDemo ] 本地通知");
        }
    }
    
    //用于获取UIScene模式下的通知数据
    [GetuiflutPlugin handleSceneWillConnectWithOptions:connectionOptions];
    
//    // 初始化个推SDK
//    [GeTuiSdk startSdkWithAppId:@"xXmjbbab3b5F1m7wAYZoG2" appKey:@"2" appSecret:@"3" delegate:self launchingOptions:nil];
//    [GeTuiSdk registerRemoteNotification: (UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge)];
    
    // 使窗口可见
    [self.window makeKeyAndVisible];
}

- (void)sceneDidBecomeActive:(UIScene *)scene {
    // 应用变为活动状态时调用
    NSLog(@"[ TestDemo ] sceneDidBecomeActive %@", scene);
}

- (void)sceneWillResignActive:(UIScene *)scene {
    // 应用即将变为非活动状态时调用
}

- (void)sceneWillEnterForeground:(UIScene *)scene {
    // 应用即将进入前台时调用
    NSLog(@"[ TestDemo ] sceneWillEnterForeground %@", scene);
}

- (void)sceneDidEnterBackground:(UIScene *)scene {
    // 应用进入后台时调用
}

- (void)sceneDidDisconnect:(UIScene *)scene {
    // 场景断开连接时调用
} 
@end
