//
//  LBAlbumPickerController.m
//  LBImagePickerController
//
//  Created by 余丽丽 on 2017/6/2.
//  Copyright © 2017年 ocarol. All rights reserved.
//

#import "LBAlbumPickerController.h"
#import "LBImagePickerController.h"
#import "LBPhotoPickerController.h"
#import "LBAlbumCell.h"

static NSString *cellID = @"TZAlbumCell";
@interface LBAlbumPickerController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *albumArr;
@end

@implementation LBAlbumPickerController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [LBImageManager manager].pickerVc.bottomBar.hidden = YES;
    [[LBImageManager manager].pickerVc clearAllSelectedModels];
    
    [self configTableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;

}

- (void)configTableView {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __weak __typeof(self) weakSelf = self;
        [[LBImageManager manager] getAllAlbumsWithCompletion:^(NSArray<LBAlbumModel *> *models) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            _albumArr = [NSMutableArray arrayWithArray:models];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!_tableView) {
                    CGFloat top = 0;
                    CGFloat tableViewHeight = 0;
                    if (strongSelf.navigationController.navigationBar.isTranslucent) {
                        top = 44;
                        if (LBIOS7Later) top += 20;
                        tableViewHeight = strongSelf.view.lb_height - top;
                    } else {
                        CGFloat navigationHeight = 44;
                        if (LBIOS7Later) navigationHeight += 20;
                        tableViewHeight = strongSelf.view.lb_height - navigationHeight;
                    }
                    
                    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, top, strongSelf.view.lb_width, tableViewHeight) style:UITableViewStylePlain];
                    _tableView = tableView;
                    _tableView.rowHeight = 86;
                    _tableView.tableFooterView = [[UIView alloc] init];
                    _tableView.dataSource = strongSelf;
                    _tableView.delegate = strongSelf;
                    [_tableView registerClass:[LBAlbumCell class] forCellReuseIdentifier:cellID];
                    [strongSelf.view addSubview:_tableView];
                } else {
                    [_tableView reloadData];
                }
            });
        }];
    });
}

#pragma mark - UITableViewDataSource && Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.albumArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LBAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    cell.model = self.albumArr[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LBPhotoPickerController *photoPickerVc = [[LBPhotoPickerController alloc] init];
    photoPickerVc.albumModel = self.albumArr[indexPath.row];
    [self.navigationController pushViewController:photoPickerVc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
