//
//  FPViewController.m
//  FPPermission
//
//  Created by FPJack on 12/24/2019.
//  Copyright (c) 2019 FPJack. All rights reserved.
//

#import "FPViewController.h"
#import <FPPermission.h>
@interface FPViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong)NSArray *sources;
@end

@implementation FPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.sources = @[@(FPPermissionCamer),@(FPPermissionPhoto),@(FPPermissionLocation),@(FPPermissionBluetooth)];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.sources.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = kPermissionTitleInfo[self.sources[indexPath.row]];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSNumber *type = self.sources[indexPath.row];
    [FPPermission requestAuthorizationStatus:type.intValue showAlertWhenDenied:YES resultBlock:^(FPPermissionStatus status) {
        
    }];
}
@end
