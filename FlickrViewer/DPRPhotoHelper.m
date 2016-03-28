//
//  DPRPhotoHelper.m
//  FlickrViewer
//
//  Created by David Richardson on 3/27/16.
//  Copyright © 2016 David Richardson. All rights reserved.
//

#import "DPRPhotoHelper.h"
#import "DPRCollectionViewController.h"

@implementation DPRPhotoHelper

+ (void)thumbnailForPhoto:(NSDictionary *)photo completion:(void (^)(UIImage *))completion {
    
    NSString *urlString =
    [NSString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@_s.jpg",
     [photo objectForKey:@"farm"], [photo objectForKey:@"server"],
     [photo objectForKey:@"id"], [photo objectForKey:@"secret"]];
    
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]]];
    
    completion(image);
    
}

+ (void)HDImageForPhoto:(NSDictionary *)photo completion:(void (^)(NSDictionary *))completion{
    
    
    NSString *photoID = [photo objectForKey:@"id"];
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.getSizes&api_key=%@&photo_id=%@&format=json&nojsoncallback=1", flickrAPIKey, photoID];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDownloadTask *downloadTask = [urlSession downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        
        NSData *data = [NSData dataWithContentsOfURL:location];
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        
        NSArray *sizes = [[jsonDictionary objectForKey:@"sizes"] objectForKey:@"size"];
        NSDictionary *HDPhoto = [sizes objectAtIndex:[sizes count] - 1];
        
        completion(HDPhoto);
        
    }];
    
    [downloadTask resume];

    
}

@end