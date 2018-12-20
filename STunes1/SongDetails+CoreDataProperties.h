//
//  SongDetails+CoreDataProperties.h
//  STunes1
//
//  Created by Cocoalabs India on 11/11/16.
//  Copyright © 2016 Cocoalabs India. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SongDetails.h"

NS_ASSUME_NONNULL_BEGIN

@interface SongDetails (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *albumName;
@property (nullable, nonatomic, retain) NSString *songName;
@property (nullable, nonatomic, retain) NSString *lyrics;
@property (nullable, nonatomic, retain) NSData *coverImg;
@property (nullable, nonatomic, retain) NSNumber *isFavourite;
@property (nullable, nonatomic, retain) NSNumber *songID;


@end

NS_ASSUME_NONNULL_END
