//
//  JXYDatePicker.m
//  Chart-Demo
//
//  Created by yongjing.xiao on 2017/6/16.
//  Copyright © 2017年 xinweilai. All rights reserved.
//

#import "JXYDatePicker.h"

@interface JXYDatePicker()<UIPickerViewDelegate,UIPickerViewDataSource>
/**
 * 数组装年份
 */
@property (nonatomic, strong) NSMutableArray *yearArray;
/**
 * 最小日期当月年剩下的月份
 */
@property (nonatomic, strong) NSMutableArray *minMonthRemainingArray;
/**
 * 最大日期当年已过去的月份
 */
@property (nonatomic, strong) NSMutableArray *maxMonthRemainingArray;
/**
 * 最小日期当月剩下的天数
 */
@property (nonatomic, strong) NSMutableArray *minDayRemainingArray;
/**
 * 最大日期当月过去的天数
 */
@property (nonatomic, strong) NSMutableArray *maxDayRemainingArray;

/**
 * 不是闰年 装一个月多少天
 */
@property (nonatomic, strong) NSArray *NotLeapYearArray;
/**
 * 闰年 装一个月多少天
 */
@property (nonatomic, strong) NSArray *leapYearArray;
@property (nonatomic, strong) NSDate *minimumDate;//最小时间
@property (nonatomic, strong) NSDate *maximumDate;//最大时间

@end

//弹框的高度
static CGFloat backViewH = 258;//大致是键盘的高度
// rgb颜色转换（16进制->10进制
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define SYSTEM_COLOR UIColorFromRGB(0x3e86c4)
#define BUTTON_BACKCOLOR UIColorFromRGB(0xed7860)

@implementation JXYDatePicker
{
    UIPickerView *yearPicker;/**<年>*/
    UIPickerView *monthPicker;/**<月份>*/
    UIPickerView *dayPicker;/**<天>*/
    UIButton *cancelButton;/**<取消按钮>*/
    UIButton *sureButton;/**<确定按钮>*/
    NSInteger minYear;
    NSInteger minMonth;
    NSInteger minDay;
    NSInteger maxYear;
    NSInteger maxMonth;
    NSInteger maxDay;
}


-(instancetype)initWithFrame:(CGRect)frame WithMinimumDate:(NSDate *)minimumDate maximumDate:(NSDate *)maximumDate{
    
    if ([super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.yearArray = [NSMutableArray array];
        self.minMonthRemainingArray = [NSMutableArray array];
        self.maxMonthRemainingArray = [NSMutableArray array];
        self.minDayRemainingArray = [NSMutableArray array];
        self.maxDayRemainingArray = [NSMutableArray array];
        NSDate *tenYearsbefore = [NSDate dateWithTimeIntervalSinceNow:(-24 *3600 *365 * 10)];
        NSDate *tenYearsLater = [NSDate dateWithTimeIntervalSinceNow:(24 *3600 *365 * 10)];
        self.minimumDate = minimumDate?minimumDate:tenYearsbefore;//默认是10年前
        self.maximumDate = maximumDate?maximumDate:tenYearsLater;//默认是10年后
        [self initData];
        [self setViews];
    }
    return self;
}

-(void)initData{
    //非闰年
    self.NotLeapYearArray = @[@"31",@"28",@"31",@"30",@"31",@"30",@"31",@"31",@"30",@"31",@"30",@"31"];
    //闰年
    self.leapYearArray = @[@"31",@"29",@"31",@"30",@"31",@"30",@"31",@"31",@"30",@"31",@"30",@"31"];
    
    //获得最小的年月日,最大的年月日
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy"];
    minYear = [[dateFormatter stringFromDate:_minimumDate] integerValue];
    maxYear = [[dateFormatter stringFromDate:_maximumDate] integerValue];
    [dateFormatter setDateFormat:@"MM"];
    minMonth = [[dateFormatter stringFromDate:_minimumDate] integerValue];
    maxMonth = [[dateFormatter stringFromDate:_maximumDate] integerValue];
    [dateFormatter setDateFormat:@"dd"];
    minDay = [[dateFormatter stringFromDate:_minimumDate] integerValue];
    maxDay = [[dateFormatter stringFromDate:_maximumDate] integerValue];
    
    for (NSInteger yearNum = minYear; yearNum <= maxYear; yearNum ++) {
        [self.yearArray addObject:[NSString stringWithFormat:@"%ld",yearNum]];//年份
    }
    //最小年份剩下的月份数
    for (NSInteger monthNum = minMonth; monthNum <= 12 ; monthNum ++) {
        [self.minMonthRemainingArray addObject:[NSString stringWithFormat:@"%ld",monthNum]];
    }
    //最大年份已过去的月份数
    for (NSInteger monthNum = 1; monthNum <= maxMonth; monthNum++) {
        [self.maxMonthRemainingArray addObject:[NSString stringWithFormat:@"%ld",monthNum]];
    }
    //最小日期剩下的天数
    NSInteger lastDay = [self LeapYearCompare:minYear withMonth:minMonth];
    for (NSInteger dayNum = minDay; dayNum <= lastDay; dayNum ++) {
        [self.minDayRemainingArray addObject:[NSString stringWithFormat:@"%ld",dayNum]];
    }
    //最大日期过去的天数
    for (NSInteger dayNum = 1; dayNum <= maxDay; dayNum ++) {
        [self.maxDayRemainingArray addObject:[NSString stringWithFormat:@"%ld",dayNum]];
    }
    
}



-(void)setViews{
    
    CGFloat traitPadding = 20;//左右间隙
    CGFloat topPadding = 10;//上下间隙
    CGFloat btnH = backViewH *1/8;//按钮高度
    CGFloat btnW = btnH *18/7;//按钮的宽度
    //取消按钮
    cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(traitPadding, topPadding, btnW, btnH);
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cancelButton.layer.cornerRadius = btnH/2;
    cancelButton.backgroundColor = SYSTEM_COLOR;
    [cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self addSubview:cancelButton];
    
    //确定按钮
    CGFloat toLeft = self.frame.size.width - traitPadding - btnW;//确定按钮的x值
    sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sureButton.frame = CGRectMake(toLeft, topPadding, btnW, btnH);
    [sureButton setTitle:@"确定" forState:UIControlStateNormal];
    [sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    sureButton.layer.cornerRadius = btnH/2;
    [sureButton addTarget:self action:@selector(sureAction) forControlEvents:UIControlEventTouchUpInside];
    sureButton.backgroundColor = BUTTON_BACKCOLOR;
    sureButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self addSubview:sureButton];
    
    CGFloat lightW = self.frame.size.width - traitPadding *2;
    UIView *lightView = [[UIView alloc]initWithFrame:CGRectMake(traitPadding, CGRectGetMaxY(cancelButton.frame) + topPadding, lightW, btnH)];
    lightView.backgroundColor = [UIColor colorWithRed:244/255.0 green:245/255.0 blue:246/255.0 alpha:1.0];
    [self addSubview:lightView];
    
    //年月日
    UILabel *yearLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, btnW, btnH)];
    yearLabel.text = @"年";
    yearLabel.textAlignment = NSTextAlignmentCenter;
    yearLabel.font = [UIFont systemFontOfSize:18];
    [lightView addSubview:yearLabel];
    
    UILabel *monthLabel = [[UILabel alloc]initWithFrame:CGRectMake((lightW - btnW)/2, 0, btnW, btnH)];
    monthLabel.text = @"月";
    monthLabel.textAlignment = NSTextAlignmentCenter;
    monthLabel.font = [UIFont systemFontOfSize:18];
    [lightView addSubview:monthLabel];
    
    UILabel *dayLabel = [[UILabel alloc]initWithFrame:CGRectMake(lightW - btnW, 0, btnW, btnH)];
    dayLabel.text = @"日";
    dayLabel.textAlignment = NSTextAlignmentCenter;
    dayLabel.font = [UIFont systemFontOfSize:18];
    [lightView addSubview:dayLabel];

    CGFloat pickerTop = CGRectGetMaxY(lightView.frame) + topPadding;//选择器的Y值
    CGFloat pickerHeight = backViewH - topPadding *4 - btnH *2;//选择器的高度
    //年
    //时间选择器
    yearPicker = [[UIPickerView alloc]init];
    yearPicker.frame = CGRectMake(traitPadding, pickerTop, btnW, pickerHeight);
    yearPicker.delegate = self;
    yearPicker.dataSource = self;
    [self addSubview:yearPicker];

    //月
    CGFloat monthX = self.frame.size.width/2 - btnW/2;
    monthPicker = [[UIPickerView alloc]init];
    monthPicker.frame = CGRectMake(monthX, pickerTop, btnW, pickerHeight);
    monthPicker.delegate = self;
    yearPicker.dataSource = self;
    [self addSubview:monthPicker];
    
    
    //日
    dayPicker = [[UIPickerView alloc]init];
    dayPicker.frame = CGRectMake(toLeft, pickerTop, btnW, pickerHeight);
    dayPicker.delegate = self;
    dayPicker.dataSource = self;
    [self addSubview:dayPicker];
    
    //默认选中某个row
    [yearPicker selectRow:0 inComponent:0 animated:YES];
    [monthPicker selectRow:0 inComponent:0 animated:YES];
    [dayPicker selectRow:0 inComponent:0 animated:YES];

    
    
}

#pragma mark - pickerView的delegate方法

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    if (pickerView == yearPicker) {
        
        [monthPicker reloadAllComponents];
        [dayPicker reloadAllComponents];
        
        
    }else if (pickerView == monthPicker){
        [dayPicker reloadAllComponents];
        
    }else{
        
        
    }
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (pickerView == yearPicker) {
        
        return self.yearArray.count;
        
    }else if (pickerView == monthPicker){
        
        return [self MonthInSelectYear];
        
    }else{
        
        return [self daysInSelectMonth];
        
        
        
    }
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    
    return 48;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    
    return 64;
    
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    CGFloat btnH = backViewH *1/8;//按钮高度
    CGFloat btnW = btnH *18/7;//按钮的宽度
    UILabel *rowLabel = [[UILabel alloc]init];
    rowLabel.textAlignment = NSTextAlignmentCenter;
    rowLabel.backgroundColor = [UIColor whiteColor];
    rowLabel.frame = CGRectMake(0, 0, btnW,self.frame.size.width);
    rowLabel.textAlignment = NSTextAlignmentCenter;
    rowLabel.font = [UIFont systemFontOfSize:18];
    rowLabel.textColor = [UIColor blackColor];
    
    CGFloat pickerCenterY = pickerView.frame.size.height/2;
    
    
    [pickerView.subviews[1] setBackgroundColor:[UIColor lightGrayColor]];
    [pickerView.subviews[2] setBackgroundColor:[UIColor lightGrayColor]];
    [pickerView.subviews[1] setFrame:CGRectMake(10 , pickerCenterY - btnH/2, 60, 2)];
    [pickerView.subviews[2] setFrame:CGRectMake(10, pickerCenterY + btnH/2, 60, 2)];
    [rowLabel sizeToFit];
    
    if (pickerView == yearPicker) {
        rowLabel.text = self.yearArray[row];
        return rowLabel;
    }else if(pickerView == monthPicker){
        NSInteger yearRow = [yearPicker selectedRowInComponent:0] % self.yearArray.count;
        if ([self.yearArray[yearRow] integerValue] == minYear) {
             NSInteger selectrow = row > _minMonthRemainingArray.count - 1 ?_minMonthRemainingArray.count -1 :row;
            rowLabel.text = [NSString stringWithFormat:@"%ld",[self.minMonthRemainingArray[selectrow] integerValue]];
        }else if ([self.yearArray[yearRow] integerValue] == maxYear){
            NSInteger selectrow = row > _maxMonthRemainingArray.count - 1 ?_maxMonthRemainingArray.count -1:row;
            rowLabel.text = [NSString stringWithFormat:@"%ld",[self.maxMonthRemainingArray[selectrow] integerValue]];
        }else{
            rowLabel.text = [NSString stringWithFormat:@"%ld",row % 12 + 1];
        }
        return rowLabel;
    }else{
        NSInteger yearRow = [yearPicker selectedRowInComponent:0] % self.yearArray.count;
        NSInteger monthRow = [monthPicker selectedRowInComponent:0] % 12;
        
        if ([self.yearArray[yearRow] integerValue] == minYear) {
            if ([self.minMonthRemainingArray[monthRow] integerValue] == minMonth) {
                NSInteger selectrow = row > _minDayRemainingArray.count - 1 ?_minDayRemainingArray.count -1 :row;
                rowLabel.text = [NSString stringWithFormat:@"%ld",[self.minDayRemainingArray[selectrow] integerValue] ];
            }else{
                NSInteger monthRemainingDays = [self LeapYearCompare:[self.yearArray[yearRow] integerValue] withMonth:[self.minMonthRemainingArray[monthRow] integerValue]];
                
                rowLabel.text = [NSString stringWithFormat:@"%ld", row % monthRemainingDays + 1];
            }
        }else if([self.yearArray[yearRow] integerValue] == minYear){
            if ([self.maxMonthRemainingArray[monthRow] integerValue] == maxMonth) {
                NSInteger selectrow = row > _maxDayRemainingArray.count - 1 ?_maxDayRemainingArray.count -1 :row;
                rowLabel.text = [NSString stringWithFormat:@"%ld",[self.maxDayRemainingArray[selectrow] integerValue] ];
            }else{
                NSInteger monthRemainingDays = [self LeapYearCompare:[self.yearArray[yearRow] integerValue] withMonth:[self.maxMonthRemainingArray[monthRow] integerValue]];
                
                rowLabel.text = [NSString stringWithFormat:@"%ld", row % monthRemainingDays + 1];
            }
        }else{
            NSInteger monthDays = [self LeapYearCompare:[self.yearArray[yearRow] integerValue] withMonth:(monthRow + 1)];
            rowLabel.text = [NSString stringWithFormat:@"%ld", row % monthDays + 1];
        }
        
        return rowLabel;
    }
    
}



-(void)cancelAction{
    [yearPicker selectRow:0 inComponent:0 animated:YES];
    [monthPicker selectRow:0 inComponent:0 animated:YES];
    [dayPicker selectRow:0 inComponent:0 animated:YES];

    if ([self.delegate respondsToSelector:@selector(cancelDatePicker)]) {
        [self.delegate cancelDatePicker];
    }
}

-(void)sureAction{
    
    NSString *yearStr = @"";
    NSString *monthStr = @"";
    NSString *dayStr = @"";
    NSInteger yearRow = [yearPicker selectedRowInComponent:0];
    NSInteger monthRow = [monthPicker selectedRowInComponent:0];
    NSInteger dayRow = [dayPicker selectedRowInComponent:0];
    yearStr = self.yearArray[yearRow];
    NSInteger monthDays = [self LeapYearCompare:[self.yearArray[yearRow] integerValue] withMonth:(monthRow + 1)];
    if ([self.yearArray[yearRow] integerValue] == minYear) {
        monthStr = self.minMonthRemainingArray[monthRow];
        if ([self.minMonthRemainingArray[monthRow] integerValue] == minMonth) {
            dayStr = self.minDayRemainingArray[dayRow];
        }else{
            NSInteger monthRemainingDays = [self LeapYearCompare:[self.yearArray[yearRow] integerValue] withMonth:[self.minMonthRemainingArray[monthRow] integerValue]];
            dayStr = [NSString stringWithFormat:@"%ld",dayRow % monthRemainingDays + 1];
        }
    }else if([self.yearArray[yearRow] integerValue] == minYear){
        monthStr = self.maxMonthRemainingArray[monthRow];
        if ([self.maxMonthRemainingArray[monthRow] integerValue] == maxMonth) {
            dayStr = self.maxDayRemainingArray[dayRow];
        }else{
            NSInteger monthRemainingDays = [self LeapYearCompare:[self.yearArray[yearRow] integerValue] withMonth:[self.maxMonthRemainingArray[monthRow] integerValue]];
            dayStr = [NSString stringWithFormat:@"%ld",dayRow % monthRemainingDays + 1];
        }
    }else{
        monthStr = [NSString stringWithFormat:@"%ld",monthRow%12 + 1];
        dayStr = [NSString stringWithFormat:@"%ld", dayRow % monthDays + 1];
    }
    
    
    NSString *dateStr = [NSString stringWithFormat:@"%@-%@-%@",yearStr,monthStr,dayStr];
    if ([self.delegate respondsToSelector:@selector(didSelectedDateString:)]) {
        [self.delegate didSelectedDateString:dateStr];
    }
}

#pragma mark - 判断是否是闰年(返回的的值,天数)
- (NSInteger)LeapYearCompare:(NSInteger)year withMonth:(NSInteger)month{
    if ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0) {
        return [self.leapYearArray[month - 1] integerValue];
    }else{
        return [self.NotLeapYearArray[month - 1] integerValue];
    }
}

/**
 * 返回有多少个月
 */
- (NSInteger)MonthInSelectYear{
    NSInteger yearRow = [yearPicker selectedRowInComponent:0];
    if ([self.yearArray[yearRow] integerValue] == minYear) {
        return _minMonthRemainingArray.count;
    }else if ([self.yearArray[yearRow] integerValue] == maxYear){
        return _maxMonthRemainingArray.count;
    }else {
        return 12;
    }
}

/**
 * 返回有多少天
 */
- (NSInteger)daysInSelectMonth{
    NSInteger yearRow = [yearPicker selectedRowInComponent:0] % self.yearArray.count;
    NSInteger monthRow = [monthPicker selectedRowInComponent:0] % 12;
    if ([self.yearArray[yearRow] integerValue] == minYear) {
        if ([self.minMonthRemainingArray[monthRow] integerValue] == minMonth) {
            return _minDayRemainingArray.count;
        }else{
            NSInteger monthRemainingDays = [self LeapYearCompare:[self.yearArray[yearRow] integerValue] withMonth:[self.minMonthRemainingArray[monthRow] integerValue]];
            return monthRemainingDays;
        }
    }else if ([self.yearArray[yearRow] integerValue] == maxYear){
        if ([self.maxMonthRemainingArray[monthRow]  integerValue]  == maxMonth){
            return _maxDayRemainingArray.count;
        }else{
            NSInteger monthRemainingDays = [self LeapYearCompare:[self.yearArray[yearRow] integerValue] withMonth:[self.maxMonthRemainingArray[monthRow] integerValue]];
            return monthRemainingDays;
        }
    }else{
        NSInteger monthDays = [self LeapYearCompare:[self.yearArray[yearRow] integerValue] withMonth:monthRow + 1];
        return monthDays;
    }
}




@end
