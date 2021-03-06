//
//  LMRumtimeViewController.m
//  LMStudyBasicDemo
//
//  Created by Tim on 2017/7/31.
//  Copyright © 2017年 LM. All rights reserved.
//

#import "LMRumtimeViewController.h"
#import "LMRuntimeBasicTestViewController.h"
#import <objc/runtime.h>
#import "AspectProxy.h"

@interface LMRumtimeViewController ()

@property (nonatomic, strong) LMRuntimeBasicTestViewController *swizzleVC;

@end

@implementation LMRumtimeViewController

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        SEL originalSel = @selector(viewDidAppear:);
        SEL swizzledSel = @selector(lm_viewDidAppear:);
        Method originalMethod = class_getInstanceMethod(class, originalSel);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSel);
        BOOL success = class_addMethod(class, originalSel, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (success) {
            class_replaceMethod(class, swizzledSel, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
        
    });
}

- (void)lm_viewDidAppear:(BOOL)animated
{
    [self lm_viewDidAppear:animated];
    NSLog(@"------ lm_viewDidAppear ---- \n");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    _swizzleVC = [[LMRuntimeBasicTestViewController alloc] init];
    [self.view addSubview:_swizzleVC.view];
    _swizzleVC.view.frame = CGRectMake(50, 100, 100, 100);
    _swizzleVC.view.backgroundColor = [UIColor redColor];
    [self addChildViewController:_swizzleVC];
    [_swizzleVC didMoveToParentViewController:self];
    
//    [self testAspectProxy];
    
//    IMP swizzle = method_getImplementation(class_getInstanceMethod([self class], @selector(testAspectProxy)));
    
//    [self class_swizzleMethodAndStore:[self class] original:@selector(viewDidAppear:) replacement:swizzle store:nil];
}

typedef IMP *IMPPointer;
- (BOOL)class_swizzleMethodAndStore:(Class)class original:(SEL)original replacement:(IMP) replacement store:(IMPPointer)store
{
    IMP imp = NULL;
    Method method = class_getInstanceMethod(class, original);
    if (method) {
        const char *type = method_getTypeEncoding(method);
        imp = class_replaceMethod(class, original, replacement, type);
        if (!imp) {
            imp = method_getImplementation(method);
        }
    }
    if (imp && store) {
        *store = imp;
    }
    return imp != NULL;
}

- (void)testAspectProxy
{
    id student = [[TestStudent alloc] init];
    NSValue *selValue1 = [NSValue valueWithPointer:@selector(study:andRead:)];
    NSArray *selValues = @[selValue1];
    AuditingInvoker *invoker = [[AuditingInvoker alloc] init];
    id studentProxy = [[AspectProxy alloc] initWithObject:student selectors:selValues andInover:invoker];
    // 使用指定的选择器向该代理发送消息---例子1
    [studentProxy study:@"Computer" andRead:@"Algorithm"];
    
    // 使用还未注册到代理中的其他选择器，向这个代理发送消息！---例子2
    [studentProxy study:@"mathematics" name:@"higher mathematics"];
    
    // 为这个代理注册一个选择器并再次向其发送消息---例子3
    [studentProxy registerSelector:@selector(study:name:)];
    [studentProxy study:@"mathematics" name:@"higher mathematics"];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"------ viewwillappear ---- \n");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

@implementation LMRumtimeViewController(Tracking)

+ (void)load
{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        Class class = [self class];
//        SEL originalSel = @selector(viewWillAppear:);
//        SEL swizzleSel = @selector(xxx_viewWillAppear:);
//
//        Method originalMethod = class_getInstanceMethod(class, originalSel);
//        Method swizzleMethod = class_getInstanceMethod(class, swizzleSel);
//
//        BOOL didAddMethod = class_addMethod(class, originalSel, method_getImplementation(swizzleMethod), method_getTypeEncoding(swizzleMethod));
//        if (didAddMethod) {
//            class_replaceMethod(class, swizzleSel, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
//        } else {
//            method_exchangeImplementations(originalMethod, swizzleMethod);
//        }
//    });
/// -------------------  下面的功能和上面想同   -----------------
//    Class class = [self class];
//    SEL originalSel = @selector(viewWillAppear:);
//    SEL swizzleSel = @selector(xxx_viewWillAppear:);
//    Method originalMethod = class_getInstanceMethod(class, originalSel);
//    Method swizzleMethod = class_getInstanceMethod(class, swizzleSel);
//
//    if (!originalMethod || !swizzleMethod) {
//        return;
//    }
//    IMP originalIMP = method_getImplementation(originalMethod);
//    IMP swizzleIMP = method_getImplementation(swizzleMethod);
//    const char *originalType = method_getTypeEncoding(originalMethod);
//    const char *swizzleType = method_getTypeEncoding(swizzleMethod);
//
//    // 这儿的先后顺序是有讲究的,如果先执行后一句,那么在执行完瞬间方法被调用容易引发死循环
//    class_replaceMethod(class, swizzleSel, originalIMP, originalType);
//    class_replaceMethod(class, originalSel, swizzleIMP, swizzleType);
//    //这是因为class_replaceMethod方法其实能够覆盖到class_addMethod和method_setImplementation两种场景, 对于第一个class_replaceMethod来说, 如果viewWillAppear:实现在父类, 则执行class_addMethod, 否则就执行method_setImplementation将原方法的IMP指定新的代码块; 而第二个class_replaceMethod完成的工作便只是将新方法的IMP指向原来的代码.
//    //
//    //但此处需要特别注意交换的顺序,应该优化把新的方法指定原IMP,再修改原有的方法的IMP.
    [LMRumtimeViewController addAnotherClassMethod];
}

+ (void)addAnotherClassMethod
{
    Class originalClass = NSClassFromString(@"LMMethonSwizzlingViewController");
    Class swizzleClass = [self class];
    SEL originalSel = NSSelectorFromString(@"viewWillAppear:");
    SEL swizzleSel = @selector(xxx_viewWillAppear:);
    Method originalMethod = class_getInstanceMethod(originalClass, originalSel);
    Method swizzleMethod = class_getInstanceMethod(swizzleClass, swizzleSel);
    
    // 向orignialclass新添加一个 xxx_viewWillAppear 方法
    BOOL registerMethod = class_addMethod(originalClass, swizzleSel, method_getImplementation(swizzleMethod), method_getTypeEncoding(swizzleMethod));
    if (!registerMethod) {
        return;
    }
    
    // 需要更新swizzlemethod变量，获取当前originalclass的method指针
    swizzleMethod = class_getInstanceMethod(originalClass, swizzleSel);
    if (!swizzleMethod) {
        return;
    }
    
    BOOL didAddMethod = class_addMethod(originalClass, originalSel, method_getImplementation(swizzleMethod), method_getTypeEncoding(swizzleMethod));
    if (didAddMethod) {
        class_replaceMethod(originalClass, swizzleSel, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzleMethod);
    }

}


- (void)xxx_viewWillAppear:(BOOL)animated {
    
    [self xxx_viewWillAppear:animated];
    NSLog(@"----- xxx viewwillappear  ----- \n");
}

@end
