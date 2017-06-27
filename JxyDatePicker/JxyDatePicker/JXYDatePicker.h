//
//  JXYDatePicker.h
//  Chart-Demo
//
//  Created by yongjing.xiao on 2017/6/16.
//  Copyright © 2017年 xinweilai. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JXYDatePickerDelegate <NSObject>
@optional
//选中日期
-(void)didSelectedDateString:(NSString *)dateString;
//取消日期
-(void)cancelDatePicker;

@end

@interface JXYDatePicker : UIView
//代理
@property (nonatomic ,weak)id<JXYDatePickerDelegate>delegate;

-(instancetype)initWithFrame:(CGRect)frame WithMinimumDate:(NSDate *)minimumDate maximumDate:(NSDate *)maximumDate;


@end
