//
//  ViewController.m
//  JxyDatePicker
//
//  Created by yongjing.xiao on 2017/6/27.
//  Copyright © 2017年 fengzixiao. All rights reserved.
//

#import "ViewController.h"
#import "JXYDatePicker.h"

#define SCREEN_HEIGHT [[UIScreen mainScreen]bounds].size.height
#define SCREEN_WIDTH [[UIScreen mainScreen]bounds].size.width

@interface ViewController ()<JXYDatePickerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *showDateLabel;

@property(nonatomic,strong)JXYDatePicker *JDatepicker;

@end

//弹框的高度
static CGFloat datePickerH = 258;//大致是键盘的高度

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addJDatePicker];
    
}

-(void)addJDatePicker{
    NSDate *minimumDate = [NSDate dateWithTimeIntervalSinceNow:(24 * 3600 * 7)];
    NSDate *maximumDate = [NSDate dateWithTimeIntervalSinceNow:(24 *3600 *365 *2)];
    _JDatepicker = [[JXYDatePicker alloc]initWithFrame:CGRectMake(0, 100, SCREEN_WIDTH, datePickerH)WithMinimumDate:minimumDate maximumDate:maximumDate];
    _JDatepicker.delegate = self;
    [self.view addSubview:_JDatepicker];
}

#pragma mark --- JXYDatePickerDelegate
-(void)didSelectedDateString:(NSString *)dateString{
    self.showDateLabel.text = [NSString stringWithFormat:@"你选中的时间是：%@",dateString];
}
-(void)cancelDatePicker{
    NSLog(@"你点击了取消");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
