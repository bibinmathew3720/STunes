//
//  FavouriteTVC.h
//  Stunes
//
//  Created by Cocoalabs India on 24/10/16.
//  Copyright © 2016 Cocoalabs India. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavouriteTVC : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgImage;
@property (weak, nonatomic) IBOutlet UILabel *lblSongName;
@property (weak, nonatomic) IBOutlet UILabel *lblDetails;

@end
