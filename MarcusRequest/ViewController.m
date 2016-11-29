//
//  ViewController.m
//  MarcusRequest
//
//  Created by marcus on 2016/11/24.
//  Copyright © 2016年 marcus. All rights reserved.
//

#import "ViewController.h"
#import "MSDemoViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)gotoNextVC:(UIButton *)sender {
    MSDemoViewController *demoVC = [[MSDemoViewController alloc]init];
    [self.navigationController pushViewController:demoVC animated:YES];
}

@end
