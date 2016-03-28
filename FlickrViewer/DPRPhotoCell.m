//
//  DPRPhotoCell.m
//  FlickrViewer
//
//  Created by David Richardson on 3/27/16.
//  Copyright © 2016 David Richardson. All rights reserved.
//

#import "DPRPhotoCell.h"
#import "DPRPhotoHelper.h"

@interface DPRPhotoCell()

@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation DPRPhotoCell

- (id) initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if(self) {
        
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];

        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        
        [self.contentView addSubview:self.imageView];
        
    }
    
    return self;
    
}

- (void)setPhoto:(NSDictionary *)photo {
    
    _photo = photo;
    
    [DPRPhotoHelper thumbnailForPhoto:photo completion:^(UIImage *image){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = image;            
        });
        
    }];
    
}

@end
