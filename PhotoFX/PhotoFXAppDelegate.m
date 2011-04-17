//
//  PhotoFXAppDelegate.m
//  PhotoFX
//
//  Created by forrest on 11-4-3.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "PhotoFXAppDelegate.h"
#import "PhotoProcessViewController.h"
#import "Three20/three20.h"
#import "LauncherViewTestController.h"
#import "TestIBView.h"
#import "IM_TestViewController.h"
#import "WelcomeViewController.h"
#import "SelectPhotoViewController.h"


@implementation PhotoFXAppDelegate


@synthesize window=_window;

//- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
//{
//    // Override point for customization after application launch.
//    PhotoProcessViewController *viewController = [[PhotoProcessViewController alloc] init];
//    [self.window addSubview:viewController.view];
//    [self.window makeKeyAndVisible];
//    return YES;
//    return YES;
//}

//- (void)applicationDidFinishLaunching:(UIApplication*)application {
//    TTNavigator* navigator = [TTNavigator navigator];
//    navigator.supportsShakeToReload = YES;
//    navigator.persistenceMode = TTNavigatorPersistenceModeNone;
//    
//    TTURLMap* map = navigator.URLMap;
//    [map from:@"*" toViewController:[TTWebController class]];
//    
//    
//    if (TTIsPad()) {
////        [map                    from: @"tt://catalog"
////              toSharedViewController: [SplitCatalogController class]];
////        
////        SplitCatalogController* controller =
////        (SplitCatalogController*)[[TTNavigator navigator] viewControllerForURL:@"tt://catalog"];
////        TTDASSERT([controller isKindOfClass:[SplitCatalogController class]]);
////        map = controller.rightNavigator.URLMap;
//        
//    } else {
//        [map                    from: @"tt://launch"
//              toSharedViewController: [LauncherViewTestController class]];
//    }
//    
//       
////    [map            from: @"tt://photoEdit"
////                  parent: @"tt://launch"
////        toViewController: [PhotoProcessViewController class]
////                selector: nil
////              transition: 0];
//   
//    [map                    from: @"tt://photoEdit"
//          toSharedViewController: [PhotoProcessViewController class]];
//    
//    [map                    from: @"tt://launch"
//          toSharedViewController: [LauncherViewTestController class]];
//    
//    [map                    from:@"tt://testIB" 
//          toSharedViewController:[TestIBView class]];    
//    
//    [map                    from:@"tt://selectPhoto" 
//          toSharedViewController:[SelectPhotoViewController class]];   
//    
//    [map                    from:@"tt://testIM" 
//          toSharedViewController:[IM_TestViewController class]];  
//    
//    [map                    from:@"tt://welcome" 
//          toSharedViewController:[WelcomeViewController class]];  
//    
//    
//    if (![navigator restoreViewControllers]) {
//        [navigator openURLAction:[TTURLAction actionWithURLPath:@"tt://welcome"]];
//    }
//}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applicationDidFinishLaunching:(UIApplication *)application {
    TTNavigator* navigator = [TTNavigator navigator];
    navigator.supportsShakeToReload = YES;
    navigator.persistenceMode = TTNavigatorPersistenceModeAll;
    navigator.window = self.window;
    
    // [TTStyleSheet setGlobalStyleSheet:[[[StyleSheet alloc] init] autorelease]];
    
    TTURLMap* map = navigator.URLMap;
    [map from:@"*" toViewController:[TTWebController class]];
    [map from:@"tt://launcher" toViewController:NSClassFromString(@"LauncherViewTestController")];
    [map from:@"tt://nib/(loadFromNib:)" toSharedViewController:self];
    [map from:@"tt://nib/(loadFromNib:)/(withClass:)" toSharedViewController:self];
    [map from:@"tt://viewController/(loadFromVC:)" toSharedViewController:self];
    [map from:@"tt://viewController/(loadFromVC:)/(withUIImage:)" toSharedViewController:self];
    [map from:@"tt://modal/(loadFromNib:)" toModalViewController:self];
    
    if (![navigator restoreViewControllers]) {
        [navigator openURLAction:[TTURLAction actionWithURLPath:@"tt://nib/WelcomeViewController"]];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Loads the given viewcontroller from the nib
 */
- (UIViewController*)loadFromNib:(NSString *)nibName withClass:className {
    UIViewController* newController = [[NSClassFromString(className) alloc]
                                       initWithNibName:nibName bundle:nil];
    [newController autorelease];
    
    return newController;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Loads the given viewcontroller from the the nib with the same name as the
 * class
 */
- (UIViewController*)loadFromNib:(NSString*)className {
    return [self loadFromNib:className withClass:className];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Loads the given viewcontroller by name
 */
- (UIViewController *)loadFromVC:(NSString *)className {
    UIViewController * newController = [[ NSClassFromString(className) alloc] init];
    [newController autorelease];
    
    return newController;
}

- (UIViewController *)loadFromVC:(NSString *)className withUIImage:(UIImage*)image{
    UIViewController * newController = [[ NSClassFromString(className) alloc] initWithImage:image];
    [newController autorelease];
    
    return newController;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)URL {
    [[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:URL.absoluteString]];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

@end
