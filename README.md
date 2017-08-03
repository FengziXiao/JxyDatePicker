# JxyDatePicker
因项目需求，需要用到一个时间选择器，设置最大可选时间与最小可选时间，其它无效不可选的时间需要‘干’掉！！！苦于找了一堆别人自定义的时间选择器，并没有符合要求的。故而：自己写了一个。只分享给有需要的人（demo已附上）。
先看效果：

![image](https://github.com/FengziXiao/JxyDatePicker/blob/master/1340843-a76f1e1788c0684f.gif)

```
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
```
简单易懂！定义了一个代理及两个方法，分别对应确定按钮与取消按钮的点击操作。
公开了一个方法，即初始化这个时间选择器的方法，参数方别对应：frame，最小日期，最大日期。

简单使用：

实现完了就可以用啦，几句代码就可以搞定：

```
NSDate *minimumDate = [NSDate dateWithTimeIntervalSinceNow:(24 * 3600 * 7)];
    NSDate *maximumDate = [NSDate dateWithTimeIntervalSinceNow:(24 *3600 *365 *2)];
    _JDatepicker = [[JXYDatePicker alloc]initWithFrame:CGRectMake(0, 100, SCREEN_WIDTH, datePickerH)WithMinimumDate:minimumDate maximumDate:maximumDate];
    _JDatepicker.delegate = self;
    [self.view addSubview:_JDatepicker];
```
非常希望得到你的指点，如果能够帮到你，我也很欣慰！