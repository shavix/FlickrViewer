//
//  DPRDetailViewController.m
//  FlickrViewer
//
//  Created by David Richardson on 3/27/16.
//  Copyright © 2016 David Richardson. All rights reserved.
//

#import "DPRDetailViewController.h"
#import "DPRPhotoHelper.h"
#import "DPRWebViewController.h"

static NSString *webSegueIdentifier = @"webSegue";

@interface DPRDetailViewController()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *imageTitle;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (strong, nonatomic) UIActivityIndicatorView *activityView;
@property (strong, nonatomic) UILabel *loadingLabel;

@property (strong, nonatomic) NSDictionary *HDPhoto;

@end

@implementation DPRDetailViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self loading];
    
    [self UISetup];
    
}

- (void)loading {
    
    _detailLabel.text = nil;
    
    // activity indicator
    self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityView.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2.0, [UIScreen mainScreen].bounds.size.height / 2.0);
    [_activityView startAnimating];
    _activityView.layer.zPosition = 1000;
    _activityView.tag = 100;
    [self.view addSubview:_activityView];
    
    // label
    int x = ([UIScreen mainScreen].bounds.size.width / 2.0) - 30;
    int y = ([UIScreen mainScreen].bounds.size.height / 2.0) + 20;
    self.loadingLabel = [[UILabel alloc]initWithFrame:CGRectMake(x, y, 200, 40)];
    _loadingLabel.textColor = [UIColor whiteColor];
    [_loadingLabel setBackgroundColor:[UIColor clearColor]];
    
    _loadingLabel.layer.zPosition = 1000;
    [_loadingLabel setText:@"Loading"];
    [[self view] addSubview:_loadingLabel];

}

- (void)UISetup {
    
    self.imageTitle.text = nil;
    
    // photo helper call - get hd image
    [DPRPhotoHelper HDImageForPhoto:_photo completion:^(NSDictionary *HDPhoto){
    
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.HDPhoto = HDPhoto;
            
            _activityView.hidden = YES;
            _loadingLabel.hidden = YES;

            NSString *title = [_photo objectForKey:@"title"];
            _imageTitle.text = title;
            _detailLabel.text = @"(click image to view Flickr post)";
            
            // get & set image
            NSString *urlString = [HDPhoto objectForKey:@"source"];
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]]];
            _imageView.image = image;
            _imageView.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
            
            _imageView.layer.borderColor = [UIColor whiteColor].CGColor;
            _imageView.layer.borderWidth = 3.0f;
            _imageView.layer.shadowColor = [UIColor blackColor].CGColor;
            _imageView.layer.shadowRadius = 3.0f;
            _imageView.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
            _imageView.layer.shadowOpacity = 0.5f;
            // make sure we rasterize nicely for retina
            _imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
            _imageView.layer.shouldRasterize = YES;

            
            // gesture for webview
            _imageView.userInteractionEnabled = YES;
            UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped)];
            [_imageView addGestureRecognizer:imageTap];
            
        });
        

    }];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:webSegueIdentifier]) {
        
        DPRWebViewController *webViewController = segue.destinationViewController;
        webViewController.photo = _HDPhoto;
        
    }
    
}

- (void)imageTapped {
    
    [self performSegueWithIdentifier:webSegueIdentifier sender:self];
    
}

@end
