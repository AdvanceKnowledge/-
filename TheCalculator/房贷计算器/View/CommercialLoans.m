//
//  CommercialLoans.m
//  追@寻//
//  Created by 追@寻 on 2017/10/12.
//  Copyright © 2017年 wangynalei. All rights reserved.
//


#import "UIColor+BinaryColor.h"
#import "CommercialLoans.h"
#import "Masonry.h"
#import "PickerviewsView.h"
#import "UIView+BlocksKit.h"
//#import "Global.h"
//屏幕物理宽高
#define BOScreenH [UIScreen mainScreen].bounds.size.height
#define BOScreenW [UIScreen mainScreen].bounds.size.width
//弱引用
#define WeakSelf(type) __weak typeof(type) weak##type = type;
//强引用
#define StrongSelf(type) __strong typeof(type) type = weak##type;
/**
 商业贷款
 思路:修改所有数据源都有可能触发计算的方法
 */

@interface CommercialLoans()<UITextFieldDelegate>
@property (nonatomic,assign)NSInteger borrowingNumber;//贷款年限,默认最小年限,5年
@property (nonatomic,assign)NSInteger repaymentModeInt;//还款方式 0 等额本息 1等额本金
@property (nonatomic,strong)NSArray *saveYears;//存储贷款年限
@property (nonatomic,assign)float multiple;//折扣,默认为1
@property (nonatomic,strong)NSMutableArray *sylilvArr;//折扣率
@property (nonatomic ,strong)PickerviewsView *pickerView;
@property (nonatomic,strong)NSString *saveCurrentRate;//保存当前基准利率

@property (nonatomic, strong) NSString *theMonthlyDeclineStr;//每月递减
@property (nonatomic, strong) NSString *totalInterestStr;//总利息
@property (nonatomic, strong) NSString *reimbursementAmount;//还款总额
@property (nonatomic, strong) NSString *topMonthlyPaymenysStr;//最高月供

@property (nonatomic, strong) UIView *topView;

@end

@implementation CommercialLoans

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)createUI{
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(calculateMortgagePaymentMonthly) name:UITextFieldTextDidChangeNotification object:nil];
    
    
    _multiple = 1.0;
    _borrowingNumber = 5;
    _sylilvArr = [[NSMutableArray alloc]initWithObjects:@"基础利率",@"9.5折",@"9折",@"8.8折",@"8.5折",@"8.3折",@"8折",@"7折",@"1.05倍",@"1.1倍",@"1.2倍",@"1.3倍", nil];
    _repaymentModeInt = 0;
    
    NSMutableArray *subViews = [NSMutableArray arrayWithCapacity:3];
    UILabel *layoutLab;
    _topView = ({UIView *view = [[UIView alloc]init];
        view.backgroundColor = [UIColor whiteColor];
        view;
    });
    [self addSubview:_topView];
     UILabel *topMonthlyPaymenys = ({
         
        UILabel *lab = [[UILabel alloc]init];
        lab.text = @"最高月供(元)";
        lab.font = [UIFont systemFontOfSize:14];
        lab.textColor = [UIColor colorWithHexString:@"#333333"];
        lab;
    });
    _topMonthlyPaymenys = ({
        UILabel *lab = [[UILabel alloc]init];
        lab.text = @"0";
        [lab setFont:[UIFont fontWithName:@"Helvetica-Bold" size:26]];
        lab.textColor = [UIColor colorWithHexString:@"#ff5a00" alpha:1];
        lab.textAlignment = NSTextAlignmentCenter;
        lab;
    });
    
    
    [_topView addSubview:topMonthlyPaymenys];
    [_topView addSubview:_topMonthlyPaymenys];
    
     NSArray *interestArr = @[@"每月递减(元)",@"支付利息(元)",@"还款总额(元)",@"0",@"0",@"0"];
    UILabel *lastLabel = nil;
    CGFloat with = [[UIScreen mainScreen]bounds].size.width/3.0;
    for (int i = 0; i < 6; i++) {
        UILabel *interestLabel = ({
            UILabel *lab = [[UILabel alloc]init];
            lab.tag = 800+i;
            lab.text = interestArr[i];
            lab.font = [UIFont systemFontOfSize:12];
            lab.textAlignment = NSTextAlignmentCenter;
            lab.textColor = [UIColor colorWithHexString:@"#333333" alpha:1];
            lab;
        });
        
        if (i/3 != 0) {
            [interestLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
        }
        [_topView addSubview:interestLabel];
        [interestLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            if (i%3 == 0) {
                make.left.equalTo(_topView);
            }else{
                make.left.equalTo(lastLabel.mas_right);
            }
            if (i%3 == 0) {
                make.top.equalTo(lastLabel?lastLabel.mas_bottom:_topMonthlyPaymenys.mas_bottom).offset(lastLabel?10:20);
            }else{
                make.top.equalTo(lastLabel.mas_top);
            }
            make.width.mas_equalTo(with);
            make.height.mas_equalTo(15);
        }];
        lastLabel = interestLabel;
        
        
        
        
        
    }
    [topMonthlyPaymenys mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_topView).offset(25);
        make.centerX.equalTo(_topView.mas_centerX);
    }];
    [_topMonthlyPaymenys mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topMonthlyPaymenys.mas_bottom).offset(10);
        make.centerX.equalTo(topMonthlyPaymenys.mas_centerX);
    }];
    [_topView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.bottom.equalTo(lastLabel.mas_bottom).offset(10);
    }];
    
    UILabel *promptingLab = ({
        UILabel *lab = [[UILabel alloc]init];
        lab.text = @"在下方输入贷款信息";
        lab.font = [UIFont systemFontOfSize:13];
        lab.textColor = [UIColor colorWithHexString:@"#999999"];
        lab;
    });
    
    UIView *bottomView = ({UIView *view = [[UIView alloc]init];
        view.backgroundColor = [UIColor whiteColor];
        view;
    });
    [self addSubview:bottomView];
    [bottomView addSubview:promptingLab];
    [promptingLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_topView.mas_bottom);
        make.left.equalTo(self.mas_left).offset(12);
        make.height.mas_equalTo(30);
    }];
    
   
    NSArray *carArr = @[@"贷款年限",@"还款方式",@"商业贷款金额(万)",@"商业贷款利率(%)"];
    UILabel *lastLab = nil;
    for (NSString *title in carArr) {
        UILabel *typeLabel = ({
            UILabel *lab = [[UILabel alloc]init];
            lab.text = title;
            lab.font = [UIFont systemFontOfSize:14];
            lab.textColor = [UIColor colorWithHexString:@"#333333" alpha:1];
            lab;
        });
        [bottomView addSubview:typeLabel];
        [typeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(bottomView.mas_left).offset(20);
            make.top.equalTo(lastLab?lastLab.mas_bottom:bottomView.mas_top).offset(lastLab?1:0);
            make.height.mas_equalTo(40);
        }];
        lastLab = typeLabel;
        [subViews addObject:lastLab];
        
        
        if (![title isEqualToString:@"商业贷款利率(%)"]) {
            UIView *lineView = ({UIView *view = [[UIView alloc]init];
                view.backgroundColor = [UIColor colorWithHexString:@"#dfe3e6" alpha:1];
                view;
            });
            [bottomView addSubview:lineView];
            [lineView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(typeLabel);
                make.height.mas_equalTo(0.5);
                make.right.equalTo(bottomView.mas_right).offset(-12);
                make.top.equalTo(typeLabel.mas_bottom);
            }];
        }
       
    }
    
    
    //贷款年限
    _saveYears = @[@"5", @"10",@"15",@"20",@"25",@"30"];
    _borrowingNumberYear = ({UISegmentedControl *segMenCon = [[UISegmentedControl alloc]initWithItems:_saveYears];
        segMenCon.selectedSegmentIndex = 0;
        segMenCon.tintColor = [UIColor colorWithHexString:@"#4697fb" alpha:1];
        [segMenCon addTarget:self action:@selector(choseYear:) forControlEvents:UIControlEventValueChanged];
        segMenCon;
    });
    [bottomView addSubview:_borrowingNumberYear];
    if (subViews.count > 0) {
        layoutLab = subViews[0];
        [_borrowingNumberYear mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(layoutLab.mas_centerY);
            make.right.equalTo(bottomView.mas_right).offset(-12);
        }];
    }
    
    //还款方式
    _repaymentModeSegmentCon = ({UISegmentedControl *segMenCon = [[UISegmentedControl alloc]initWithItems:@[@"等额本息", @"等额本金"]];
        segMenCon.selectedSegmentIndex = 0;
        segMenCon.tintColor = [UIColor colorWithHexString:@"#4697fb" alpha:1];
        [segMenCon addTarget:self action:@selector(repaymentMode:) forControlEvents:UIControlEventValueChanged];
        segMenCon;
    });
    [bottomView addSubview:_repaymentModeSegmentCon];
    if (subViews.count > 1) {
        layoutLab = subViews[1];
        [_repaymentModeSegmentCon mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(layoutLab.mas_centerY);
            make.right.equalTo(bottomView.mas_right).offset(-12);
        }];
    }

    //输入金额
    _inputTextF = ({UITextField *textField = [[UITextField alloc]init];
        textField.placeholder = @"请输入金额";
        textField.delegate = self;
        textField.textAlignment = NSTextAlignmentRight;
        textField.textColor = [UIColor colorWithHexString:@"#333333" alpha:1];
        textField.font = [UIFont systemFontOfSize:14];
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField;
    });
    [bottomView addSubview:_inputTextF];
    if (subViews.count > 2) {
        layoutLab = subViews[2];
        [_inputTextF mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(layoutLab.mas_centerY);
            make.right.equalTo(bottomView.mas_right).offset(-12);
        }];
        
    }

    //利率
    _interestRateLab = ({
        UILabel *lab = [[UILabel alloc]init];
        lab.text = @"4.75";
        _saveCurrentRate = @"4.75";
        lab.font = [UIFont systemFontOfSize:14];
        lab.textColor = [UIColor colorWithHexString:@"#333333" alpha:1];
        lab.userInteractionEnabled = YES;
        WeakSelf(self);
        [lab bk_whenTapped:^{
            StrongSelf(self);
            [self showPickView];
        }];
        lab;
    });
    [bottomView addSubview:_interestRateLab];
    if (subViews.count > 3) {
        layoutLab = subViews[3];
        [_interestRateLab mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(layoutLab.mas_centerY);
            make.right.equalTo(bottomView.mas_right).offset(-12);
        }];
    }

    [bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(promptingLab.mas_bottom);
        make.left.right.equalTo(self);
        make.bottom.equalTo(lastLab).offset(10);
    }];
}

//选择还款方式
- (void)repaymentMode:(UISegmentedControl *)segMentCon{
    _repaymentModeInt = segMentCon.selectedSegmentIndex;
    [self calculatedRealInterestRate];
}

#pragma mark-
#pragma mark-创建利率折扣显示控件
- (PickerviewsView *)pickerView{
    if (!_pickerView) {
        _pickerView = ({PickerviewsView *pickView = [[PickerviewsView alloc]initWithFrame:CGRectMake(0, 0, BOScreenW, BOScreenH)];
            pickView.hidden = YES;
            [pickView.cancelButton addTarget:self action:@selector(hidenThePickView) forControlEvents:UIControlEventTouchUpInside];
            [pickView.sureButton addTarget:self action:@selector(sureButtonClick) forControlEvents:UIControlEventTouchUpInside];
           
            WeakSelf(self);
            [pickView bk_whenTapped:^{
                StrongSelf(self);
                [self hidenThePickView];
            }];
            pickView;
        });
        [[UIApplication sharedApplication].keyWindow addSubview:_pickerView];
        
    }
    return _pickerView;
}

//显示折扣选择器
- (void)showPickView{
    self.pickerView.hidden = NO;
    self.pickerView.number = _sylilvArr;
    _pickerView.titleLabel.text = @"商业贷款利率(%)";
    _pickerView.number = _sylilvArr;
    [_pickerView.payPicView selectRow:0 inComponent:0 animated:NO];
    [_pickerView.payPicView reloadAllComponents];
}

//隐藏折扣选择器
- (void)hidenThePickView{
    _pickerView.hidden = YES;
}
//折扣选择器确定按钮
- (void)sureButtonClick{
    NSLog(@"%@",@"123");
    NSLog(@"123");
    NSLog(@"%@",_pickerView.chooseString);
    if (_pickerView.chooseString != nil){
        
        if ([_pickerView.chooseString isEqualToString:@"基础利率"]) {
            _multiple = 1;
        }else{
            NSString *multipeStr = [_pickerView.chooseString substringToIndex:_pickerView.chooseString.length-1];
            NSLog(@"%@",multipeStr);
            _multiple = [multipeStr floatValue];
            if (_multiple < 2) {
                _multiple = _multiple*10;
            }
            
        }
        
    }else{
        _multiple = 1.0;
    }
    _pickerView.chooseString = nil;
    _pickerView.hidden = YES;
    [self calculatedRealInterestRate];
    
}

//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
//    [self calculatedRealInterestRate];
//    return YES;
//}
//- (void)textFieldDidBeginEditing:(UITextField *)textField{
//    [self calculatedRealInterestRate];
//}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    //触发开始计算,判断信息是否完善开始计算
    [self calculatedRealInterestRate];
}

- (void)choseYear:(UISegmentedControl *)segmentedCon{
    //判断信息是否完善,计算房贷数据
    _borrowingNumber = [_saveYears[segmentedCon.selectedSegmentIndex] integerValue];
    [self calculatedRealInterestRate];
}

//计算折扣利率
- (void)calculatedRealInterestRate{
    if (_borrowingNumber == 5) {
        _saveCurrentRate = @"4.75";
        if (_multiple ==  1) {
            _interestRateLab.text = [NSString stringWithFormat:@"%@%%",_saveCurrentRate];
        }else{
            _interestRateLab.text = [NSString stringWithFormat:@"%@%%",[NSString stringWithFormat:@"%.3f",0.475*_multiple]];
        }
    }else{
        _saveCurrentRate = @"4.90";
        if (_multiple ==  1) {
            _interestRateLab.text = [NSString stringWithFormat:@"%@%%",_saveCurrentRate];
        }else{
            _interestRateLab.text = [NSString stringWithFormat:@"%@%%",[NSString stringWithFormat:@"%.3f",0.490*_multiple]];
        }
    }
    [self calculateMortgagePaymentMonthly];
    
}

//计算房贷具体每月换多少
- (void)calculateMortgagePaymentMonthly{
    if (_inputTextF.text.length == 0) {
        return;
    }
    if (_repaymentModeInt == 0) {
        //等额本息
        [self equlePrincipalAndInterest];
    }else{
        //等额本金
        [self standardOf];
        
    }
    
    
}


#pragma mark-
#pragma mark-等额本息
- (void)equlePrincipalAndInterest{
    /*
     每月月供额=〔贷款本金×月利率×(1＋月利率)＾还款月数〕÷〔(1＋月利率)＾还款月数-1〕
     每月应还利息=贷款本金×月利率×〔(1+月利率)^还款月数-(1+月利率)^(还款月序号-1)〕÷〔(1+月利率)^还款月数-1〕
     每月应还本金=贷款本金×月利率×(1+月利率)^(还款月序号-1)÷〔(1+月利率)^还款月数-1〕
     总利息=还款月数×每月月供额-贷款本金
     */
    float theLoanAmount = [_inputTextF.text floatValue]*10000.0;//贷款金额
    float anInterest = [_interestRateLab.text floatValue]/1200.0;//月利率
    float repaymentMonths = _borrowingNumber*12.0;//还款月数
//    pow(2, 3))  2 的3次方
    float monthlyPayments = (theLoanAmount*anInterest*pow((1+anInterest), repaymentMonths))/(pow((1+anInterest), repaymentMonths)-1);//每月月供
    
//    float monthlyInterest = theLoanAmount*anInterest*(pow(1+anInterest, repaymentMonths)-pow(1+anInterest, repaymentMonths-1))/pow(1+anInterest, repaymentMonths-1);//每月应还利息
    
//    float allMonthlyInterest = monthlyInterest*repaymentMonths;//还款利息
    float allMonthlyInterest = repaymentMonths*monthlyPayments-theLoanAmount;//还款利息
    
    _theMonthlyDeclineStr = @"0";//每月递减
    _totalInterestStr = [NSString stringWithFormat:@"%.0f",allMonthlyInterest];//总利息
    _reimbursementAmount = [NSString stringWithFormat:@"%.0f",theLoanAmount+allMonthlyInterest];//总还款额
    _topMonthlyPaymenysStr = [NSString stringWithFormat:@"%.0f",monthlyPayments];//最高月供
    [self refreshTheInterface];
    
}


#pragma mark-
#pragma mark-等额本金
- (void)standardOf{
    /*
     等额本金计算方法
     每月月供额=(贷款本金÷还款月数)+(贷款本金-已归还本金累计额)×月利率
     每月应还本金=贷款本金÷还款月数
     每月应还利息=剩余本金×月利率=(贷款本金-已归还本金累计额)×月利率
     每月月供递减额=每月应还本金×月利率=贷款本金÷还款月数×月利率
     总利息=〔(总贷款额÷还款月数+总贷款额×月利率)+总贷款额÷还款月数×(1+月利率)〕÷2×还款月数-总贷款额
     */
    float theLoanAmount = [_inputTextF.text floatValue]*10000.0;//贷款金额
    float anInterest = [_interestRateLab.text floatValue]/1200.0;//月利率
    float repaymentMonths = _borrowingNumber*12.0;//还款月数
    float firstMonthsMoney = (theLoanAmount/repaymentMonths)+(theLoanAmount-0)*anInterest;//第一个月需要支付的钱
    float hasBeenReturned = theLoanAmount/repaymentMonths;//已支付本金
    float secondMonthsMoney = (theLoanAmount/repaymentMonths)+(theLoanAmount-hasBeenReturned)*anInterest;//第一个月需要支付的钱
//    〔(总贷款额÷还款月数+总贷款额×月利率)+总贷款额÷还款月数×(1+月利率)〕÷2×还款月数-总贷款额
    float totalInterest = ((((theLoanAmount/repaymentMonths)+(theLoanAmount*anInterest))+(theLoanAmount/repaymentMonths)*(1+anInterest))/2)*repaymentMonths-theLoanAmount;//支付的总利息
    float priceDifference = firstMonthsMoney - secondMonthsMoney;//每月递减

    
    _theMonthlyDeclineStr = [NSString stringWithFormat:@"%.0f",priceDifference];//每月递减
    _totalInterestStr = [NSString stringWithFormat:@"%.0f",totalInterest];//总利息
    _reimbursementAmount = [NSString stringWithFormat:@"%.0f",theLoanAmount+totalInterest];//总还款额
    _topMonthlyPaymenysStr = [NSString stringWithFormat:@"%.0f",firstMonthsMoney];//最高月供
    [self refreshTheInterface];
}



//刷新界面
- (void)refreshTheInterface{
//    [self setNeedsDisplay];
    _topMonthlyPaymenys.text = _topMonthlyPaymenysStr;
    UILabel *label1 = [_topView viewWithTag:803];
    label1.text = _theMonthlyDeclineStr;
    UILabel *label2 = [_topView viewWithTag:804];
    label2.text = _totalInterestStr;
    UILabel *label3 = [_topView viewWithTag:805];
    label3.text = _reimbursementAmount;
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
