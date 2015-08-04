//
//  HistoryItem.m
//  LocaliseMoi
//
//  Created by Thibault Le Cornec on 11/07/2014.
//  Copyright (c) 2014 Tibimac. All rights reserved.
//

#import "HistoryItem.h"

@implementation HistoryItem

/* ************************************************** */
/* ------------------ Initializers ------------------ */
/* ************************************************** */
- (instancetype)init
{
    self = [super init];
    
    return self;
}


//  Convenience Initializer
- (instancetype)initWithAddress:(NSString*)address andCoordinates:(CLLocationCoordinate2D)coordinates
{
    self = [self init];
    
    if (self)
    {
        _address = [address copy];
        _coordinates = coordinates;
    }
    
    return self;
}


//  Designated Initializer
- (instancetype)initHistoryItemWithTitle:(NSString*)title
                                 address:(NSString*)address
                          andCoordinates:(CLLocationCoordinate2D)coordinates
{
    self = [self initWithAddress:address andCoordinates:coordinates];
    
    if (self)
    {
        _title = [title copy];
    }
    
    return self;
}





/* ************************************************** */
/* ------------------ Sérialisation ----------------- */
/* ************************************************** */
#pragma mark - Sérialisation

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_title forKey:@"title"];
    [encoder encodeObject:_address forKey:@"address"];
    
    NSNumber *latitude = [NSNumber numberWithDouble:_coordinates.latitude];
    NSNumber *longitude = [NSNumber numberWithDouble:_coordinates.longitude];
    [encoder encodeObject:latitude forKey:@"latitude"];
    [encoder encodeObject:longitude forKey:@"longitude"];
}


- (instancetype)initWithCoder:(NSCoder*)decoder
{
    NSString *title = [[decoder decodeObjectForKey:@"title"] retain];
    NSString * address = [[decoder decodeObjectForKey:@"address"] retain];
    NSNumber *latitude = [[decoder decodeObjectForKey:@"latitude"] retain];
    NSNumber *longitude = [[decoder decodeObjectForKey:@"longitude"] retain];
    
    CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]);
    
    HistoryItem *item = [[HistoryItem alloc] initHistoryItemWithTitle:title address:address andCoordinates:coordinates];
    
    [title release];
    title = nil;
    [address release];
    address = nil;
    [latitude release];
    latitude = nil;
    [longitude release];
    longitude = nil;
    
    return item;
}





/* ************************************************** */
/* ----------------- Gestion mémoire ---------------- */
/* ************************************************** */
#pragma mark - Gestion mémoire
- (void)dealloc
{
    [_title release];
    _title = nil;
    [_address release];
    _address = nil;
    
    [super dealloc];
}

@end
