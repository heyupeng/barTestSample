//
//  AppDelegate.m
//  BarTestSample
//
//  Created by Mac on 2021/2/7.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
        
    /*
     iOS 13, 新建工程变化：
     1. AppDelegate 删除 window 属性，增加 {UISceneSession} 生命周期的代理方法。
     2. 增加 SceneDelegate.{h,m} 文件， window 属性转移到 SceneDelegate 下。
     3. Info.plist 增加新键名 UIApplicationSceneManifest(NSDictionary)，用于 UIWindowScene 场景配置。
    
     直接运行程序，此时 {application.windows} 为空，无法拿到 window。需要对 window 做修改的移步 [SceneDelegate scene:willConnectToSession:options:]。
     若不需要多场景支持，向下兼容，可同时删除Info.plist UIApplicationSceneManifest 键值对、{UISceneSession} 生命周期的实现方法，AppDelegate 增加 window 属性。
     */
    
    UIWindow * window = application.windows.firstObject;
    
    // In iOS 13,on iPhone X line , while navigationController.navigationBar.prefersLargeTitles is YES, the statusBar backgroundColor is transparent.
    // iOS 13后，navigationController.view 背景色为透明，当 {navigationController.navigationBar.prefersLargeTitles} 为YES，导航栏区域也可能为黑色（即UIWindow背景色）。
    
    // 3DB9BF
    UIColor * color = [UIColor colorWithRed:0xBd/255.0 green:0xB9/255.0 blue:0xBF/255.0 alpha:1];
    window.rootViewController.view.backgroundColor = color;
    return YES;
}


#pragma mark - UISceneSession lifecycle


//- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
//    // Called when a new scene session is being created.
//    // Use this method to select a configuration to create the new scene with.
//    NSLog(@"%s", __func__);
//    UISceneConfiguration * configuration = [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
//    configuration.storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    configuration.delegateClass = NSClassFromString(@"SceneDelegate");
//    return configuration;
//}
//
//
//- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
//    // Called when the user discards a scene session.
//    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//    NSLog(@"%s", __func__);
//}


@end
