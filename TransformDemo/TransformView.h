//
//  TransformView.h
//  TransformDemo
//
//  Created by apple on 2017/2/13.
//  Copyright © 2017年 Victor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransformViewCell.h"

@class TransformView;

@protocol TransformViewDelegate <NSObject>
//返回 行高
- (CGFloat)heightForTransformViewCell;
//点击回调 暂未实现
- (void)transformView:(nonnull TransformView *)transformView didSelectedItemAtIndex:(NSInteger )index;

@end
@protocol TransformViewDataSource <NSObject>

@required
//返回item总数
- (NSInteger)numberOfRows;
//返回TransformViewCell
- (nonnull TransformViewCell *)transformView:(nonnull TransformView *)transformView cellfForRowAtIndex:(NSInteger )index;

@end

@interface TransformView : UIView
@property (nonatomic, weak, nullable) id<TransformViewDelegate> delegate;
@property (nonatomic, weak, nullable) id<TransformViewDataSource> dataSouses;
//刷新
- (void)transformViewReloadData;
//获取重用cell
- (nullable TransformViewCell *)dequeueReusableTransformViewCellWithIdentifier:(nonnull NSString *)identifier;
@end
