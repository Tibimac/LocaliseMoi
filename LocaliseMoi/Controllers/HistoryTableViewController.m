//
//  HistoryTableViewController.m
//  LocaliseMoi
//
//  Created by Thibault Le Cornec on 11/07/2014.
//  Copyright (c) 2014 Tibimac. All rights reserved.
//

#import "HistoryTableViewController.h"
#import "MapViewController.h"

@implementation HistoryTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    
    if (self)
    {
        //  Icône pour la tabBar si on est sur un iPhone
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            [[self tabBarItem] setImage:[UIImage imageNamed:@"HistoryIcon"]];
        }

        //  Titre pour la navigationBar et pour le tabBarItem
        [self setTitle:@"Historique"];
        
        [[self tableView] setDelegate:self];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Bouton Edit géré automatiquement par le TableViewController
    [[self editButtonItem] setTitle:@"Modifier"];
    [[self navigationItem] setLeftBarButtonItem:[self editButtonItem] animated:YES];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Sauvegarder" style:UIBarButtonItemStylePlain target:self action:@selector(createBackup)];
    [[self navigationItem] setRightBarButtonItem:saveButton animated:YES];
}


#pragma mark - Changement nom bouton Modifier TableView
//  Méthode appellée par le bouton de modification de la TableView (bouton en haut à gauche)
//  Par défaut le nom du bouton est Edit/Done
//  Par défaut il appelle la méthode setEditing:animated: de UIViewController
//  Il faut surcharger la méthode pour redéfinir le nom du bouton à la volée
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    // Make sure you call super first
    [super setEditing:editing animated:animated];
    
    if (editing)
    {
        [[self editButtonItem] setTitle:@"OK"];
    }
    else
    {
        [[self editButtonItem] setTitle:@"Modifier"];
    }
}


#pragma mark - Création sauvegarde (Action)
- (void)createBackup
{
    BOOL backupCreated = [_dataSourceManager createBackup];
    
    NSString *message;
    
    if (backupCreated)
    {
       message = @"La sauvegarde de l'historique a été éffectuée.";
    }
    else
    {
        message = @"La sauvegarde de l'historique n'a pu être effectuée.";
    }
    
    UIAlertView *backupSucceed = [[UIAlertView alloc] initWithTitle:@"Sauvegarde" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [backupSucceed show];
    [backupSucceed release];
    backupSucceed = nil;
}



#pragma mark - Sélection celulle => affichage coordonnées sur map
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //  Affichage de la carte en demandant au TabBarcontroller d'afficher la vue de l'index 0 (vue de gauche = MapView)
    //  On ne peut pas passer par _mapViewController car cell-ci est contenu dans un NavigationController
    //      le TabBarController connait le NavigationController mais pas _mapViewController
    //      lui demander d'afficher _mapViewController = crash
    [_tabBarController setSelectedIndex:0];
    
    //  Récupération item historique et ses coordonées GPS
    HistoryItem *item = [[_dataSourceManager objectAt:(int)indexPath.row] retain];
    CLLocationCoordinate2D coordinates = [item coordinates];
    
    // On défini de "zoom"
    MKCoordinateSpan span = {.latitudeDelta = 0.015, .longitudeDelta = 0.015};
    
    // On défini la région a afficher avec les coordonnées et la valeur de "zoom"
    [[[_mapViewController mapView] map] setRegion:MKCoordinateRegionMake(coordinates, span) animated:YES];
    
    [item release];
    
    //  Création et affichage de la notification
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    [notification setAlertBody:[NSString stringWithFormat:@"Voyage au %@", [item address]]];
    [notification setSoundName:UILocalNotificationDefaultSoundName];
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
   
    [notification release];
}


#pragma mark - Gestion mémoire
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
