//
//  MapViewController.h
//  LocaliseMoi
//
//  Created by Thibault Le Cornec on 11/07/2014.
//  Copyright (c) 2014 Tibimac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "DataSourceManager.h"
@class MapView;
@class HistoryTableViewController;

@interface MapViewController : UIViewController <UISplitViewControllerDelegate, MKMapViewDelegate, UITextFieldDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate, NSXMLParserDelegate>
{
    NSMutableData *xmlDataBuffer;
}

////////// Propriétés //////////

@property (readonly) MapView *mapView;
@property (retain) HistoryTableViewController *historyTableViewController;
@property (retain) DataSourceManager *dataSourceManager;

@end
