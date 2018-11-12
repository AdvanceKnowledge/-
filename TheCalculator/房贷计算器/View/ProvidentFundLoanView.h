//
//  ProvidentFundLoanView.h
//  追@寻
//
//  Created by 追@寻 on 2017/10/13.
//  Copyright © 2017年 wangynalei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProvidentFundLoanView : UIView
@property (nonatomic, strong) UILabel *topMonthlyPaymenys;//最高月供
@property (nonatomic ,strong)UISegmentedControl *borrowingNumberYear;//贷款年限
@property (nonatomic ,strong)UISegmentedControl *repaymentModeSegmentCon;//还款方式
@property (nonatomic ,strong)UITextField *inputTextF;//请输入金额
@property (nonatomic, strong) UILabel *interestRateLab;//利率
@end
