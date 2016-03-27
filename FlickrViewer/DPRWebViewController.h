//
//  DPRWebViewController.h
//  FlickrViewer
//
//  Created by David Richardson on 3/27/16.
//  Copyright © 2016 David Richardson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DPRWebViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) NSDictionary *photo;

@end
