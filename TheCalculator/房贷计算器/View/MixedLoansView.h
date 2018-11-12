//
//  MixedLoansView.h
//  追@寻
//
//  Created by 追@寻 on 2017/10/13.
//  Copyright © 2017年 wangynalei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MixedLoansView : UIView
@property (nonatomic, strong) UILabel *topMonthlyPaymenys;//最高月供
@property (nonatomic ,strong)UISegmentedControl *borrowingNumberYear;//贷款年限
@property (nonatomic ,strong)UISegmentedControl *repaymentModeSegmentCon;//还款方式


@property (nonatomic ,strong)UITextField *commercialLoanAmountTextField;//请输入商业金额
@property (nonatomic, strong) UILabel *commercialInterestRates;//商业利率


@property (nonatomic ,strong)UITextField *providentFundTextField;//请输入公积金金额
@property (nonatomic, strong) UILabel *providentFundRate;//公积金利率
@end
