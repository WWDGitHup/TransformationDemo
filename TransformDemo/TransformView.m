//
//  TransformView.m
//  TransformDemo
//
//  Created by apple on 2017/2/13.
//  Copyright © 2017年 Victor. All rights reserved.
//

#import "TransformView.h"
#import "TransformViewCell.h"
#import <FBRetainCycleDetector.h>
@interface TransformView ()
@property (nonatomic, strong) UIPanGestureRecognizer     *panGesture;
@property (nonatomic, strong) NSMutableDictionary        *dequeueReusableDictory;
//当前显示的 index
@property (nonatomic, assign) NSInteger                   currentShowIndex;
@property (nonatomic, assign) NSInteger                   allItemCount;
@end

@implementation TransformView

//开始倾斜按钮
#define BeginAngle M_PI / 4
//开始偏移量
#define BeginOffsetX 30 * [UIScreen mainScreen].bounds.size.width / 320
//缩小倍数
#define BeginScale  1
//完整滚动 所需要的偏移量
#define AllOffsetX ([UIScreen mainScreen].bounds.size.width / 2 - 30 * [UIScreen mainScreen].bounds.size.width / 320)
//Z轴初始偏移量
#define OffsetZ 80
#define TScreenWidth [UIScreen mainScreen].bounds.size.width
#define TScreenHeight [UIScreen mainScreen].bounds.size.height
#define BasicTag 100000

#pragma mark view life cycle
- (instancetype)init{
    if (self = [super init]) {
        [self addGestureRecognizer:self.panGesture];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}
- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
}
- (void)layoutSubviews{
    [super layoutSubviews];
}

#pragma mark datasources
- (void)transformViewReloadData{
    [self loadDataOnInit];
}
//首次加载 图片
- (void)loadDataOnInit{
    //获取有多少行
    self.allItemCount = [self.dataSouses numberOfRows];
    for (int i = 0; i < 3; i ++) {
        NSInteger indexShow = i;
        if (i == 0) {
            indexShow = self.allItemCount - 1;
        }
        TransformViewCell * cell = [self.dataSouses transformView:self cellfForRowAtIndex:indexShow];
        cell.transModel.index = indexShow;
        self.currentShowIndex = 0;
        if (cell == nil) {
            return ;
        }
        cell.tag = BasicTag + i + 4;
        [self addSubview:cell];
        cell.layer.anchorPoint = CGPointMake(0.5, 0.5);
        CGFloat cellHeight = TScreenHeight - 200;
        if ([self.delegate respondsToSelector:@selector(heightForTransformViewCell)]) {
            cellHeight = [self.delegate heightForTransformViewCell];
        }
        cell.bounds = CGRectMake(0, 0, TScreenWidth - BeginOffsetX * 2, cellHeight);
        cell.layer.position = self.center;
        cell.layer.shadowColor = [UIColor colorWithRed:183/255.0 green:183/255.0 blue:183/255.0 alpha:1.0].CGColor;
        cell.layer.shadowPath = [UIBezierPath bezierPathWithRect:cell.bounds].CGPath;
        cell.layer.shadowRadius = 2;
        cell.layer.shadowOffset = CGSizeMake(0, 2);
        cell.layer.shadowOpacity = 1.0;
        cell.backgroundColor = [UIColor whiteColor];
        if (i == 0) {
            //滑动 变换
            cell.transModel.transMakeZ = -OffsetZ;
            cell.transModel.beginAngle = BeginAngle;
            cell.transModel.beginOffsetX = BeginOffsetX;

        }else if(i == 1){
            cell.transModel.transMakeZ = 0;
            cell.transModel.beginAngle = 0;
            cell.transModel.beginOffsetX = TScreenWidth/2;
        }else if (i == 2){
            cell.transModel.transMakeZ = -OffsetZ;
            cell.transModel.beginAngle = - BeginAngle;
            cell.transModel.beginOffsetX = TScreenWidth - BeginOffsetX;
        }
        [self transFormViewChanged:cell beginAngle:cell.transModel.beginAngle beginOffsetX:cell.transModel.beginOffsetX transMakeZ:cell.transModel.transMakeZ];
    }
}

#pragma mark touch events
//手势移动方法
- (void)panGestureMoves:(UIPanGestureRecognizer *)panGesture{
    //滑动时 view改变
    [self transformChangedWhenTouchMoved:panGesture];
    [self addTransformViewCellWhenNeed:panGesture];
}
//对应做动画
- (void)transformChangedWhenTouchMoved:(UIPanGestureRecognizer *)panGesture{
    static CGFloat  beginX = 0;
    UIView *piece = panGesture.view;
    CGPoint locationInView = [panGesture locationInView:piece];
    if (panGesture.state == UIGestureRecognizerStateBegan){
        beginX = locationInView.x;
    }
    if (panGesture.state == UIGestureRecognizerStateBegan || panGesture.state == UIGestureRecognizerStateChanged){
        CGFloat distanceX = locationInView.x - beginX;
        // 获取完整一次滚动的比例
        CGFloat rateX = distanceX / AllOffsetX;
        //先偏移  偏移到 AllOffsetX  结束一次滚动
        NSArray * cellArray = [self obtainAllTransformViewCellInCurrentView];
        for (int i = 0; i < cellArray.count; i ++) {
            TransformViewCell * cell = cellArray[i];
            CGFloat beginAngle = -(cell.tag - 100005) * BeginAngle- BeginAngle * rateX;
            CGFloat beginOffsetX = distanceX -(cell.tag - 100005) * BeginOffsetX  + (cell.tag - 100004) * TScreenWidth / 2 ;
            CGFloat transMakeZ =(cell.tag - 100005) * OffsetZ  + OffsetZ * rateX;
            if (transMakeZ > 0) {
                transMakeZ = - transMakeZ;
            }
            [self transFormViewChanged:cell beginAngle:beginAngle beginOffsetX:beginOffsetX transMakeZ:transMakeZ];
        }
    }
}
//cell 仿射变换
- (void)transFormViewChanged:(TransformViewCell *)transformView beginAngle:(CGFloat)beginAngle beginOffsetX:(CGFloat)beginOffsetX transMakeZ:(CGFloat)transMakeZ{
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = - 1.0 / 500.0;
    transformView.center = CGPointMake(beginOffsetX , TScreenHeight / 2 - 50);
    CATransform3D transMake = CATransform3DMakeTranslation(0, 0, transMakeZ);
    transform = CATransform3DRotate(transform, beginAngle, 0, 1, 0);
    transformView.layer.transform = CATransform3DConcat(transMake, transform);
}
//动态添加删除cell
- (void)addTransformViewCellWhenNeed:(UIPanGestureRecognizer *)panGesture{
    //判断 左滑还是右滑 根据距离判断是否要创建新的cell
    static CGFloat  beginX = 0;
    UIView *piece = panGesture.view;
    CGPoint locationInView = [panGesture locationInView:piece];
    if (panGesture.state == UIGestureRecognizerStateBegan){
        beginX = locationInView.x;
    }
    CGFloat distanceX = locationInView.x - beginX;
    if (distanceX < 0) {
        //向左滑 ，，在右边添加
        TransformViewCell * rightCell = [[self obtainAllTransformViewCellInCurrentView] lastObject];
        if (rightCell.center.x < TScreenWidth - BeginOffsetX ) {
            NSInteger index = rightCell.transModel.index + 1;
            TransformViewCell * cell = [self creatTransformViewIndex:index];
            if (cell == nil) {
                return ;
            }
            cell.tag = rightCell.tag + 1;
            cell.transModel.transMakeZ = -OffsetZ*2;
            cell.transModel.beginAngle = - BeginAngle * 2;
            cell.transModel.beginOffsetX = -BeginOffsetX + TScreenWidth * 3/2;
            [self transFormViewChanged:cell beginAngle:cell.transModel.beginAngle beginOffsetX:cell.transModel.beginOffsetX transMakeZ:cell.transModel.transMakeZ];
            [self addSubview:cell];
        }
    }else{
        //向右滑。。。在左边添加
        TransformViewCell * leftCell = [[self obtainAllTransformViewCellInCurrentView] firstObject];
        //偏移量
        if (leftCell.center.x > BeginOffsetX) {
            NSInteger index = leftCell.transModel.index - 1;
            TransformViewCell * cell = [self creatTransformViewIndex:index];
            if (cell == nil) {
                return ;
            }
            cell.tag = leftCell.tag - 1;
            cell.transModel.transMakeZ = -OffsetZ*2;
            cell.transModel.beginAngle =  BeginAngle * 2;
            cell.transModel.beginOffsetX = BeginOffsetX - TScreenWidth/2;
            [self transFormViewChanged:cell beginAngle:cell.transModel.beginAngle beginOffsetX:cell.transModel.beginOffsetX transMakeZ:cell.transModel.transMakeZ];
            [self addSubview:cell];
        }
    }
    if (panGesture.state == UIGestureRecognizerStateEnded){
        [self resetView];
    }
    
}
//创建cell 并初始化赋值
- (TransformViewCell *)creatTransformViewIndex:(NSInteger )index{
    NSInteger indexNew = index;
    if (index < 0) {
        indexNew = self.allItemCount + index;
    }
    if (index > self.allItemCount - 1) {
        indexNew = index - self.allItemCount;
    }
    
    TransformViewCell * cell = [self.dataSouses transformView:self cellfForRowAtIndex:indexNew];
    if (cell == nil) {
        return nil;
    }
    cell.transModel.index = indexNew;
    cell.layer.anchorPoint = CGPointMake(0.5, 0.5);
    cell.bounds = CGRectMake(0, 0, TScreenWidth - BeginOffsetX * 2, TScreenHeight - 200);
    cell.layer.shadowColor = [UIColor colorWithRed:183/255.0 green:183/255.0 blue:183/255.0 alpha:1.0].CGColor;
    cell.layer.shadowPath = [UIBezierPath bezierPathWithRect:cell.bounds].CGPath;
    cell.layer.shadowRadius = 2;
    cell.layer.shadowOffset = CGSizeMake(0, 2);
    cell.layer.shadowOpacity = 1.0;
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}
//滑动结束时 重置cell
- (void)resetView{
    //归位
    UIView * leftView = nil;
    UIView * centerView = nil;
    UIView * rightView = nil;
    NSArray * array = [self obtainAllTransformViewCellInCurrentView];
    for (UIView * cell in array) {
        //确定中间的view
        if (cell.center.x >= TScreenWidth / 4 && cell.center.x <= TScreenWidth * 3 / 4) {
            centerView = cell;
            //确定当前是那个view
            self.currentShowIndex = self.currentShowIndex + (centerView.tag - 100005);
            NSInteger leftIndex = [array indexOfObject:cell];
            leftView = array[leftIndex - 1];
            rightView = array[leftIndex + 1];
            break;
        }
    }
    for (TransformViewCell * cell in array) {
        if (cell != leftView && cell != rightView && cell != centerView) {
            NSArray * unused = [self.dequeueReusableDictory objectForKey:cell.transModel.identifier];
            NSMutableArray * unuseMutableArray = nil;
            if (unused == nil) {
                unuseMutableArray = [[NSMutableArray alloc] init];
            }else{
                unuseMutableArray = [NSMutableArray arrayWithArray:unused];
            }
            [unuseMutableArray addObject:cell];
            [self.dequeueReusableDictory setObject:unuseMutableArray forKey:cell.transModel.identifier];
            [cell removeFromSuperview];
        }
    }
    leftView.tag = 100004;
    centerView.tag = 100005;
    rightView.tag = 100006;
    __block CATransform3D transformL = CATransform3DIdentity;
    transformL.m34 = - 1.0 / 500.0;
    __block CATransform3D transformC = CATransform3DIdentity;
    transformC.m34 = - 1.0 / 500.0;
    __block CATransform3D transformR = CATransform3DIdentity;
    transformR.m34 = - 1.0 / 500.0;
    [UIView animateWithDuration:0.35 animations:^{
        //滑动 变换
        leftView.center = CGPointMake(BeginOffsetX , TScreenHeight / 2 - 50);
        CATransform3D transMakeL = CATransform3DMakeTranslation(0, 0, -OffsetZ);
        transformL = CATransform3DRotate(transformL, BeginAngle, 0, 1, 0);
        leftView.layer.transform = CATransform3DConcat(transMakeL, transformL);
        
        centerView.center = CGPointMake(TScreenWidth/2 , TScreenHeight / 2 - 50);
        transformC = CATransform3DRotate(transformC, 0, 0, 1, 0);
        CATransform3D  transMakeC = CATransform3DMakeScale(1, 1, 1);
        centerView.layer.transform = CATransform3DConcat(transMakeC, transformC);
        
        rightView.center = CGPointMake(TScreenWidth - BeginOffsetX, TScreenHeight / 2 - 50);
        transformR = CATransform3DRotate(transformR, - BeginAngle, 0, 1, 0);
        CATransform3D transMakeR = CATransform3DMakeTranslation(0, 0, -OffsetZ);
        rightView.layer.transform = CATransform3DConcat(transMakeR, transformR);
        
    }];
    
}

//取出 view 上存放的 TransformViewCell 并按照从左到右的顺序排序
- (NSArray <TransformViewCell *> *)obtainAllTransformViewCellInCurrentView{
    NSMutableArray * array = [NSMutableArray array];
    for (UIView * view in self.subviews) {
        if ([view isKindOfClass:[TransformViewCell class]]) {
            [array addObject:view];
        }
    }
    if (array.count == 0) {
        return nil;
    }
    for (int i = 0; i < array.count - 1; i ++) {
        for (int j = 0; j < array.count - 1 - i; j ++) {
            UIView * viewA = array[j];
            UIView * viewB = array[j + 1];
            if (viewA.center.x > viewB.center.x) {
                [array exchangeObjectAtIndex:j withObjectAtIndex:j + 1];
            }
        }
    }
    return array;
}


#pragma mark dequeueReusableTransformViewCell 重用cell获取
- (TransformViewCell *)dequeueReusableTransformViewCellWithIdentifier:(NSString *)identifier{
    NSArray * sourceArray = [self.dequeueReusableDictory objectForKey:identifier];
    if (sourceArray == nil || sourceArray.count == 0) {
        return nil;
    }else{
        NSMutableArray * sourceMutable = [NSMutableArray arrayWithArray:sourceArray];
        TransformViewCell * cell = (TransformViewCell *)[sourceArray firstObject];
        [sourceMutable removeObjectAtIndex:0];
        [self.dequeueReusableDictory setObject:sourceMutable forKey:cell.transModel.identifier];
        return cell;
    }
}

#pragma mark set get meothod
- (UIPanGestureRecognizer *)panGesture{
    if (_panGesture == nil) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureMoves:)];
    }
    return _panGesture;
}
- (NSMutableDictionary *)dequeueReusableDictory
{
    if (_dequeueReusableDictory == nil) {
        _dequeueReusableDictory = [[NSMutableDictionary alloc] init];
    }
    return _dequeueReusableDictory;
}

@end
