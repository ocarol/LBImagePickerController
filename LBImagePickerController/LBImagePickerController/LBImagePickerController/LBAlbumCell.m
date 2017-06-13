//
//  LBAlbumCell.m
//  LBImagePickerController
//
//  Created by 余丽丽 on 2017/6/2.
//  Copyright © 2017年 ocarol. All rights reserved.
// cell 的高度为86

#import "LBAlbumCell.h"

@interface LBAlbumCell()
/** 图片*/
@property (nonatomic, weak) UIImageView * photoImage;
/** 分类名*/
@property (nonatomic, weak) UILabel * classifyLabel;
/** 数量*/
@property (nonatomic, weak) UILabel * photoNumber;
/** 箭头*/
@property (nonatomic, weak) UIImageView * arrowImageView;
@end

@implementation LBAlbumCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self setUpUI];
    }
    
    return self;
}

- (void)setUpUI{
    
    UIImageView *photoImage = [[UIImageView alloc] init];
    photoImage.contentMode = UIViewContentModeScaleAspectFill;
    photoImage.clipsToBounds = YES;
    
    UILabel *classifyLabel = [[UILabel alloc] init];
    classifyLabel.font = [UIFont systemFontOfSize:17];
    classifyLabel.textColor = [UIColor blackColor];
    
    UILabel *photoNumber = [[UILabel alloc] init];
    photoNumber.font = [UIFont systemFontOfSize:10];
    photoNumber.textColor = [UIColor grayColor];
    
    UIImageView *arrowImageView = [[UIImageView alloc] init];
    
    [self.contentView addSubview:photoImage];
    [self.contentView addSubview:classifyLabel];
    [self.contentView addSubview:photoNumber];
    [self.contentView addSubview:arrowImageView];
    
    self.photoImage = photoImage;
    self.classifyLabel = classifyLabel;
    self.photoNumber = photoNumber;
    self.arrowImageView = arrowImageView;
    
    CGFloat arrowWH = 15;
    CGFloat photoH = 70;
    CGFloat marginW = 20;
    CGFloat cellH = 86;

    self.photoImage.frame = CGRectMake(10, (cellH - photoH) * 0.5, photoH, photoH);
    self.arrowImageView.frame = CGRectMake(LBPHONEWIDTH - marginW - arrowWH, (cellH - arrowWH) * 0.5, arrowWH, arrowWH);
    
    CGFloat labelX = CGRectGetMaxX(self.photoImage.frame) + marginW;
    CGFloat labelW = CGRectGetMinX(self.arrowImageView.frame) - labelX;
    self.classifyLabel.frame = CGRectMake(labelX, cellH * 0.5 - 5 - 20, labelW, 20);
    self.photoNumber.frame = CGRectMake(labelX, cellH * 0.5 + 5 , labelW, 10);
}

- (void)setModel:(LBAlbumModel *)model {
    _model = model;
    self.classifyLabel.text = model.name;
    self.photoNumber.text = [NSString stringWithFormat:@"%zd",model.count];

__weak __typeof(self) weakSelf = self;
    [[LBImageManager manager] getPostImageWithAlbumModel:model completion:^(UIImage *postImage) {
        weakSelf.photoImage.image = postImage;
    }];
}

@end
