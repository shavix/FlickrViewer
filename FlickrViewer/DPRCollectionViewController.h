//
//  DPRCollectionViewController.h
//  FlickrViewer
//
//  Created by David Richardson on 3/27/16.
//  Copyright © 2016 David Richardson. All rights reserved.
//

#import <UIKit/UIKit.h>

static const NSString *flickrAPIKey = @"d7f3b39e34aad94a9c0249e676c0074f";

@interface DPRCollectionViewController : UICollectionViewController <UISearchBarDelegate,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

@end
