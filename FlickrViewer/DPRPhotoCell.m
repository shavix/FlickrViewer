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
        
        self.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
        
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 3.0f;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowRadius = 3.0f;
        self.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
        self.layer.shadowOpacity = 0.5f;
        // make sure we rasterize nicely for retina
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.layer.shouldRasterize = YES;
        
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
