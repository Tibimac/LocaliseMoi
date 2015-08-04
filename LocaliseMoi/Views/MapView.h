//
//  MapView.h
//  LocaliseMoi
//
//  Created by Thibault Le Cornec on 11/07/2014.
//  Copyright (c) 2014 Tibimac. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MapViewController;
@class MKMapView;

@interface MapView : UIView

////////// Propriétés //////////

@property (retain) MapViewController *mapViewController;

@property (readonly) UITextField *addressTextField;
@property (readonly) MKMapView *map;


////////// Méthodes //////////

- (void)setConstraintsForOrientation:(UIInterfaceOrientation)orientation;

@end
