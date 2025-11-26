#import <Flutter/Flutter.h>

@interface GetuiflutPlugin : NSObject<FlutterPlugin>
@property FlutterMethodChannel *channel;
+ (void)handleSceneWillConnectWithOptions:(UISceneConnectionOptions *)connectionOptions;
@end
