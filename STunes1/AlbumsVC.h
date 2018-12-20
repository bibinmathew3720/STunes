//
//  AlbumsVC.h
//  Stunes
//
//  Created by Cocoalabs India on 22/10/16.
//  Copyright © 2016 Cocoalabs India. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumsVC : UIViewController
@property (weak, nonatomic) IBOutlet UICollectionView *AlbumsCollection;
@property (weak, nonatomic) IBOutlet UISegmentedControl *Segment;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *NavPlayer;

@end
