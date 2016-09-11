//
//  ViewController.m
//  runTime
//
//  Created by liu on 16/9/9.
//  Copyright © 2016年 思想加. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import <objc/runtime.h>

@interface ViewController ()

@end

@implementation ViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
   
    UIButton *gMBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    gMBtn.frame = CGRectMake(100,100, 200, 100);
    [gMBtn setTitle:@"获取类方法" forState: UIControlStateNormal];
    [gMBtn addTarget:self action:@selector(getMethod) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:gMBtn];
    
     UIButton *gVBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    gVBtn.frame = CGRectMake(100,300, 200, 100);
    [gVBtn setTitle:@"获取类的属性列表" forState: UIControlStateNormal];
    [gVBtn addTarget:self action:@selector(getVar) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:gVBtn];
    
    UIButton *createClassBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    createClassBtn.frame = CGRectMake(100,500, 200, 100);
    [createClassBtn setTitle:@"动态创建类和方法" forState: UIControlStateNormal];
    [createClassBtn addTarget:self action:@selector(createClass) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:createClassBtn];
    
}
/*获取类的方法*/
-(void)getMethod{
    
    unsigned int methCount = 0;
    Method *meths = class_copyMethodList([Person class], &methCount);
    
    for(int i = 0; i < methCount; i++) {
        
        Method meth = meths[i];
        
        SEL sel = method_getName(meth);
        
        const char *name = sel_getName(sel);
        
        NSLog(@"Person的方法：%s", name);
        
    }

    free(meths);
}
/*获取类的成员变量*/
-(void)getVar{
     //成员变量个数
    unsigned int count;
    Ivar *vars = class_copyIvarList(NSClassFromString(@"Person"), &count);
    NSString *key=nil;
    for(int i = 0; i < count; i++) {
        
        Ivar thisIvar = vars[i];
         //获取成员变量的名字
        key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
        NSLog(@"成员变量的名字 :%@", key);
         //获取成员变量的数据类型
        key = [NSString stringWithUTF8String:ivar_getTypeEncoding(thisIvar)];
        NSLog(@"成员变量的数据类型 :%@", key);
    }
    // 释放
    free(vars);
}

/*动态创建类*/
-(void)createClass{
    Class MyClass = objc_allocateClassPair([NSObject class], "myclass", 0);
    //添加一个NSString的变量，第四个参数是对其方式，第五个参数是参数类型
    if (class_addIvar(MyClass, "itest", sizeof(NSString *), 0, "@")) {
        NSLog(@"add ivar success");
    }
    //myclasstest是已经实现的函数，"v@:"这种写法见参数类型连接
    class_addMethod(MyClass, @selector(myclasstest:), (IMP)myclasstest, "v@:");
    //注册这个类到runtime系统中就可以使用他了
    objc_registerClassPair(MyClass);
    //生成了一个实例化对象
    id myobj = [[MyClass alloc] init];
    NSString *str = @"给动态添加的变量赋的值";
    //给刚刚添加的变量赋值
    //    object_setInstanceVariable(myobj, "itest", (void *)&str);在ARC下不允许使用
    [myobj setValue:str forKey:@"itest"];
    //调用myclasstest方法，也就是给myobj这个接受者发送myclasstest这个消息
    [myobj myclasstest:@"调用动态生成的方法传入的值"];
}
//这个方法实际上没有被调用,但是必须实现否则不会调用下面的方法
- (void)myclasstest:(NSString *)str
{
    NSLog(@"这个方法实际上没有被调用");
}
//调用的是这个方法
static void myclasstest(id self, SEL _cmd,  NSString *str) //self和_cmd是必须的，在之后可以随意添加其他参数
{
    
    Ivar v = class_getInstanceVariable([self class], "itest");
    //返回名为itest的ivar的变量的值
    id o = object_getIvar(self, v);
    //成功打印出结果
    NSLog(@"%@", o);
    NSLog(@"调用 ＝＝ %@", str);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
