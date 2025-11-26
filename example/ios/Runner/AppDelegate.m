#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"

@implementation AppDelegate

//MARK: - 非Scene场景
//- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    [GeneratedPluginRegistrant registerWithRegistry:self];
//
//    return [super application:application didFinishLaunchingWithOptions:launchOptions];
//}
//
//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
//    //warning: 需要重写当前方法，gtsdk的接管系统方法就会生效，否则会影响回执
//    //保持空实现
//}

//MARK: - Scene场景 （需要配置Info.plist Application Scene Manifest)

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if (@available(iOS 13, *)) {
        // iOS 13+ 由 SceneDelegate 处理
    }
    else {
        // iOS 12 及以下，从 launchOptions 获取通知
        // 插件的didFinishLaunchingWithOptions会被触发 来获取launchOptions
    }
    
    return YES;
}

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // 配置场景连接时的场景配置
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // 当用户放弃场景会话时调用
    // 释放与被丢弃场景相关的资源
}

@end
