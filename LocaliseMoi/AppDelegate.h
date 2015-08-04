//
//  AppDelegate.h
//  LocaliseMoi
//
//  Created by Thibault Le Cornec on 11/07/2014.
//  Copyright (c) 2014 Tibimac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapViewController.h"
#import "MapView.h"
#import "HistoryTableViewController.h"
#import "DataSourceManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    MapViewController *mapViewcontroller;
    HistoryTableViewController *historyTableViewController;
    DataSourceManager *dataSourceManager;
}

////////// Propriétés //////////

@property (strong, nonatomic) UIWindow *window;

@end
