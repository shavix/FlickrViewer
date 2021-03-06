//
//  DPRPhotoCell.h
//  FlickrViewer
//
//  Created by David Richardson on 3/27/16.
//  Copyright © 2016 David Richardson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DPRPhotoCell : UICollectionViewCell

// Flickr photo encapsulated in cell
@property (strong, nonatomic) NSDictionary *photo;

@end
