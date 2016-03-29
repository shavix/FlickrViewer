//
//  DPRCollectionViewController.h
//  FlickrViewer
//
//  Created by David Richardson on 3/27/16.
//  Copyright © 2016 David Richardson. All rights reserved.
//

#import <UIKit/UIKit.h>

// CollectionViewController with search bar and image loading
@interface DPRCollectionViewController : UICollectionViewController <UISearchBarDelegate,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

@end
