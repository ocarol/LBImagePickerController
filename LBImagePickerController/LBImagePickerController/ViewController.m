//
//  ViewController.m
//  LBImagePickerController
//
//  Created by 余丽丽 on 2017/6/2.
//  Copyright © 2017年 ocarol. All rights reserved.
//

#import "ViewController.h"
#import "LBImagePickerController.h"
#import "LBPhotoPreviewController.h"

@interface ViewController ()<LBImagePickerControllerDelegate>
@property (nonatomic, strong) NSArray *assetModels;

@property (weak, nonatomic) IBOutlet UITextField *maxText;

@property (weak, nonatomic) IBOutlet UITextField *maxTitle;

@property (weak, nonatomic) IBOutlet UISwitch *sortAscending;

@property (weak, nonatomic) IBOutlet UISwitch *showCamera;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)preview:(UIButton *)sender {
    NSMutableArray *arrayM = [NSMutableArray array];
    for (int i = 0; i < self.assetModels.count; i++) {
        LBAssetModel *model = self.assetModels[i];
        UIImage *image = model.PreviewImage;
        [arrayM addObject:image];
    }
    
    LBPhotoPreviewController *vc = [[LBPhotoPreviewController alloc] initWithImages:arrayM.copy];
    vc.didDeletedBlock = ^(NSInteger index,UIImage *image) {
      NSLog(@"已删除第%ld张照片.原位置为第%ld张",index,[arrayM indexOfObject:image]);
    };
    [self presentViewController:vc animated:YES completion:nil];
    
}

- (IBAction)image_picker_outside:(id)sender {
    [self pushPickerWithcameraInside:NO];
}

- (IBAction)image_picker:(UIButton *)sender {
    [self pushPickerWithcameraInside:YES];
}

- (void)pushPickerWithcameraInside:(BOOL)cameraInside {
    NSMutableArray *arrayM = [NSMutableArray array];
    for (int  i = 0; i < [self.maxTitle.text integerValue]; i++) {
        NSString *title = [NSString stringWithFormat:@"请选择第%d张图片",i];
        [arrayM addObject:title];
    }
    
    LBImagePickerController *picker;
    if (arrayM.count) {
        picker = [[LBImagePickerController alloc] initWithPhotoTitles:arrayM.copy delegate:self cameraInside:cameraInside];
    }else {
        picker = [[LBImagePickerController alloc] initWithMaxImagesCount:[self.maxText.text integerValue] delegate:self cameraInside:cameraInside];
    }
    
    picker.showCamera = self.showCamera.on;
    picker.sortAscendingByModificationDate = self.sortAscending.on;
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)LBImagePickerController:(LBImagePickerController *)picker didFinishPickingPhotos:(NSArray <LBAssetModel *> *)assetModels {
    self.assetModels = assetModels;
    for (LBAssetModel *model in assetModels) {
        NSLog(@"已选中第%ld张照片",model.selctedIndex);
    }
}


- (void)LBImagePickerControllerDidCancel:(LBImagePickerController *)picker {
    NSLog(@"取消选择照片");

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
