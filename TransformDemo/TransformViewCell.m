//
//  TransformViewCell.m
//  TransformDemo
//
//  Created by apple on 2017/2/14.
//  Copyright © 2017年 Victor. All rights reserved.
//

#import "TransformViewCell.h"
#import "TransformView.h"

@implementation TransformViewCell
- (instancetype)initWithIndentifier:(NSString *)identifier{
    if (self = [super init]) {
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnView)];
        [self addGestureRecognizer:tap];
        self.transModel.identifier = identifier;
        [self addSubview:self.testLabel];
        
        UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake(20, 250, 60, 60)];
        button.backgroundColor = [UIColor redColor];
        [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
    return self;
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    self.testLabel.frame = CGRectMake(20, 0, 200, 200);
}
- (void)tapOnView{
    TransformView * transformView = (TransformView *)self.superview;
    if ([transformView.delegate respondsToSelector:@selector(transformView:didSelectedItemAtIndex:)]) {
        [transformView.delegate transformView:transformView didSelectedItemAtIndex:self.transModel.index];
    }
}

#pragma mark loadDData
- (void)setData:(id)data{
    _data = data;
    if ([_data isKindOfClass:[NSString class]]) {
        NSString * string = (NSString *)_data;
        
        self.testLabel.text = string;
    }
}

#pragma mark set get method
- (UILabel *)testLabel{
    if (_testLabel == nil) {
        _testLabel = [[UILabel alloc] init];
        _testLabel.numberOfLines = MAXFLOAT;
    }
    return _testLabel;
}
//测试 点击
- (void)buttonClick{
    NSLog(@"点击了额");
}

- (TransformModel *)transModel{
    if (_transModel == nil) {
        _transModel = [[TransformModel alloc] init];
        _transModel.index = 0;
        _transModel.beginAngle = 0;
        _transModel.transMakeZ = 0;
    }
    return _transModel;
}
@end
