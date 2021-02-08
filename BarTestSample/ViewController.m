//
//  ViewController.m
//  BarTestSample
//
//  Created by Mac on 2021/2/7.
//

#import "ViewController.h"

@interface UINavigationBar(yp_UIHierarchy)

@end

@implementation UINavigationBar (yp_UIHierarchy)

/*
 UINavigationBar UI 层级结构
 {
    UINavigationBar ; // 高度 height = 44；大标题风格高度 height = 96；
        -- 0. _UIBarBackground // 背景层。
            -- 0. _UIBarBackgroundShadowView
                -- 0. _UIBarBackgroundShadowContentImageView
            -- 1. UIImageView // Bar背景色的执行者。
        -- 1. _UINavigationBarLargeTitleView // 大标题层。
        -- 2. _UINavigationBarContentView // 导航栏层(高度 height = 44)。
        -- 3. UIView ;
    
    (0). _UIBarBackground 背景层。
     1. origin.x = - safe.top (电池栏高度 20 or 44)。
     2. 高度 height = safe.top + bar.height。
        ⚠️ 注意：iOS 13后，高度 height = safe.top + 44。
        
    (0-1). UIImageView Bar背景色的执行者。
        小标题模式：alpha = 1。backgroundColor = bar.barTintColor 生效。
        大标题模式：alpha = 1。 ⚠️ 注意：iOS 13后，alpha = 0。大标题风格，因为背景色执行视图透明值alpha为0，暴露出视图背后内容，导航栏区域可能为黑色（bar背景色为透明）。
    
    ----- ⚠️ 注意场景：右滑手势返回上层 -----
    1. 大标题风格 => 小标题风格。
        导航栏高已变更为44，导航栏与下方源视图之间存在间隔，背景层诸多属性增加基动画过渡，动画开始前，间隔被背景层遮挡。
        跟随手势右移，源视图右移，背景层高度向上缩小，间隔被暴露，显示源视图背后的视图, 间隔宽度变小，高度变大，直到宽为0。
    2. 小标题风格 => 大标题风格。
        导航栏高已变更为96，背景层诸多属性增加基动画过渡，动画完成前，背景层与下方目标视图之间存在间隔，间隔被源视图遮挡。
        跟随手势右移，源视图右移，间隔被暴露，同时，背景层高度向下扩大，间隔高度变小，直到高为0。
    ----- -----
    
    (1). _UINavigationBarLargeTitleView 大标题层（iOS 11 新增）。
        origin.x = 44，即，高度 height = bar.height - 44。当 bar.prefersLargeTitles = NO，从父视图移除。
        ⚠️ 注意：通过监听frame测算得出，当 height > 16 时，alpha = 1，视图处于可见状态。
 
 ----- ----- ----- ----- ----- iOS 11, XCode 14.2 ----- ----- ----- ----- -----
 当 bar.translucent = YES, _UIBarBackground 层级结构发生变化：
    _UIBarBackground
        -- 0. UIImageView // 阴影视图 height = 1/3。
        -- 1. UIVisualEffectView
            -- 0. _UIVisualEffectBackdropView
            -- 1. _UIVisualEffectSubview // 默认背景层。
            -- 2. _UIVisualEffectSubview // 定制背景层，Bar背景色的执行者。
    
    (1-1). 默认背景层
        背景色为 0xf8f87f {White:0.97 Alpha:0.5}。
    (1-2). 定制背景层
        bar.barTintColor 的实际执行者，透明度alpha = 0.85。
    ⚠️ 注意：视觉效果存在色差。
    如：色值 0x3DB9BF，在 UIHierarchy 上取色为 0x57D2D7，在 iPhone8 上截图取色为 iOS 13.4 0x57BBC0 。
 ----- ----- ----- ----- ----- End ----- ----- ----- ----- -----
 }
 
 */

/// NavigationBar 背景视图。
/// @Return UIView 子类，私有类名"_UIBarBackground"。
- (UIView *)barBackgroundView {
    UINavigationBar * bar = self;
    /**
     * 1. iOS 10 以前：_UINavigationBarBackground; UIImageView 子类，有毛玻璃效果子视图;
     * 2. iOS 10 及以后：_UIBarBackground; UIView 子类, UIImageView 作为子视图;
     */
    NSString * barBackgroundCls = @"_UINavigationBarBackground";
    NSString * barBackgroundCls_10 = @"_UIBarBackground";
    for (UIView * subview in bar.subviews) {
        NSString * cls = NSStringFromClass(subview.class);
        if ([cls isEqualToString:barBackgroundCls] ||
            [cls isEqualToString:barBackgroundCls_10]) {
            return subview;
        }
    }
    NSLog(@"Get barBackgroundView");
    return nil;
}

/// NavigationBar 背景色的实际执行视图。
- (UIView *)barBackgroundColorView {
    return [[self barBackgroundView] subviews].lastObject;
}

/// NavigationBar 大标题容器视图。
/// @Discussion iOS 11 新增大标题风格。
/// @Return UIView 子类，私有类名"_UINavigationBarLargeTitleView"。
- (UIView *)barLargeTitleView {
    UINavigationBar * bar = self;
    
    NSString * kBarBackgroundCls = @"_UINavigationBarLargeTitleView";
    for (UIView * subview in bar.subviews) {
        NSString * cls = NSStringFromClass(subview.class);
        if ([cls isEqualToString:kBarBackgroundCls]) {
            return subview;
        }
    }
    NSLog(@"Get barLargeTitleView");
    return nil;
}

@end

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initUI];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    NSString * cls = NSStringFromClass([object class]);
    BOOL isPrior = [[change objectForKey:NSKeyValueChangeNotificationIsPriorKey] boolValue];
    
    if (isPrior) {
        printf(" Cls: %s \n - key : %s: %s \n", cls.UTF8String, keyPath.UTF8String, [object description].UTF8String);
    }
    
    static CGRect barFrame;
    if ([keyPath isEqualToString:@"frame"]) {
        UINavigationBar * bar = (UINavigationBar *)object;
        CGRect frame = bar.bounds;
        
        if (CGRectEqualToRect(frame, barFrame)) { return; }
        barFrame = frame;
        
        printf("frame: %s \n", NSStringFromCGRect(frame).UTF8String);
        printf("%s barLargeTitleView height: %.2f , alpha: %.2f \n", NSStringFromCGRect(frame).UTF8String, CGRectGetHeight([bar barLargeTitleView].frame), [bar barLargeTitleView].alpha);
        
        return;
        UIView * bgview = [bar viewWithTag:1001];
        if (!bgview) {
            bgview = [[UIView alloc] init];
            bgview.frame = frame;
            bgview.tag = 1001;
            bgview.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.3];
            [bar insertSubview:bgview atIndex:0];
        }
        bgview.frame = frame;
    }
}

- (void)interactivePopGestureRecognizerAction:(UIGestureRecognizer *)sender {
    UIView * view = [sender view];
    CGPoint location = [sender locationInView:nil];
    CGFloat offsetX = location.x;
    CGFloat progess = location.x / CGRectGetWidth(view.bounds);
    
    UINavigationBar * bar = self.navigationController.navigationBar;
    UIView * barLargeTitleView = [bar barLargeTitleView];
    
    static CGRect frame;
    static BOOL isChangeHeight;
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"右滑开始");
        // 开始右滑
        frame = barLargeTitleView.frame;
        isChangeHeight = NO;
        
    } else if (sender.state == UIGestureRecognizerStateChanged){
        NSLog(@"右滑ing...");
        if (CGRectGetHeight(frame) != CGRectGetHeight(barLargeTitleView.frame)) {
            isChangeHeight = YES;
            
            // 删除 position 动画
            [[bar barBackgroundView].layer removeAllAnimations];
            // 铲除 opacity 动画
            [[bar barBackgroundColorView].layer removeAllAnimations];
            [bar barBackgroundColorView].alpha = 0;
        }
        NSLog(@"%@", NSStringFromCGRect([bar barBackgroundView].frame));
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        NSLog(@"右滑结束");
    } else if (sender.state == UIGestureRecognizerStateCancelled) {
        NSLog(@"右滑取消");
    }
    
    NSLog(@"右滑: %.3f(%.2f %%)", offsetX, progess);
    
    if (!isChangeHeight) {
        return;;
    }
    
    barLargeTitleView.layer.opacity = 1;
    
    CGRect newFrame = [bar barBackgroundView].frame;
    newFrame.origin.x = 0;
    newFrame.size.height = - CGRectGetMinY(newFrame) + 44 + (CGRectGetHeight(bar.frame) - 44) * progess;
    [bar barBackgroundView].frame = newFrame;
}

- (void)initUI {
//    self.automaticallyAdjustsScrollViewInsets = NO;
//    self.view.backgroundColor = [UIColor whiteColor];
    
    UIColor * barBackgroundColor = [UIColor colorWithRed:0x3d/255.0 green:0xB9/255.0 blue:0xBF/255.0 alpha:1];
    
    UINavigationBar * bar = self.navigationController.navigationBar;
    
    [bar addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionPrior context:nil];
    [bar addObserver:self forKeyPath:@"layer.timeOffset" options:NSKeyValueObservingOptionPrior context:nil];
    
//    [[bar barLargeTitleView] addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionPrior context:nil];
//    [[bar barLargeTitleView] addObserver:self forKeyPath:@"alpha" options:NSKeyValueObservingOptionPrior context:nil];
    
//    bar.delegate = self;
    
    bar.barTintColor = barBackgroundColor;
    
    [[bar barBackgroundColorView].layer removeAllAnimations];
    [bar barBackgroundView].backgroundColor = barBackgroundColor;
    
    [bar barLargeTitleView].backgroundColor = barBackgroundColor;
    
    [self.navigationController.interactivePopGestureRecognizer addTarget:self action:@selector(interactivePopGestureRecognizerAction:)];
}

@end
