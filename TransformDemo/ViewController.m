//
//  ViewController.m
//  TransformDemo
//
//  Created by apple on 2017/2/13.
//  Copyright © 2017年 Victor. All rights reserved.
//

#import "ViewController.h"
#import "UIImageView+WebCache.h"
#import "TransformView.h"


@interface ViewController ()<TransformViewDelegate,TransformViewDataSource>
@property (nonatomic, strong) NSArray             *dataArray;
@property (nonatomic, strong) TransformView           * transView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _dataArray = [NSArray arrayWithObjects:@"test ios6之后API发生了变化，ios6之前完全不用写，ios6之后根据情况,registerClass是和cell联系在一起的 ,UITableViewCell或UICollectionViewCell", @"当你改变CALayer的一个可做动画的属性，它并不能立刻在屏幕上体现出来。相反，它是从先前的值平滑过渡到新的值。这一切都是默认的行为，你不需要做额外的操作。",@"这看起来这太棒了，似乎不太真实，我们来用一个demo解释一下：首先和第一章“图层树”一样创建一个蓝色的方块，然后添加一个按钮，随机改变它的颜色。代码见清单7.1。点击按钮，你会发现图层的颜色平滑过渡到一个新值，而不是跳变（图7.1）",@"这其实就是所谓的隐式动画。之所以叫隐式是因为我们并没有指定任何动画的类型。我们仅仅改变了一个属性，然后Core Animation来决定如何并且何时去做动画。Core Animaiton同样支持显式动画，下章详细说明",@"但当你改变一个属性，Core Animation是如何判断动画类型和持续时间的呢？实际上动画执行的时间取决于当前事务的设置，动画类型取决于图层行为。",@"事务实际上是Core Animation用来包含一系列属性动画集合的机制，任何用指定事务去改变可以做动画的图层属性都不会立刻发生变化，而是当事务一旦提交的时候开始用一个动画过渡到新值。",@"事务是通过CATransaction类来做管理，这个类的设计有些奇怪，不像你从它的命名预期的那样去管理一个简单的事务，而是管理了一叠你不能访问的事务。CATransaction没有属性或者实例方法，并且也不能用+alloc和-init方法创建它。但是可以用+begin和+commit分别来入栈或者出栈",@"任何可以做动画的图层属性都会被添加到栈顶的事务，你可以通过+setAnimationDuration:方法设置当前事务的动画时间，或者通过+animationDuration方法来获取值（默认0.25秒）",@"test ios6之后API发生了变化，ios6之前完全不用写，ios6之后根据情况,registerClass是和cell联系在一起的 ,UITableViewCell或UICollectionViewCell",@"的+setAnimationDuration:方法来修改动画时间，但在这里我们首先起一个新的事务，于是修改时间就不会有别的副作用。因为修改当前事务的时间可能会导致同一时刻别的动画（如屏幕旋转），所以最好还是在调整动画之前压入一个新的事务",@"明白这些之后，我们就可以轻松修改变色动画的时间了。我们当然可以用当前事务",@"Core Animation在每个run loop周期中自动开始一次新的事务（run loop是iOS负责收集用户输入，处理定时器或者网络事件并且重新绘制屏幕的东西），即使你不显式的用[CATransaction begin]开始一次事务，任何在一次run loop循环中属性的改变都会被集中起来，然后做一次0.25秒的动画",nil];
    [self.view addSubview:self.transView];
    [self.transView transformViewReloadData];
    
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.transView.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64);
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark TransformViewDataSource

- (NSInteger )numberOfRows{
    return _dataArray.count;
}

- (TransformViewCell *)transformView:(TransformView *)transformView cellfForRowAtIndex:(NSInteger)index{
    NSLog(@"----  %ld",(long)index);
    TransformViewCell * cell = [transformView dequeueReusableTransformViewCellWithIdentifier:@"TransformViewCell"];
    if (cell == nil) {
        cell = [[TransformViewCell alloc] initWithIndentifier:@"TransformViewCell"];
    }
    cell.data = self.dataArray[index];
    return cell;
}

- (void)transformView:(TransformView *)transformView didSelectedItemAtIndex:(NSInteger)index{
    NSLog(@"%ld",(long)index);
}

- (CGFloat)heightForTransformViewCell{
    return [UIScreen mainScreen].bounds.size.height - 200;
}


#pragma mark touch events
- (IBAction)transformClick:(id)sender {

}

#pragma mark set get method


- (TransformView *)transView{
    if (_transView == nil) {
        _transView = [[TransformView alloc] init];
        _transView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
        _transView.dataSouses = self;
        _transView.delegate = self;
    }
    return _transView;
}

@end
