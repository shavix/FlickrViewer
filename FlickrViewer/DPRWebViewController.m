//
//  DPRWebViewController.m
//  FlickrViewer
//
//  Created by David Richardson on 3/27/16.
//  Copyright © 2016 David Richardson. All rights reserved.
//

#import "DPRWebViewController.h"
#import "DPRPhotoHelper.h"

static const NSString *flickrAPIKey = @"d7f3b39e34aad94a9c0249e676c0074f";

@interface DPRWebViewController()

@property (strong, nonatomic) UIActivityIndicatorView *activityView;
@property (strong, nonatomic) UILabel *loadingLabel;

@end

@implementation DPRWebViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self activityIndicator];
    
}

- (void)activityIndicator {
    
    // activity indicator
    _activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
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
    [[self view] addSubview:_loadingLabel];
    
    // make request
    [self urlRequest];

}

#pragma mark - webView

- (void) webViewDidFinishLoad:(UIWebView *)webView {
    
    _activityView.hidden = YES;
    _loadingLabel.hidden = YES;
    
}

- (void)urlRequest {
    
    // get info
    [DPRPhotoHelper infoForPhoto:_photo withAPIKey:flickrAPIKey completion:^(NSDictionary *info){
        
        NSArray *urlDictionary = [[info objectForKey:@"urls"] objectForKey:@"url"];
        NSString *website = [[urlDictionary objectAtIndex:0] objectForKey:@"_content"];
        NSURL *url = [NSURL URLWithString:website];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
        
        [self.webView loadRequest:urlRequest];
        [self.webView setDelegate:self];
        
    }];
}


@end
