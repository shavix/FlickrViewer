//
//  DPRPhotoHelper.h
//  FlickrViewer
//
//  Created by David Richardson on 3/27/16.
//  Copyright © 2016 David Richardson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DPRCollectionViewController.h"

@interface DPRPhotoHelper : NSObject

+ (void)thumbnailForPhoto:(NSDictionary *)photo completion:(void(^)(UIImage *image))completion;
+ (void)HDImageForPhoto:(NSDictionary *)photo completion:(void(^)(NSDictionary *HDPhoto))completion;
+ (void)infoForPhoto:(NSDictionary *)photo completion:(void(^)(NSDictionary *info))completion;

@end
