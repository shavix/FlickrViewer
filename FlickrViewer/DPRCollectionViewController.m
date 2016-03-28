//
//  DPRCollectionViewController.m
//  FlickrViewer
//
//  Created by David Richardson on 3/27/16.
//  Copyright © 2016 David Richardson. All rights reserved.
//

#import "DPRCollectionViewController.h"
#import "DPRDetailViewController.h"
#import "DPRPhotoCell.h"
#import "DPRPhotoHelper.h"

static const NSString *flickrSecretKey = @"b47a9d72da514bdf";
static const NSInteger numResults = 50;

static NSString *cellReuseIdentifier = @"photoCell";
static NSString *detailSegueIdentifier = @"detailSegue";

@interface DPRCollectionViewController()

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIView *fullScreenView;

@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic, strong) NSArray *photos;
@property (nonatomic) BOOL endOfSearch;

@end

@implementation DPRCollectionViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setup];
    
    [self UISetup];
    
}

- (void)setup {
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[DPRPhotoCell class] forCellWithReuseIdentifier:cellReuseIdentifier];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.urlSession = [NSURLSession sessionWithConfiguration:configuration];

}


#pragma mark - searching

- (void)search {
    
    NSString *text = _searchBar.text;
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&tags=%@&per_page=%ld&format=json&nojsoncallback=1", flickrAPIKey, text, numResults];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDownloadTask *dataTask = [_urlSession downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        
        NSData *data = [NSData dataWithContentsOfURL:location];
        
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];

        self.photos = [[jsonDictionary valueForKey:@"photos"] objectForKey:@"photo"];

        dispatch_async(dispatch_get_main_queue(), ^{
            
            // if user hit search - store results
            if(_endOfSearch){
                [self persistData];
            }
            
            // only update UI if user's done typing
            [self.collectionView reloadData];
            
        });
        
    }];
    
    [dataTask resume];
}


#pragma mark - UI

- (void)UISetup {
    
    [self addSearchBar];
    
    //UITapGestureRecognizer *collectionViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(collectionViewTapped)];
    
    //[self.collectionView addGestureRecognizer:collectionViewTap];
    
}

- (void)collectionViewTapped {

    [self.searchBar resignFirstResponder];

}

- (void)addSearchBar {
    
    if(!_searchBar) {
        
        CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        CGFloat searchY = self.navigationController.navigationBar.frame.size.height + statusBarHeight;
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        
        CGRect frame = CGRectMake(0, searchY, screenWidth, 40);
        self.searchBar = [[UISearchBar alloc] initWithFrame:frame];
        
        self.searchBar.delegate = self;
        self.searchBar.placeholder = @"search";
        
    }
    
    if (![self.searchBar isDescendantOfView:self.view]) {
        [self.view addSubview:self.searchBar];
    }
    
}

#pragma mark - collectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [_photos count];
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    DPRPhotoCell *photoCell = [collectionView dequeueReusableCellWithReuseIdentifier:cellReuseIdentifier forIndexPath:indexPath];
    
    // Load image on a non-ui-blocking thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
        NSDictionary *photo = [_photos objectAtIndex:indexPath.row];
        // image set in main queue
        photoCell.photo = photo;
    });
    
    return photoCell;
    
}

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // set image to full screen
    _fullScreenView = [[UIView alloc] initWithFrame:self.view.frame];
    _fullScreenView.backgroundColor = [UIColor blackColor];

    UISwipeGestureRecognizer *imageSwiped = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(imageSwiped)];
    [imageSwiped setDirection:(UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown)];
    [_fullScreenView addGestureRecognizer:imageSwiped];
    
    [DPRPhotoHelper HDImageForPhoto:[_photos objectAtIndex:indexPath.row] completion:^(NSDictionary *HDPhoto){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //self.navigationItem.title = title;

            // get & set image
            NSString *urlString = [HDPhoto objectForKey:@"source"];
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]]];
            
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            
            CGFloat imageWidth = image.size.width;
            CGFloat scale = self.view.frame.size.width / imageWidth;
            
            CGFloat imageHeight = image.size.height;
            CGFloat newHeight = imageHeight * scale;
            
            CGRect imageFrame = CGRectMake(0, 0, self.view.frame.size.width, newHeight);
            
            imageView.frame = imageFrame;
            imageView.center = CGPointMake(self.view.center.x, self.view.center.y);
            
            [_fullScreenView addSubview:imageView];
            
            // add title label
            NSString *title = [[_photos objectAtIndex:indexPath.row] objectForKey:@"title"];
            CGRect titleFrame = CGRectMake(0, 0, self.view.frame.size.width, 40);
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
            titleLabel.text = title;
            titleLabel.textColor = [UIColor whiteColor];
            [titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
            titleLabel.adjustsFontSizeToFitWidth = NO;
            titleLabel.numberOfLines = 0;
            titleLabel.textAlignment = NSTextAlignmentCenter;

            CGFloat startY = self.view.frame.size.height - 80;
            titleLabel.center = CGPointMake(self.view.center.x, startY);
            
            [_fullScreenView addSubview:titleLabel];
            
            // add buttons to navigation bar
            
        });
    }];

    [self.view addSubview:_fullScreenView];
    
}

- (void)imageSwiped {
    
    self.navigationItem.title = @"Photo Reel";
    [_fullScreenView removeFromSuperview];
    
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:detailSegueIdentifier]){
        
        NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
        NSIndexPath *indexPath = [indexPaths firstObject];
        NSInteger index = indexPath.item;
        
        DPRDetailViewController *detailViewController = segue.destinationViewController;
        NSDictionary *photo = [self.photos objectAtIndex:index];
        detailViewController.photo = photo;
        
    }
    
}



#pragma mark - searchBar

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    // search as you type (optional)
    self.endOfSearch = false;
    
    [self search];

}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    self.endOfSearch = true;
    [self.view endEditing:YES];
    [self search];
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    [self cancelSearch];
    
    // clear collectionView
    self.photos = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
    [self.searchBar setShowsCancelButton:YES animated:YES];

}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    
    [self.searchBar setShowsCancelButton:NO animated:YES];
    
}

- (void)cancelSearch {
    
    [self.searchBar resignFirstResponder];
    self.searchBar.text = nil;
    
}


#pragma mark - data persistence


- (void)persistData {
    
    //Get the documents directory path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"searches.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: path]) {
        
        path = [documentsDirectory stringByAppendingPathComponent: [NSString stringWithFormat:@"searches.plist"] ];
        NSLog(@"DOESN'T EXIST");

    }
    else {
        NSLog(@"EXISTS");
    }
    
    NSMutableDictionary *data;
    
    if ([fileManager fileExistsAtPath: path]) {
        
        data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    }
    else {
        // If the file doesn’t exist, create an empty dictionary
        data = [[NSMutableDictionary alloc] init];
    }
    
    //To insert the data into the plist
    NSString *text = _searchBar.text;

    // array of photo IDs to identify them
    NSMutableArray *photoIDs = [[NSMutableArray alloc] init];
    
    // populate array with photoIDs
    for (NSDictionary *photo in _photos) {
        
        NSString *ID = [photo objectForKey:@"id"];
        [photoIDs addObject:ID];
        
    }
    
    [data setObject:photoIDs forKey:text];
    [data writeToFile:path atomically:YES];
    
    //To reterive the data from the plist
    NSMutableDictionary *savedValue = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    NSString *value = [savedValue objectForKey:@"id"];
    NSLog(@"%@",value);
}






@end