//
//  DataSourceManager.h
//  LocaliseMoi
//
//  Created by Thibault Le Cornec on 11/07/2014.
//  Copyright (c) 2014 Tibimac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HistoryItem.h"

@interface DataSourceManager : NSObject <UITableViewDataSource>
{
    NSMutableArray *historyItems;
}

////////// Méthodes //////////

//  Méthode appellée par AppDelegate lors du lancement de l'application.
//  Cette méthode vérifie si un fichier backup est présent dans le dossier
//      Document de l'app et si oui le charge pour en extraire le contenu.
//      Ce contenu est ensuite converti en objet(s) HistoryItem, inséré(s)
//      dans le tableau historyItems.
- (BOOL)loadBackup;

//  Méthode appellée lorsque l'utilisateur demande à sauvegarder l'historique
//  Cette méthode vérifie si un fichier de backup existe déjà et si oui, le
//      supprime avant d'en créer un nouveau
- (BOOL)createBackup;

- (void)addItem:(HistoryItem*)item;
- (void)removeItem:(HistoryItem*)item;
- (HistoryItem*)objectAt:(int)index;
- (CLLocationCoordinate2D)coordinatesForItem:(HistoryItem*)item;

@end
