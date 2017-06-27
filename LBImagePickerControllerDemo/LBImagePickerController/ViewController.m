//
//  ViewController.m
//  LBImagePickerController
//
//  Created by ocarol on 2017/6/2.
//  Copyright © 2017年 ocarol. All rights reserved.
//

#import "ViewController.h"
#import "LBImagePickerController.h"
#import "LBPhotoPreviewController.h"
#import "CollectionViewCell.h"

@interface ViewController ()<LBImagePickerControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collection;

@property (weak, nonatomic) IBOutlet UITextField *maxText;

@property (weak, nonatomic) IBOutlet UITextField *maxTitle;
@property (weak, nonatomic) IBOutlet UISwitch *cameraInside;

@property (weak, nonatomic) IBOutlet UISwitch *sortAscending;

@property (weak, nonatomic) IBOutlet UISwitch *showCamera;

@property (nonatomic, strong) NSArray *assetModels;
@property (nonatomic, strong) NSArray * images;
@property (nonatomic, strong) NSArray * titles;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)image_picker:(UIButton *)sender {
    [self pushPickerWithcameraInside:self.cameraInside.on];
}

- (void)pushPickerWithcameraInside:(BOOL)cameraInside {
    NSMutableArray *arrayM = [NSMutableArray array];
    for (int  i = 0; i < [self.maxTitle.text integerValue]; i++) {
        NSString *title = [NSString stringWithFormat:@"第%d张图片",i];
        [arrayM addObject:title];
    }
    self.titles = arrayM.copy;
    
    LBImagePickerController *picker;
    if (arrayM.count) {
        picker = [[LBImagePickerController alloc] initWithPhotoTitles:self.titles cameraInside:cameraInside];
    }else {
        picker = [[LBImagePickerController alloc] initWithMaxImagesCount:[self.maxText.text integerValue] cameraInside:cameraInside];
    }
    
    picker.showCamera = self.showCamera.on;
    picker.sortAscendingByModificationDate = self.sortAscending.on;
    __weak __typeof(self) weakSelf = self;
    picker.LBImagePickerDidFinishPickingPhotosBlock = ^(NSArray<LBAssetModel *> *assetModels, NSArray<UIImage *> *images) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.assetModels = assetModels;
        strongSelf.images = images;
        [strongSelf.collection reloadData];
    };
    
    [self presentViewController:picker animated:YES completion:nil];
}


#pragma mark - UICollectionView delegete method
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LBAssetModel * model = self.assetModels[indexPath.row];
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ocarol" forIndexPath:indexPath];
    cell.image = self.images[indexPath.row];
    cell.title = (self.titles.count && self.titles.count - 1 < model.selctedIndex) ? self.titles[model.selctedIndex] : @"";
    
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *imagesM = [NSMutableArray arrayWithArray:self.images];
    NSMutableArray *modelsM = [NSMutableArray arrayWithArray:self.assetModels];
    LBPhotoPreviewController *vc = [[LBPhotoPreviewController alloc] initWithImages:imagesM.copy];
    vc.autoPositionIndex = indexPath.row;
    __weak __typeof(self) weakSelf = self;
    vc.didDeletedBlock = ^(NSInteger index,UIImage *image) {
        [imagesM removeObject:image];
        [modelsM removeObjectAtIndex:index];
        weakSelf.images = imagesM.copy;
        weakSelf.assetModels = modelsM.copy;
        [weakSelf.collection reloadData];
        
    };
    [self presentViewController:vc animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
