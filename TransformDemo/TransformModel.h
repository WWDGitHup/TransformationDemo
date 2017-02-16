//
//  TransformModel.h
//  TransformDemo
//
//  Created by apple on 2017/2/16.
//  Copyright © 2017年 Victor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TransformModel : NSObject
@property (nonatomic, assign) NSInteger             index;
@property (nonatomic, assign) float                 beginAngle;
@property (nonatomic, assign) float                 transMakeZ;//Z轴偏移量
@property (nonatomic, assign) float                 beginOffsetX;//X轴初始偏移量
@property (nonatomic, copy)   NSString             * identifier;
@end
