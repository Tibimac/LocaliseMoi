//
//  HistoryItem.h
//  LocaliseMoi
//
//  Created by Thibault Le Cornec on 11/07/2014.
//  Copyright (c) 2014 Tibimac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface HistoryItem : NSObject <NSCoding>

////////// Propriétées //////////

@property (readonly) NSString *title;
@property (readonly) NSString *address;
@property (readonly) CLLocationCoordinate2D coordinates;


////////// Méthodes //////////

//  Convenience Initializers
- (instancetype)initWithAddress:(NSString*)address
                andCoordinates:(CLLocationCoordinate2D)coordinates;
//  Designated Initializer
- (instancetype)initHistoryItemWithTitle:(NSString*)title
                                 address:(NSString*)address
                          andCoordinates:(CLLocationCoordinate2D)coordinates;

@end
