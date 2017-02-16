//
//  TransformViewCell.h
//  TransformDemo
//
//  Created by apple on 2017/2/14.
//  Copyright © 2017年 Victor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransformModel.h"

@interface TransformViewCell : UIView
@property (nonatomic, strong) TransformModel   * transModel;
@property (nonatomic, strong) id                 data;
@property (nonatomic, strong) UILabel         * testLabel;
//初始化方法必须调用该方法，否则可能导致初始化失败无法进行下一步
- (instancetype)initWithIndentifier:(NSString *)identifier;
@end
