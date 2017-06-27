//
//  LBPhotoPickerPreviewCell.m
//  LBImagePickerController
//
//  Created by ocarol on 2017/6/2.
//  Copyright © 2017年 ocarol. All rights reserved.
//

#import "LBPhotoPickerPreviewCell.h"

#define ZOOM_MAX 2.0
#define ZOOM_MIN 1.0
#define ZOOM_FACTOR 2.0
#define TAP_AREA_SIZE 48.0f

@interface LBPhotoPickerPreviewCell()<UIScrollViewDelegate,UIGestureRecognizerDelegate>
/** 缩放scrollView */
@property (nonatomic,strong) UIScrollView *scrollView;
/** 图片 */
@property (nonatomic, strong) UIImageView *photoimageView;
/** 当前缩放比例 */
@property(nonatomic, assign)CGFloat currentZoomScale;

@end


@implementation LBPhotoPickerPreviewCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self addSubview:self.scrollView];
        [self.scrollView addSubview:self.photoimageView];
        self.scrollView.frame = self.bounds;
        self.photoimageView.frame = self.scrollView.bounds;
        [self addHanderGesture];
    }
    return self;
}

- (void)setModel:(LBAssetModel *)model {
    _model = model;
    [self zoomResetAnimated:NO];
    
    if (model.PreviewImage) {
        self.photoimageView.image = model.PreviewImage;
        return;
    }
    
    [[LBImageManager manager] getPhotoWithAsset:model.asset photoWidth:LBPHONEWIDTH completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        self.photoimageView.image = photo;
        if (!isDegraded) {
            model.PreviewImage = photo;
        }
    }];
}

/**
 * @brief 添加手势
 */
- (void)addHanderGesture {
    
    // 添加手势 单个手指双击
    UITapGestureRecognizer *doubleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTapOne.numberOfTouchesRequired = 1; doubleTapOne.numberOfTapsRequired = 2; doubleTapOne.delegate = self;
    [self.scrollView addGestureRecognizer:doubleTapOne];
    self.currentZoomScale = self.scrollView.zoomScale;
    
    // 点击手势  单击放大
    UITapGestureRecognizer *singleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTapOne.numberOfTouchesRequired = 1;
    singleTapOne.numberOfTapsRequired = 1;
    singleTapOne.delegate = self;
    [self.scrollView addGestureRecognizer:singleTapOne];
    
}
/**
 * @brief 放大
 */
-(void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        
        CGRect viewRect = recognizer.view.bounds; // View bounds
        
        CGPoint point = [recognizer locationInView:recognizer.view]; // Point
        // 手势点击区域
        CGRect zoomArea = CGRectInset(viewRect, TAP_AREA_SIZE, TAP_AREA_SIZE);
        
        if (CGRectContainsPoint(zoomArea, point)== true) {
            
            [self zoomIncrement:recognizer];
        }
    }
}

/**
 * @brief 双击手势
 */
-(void)handleDoubleTap:(UITapGestureRecognizer *)recognizer{
    
    
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        
        CGRect viewRect = recognizer.view.bounds; // View bounds
        
        CGPoint point = [recognizer locationInView:recognizer.view]; // Point
        
        // 手势点击区域
        CGRect zoomArea = CGRectInset(viewRect, TAP_AREA_SIZE, TAP_AREA_SIZE); // Area
        
        if (CGRectContainsPoint(zoomArea, point)== true) {
            
            switch (recognizer.numberOfTouchesRequired) // Touches count
            {
                case 1: // One finger double tap: zoom++
                {
                    // lyf一个手指双击放大
                    [self zoomIncrement:recognizer]; break;
                }
                    
                case 2: // Two finger double tap: zoom--
                {
                    // lyf 两个手指双击缩小
                    [self zoomDecrement:recognizer]; break;
                }
            }
            
            return;
        }
    }
    
}

/**
 *  放大
 *  @param recognizer 当前手势
 */
- (void)zoomIncrement:(UITapGestureRecognizer *)recognizer {
    
    [self updateMinimumMaximumZoom];
    
    CGPoint point = [recognizer locationInView:self.photoimageView];
    CGFloat zoomScale = self.scrollView.zoomScale;
    if (zoomScale < ZOOM_MAX) {
        
        zoomScale *= ZOOM_FACTOR;
        if (zoomScale > self.scrollView.maximumZoomScale){
            zoomScale = self.scrollView.maximumZoomScale;
        }
        
        CGRect zoomRect = [self zoomRectForScale:zoomScale withCenter:point];
        [self.scrollView zoomToRect:zoomRect animated:YES];
    }
}


// 缩小
- (void)zoomDecrement:(UITapGestureRecognizer *)recognizer{
    
    CGFloat zoomScale = self.scrollView.zoomScale;
    // lyf 获取手势触摸点的位置
    CGPoint point = [recognizer locationInView:self.photoimageView];
    
    if (zoomScale > self.scrollView.minimumZoomScale) // Zoom out
    {
        zoomScale /= ZOOM_FACTOR; // Zoom out by zoom factor amount
        
        if (zoomScale < self.scrollView.minimumZoomScale){
            zoomScale = self.scrollView.minimumZoomScale;
        }
        CGRect zoomRect = [self zoomRectForScale:zoomScale withCenter:point];
        [self.scrollView zoomToRect:zoomRect animated:YES];
    }
    else{
        
    }
    
}

/**
 * @brief 图片缩放比例复位
 */
- (void)zoomResetAnimated:(BOOL)animated {
    
    if (self.scrollView.zoomScale > ZOOM_MIN) // Reset zoom
    {
        if (animated) {
            [self.scrollView setZoomScale:self.scrollView. minimumZoomScale animated:YES];
        }else{
            self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
        }
    }
}

/**
 * @brief lyf获取缩放的手指中心区域
 */
- (CGRect)zoomRectForScale:(CGFloat)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect; // Centered zoom rect
    zoomRect.size.width = (self.bounds.size.width / scale);
    zoomRect.size.height = (self.bounds.size.height / scale);
    zoomRect.origin.x = (center.x - (zoomRect.size.width * 0.5f));
    zoomRect.origin.y = (center.y - (zoomRect.size.height * 0.5f));
    return zoomRect;
}

/**
 * @brief 更新缩放
 */
- (void)updateMinimumMaximumZoom{
    
    self.currentZoomScale = (self.currentZoomScale >= self.scrollView.maximumZoomScale) ? ZOOM_MAX : self.scrollView.zoomScale;
}

/**
 * @brief 设置中心点
 */
- (void)centerScrollViewContent {
    CGFloat iw = 0.0f; CGFloat ih = 0.0f; // Content width and height insets
    
    CGSize boundsSize = self.scrollView.bounds.size;
    CGSize contentSize = self.scrollView.contentSize; // Sizes
    if (contentSize.width < boundsSize.width) iw = ((boundsSize.width - contentSize.width) * 0.5f);
    
    if (contentSize.height < boundsSize.height) ih = ((boundsSize.height - contentSize.height) * 0.5f);
    
    UIEdgeInsets insets = UIEdgeInsetsMake(ih, iw, ih, iw); // Create (possibly updated) content insets
    
    if (UIEdgeInsetsEqualToEdgeInsets(self.scrollView.contentInset, insets) == false){
        self.scrollView.contentInset = insets;
    }
}

#pragma mark -更新scale
- (CGFloat)zoomScaleThatFitsWithTarget:(CGSize) target withSource:(CGSize) source {
    
    // 考虑内边距问题
    CGFloat g_BugFixWidthInset = 0.0f;
    CGFloat w_scale = (target.width / (source.width + g_BugFixWidthInset));
    CGFloat h_scale = (target.height / source.height);
    return ((w_scale < h_scale) ? w_scale : h_scale);
}


#pragma mark - scrollViewDelegate
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.photoimageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // 设置contenOffsize
    [self centerScrollViewContent];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    
    if (self.scrollView.zoomScale > self.scrollView.maximumZoomScale) {
        [self.scrollView setZoomScale:self.scrollView.zoomScale];
    }
}



#pragma mark -setters and getters
- (UIScrollView *)scrollView {
    
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.delegate = self;
        _scrollView.minimumZoomScale = ZOOM_MIN;
        _scrollView.maximumZoomScale = ZOOM_MAX;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        
        _scrollView.bounces = YES;
    }
    return _scrollView;
}

- (UIImageView *)photoimageView {
    
    if (!_photoimageView) {
        _photoimageView = [[UIImageView alloc] init];
        _photoimageView.contentMode = UIViewContentModeScaleAspectFit;
        _photoimageView.backgroundColor = [UIColor blackColor];
    }
    return _photoimageView;
}

@end
