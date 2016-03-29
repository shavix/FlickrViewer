//
//  DPRPhotoHelper.h
//  FlickrViewer
//
//  Created by David Richardson on 3/27/16.
//  Copyright © 2016 David Richardson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DPRCollectionViewController.h"

// layer on top of Flickr API
@interface DPRPhotoHelper : NSObject

// class method - retrieve 
+ (void)thumbnailForPhoto:(NSDictionary *)photo completion:(void(^)(UIImage *image))completion;
+ (void)HDImageForPhoto:(NSDictionary *)photo withAPIKey:(const NSString *)flickrAPIKey completion:(void(^)(NSDictionary *HDPhoto))completion;
+ (void)infoForPhoto:(NSDictionary *)photo withAPIKey:(const NSString *)flickrAPIKey completion:(void(^)(NSDictionary *info))completion;

@end
