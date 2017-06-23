//
//  CollectionViewCell.m
//  LBImagePickerController
//
//  Created by 余丽丽 on 2017/6/14.
//  Copyright © 2017年 ocarol. All rights reserved.
//

#import "CollectionViewCell.h"
#import "UIView+LBLayout.h"

@interface CollectionViewCell()
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *photoImageView;
@end

@implementation CollectionViewCell

- (void)setImage:(UIImage *)image {
    _image = image;
    self.photoImageView.image = image;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
    self.titleLabel.hidden = (title.length == 0);
}
@end
