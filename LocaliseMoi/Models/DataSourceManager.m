//
//  DataSourceManager.m
//  LocaliseMoi
//
//  Created by Thibault Le Cornec on 11/07/2014.
//  Copyright (c) 2014 Tibimac. All rights reserved.
//

#import "DataSourceManager.h"

@implementation DataSourceManager

/* ************************************************** */
/* ----------------- Initialisation ----------------- */
/* ************************************************** */
#pragma mark - Initialisation

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        historyItems = [[NSMutableArray alloc] init];
    }
    
    return self;
}





/* ************************************************** */
/* --------------- Méthodes publiques --------------- */
/* ************************************************** */
#pragma mark - Méthodes publiques

- (void)addItem:(HistoryItem*)item
{
    [historyItems addObject:item];
}


- (void)removeItem:(HistoryItem*)item
{
    [historyItems removeObject:item];
}


#pragma mark |--> Accesseur
- (CLLocationCoordinate2D)coordinatesForItem:(HistoryItem*)item
{
    NSUInteger indexOfItem = [historyItems indexOfObject:item];
    
    return [[historyItems objectAtIndex:indexOfItem] coordinates];
}


- (HistoryItem*)objectAt:(int)index
{
    return [historyItems objectAtIndex:index];
}





/* ************************************************** */
/* ------ Chargement/Enregistrement Sauvegarde ------ */
/* ************************************************** */
#pragma mark - Chargement/Enregistrement Sauvegarde

#pragma mark |--> Chargement sauvegarde
//  Méthode appellée par AppDelegate lors du lancement de l'application.
//  Cette méthode vérifie si un fichier backup est présent dans le dossier
//      Document de l'app et si oui le charge pour en extraire le contenu.
//      Ce contenu est ensuite converti en objet(s) HistoryItem, inséré(s)
//      dans le tableau historyItems.
- (BOOL)loadBackup
{
    NSArray *pathDocumentDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *pathBackupFile = [[pathDocumentDirectory objectAtIndex:0] stringByAppendingPathComponent:@"backupHistory"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathBackupFile])
    {
        NSArray *historyItemsFromBackup = [NSKeyedUnarchiver unarchiveObjectWithFile:pathBackupFile];
        
        if (historyItemsFromBackup)
        {
            [historyItems addObjectsFromArray:historyItemsFromBackup];
            return YES; //  Données pré-chargées -> renvoi YES
        }
    }
    else
    {
        NSLog(@"Pas de fichier de sauvegarde");
    }
    
    return NO; // Aucune donnée pré-chargée
}


#pragma mark |--> Enregistrement sauvegarde
//  Méthode appellée lorsque l'utilisateur demande à sauvegarder l'historique
//  Cette méthode vérifie si un fichier de backup existe déjà et si oui, le
//      supprime avant d'en créer un nouveau
- (BOOL)createBackup
{
    NSArray *pathDocumentDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *pathBackupFile = [[pathDocumentDirectory objectAtIndex:0] stringByAppendingPathComponent:@"backupHistory"];
    
    //  Si un fichier de sauvegarde existe déjà, on le supprime
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathBackupFile])
    {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:pathBackupFile error:&error];
        
        if (error)
        {
            NSLog(@"%@", error);
        }
    }
    
    //  Sauvegarde du tableau d'historique dans un fichier (sérialisation)
//    if ([historyItems count] > 0)
//    {
        BOOL success = [NSKeyedArchiver archiveRootObject:historyItems toFile:pathBackupFile];
        
        if (! success)
        {
            NSLog(@"Erreur lors de la sauvegarde");
            return NO; // Sauvegarde échouée
        }
        
        return YES; //  Sauvegarde effectuée
//    }
    
//    return NO; // Aucun élément à sauvegarder
}





/* ************************************************** */
/* --------- Méthodes UITableViewDataSource --------- */
/* ************************************************** */
#pragma mark - Méthodes UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [historyItems count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL newCell = NO;
    static NSString *CellIdentifier = @"ServiceCell";
    NSUInteger row = indexPath.row;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (row < [historyItems count])
    {
        if (cell == nil) // Si aucune cellule récupérée -> création d'une nouvelle
        {
            newCell = YES;
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
        
        /* ========== Paramétrage Cellule ========== */
        //  Easter Egg :D
        HistoryItem *item = [historyItems objectAtIndex:row];
        
        if ( (([item coordinates].latitude == 37.34) && ([item coordinates].longitude == -122.06))
            || ([[item address] rangeOfString:@"2066 Crist Drive, Los Altos"].location != NSNotFound) )
        {
            [[cell imageView] setImage:[UIImage imageNamed:@"MacintoshIconCell"]];
        }
        
        [[cell textLabel]       setText:[item title]];
        [[cell detailTextLabel] setText:[item address]];
    }
    
    if (newCell)
    {
        return [cell autorelease];
    }
    else
    {
        return cell;
    }
}





/* ************************************************** */
/* ------------ Déplacement des Cellules ------------ */
/* ************************************************** */
#pragma mark - Déplacement des Cellules (UITableViewDataSource)

#pragma mark |--> Demande si la cellule est déplacable
//  Méthode appellée en mode édition pour chaque cellule afin de savoir si elle peut être déplacée
//  Cette méthode peut renvoyer YES ou NO en fonction de la cellule pour laquelle c'est demandée
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


#pragma mark |--> Déplacement d'une cellule et des données liées
//  Si la cellule est déplacable, il faut implémenter cette méthode pour avoir les "poignets" de déplacement
//  Méthode appellée lorsqu'une cellule a été déplacée
//  Cette méthode récupère l'objet a déplacer, le supprime de sa place d'origine et l'insère à sa nouvelle place
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    HistoryItem *item = [[historyItems objectAtIndex:fromIndexPath.row] retain];

    [historyItems removeObjectAtIndex:fromIndexPath.row];
    [historyItems insertObject:item atIndex:toIndexPath.row];
    
    [item release];
}





/* ************************************************** */
/* ---------- Suppression/Ajout de cellules --------- */
/* ************************************************** */
#pragma mark - Suppression/Ajout de cellules

#pragma mark |--> Demande si la cellule est modifiable
//  Méthode appellé en mode édition pour chaque cellule afin de savoir si elle peut être modifiée
//  Cette méthode peut renvoyer YES ou NO en fonction de la cellule pour laquelle c'est demandée
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


#pragma mark |--> Édition cellule à l'index donné (suppression)
//  Méthode appellée lors d'une suppression d'une cellule
//  Cette méthode supprime l'objet du tableau et de la tableView
- (void) tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [historyItems removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        //[tableView setNeedsDisplay];
    }
}

@end
