//
//  WYLMortgageCalculatorViewController.m
//  追@寻
//
//  Created by 追@寻 on 2017/10/12.
//  Copyright © 2017年 wangynalei. All rights reserved.
//

#import "WYLMortgageCalculatorViewController.h"
#import "CommercialLoans.h"
#import "ProvidentFundLoanView.h"
#import "MixedLoansView.h"
#import "Masonry.h"
#import "UIColor+BinaryColor.h"


//是否iPhoneX YES:iPhoneX屏幕 NO:传统屏幕
#define kIs_iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
//安全区域
#define safeArea  (kIs_iPhoneX?34:0)

@interface WYLMortgageCalculatorViewController ()
@property (nonatomic, strong) CommercialLoans *commercialLoans;//商业贷款
@property (nonatomic, strong) ProvidentFundLoanView *providentFundLoanView;//公积金
@property (nonatomic, strong) MixedLoansView *mixedLoansView;//混合贷款

@end

@implementation WYLMortgageCalculatorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>7.0) {
        // 为了让视图从导航条下面开始进行
        self.edgesForExtendedLayout =UIRectEdgeNone;
    }else{
    }
    self.navigationItem.title = @"房贷计算器";
    [self createUI];
    // Do any additional setup after loading the view.
}

- (void)createUI{
    
    UIView *navBgView = ({
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, 40)];
        view.backgroundColor = [UIColor colorWithHexString:@"#2d84f2" alpha:1];
        view;
    });
    
    
    //商业贷款  积金贷款  组合贷款
    UISegmentedControl *segmentCon = ({
        UISegmentedControl *seg = [[UISegmentedControl alloc]
                                   initWithItems:@[@"商业贷款", @"公积金贷款",@"组合贷款"]];
        seg.selectedSegmentIndex = 0;
        seg.tintColor = [UIColor whiteColor];
        [seg addTarget:self
                action:@selector(segmentConAction:)
      forControlEvents:UIControlEventValueChanged];//添加响应方法
        seg;
    });
    [navBgView addSubview:segmentCon];
    [self.view addSubview:navBgView];

    [navBgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.height.mas_equalTo(70+safeArea);
    }];
    
    [segmentCon mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(navBgView.mas_centerX);
        make.height.mas_equalTo(30);
        make.bottom.mas_equalTo(-5);
    }];
    
    _commercialLoans = [[CommercialLoans alloc]init];
    _commercialLoans.backgroundColor = [UIColor colorWithRed:245/255.0
                                                       green:245/255.0
                                                        blue:247/255.0
                                                       alpha:1];
    [self.view addSubview:_commercialLoans];
    [_commercialLoans mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(navBgView.mas_bottom);
    }];
    
    _providentFundLoanView = ({
        ProvidentFundLoanView *view = [[ProvidentFundLoanView alloc]init];
        view.backgroundColor = [UIColor colorWithRed:245/255.0
                                               green:245/255.0
                                                blue:247/255.0
                                               alpha:1];
        view.hidden = YES;
        view;
    });
    [self.view addSubview:_providentFundLoanView];
    [_providentFundLoanView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(navBgView.mas_bottom);
    }];
    
    _mixedLoansView = ({
        MixedLoansView *view = [[MixedLoansView alloc]init];
        view.backgroundColor = [UIColor colorWithRed:245/255.0
                                               green:245/255.0
                                                blue:247/255.0
                                               alpha:1];
        view.hidden = YES;
        view;
    });
    
    [self.view addSubview:_mixedLoansView];
    [_mixedLoansView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(navBgView.mas_bottom);
    }];
}

- (void)segmentConAction:(UISegmentedControl *)segmentCon{
    switch (segmentCon.selectedSegmentIndex) {
        case 0:
            _commercialLoans.hidden = NO;
            _providentFundLoanView.hidden = YES;
            _mixedLoansView.hidden = YES;
            break;
        case 1:
            _commercialLoans.hidden = YES;
            _providentFundLoanView.hidden = NO;
            _mixedLoansView.hidden = YES;
            break;
        case 2:
            _commercialLoans.hidden = YES;
            _providentFundLoanView.hidden = YES;
            _mixedLoansView.hidden = NO;
            break;

        default:
            break;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
