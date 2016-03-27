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
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"owl" ofType:@"gif"];
    NSData *gif = [NSData dataWithContentsOfFile:filePath];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    [webView loadData:gif MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
    webView.userInteractionEnabled = NO;
    [self.view addSubview:webView];
    
}

@end
