//
//  DPRWebViewController.m
//  FlickrViewer
//
//  Created by David Richardson on 3/27/16.
//  Copyright © 2016 David Richardson. All rights reserved.
//

#import "DPRWebViewController.h"

@interface DPRWebViewController()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (strong, nonatomic) UIActivityIndicatorView *activityView;
@property (strong, nonatomic) UILabel *loadingLabel;

@end

@implementation DPRWebViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
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
    
    [self urlRequest];

    
}


- (void) webViewDidFinishLoad:(UIWebView *)webView {
    
    _activityView.hidden = YES;
    
    _loadingLabel.hidden = YES;
    
}


- (void)urlRequest {
    
    NSString *website = [_photo objectForKey:@"url"];
    
    NSURL *url = [NSURL URLWithString:website];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    
    [self.webView loadRequest:urlRequest];
    
    [self.webView setDelegate:self];
}


@end
