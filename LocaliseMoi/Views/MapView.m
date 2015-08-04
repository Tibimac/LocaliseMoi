//
//  MapView.m
//  LocaliseMoi
//
//  Created by Thibault Le Cornec on 11/07/2014.
//  Copyright (c) 2014 Tibimac. All rights reserved.
//

#import "MapView.h"
#import "MapViewController.h"

@implementation MapView

NSArray *iPhonePortraitVerticalConstraint = nil, *iPhoneLandscapeVerticalConstraint = nil;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        /* ========== Initialisation ========== */
        [self setBackgroundColor:[UIColor whiteColor]];
        
        /* === TextField === */
        _addressTextField = [[UITextField alloc] init];
        [_addressTextField setDelegate:_mapViewController];
        
        [_addressTextField setReturnKeyType:UIReturnKeyJoin];
        [_addressTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
        //[UIColor colorWithRed:0.21 green:0.61 blue:0.68 alpha:0.4]
        [_addressTextField setBackgroundColor:[UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1]];
        [_addressTextField setPlaceholder:@"Aller à ..."];
        
        // Définition du padding
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
        [paddingView setBackgroundColor:[UIColor clearColor]];
        // Padding entre le bord du UITextField et le texte à gauche
        [_addressTextField setLeftView:paddingView];
        [_addressTextField setLeftViewMode:UITextFieldViewModeAlways];
        [paddingView release];
        
        [self addSubview:_addressTextField];
        [_addressTextField release];
        
        
        /* === Map === */
        _map = [[MKMapView alloc] init];
        [_map setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:_map];
        [_map release];
        
        
        /* ========== Initialisation des contraintes ========== */
        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_addressTextField, _map);
        
        /* === iPhone === */
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            iPhonePortraitVerticalConstraint = [@[[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-69-[_addressTextField(==30)]-5-[_map]-49-|"
                                                                                          options:0 metrics:nil views:viewsDictionary],
                                                  [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_addressTextField]-5-|"
                                                                                          options:0 metrics:nil views:viewsDictionary],
                                                  [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_map]|"
                                                                                          options:0 metrics:nil views:viewsDictionary]] retain];
            
            iPhoneLandscapeVerticalConstraint = [@[[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-57-[_addressTextField(==30)]-5-[_map]-49-|"
                                                                                           options:0 metrics:nil views:viewsDictionary],
                                                   [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_addressTextField]-5-|"
                                                                                           options:0 metrics:nil views:viewsDictionary],
                                                   [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_map]|"
                                                                                           options:0 metrics:nil views:viewsDictionary]] retain];
            
            [self setConstraintsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
        }
        
        /* === iPad === */
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            //  Contrainte Verticale
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-74-[_addressTextField(==30)]-10-[_map]|"
                                                                         options:0 metrics:nil views:viewsDictionary]];
            
            //  Contraintes Horizontales
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_addressTextField]-10-|"
                                                                         options:0 metrics:nil views:viewsDictionary]];
            
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_map]|"
                                                                         options:0 metrics:nil views:viewsDictionary]];
        }
    }
    
    return self;
}


//  Méthode pour paramétrer la vue avec les contraintes adéquates selon l'orientation
//  Cette méthode supprime les contraintes ne correspondants plus à la future orientation
//      puis ajoute les nouvelles contraites correspondants à la future orientation
- (void)setConstraintsForOrientation:(UIInterfaceOrientation)orientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        /* === Portrait === */
        if (UIInterfaceOrientationIsPortrait(orientation))
        {
            [self deleteViewContraints:iPhoneLandscapeVerticalConstraint];
            [self addViewContraints:iPhonePortraitVerticalConstraint];
        }/* === Paysage === */
        else if (UIInterfaceOrientationIsLandscape(orientation))
        {
            [self deleteViewContraints:iPhonePortraitVerticalConstraint];
            [self addViewContraints:iPhoneLandscapeVerticalConstraint];
        }
    }
}


//  Ajoute à la vue les contraintes du tableau passé en paramètre
-(void) addViewContraints:(NSArray *)constraints
{
    for (NSArray *constraint in constraints)
    {
        [self addConstraints:constraint];
    }
}


//  Supprime de la vue les contraintes du tableau passé en paramètre
-(void) deleteViewContraints:(NSArray *)constraints
{
    for (NSArray *constraint in constraints)
    {
        [self removeConstraints:constraint];
    }
}
@end
