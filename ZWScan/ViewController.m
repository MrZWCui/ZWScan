//
//  ViewController.m
//  ZWScan
//
//  Created by 崔先生的MacBook Pro on 2022/10/6.
//

#import "ViewController.h"
#import "ZWScanViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initView];
}

- (void)initView {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    btn.center = self.view.center;
    btn.backgroundColor = [UIColor hexColor:@"4c4c4c"];
    [btn setTitle:@"扫一扫" forState:UIControlStateNormal];
    btn.layer.cornerRadius = 10;
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)btnClick {
    ZWScanViewController *scanVC = [[ZWScanViewController alloc] init];
    [self.navigationController pushViewController:scanVC animated:YES];
}

@end
