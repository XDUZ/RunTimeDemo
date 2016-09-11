//
//  Person.h
//  runTime
//
//  Created by liu on 16/9/9.
//  Copyright © 2016年 思想加. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) int age;

-(void)getHeight;
@end
