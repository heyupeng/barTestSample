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
 }
 
 (0). _UIBarBackground 背景层。
    1. origin.x = - safe.top (电池栏高度 20 or 44)。
    2. 高度 height = safe.top + bar.height。
    ⚠️ 注意：iOS 13后，高度 height = safe.top + 44。
        
 (0-1). UIImageView Bar背景色的执行者。
    小标题模式：alpha = 1。backgroundColor = bar.barTintColor 生效。
    大标题模式：alpha = 1。
    ⚠️ 注意：iOS 13后，大标题模式下，默认 alpha = 0。
    大标题风格，因为背景色执行视图透明值alpha为0，暴露出视图背后内容，导航栏区域可能为黑色（bar背景色为透明）。
    
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
 
 ----- ----- ----- ----- ----- XCode 14.2 & iOS 11 ----- ----- ----- ----- -----
 0. 当 bar.translucent = NO, _UIBarBackground 层级结构：
 {
    _UIBarBackground // 背景层。
        -- 0. _UIBarBackgroundShadowView
            -- 0. _UIBarBackgroundShadowContentImageView
        -- 1. UIImageView // Bar背景色的执行者。
 }
 
 1. 当 bar.translucent = YES, _UIBarBackground 层级结构发生变化：
 {
    _UIBarBackground
        -- 0. UIImageView // 阴影视图 height = 1/3。
        -- 1. UIVisualEffectView
            -- 0. _UIVisualEffectBackdropView
            -- 1. _UIVisualEffectSubview // 默认背景层。
            -- 2. _UIVisualEffectSubview // 定制背景层，Bar背景色的执行者。
 }
 
 (1-1). 默认背景层
    背景色为 0xf8f87f {White:0.97 Alpha:0.5}。
 (1-2). 定制背景层
    bar.barTintColor 的实际执行者，透明度alpha = 0.85。
 ⚠️ 注意：视觉效果存在色差。
    如：色值 0x3DB9BF，在 UIHierarchy 上取色为 0x57D2D7，在 iPhone8 上截图取色为 iOS 13.4 0x57BBC0 。
 ----- ----- ----- ----- ----- End ----- ----- ----- ----- -----
 
 */

/// NavigationBar 背景视图。
/// @Return UIView 子类，私有类名"_UIBarBackground"。
- (UIView *)backgroundView {
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
    NSLog(@"Get backgroundView");
    return nil;
}

/// NavigationBar 背景色的实际执行视图。
- (UIView *)backgroundColorView {
    return [[self backgroundView] subviews].lastObject;
}

/// NavigationBar 大标题容器视图。
/// @Discussion iOS 11 新增大标题风格。
/// @Return UIView 子类，私有类名"_UINavigationBarLargeTitleView"。
- (UIView *)largeTitleView {
    UINavigationBar * bar = self;
    
    NSString * kBarBackgroundCls = @"_UINavigationBarLargeTitleView";
    for (UIView * subview in bar.subviews) {
        NSString * cls = NSStringFromClass(subview.class);
        if ([cls isEqualToString:kBarBackgroundCls]) {
            return subview;
        }
    }
    NSLog(@"Get largeTitleView");
    return nil;
}

#define USE_CUSTOM_BACKGROUNDVIEW_FLAG 0

/// 自定义背景色视图。
- (UIView *)my_backgroundView {
    UINavigationBar * bar = self;
    
    int myBackgroundViewTag = 10000 + 1;
    UIView * myBackgroundView = [bar viewWithTag:myBackgroundViewTag];
    if (!myBackgroundView) {
        myBackgroundView = [[UIView alloc] init];
        myBackgroundView.userInteractionEnabled = NO;
        myBackgroundView.tag = myBackgroundViewTag;
        myBackgroundView.layer.zPosition = - myBackgroundViewTag;
        [bar addSubview:myBackgroundView];
        
        CGRect frame = bar.frame;
        frame.origin.y = - CGRectGetMinY(frame);
        frame.size.height += - CGRectGetMinY(frame);
        myBackgroundView.frame = frame;
    }
    
    myBackgroundView.backgroundColor = bar.barTintColor;
    return myBackgroundView;
}

- (void)my_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    NSString * cls = NSStringFromClass([object class]);
    BOOL isPrior = [[change objectForKey:NSKeyValueChangeNotificationIsPriorKey] boolValue];
    
    printf("Cls: %s, key: %s \n", cls.UTF8String, keyPath.UTF8String);
    printf("%s \n", [object description].UTF8String);
    printf("%s \n", [change description].UTF8String);
    if (isPrior) {
        return;
    }
    
    if ([cls isEqualToString:@"UINavigationBar"] && [keyPath isEqualToString:@"frame"]) {
        UINavigationBar * bar = (UINavigationBar *)object;
        CGRect frame = bar.frame;
        
        BOOL isChangeValue = NO;
        NSValue *old, *new;
        old = [change objectForKey:NSKeyValueChangeOldKey];
        new = [change objectForKey:NSKeyValueChangeNewKey];
        if (!CGRectEqualToRect(old.CGRectValue, new.CGRectValue)) { isChangeValue = YES; }
#if 0
        static CGRect barFrame;
        if (!CGRectEqualToRect(frame, barFrame)) { isChangeValue = YES; }
        barFrame = frame;
#endif
        printf("  - navigationBar frame is changed ? %d \n", isChangeValue);
        
        /* 推进/推出时，backgroundView 的坐标位置随动画变化，起始位/结束位在侧屏幕外，即 ±width。
         *  小标题转大标题：● 推入时，x = - width；● 推出时，x = width。
         */
        UIView * backgroundView = [bar backgroundView];
        // 1.1 删除 position 动画
        [backgroundView.layer removeAllAnimations];
        // 1.2 修正 frame（推进时需修正）
        CGRect newFrame = backgroundView.frame;
        printf("  - backgroundView frame: %s \n", NSStringFromCGRect(newFrame).UTF8String);
        if (CGRectGetMinX(newFrame) != 0) {
            newFrame.origin.x = 0;
            newFrame.size.height = - CGRectGetMinY(newFrame) + CGRectGetHeight(frame);
            backgroundView.frame = newFrame;
            printf("  - ! reset frame: %s) \n", NSStringFromCGRect(newFrame).UTF8String);
        }
        
        UIView * largeTitleView = [bar largeTitleView];
        printf("  - largeTitleView height: %.2f , alpha: %.2f \n", CGRectGetHeight( largeTitleView.frame), largeTitleView.alpha);
        
        /* 通过监听frame得出，当 height > 16 时，alpha = 1，视图处于可见状态。当 height < 16 时，alpha = 0，视图不可见（内部逻辑，此处修改`largeTitleView.alpha`效果不佳）。 */
        /*!
         if (CGRectGetHeight(largeTitleView.frame) < 16 &&
             largeTitleView.alpha == 0) {
             [largeTitleView.layer removeAnimationForKey:@"opacity"];
             largeTitleView.layer.opacity = 1;
             largeTitleView.alpha = 1;
         }
         */
        
        frame.origin.y = - CGRectGetMinY(frame);
        frame.size.height += - CGRectGetMinY(frame);

#if USE_CUSTOM_BACKGROUNDVIEW_FLAG
        UIView * myBackgroundView;
        myBackgroundView = [bar my_backgroundView];
        if (isChangeValue) {
            myBackgroundView.frame = frame;
        }
        CABasicAnimation * anim = [[[[bar largeTitleView] layer] animationForKey:@"bounds.size"] mutableCopy];
        anim.delegate = nil;
        if (anim && anim.speed == 1) {
            // 推出时，largeTitleView 携带动画。为myBackgroundView增加动画。
            CGSize fromSize = [anim.fromValue CGSizeValue];
            CGSize toSize = [anim.toValue CGSizeValue];
            
            anim.additive = 0;
            anim.keyPath = @"bounds";
            anim.toValue = [NSValue valueWithCGRect:frame];
            frame.size.height += fromSize.height;
            anim.fromValue = [NSValue valueWithCGRect:frame];
            [myBackgroundView.layer addAnimation:anim forKey:@"bounds"];
        }
#endif
        printf("  \n");
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    [self my_observeValueForKeyPath:keyPath ofObject:object change:change context:context];
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

- (void)interactivePopGestureRecognizerAction:(UIGestureRecognizer *)sender {
    UIView * view = [sender view];
    CGPoint location = [sender locationInView:nil];
    CGFloat offsetX = location.x;
    CGFloat width = CGRectGetWidth(view.bounds);
    CGFloat progess = location.x / width;
    
    UINavigationBar * bar = self.navigationController.navigationBar;
    UIView * largeTitleView = [bar largeTitleView];
    
    static CGRect frame;
    static BOOL isChangeHeight;
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"右滑开始");
        // 开始右滑
        frame = largeTitleView.frame;
        isChangeHeight = NO;
        
    } else if (sender.state == UIGestureRecognizerStateChanged){
        NSLog(@"右滑ing...");
        if (CGRectGetHeight(frame) != CGRectGetHeight(largeTitleView.frame)) {
            isChangeHeight = YES;
            
            // 删除 position 动画
            [[bar backgroundView].layer removeAllAnimations];
            // 铲除 opacity 动画
            [[bar backgroundColorView].layer removeAllAnimations];
            [bar backgroundColorView].alpha = 0;
        }
        NSLog(@"%@", NSStringFromCGRect([bar backgroundView].frame));
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        NSLog(@"右滑结束");
    } else if (sender.state == UIGestureRecognizerStateCancelled) {
        NSLog(@"右滑取消");
    }
    
    NSLog(@"右滑位移: %.2f/%.2f(%.2f %%)", offsetX, width, progess);
    
    if (!isChangeHeight) {
        return;;
    }
    
    largeTitleView.layer.opacity = 1;
    
    CGRect newFrame = [bar backgroundView].frame;
    newFrame.origin.x = 0; // (小标题转大标题 & 推出时，x = width。)
    newFrame.size.height = - CGRectGetMinY(newFrame) + 44 + (CGRectGetHeight(bar.frame) - 44) * progess;
    [bar backgroundView].frame = newFrame;
    
#if USE_CUSTOM_BACKGROUNDVIEW_FLAG
    UIView * myBackgroundView;
    myBackgroundView = [bar my_backgroundView];
    CABasicAnimation * anim = [[[bar largeTitleView] layer] animationForKey:@"bounds.size"];
    if (anim) {
        CGSize fromSize = [anim.fromValue CGSizeValue];
        CGSize toSize = [anim.toValue CGSizeValue];
        CGFloat h = fromSize.height * (1-progess) + toSize.height * progess;
        newFrame.size.height = - CGRectGetMinY(newFrame) + 44 + h;
        myBackgroundView.frame = newFrame;
    }
#endif
}

- (void)initUI {
//    self.automaticallyAdjustsScrollViewInsets = NO;
//    self.view.backgroundColor = [UIColor whiteColor];
    
    UIColor * barBackgroundColor = [UIColor colorWithRed:0x3d/255.0 green:0xB9/255.0 blue:0xBF/255.0 alpha:1];
    
    UINavigationBar * bar = self.navigationController.navigationBar;
    
    [bar addObserver:bar forKeyPath:@"frame" options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionInitial context:nil];
    [bar addObserver:self forKeyPath:@"layer.timeOffset" options:NSKeyValueObservingOptionPrior context:nil];
    
//    [[bar largeTitleView] addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionPrior context:nil];
//    [[bar largeTitleView] addObserver:self forKeyPath:@"alpha" options:NSKeyValueObservingOptionPrior context:nil];
    
    bar.barTintColor = barBackgroundColor;
    
    [bar backgroundView].backgroundColor = barBackgroundColor;
    [bar largeTitleView].backgroundColor = barBackgroundColor;
    
    [self.navigationController.interactivePopGestureRecognizer addTarget:self action:@selector(interactivePopGestureRecognizerAction:)];
}

@end
