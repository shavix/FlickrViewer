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

static const NSString *flickrSecretKey = @"b47a9d72da514bdf";
static const NSInteger numResults = 10;

static NSString *cellReuseIdentifier = @"photoCell";
static NSString *detailSegueIdentifier = @"detailSegue";

@interface DPRCollectionViewController()

@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic, strong) NSArray *photos;

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
            [self.collectionView reloadData];
        });
        
    }];
    
    [dataTask resume];
}


#pragma mark - UI

- (void)UISetup {
    
    [self addSearchBar];
    
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
    
    NSDictionary *photo = [_photos objectAtIndex:indexPath.row];
    
    photoCell.photo = photo;
    
    return photoCell;
    
}

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [self performSegueWithIdentifier:detailSegueIdentifier sender:self];
    
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
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [self.view endEditing:YES];
    [self search];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    [self cancelSearch];
    
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






@end
