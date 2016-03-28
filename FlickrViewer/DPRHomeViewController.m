//
//  HomeViewController.m
//  FlickrViewer
//
//  Created by David Richardson on 3/27/16.
//  Copyright © 2016 David Richardson. All rights reserved.
//

#import "DPRHomeViewController.h"

@interface DPRHomeViewController()
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@end

@implementation DPRHomeViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self UISetup];
    
}

- (void)UISetup {
    
    _startButton.hidden = YES;
    
    // gif background
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"owl" ofType:@"gif"];
    NSData *gif = [NSData dataWithContentsOfFile:filePath];
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);

    UIWebView *webView = [[UIWebView alloc] init];
    webView.delegate = self;
    webView.layer.zPosition = -1;
    webView.center = CGPointMake(self.view.center.x, self.view.center.y);
    [webView loadData:gif MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
    webView.frame = frame;
    webView.userInteractionEnabled = NO;
    
    [self.view addSubview:webView];

    // button ui
    _startButton.layer.cornerRadius = 10;
    _startButton.layer.shadowColor = [UIColor blackColor].CGColor;
    _startButton.layer.shadowRadius = 3.0f;
    _startButton.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    _startButton.layer.shadowOpacity = 0.5f;
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    _startButton.hidden = NO;
}

@end
