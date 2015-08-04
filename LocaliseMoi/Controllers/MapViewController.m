//
//  MapViewController.m
//  LocaliseMoi
//
//  Created by Thibault Le Cornec on 11/07/2014.
//  Copyright (c) 2014 Tibimac. All rights reserved.
//

#import "MapViewController.h"
#import "MapView.h"
#import "HistoryTableViewController.h"

@interface MapViewController ()
{
    int nbResult;               //  Stocke le nombre de résultats dans le XML renvoyé par Google
    int nbAddressComponent;     //  Stocke le nombre de balises "address_component" dans un resultat (remis à zéro à chaque nouvelle balise "result"
    BOOL isFormattedAddress;    // Indique si on est dans la balise formatted_address
    BOOL isShortName;           // Indique si on est dans la balise short_name
    BOOL isGeometry;            //  Indique si on est dans la balise geometry
    BOOL isLocation;            // Indique si on a passé la balise location dans laquelle se trouve les coordonées GPS.
    BOOL isLatitude;
    BOOL isLongitude;
    NSString *tempString;       //  Stocke la string renvoyée par parser:foundCharacters:
    NSString *xmlResult_FormattedAddress;   //  Stocke l'adresse postale du résultat pris en compte (le premier du fichier XML)
    NSString *xmlResult_Locality;           //  Stocke le nom de la localité de l'adresse postale du résultat pris en compte (cf ci-dessus)
    CLLocationCoordinate2D xmlResult_Coordinates;   // Stocke les coordonnées GPS de l'adresse (cf ci-dessus)
}
@end


@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        //  Icône pour la tabBar si on est sur un iPhone
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            [[self tabBarItem] setImage:[UIImage imageNamed:@"MapViewIcon"]];
        }
        
        //  Titre pour la navigationBar et pour le tabBarItem
        [self setTitle:@"LocaliseMoi"];
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _mapView = [[MapView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [_mapView setMapViewController:self];
    
    [[_mapView addressTextField] setDelegate:self];
    [[_mapView map] setDelegate:self];
    
    [self setView:_mapView];
}





/* ************************************************** */
/* ----------------- Saisie Adresse ----------------- */
/* ************************************************** */
#pragma mark - Saisie Adresse

#pragma mark |--> Touche "Rejoindre" validée (UITextFieldDelegate)
//  Cette méthode est appellée lorsque l'édition du champ de saisi est terminée
//      après que l'utilisateur est appuyé sur la touche "Rejoindre"
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [[_mapView addressTextField] resignFirstResponder]; // Appel textFieldDidEndEditing

    //  Création adresse URL, requête et connexion
    NSString *addresseToGo = [[[_mapView addressTextField] text] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSURL *urlGoogleMaps = [NSURL URLWithString:[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/xml?address=%@&sensor=false", addresseToGo]];
    NSURLRequest *requestToGoogleMaps = [NSURLRequest requestWithURL:urlGoogleMaps cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15];
    NSURLConnection *connectionToGoogleMaps = [NSURLConnection connectionWithRequest:requestToGoogleMaps delegate:self];

    //  Initialisation du buffer pour qu'il soit prêt à recevoir les données
    xmlDataBuffer = [[NSMutableData alloc] init];
    //  Lancement de la connexion
    [connectionToGoogleMaps start];
    
    return YES;
}





/* ************************************************** */
/* --------------- Gestion Connexion ---------------- */
/* ************************************************** */
#pragma mark - Gestion Connexion

#pragma mark |--> Erreur Connexion (NSURLConnectionDelegation)
//  Méthode appellée lorsque la tentative de connexion échoue
//  Cette méthode affiche une UIAlertView pour indiquer l'erreur à l'utilisateur
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    UIAlertView *connectionError = [[UIAlertView alloc] initWithTitle:@"Connexion"
                                                              message:[NSString stringWithFormat:@"Erreur lors de la connexion.\nVérifier votre connexion réseau.\n%@", [error localizedDescription]]
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil, nil];
    [connectionError show];
    [connectionError release];
    connectionError = nil;
    [connection release];
    connection = nil;
    
}


#pragma mark |--> Réception des données (NSURLConnectionDataDelegate)
//  Méthode appellée lorsque l'objet NSURLConnection reçoit des données
//  Cette méthode ajoute les données reçues au buffer.
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [xmlDataBuffer appendData:data];
}


#pragma mark |--> Données reçues (NSURLConnectionDataDelegate)
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
//    NSLog(@"Téléchagement fini");
    [[_mapView addressTextField] setText:nil];
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:xmlDataBuffer];
    [xmlParser setDelegate:self];
    [xmlParser parse];
}





/* ************************************************** */
/* ----------------- Parsage XML ----------------- */
/* ************************************************** */
#pragma mark - Parsage XML


- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    // Initialisation des variables
    nbResult = 0;
    nbAddressComponent = 0;
    
    isFormattedAddress = NO;
    isShortName = NO;
    isGeometry = NO;
    isLocation = NO;
    isLatitude = NO;
    isLongitude = NO;
    
    tempString = nil;
    xmlResult_FormattedAddress = nil;
    xmlResult_Locality = nil;
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    //  Incrémentation nbResult puis initialisation des variables
    if ([elementName isEqualToString:@"result"])
    {
        nbResult++;
    }
    
    if (nbResult == 1) // Si plusieurs résultats on ne prends en compte que le 1er
    {
        //  On est dans la balise "formatted_address"
        if ([elementName isEqualToString:@"formatted_address"])
        {
            isFormattedAddress = YES;
        }
        
        //  Passage dans une balise "address_component
        if ([elementName isEqualToString:@"address_component"])
        {
            nbAddressComponent++;
        }
        
        //  3ème balise "address_component" et on est est dans la balise "short_name"
        if (nbAddressComponent == 3 && [elementName isEqualToString:@"short_name"])
        {
            isShortName = YES;
        }
        
        //  On est dans la balise geometry
        if ([elementName isEqualToString:@"geometry"])
        {
            isGeometry = YES;
        }
        
        //  On est dans la balise location dans geometry
        if (isGeometry && [elementName isEqualToString:@"location"])
        {
            isLocation = YES;
        }
        
        //  On est dans la balise lat dans location dans geometry
        if (isGeometry && isLocation && [elementName isEqualToString:@"lat"])
        {
            isLatitude = YES;
        }
        
        //  On est dans la balise lng dans location dans geometry
        if (isGeometry && isLocation && [elementName isEqualToString:@"lng"])
        {
            isLongitude = YES;
        }
    }
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (nbResult == 1) // Si plusieurs résultats on ne prends en compte que le 1er
    {
        //  Stockage de la string trouvée seulement si différente d'un retour à la ligne
        if ([string rangeOfString:@"\n"].location == NSNotFound)
        {
            if (tempString != nil)
            {
                [tempString release];
                tempString = nil;
            }
            
            tempString = [string copy];
        }

        //  Si on est dans la balise 'formatted_address", chaine = l'adresse complète => on conserve
        if (isFormattedAddress)
        {
            xmlResult_FormattedAddress = [string copy];
            //  Passage à NO pour ne plus stocker les prochaines string de cette balise
            isFormattedAddress = NO;
        }
        
        //  Si on est dans la 3ème balise "address_component"
        if (nbAddressComponent == 3)
        {
            //  Si on est dans la balise "short_name", chaine = la localité => on conserve
            if (isShortName)
            {
                xmlResult_Locality = [string copy];
                //  Passage à NO pour ne plus stocker les prochaines string de cette balise
                isShortName = NO;
            }
        }
        
        //  Si on est dans la balise lat de location de geometry, chaine = lattitude => on conserve
        if (isGeometry && isLocation && isLatitude)
        {
            xmlResult_Coordinates.latitude = [string doubleValue];
            //  Passage à NO pour ne plus stocker les prochaines string de cette balise
            isLatitude = NO;
        }

        //  Si on est dans la balise lnt de location de geometry, chaine = longitude => on conserve
        if (isGeometry && isLocation && isLongitude)
        {
            xmlResult_Coordinates.longitude = [string doubleValue];
            //  Passage à NO pour ne plus stocker les prochaines string de cette balise
            isLongitude = NO;
        }
    }
}


- (void)parserDidEndDocument:(NSXMLParser *)parser
{
//    NSLog(@"formatted adress : %@, locality = %@, latitude = %f et longitude = %f", xmlResult_FormattedAddress, xmlResult_Locality, xmlResult_Coordinates.latitude, xmlResult_Coordinates.longitude);
  
    if (xmlResult_FormattedAddress != nil && xmlResult_Locality != nil && xmlResult_Coordinates.latitude != 0 && xmlResult_Coordinates.longitude != 0)
    {
        // Enregistrement dans l'historique
        HistoryItem *newItem = [[HistoryItem alloc] initHistoryItemWithTitle:xmlResult_Locality address:xmlResult_FormattedAddress andCoordinates:xmlResult_Coordinates];
        [_dataSourceManager addItem:newItem];
        [[_historyTableViewController tableView] reloadData];
        
        
        // Affichage de l'adresse sur la carte
        MKCoordinateSpan span = {.latitudeDelta = 0.015, .longitudeDelta = 0.015};
        // On défini la région a afficher avec les coordonnées et la valeur de "zoom"
        [[_mapView map] setRegion:MKCoordinateRegionMake([newItem coordinates], span) animated:YES];
        
        
        //  Création et affichage de la notification
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        [notification setAlertBody:[NSString stringWithFormat:@"Voyage au %@", [newItem address]]];
        [notification setSoundName:UILocalNotificationDefaultSoundName];
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        
        
        [notification release];
        [newItem release];
        [xmlResult_FormattedAddress release];
        [xmlResult_Locality release];
    }
}





/* ************************************************** */
/* ---------------- Gestion Rotation ---------------- */
/* ************************************************** */
#pragma mark - Gestion Rotation

- (BOOL)shouldAutorotate
{
    return YES;
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        [_mapView setConstraintsForOrientation:toInterfaceOrientation];
    }
}


#pragma mark |--> Rotation en mode portrait (ISplitViewControllerDelegate)
- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    [[self navigationItem] setLeftBarButtonItem:barButtonItem animated:YES];
}


#pragma mark |--> Rotation en mode paysage (ISplitViewControllerDelegate)
- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)button
{
    [[self navigationItem] setLeftBarButtonItem:nil animated:YES];
}





/* ************************************************** */
/* ----------------- Gestion Mémoire ---------------- */
/* ************************************************** */
#pragma mark - Gestion Mémoire

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
