//
//  DPRCollectionViewController.m
//  FlickrViewer
//
//  Created by David Richardson on 3/27/16.
//  Copyright © 2016 David Richardson. All rights reserved.
//

#import "DPRCollectionViewController.h"
#import "DPRPhotoCell.h"
#import "DPRPhotoHelper.h"
#import "DPRWebViewController.h"

static const NSInteger numResults = 60;
static NSString *cellReuseIdentifier = @"photoCell";
static NSString *webViewSegueIdentifier = @"webViewSegue";

@interface DPRCollectionViewController()

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIView *fullScreenView;
@property (nonatomic, strong) UIBarButtonItem *cancelButton;
@property (nonatomic, strong) UIBarButtonItem *saveButton;
@property (nonatomic, strong) UILabel *startLabel;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *HDImageView;
@property (nonatomic, strong) UIButton *webViewButton;
@property (strong, nonatomic) UIActivityIndicatorView *activityView;
@property (strong, nonatomic) UILabel *loadingLabel;

@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic, strong) NSArray *photos;
@property (nonatomic) BOOL endOfSearch;
@property (nonatomic, strong) UIImage *HDImage;
@property (nonatomic, strong) NSDictionary *currentPhoto;

@end

@implementation DPRCollectionViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setup];
    
    [self UISetup];
    
}

- (void)setup {
    
    // collectionView
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[DPRPhotoCell class] forCellWithReuseIdentifier:cellReuseIdentifier];
    
    // urlSession
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.urlSession = [NSURLSession sessionWithConfiguration:configuration];

}

#pragma mark - UI

- (void)UISetup {
    
    [self addSearchBar];
    
    [[UINavigationBar appearance] setBackgroundColor:[UIColor whiteColor]];
}

- (void)collectionViewTapped {

    [self.searchBar resignFirstResponder];

}

- (void)addSearchBar {
    
    // create search bar
    if(!_searchBar) {
        CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        CGFloat searchY = self.navigationController.navigationBar.frame.size.height + statusBarHeight;
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        
        CGRect frame = CGRectMake(0, searchY, screenWidth, 40);
        self.searchBar = [[UISearchBar alloc] initWithFrame:frame];
        
        self.searchBar.delegate = self;
        self.searchBar.placeholder = @"search";
        
        [(UITextField *)self.searchBar setReturnKeyType:UIReturnKeyDone];

    }
    
    // add once
    if (![self.searchBar isDescendantOfView:self.view]) {
        [self.view addSubview:self.searchBar];
    }
    
}

- (void)linkTapped {
    [self performSegueWithIdentifier:webViewSegueIdentifier sender:self];
}

- (void)cancelPhoto {
    [self closePhoto];
}

- (void)savePhoto {
    UIImageWriteToSavedPhotosAlbum(_HDImage, self, @selector(savedImage:toPhotoAlbumWithError:usingContextInfo:), nil);
}

- (void)savedImage:(UIImage *)image toPhotoAlbumWithError:(NSError *)error usingContextInfo:(void*)ctxInfo {
    
    // unable to save to photo album
    if (error) {
        UIAlertController *controller = [UIAlertController
                                         alertControllerWithTitle:@"Error"
                                         message:@"Unable to save to photo album"
                                         preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:@"OK"
                                   style:UIAlertActionStyleDefault
                                   handler:nil];
        [controller addAction:okAction];
        
        [self presentViewController:controller animated:YES completion:nil];
    }
    // saved to photo album
    else {
        UIAlertController *controller = [UIAlertController
                                         alertControllerWithTitle:@"Message"
                                         message:@"Saved to photo album!"
                                         preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:@"OK"
                                   style:UIAlertActionStyleDefault
                                   handler:nil];
        [controller addAction:okAction];
        
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (void)closePhoto {
    
    // reset navigation item
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.title = @"Photo Reel";
    [_fullScreenView removeFromSuperview];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // webView segue
    if([segue.identifier isEqualToString:webViewSegueIdentifier]){
        
        DPRWebViewController *webViewController = segue.destinationViewController;
        webViewController.photo = _currentPhoto;
        
    }
    
}

- (void)activityIndicator {
    
    // activity indicator
    _activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _activityView.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2.0, [UIScreen mainScreen].bounds.size.height / 2.0);
    [_activityView startAnimating];
    _activityView.layer.zPosition = 1000;
    _activityView.tag = 100;
    [self.view addSubview:_activityView];
    
    // label
    int x = ([UIScreen mainScreen].bounds.size.width / 2.0) - 30;
    int y = ([UIScreen mainScreen].bounds.size.height / 2.0) + 20;
    _loadingLabel = [[UILabel alloc]initWithFrame:CGRectMake(x, y, 200, 40)];
    [_loadingLabel setBackgroundColor:[UIColor clearColor]];
    
    _loadingLabel.layer.zPosition = 1000;
    [_loadingLabel setText:@"Loading"];
    _loadingLabel.textColor = [UIColor whiteColor];
    [[self view] addSubview:_loadingLabel];
    
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
    
    [self activityIndicator];

    [DPRPhotoHelper HDImageForPhoto:[_photos objectAtIndex:indexPath.row] completion:^(NSDictionary *HDPhoto){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // get & set image
            NSString *urlString = [HDPhoto objectForKey:@"source"];
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]]];
            self.HDImage = image;

            self.currentPhoto = [_photos objectAtIndex:indexPath.row];
            
            self.HDImageView = [[UIImageView alloc] initWithImage:image];
            CGFloat imageWidth = image.size.width;
            CGFloat scale = self.view.frame.size.width / imageWidth;
            CGFloat imageHeight = image.size.height;
            CGFloat newHeight = imageHeight * scale;
            CGRect imageFrame = CGRectMake(0, 0, self.view.frame.size.width, newHeight);
            _HDImageView.frame = imageFrame;
            _HDImageView.center = CGPointMake(self.view.center.x, self.view.center.y);
            
            // scrollView
            self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
            self.scrollView.center = CGPointMake(self.view.center.x, self.view.center.y);
            self.scrollView.minimumZoomScale=0.5;
            self.scrollView.maximumZoomScale=6.0;
            self.scrollView.contentSize=CGSizeMake(_HDImageView.frame.size.width, _HDImageView.frame.size.height);
            self.scrollView.showsHorizontalScrollIndicator = NO;
            self.scrollView.showsVerticalScrollIndicator = NO;
            self.scrollView.delegate=self;
            [self.scrollView addSubview:_HDImageView];
            [_fullScreenView addSubview:_scrollView];
            
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
            
            // add webView button
            CGRect buttonFrame = CGRectMake(0, 0, 100, 20);
            self.webViewButton = [[UIButton alloc] initWithFrame:buttonFrame];
            [self.webViewButton setTitle:@"Flickr link" forState:UIControlStateNormal];
            [self.webViewButton titleLabel].font = [UIFont italicSystemFontOfSize:12];
            [self.webViewButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.webViewButton.center = CGPointMake(titleLabel.center.x, titleLabel.center.y + 40);
            [self.webViewButton addTarget:self action:@selector(linkTapped) forControlEvents:UIControlEventTouchUpInside];
            [_fullScreenView addSubview:self.webViewButton];
            
            // add buttons to navigation bar
            _saveButton = [[UIBarButtonItem alloc]
                                           initWithTitle:@"Save"
                                           style: UIBarButtonItemStylePlain
                                           target:self
                                           action:@selector(savePhoto)];
            self.navigationItem.rightBarButtonItem = _saveButton;
            
            _cancelButton = [[UIBarButtonItem alloc]
                           initWithTitle:@"Cancel"
                           style: UIBarButtonItemStylePlain
                           target:self
                           action:@selector(cancelPhoto)];
            self.navigationItem.leftBarButtonItem = _cancelButton;
            
            // hide activity indicator
            [_activityView removeFromSuperview];
            [_loadingLabel removeFromSuperview];
            
        });
    }];

    [self.view addSubview:_fullScreenView];
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.HDImageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollV withView:(UIView *)view atScale:(CGFloat)scale
{
    [self.scrollView setContentSize:CGSizeMake(scale*self.view.frame.size.width, scale*self.view.frame.size.height)];
}

#pragma mark - searching

- (void)search {
    
    // if user hit search - store results
    if(_endOfSearch){
        [self persistData];
        return;
    }
    
    // remove all spaces
    NSString *text = [_searchBar.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // create request
    NSString *urlString = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&tags=%@&per_page=%ld&format=json&nojsoncallback=1", flickrAPIKey, text, (long)numResults];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // begin urlsession
    NSURLSessionDownloadTask *dataTask = [_urlSession downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        
        // parse data
        NSData *data = [NSData dataWithContentsOfURL:location];
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        self.photos = [[jsonDictionary valueForKey:@"photos"] objectForKey:@"photo"];
                
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
        
    }];
    
    [dataTask resume];
}

#pragma mark - searchBar

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    // do not search if newest character is space
    NSInteger length = [searchText length];
    char last = [searchText characterAtIndex:length - 1];
    if(last == ' '){
        return;
    }
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
}






@end
