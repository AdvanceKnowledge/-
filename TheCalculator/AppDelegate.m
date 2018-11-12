//
//  AppDelegate.m
//  TheCalculator
//
//  Created by 追@寻 on 2018/10/23.
//  Copyright © 2018 追@寻. All rights reserved.
//

#import "AppDelegate.h"
#import "WYLMortgageCalculatorViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyWindow];
    
     WYLMortgageCalculatorViewController *vc = [[WYLMortgageCalculatorViewController alloc]init];
    vc.tabBarItem.selectedImage = [UIImage imageNamed:@"home_highlight"];
    vc.tabBarItem.image = [UIImage imageNamed:@"home_normal"];
    [vc.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:250/255 green:197/255 blue:50/255 alpha:1], UITextAttributeTextColor,nil]forState:UIControlStateSelected];
    
    vc.title = @"房贷计算器";

    UITabBarController *TabBar_VC = [[UITabBarController alloc]init];
    TabBar_VC.tabBar.backgroundColor = [UIColor whiteColor];
    [TabBar_VC addChildViewController:vc];
    
    
    
   
    self.window.rootViewController = TabBar_VC;
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
