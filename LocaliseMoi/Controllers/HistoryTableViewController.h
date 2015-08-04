//
//  HistoryTableViewController.h
//  LocaliseMoi
//
//  Created by Thibault Le Cornec on 11/07/2014.
//  Copyright (c) 2014 Tibimac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataSourceManager.h"
#import "MapView.h"
@class MapViewController;

@interface HistoryTableViewController : UITableViewController <UITableViewDelegate>

////////// Propriétés //////////

@property (retain) UITabBarController *tabBarController;
@property (retain) MapViewController *mapViewController;
@property (retain) DataSourceManager *dataSourceManager;

@end
