//
//  AppDelegate.m
//  LocaliseMoi
//
//  Created by Thibault Le Cornec on 11/07/2014.
//  Copyright (c) 2014 Tibimac. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    
    /* ========== MapViewController ========== */
    mapViewcontroller = [[MapViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *navcMapViewController = [[UINavigationController alloc] initWithRootViewController:mapViewcontroller];
    
    
    /* ========== HistoryViewController ========== */
    historyTableViewController = [[HistoryTableViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *navcHistoryTableViewController = [[UINavigationController alloc] initWithRootViewController:historyTableViewController];
    
    /* ========== DataSourceManager ========== */
    dataSourceManager = [[DataSourceManager alloc] init];
    
    
    /* ========== Affectation Références Objets ========== */
    [mapViewcontroller setHistoryTableViewController:historyTableViewController];
    [mapViewcontroller setDataSourceManager:dataSourceManager];
    [historyTableViewController setMapViewController:mapViewcontroller];
    [historyTableViewController setDataSourceManager:dataSourceManager];
    [[historyTableViewController tableView] setDataSource:dataSourceManager];

    
    /* ========== Chargement sauvegarde ========== */
    BOOL dataLoaded = [dataSourceManager loadBackup];
    
    if (dataLoaded) //  Des données ont été chargées, il faut rafraichir la tableView
    {
        [[historyTableViewController tableView] reloadData];
    }
    
    
    /* ========== UI Controllers ========== */
    /* === iPhone === */
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        //  MapView à gauche, Historique à droite
        NSArray *viewsControllers = [NSArray arrayWithObjects:navcMapViewController, navcHistoryTableViewController, nil];
        
        /* ===== TabBarController ===== */
        UITabBarController *tabBarController = [[UITabBarController alloc] init];
        [tabBarController setViewControllers:viewsControllers];
        
        [historyTableViewController setTabBarController:tabBarController];
        
        [[self window] setRootViewController:tabBarController];
        
        [tabBarController release];
    }
    
    /* === iPad === */
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        //  Historique à gauche (detail), MapView à droite (master)
        NSArray *viewsControllers = [NSArray arrayWithObjects:navcHistoryTableViewController, navcMapViewController, nil];
        
        /* ===== SplitViewController ===== */
        UISplitViewController *splitViewController = [[UISplitViewController alloc] init];
        [splitViewController setViewControllers:viewsControllers];
        [splitViewController setDelegate:mapViewcontroller];
        
        [[self window] setRootViewController:splitViewController];
        
        [splitViewController release];
    }
    
    [navcHistoryTableViewController release];
    [navcMapViewController release];
    
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
