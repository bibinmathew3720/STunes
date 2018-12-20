//
//  FavouritesVC.h
//  Stunes
//
//  Created by Cocoalabs India on 24/10/16.
//  Copyright © 2016 Cocoalabs India. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavouritesVC : UIViewController
@property (weak, nonatomic) IBOutlet UIView *NoResultsView;
@property (weak, nonatomic) IBOutlet UITableView *tblFavs;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *NavPlayer;
@property (weak, nonatomic) IBOutlet UILabel *lblNoFavs;

@end
