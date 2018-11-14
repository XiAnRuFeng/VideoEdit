//
//  XNGVideoClipView.m
//  VideoEditDemo
//
//  Created by 吴吟迪 on 2018/11/12.
//  Copyright © 2018 吴吟迪. All rights reserved.
//

#import "XNGVideoClipView.h"
#import "XNGVideoClipViewCell.h"

#define cellId   @"XNGVideoClipViewCellId"

@interface XNGVideoClipView ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

// 边框布局控件
@property (weak, nonatomic) IBOutlet UIView *topLineView;
@property (weak, nonatomic) IBOutlet UIView *bottomLineView;
@property (weak, nonatomic) IBOutlet UIView *leftLineView;
@property (weak, nonatomic) IBOutlet UIView *rightLineView;
// 时间显示控件
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;
// collectionView 相关
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray<UIImage *> * imageSource;

@property (nonatomic, strong) NSTimer * timer;

@end

@implementation XNGVideoClipView

#pragma mark Lift-Cycle
- (instancetype)initWithFrame:(CGRect)frame imageSource:(NSArray *)images {
    self = [super initWithFrame:frame];
    if (self) {
        self = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil][0];
        self.frame = frame;
        self.imageSource = [NSMutableArray<UIImage *> array];
        [self sliderInitialStatus];
        [self collectionViewConfig];
        [self layoutLineView];
    }
    return self;
}

#pragma mark Private-Method

- (void)beginTimerAction {
    self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(settingSliderPosition:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    [self.timer fire];
}

- (void)endTimerAction {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)settingSliderPosition:(NSTimer *)timer {
    CGFloat increment = (KScreenWidth-26)/30;
    self.sliderLeftConstraint.constant += increment;
    if (self.sliderLeftConstraint.constant >= (KScreenWidth-26)) {
        [self sliderInitialStatus];
    }
}

- (void)sliderInitialStatus {
    self.sliderLeftConstraint.constant = 0;
}

- (void)setModel:(NSMutableArray<UIImage *> *)imageSources {
    self.imageSource = imageSources;
    [self.collectionView reloadData];
}

- (void)settingBegin:(NSTimeInterval)begin {

    if (begin <= 0) {
        begin = 0;
    }
    
    self.startTimeLabel.text = [self convertTime:begin];
    self.endTimeLabel.text = [self convertTime:begin+30.f];
}

#pragma mark >>> 时间戳转换
- (NSString *)convertTime:(CGFloat)second{
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (second/3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [formatter stringFromDate:d];
    return showtimeNew;
}

/**
 collectionView 基本配置
 */
- (void)collectionViewConfig {
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    // 注册cell
    [_collectionView registerClass:[XNGVideoClipViewCell class] forCellWithReuseIdentifier:cellId];
}

/**
 画出边框的样式
 */
- (void)layoutLineView {
    //设置切哪个直角
    /**
     *  UIRectCornerTopLeft     = 1 << 0,  左上角
     *  UIRectCornerTopRight    = 1 << 1,  右上角
     *  UIRectCornerBottomLeft  = 1 << 2,  左下角
     *  UIRectCornerBottomRight = 1 << 3,  右下角
     *  UIRectCornerAllCorners  = ~0UL     全部角
     */
    //得到view的遮罩路径
    UIBezierPath * topMaskPath = [UIBezierPath bezierPathWithRoundedRect:self.topLineView.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(3, 3)];
    UIBezierPath * bottomMaskPath = [UIBezierPath bezierPathWithRoundedRect:self.bottomLineView.bounds byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight cornerRadii:CGSizeMake(3, 3)];
    UIBezierPath * leftMaskPath = [UIBezierPath bezierPathWithRoundedRect:self.leftLineView.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft cornerRadii:CGSizeMake(3, 3)];
    UIBezierPath * rightMaskPath = [UIBezierPath bezierPathWithRoundedRect:self.rightLineView.bounds byRoundingCorners:UIRectCornerTopRight|UIRectCornerBottomRight cornerRadii:CGSizeMake(3, 3)];
    //创建 layer
    CAShapeLayer * topMaskLayer = [[CAShapeLayer alloc] init];
    topMaskLayer.frame = self.topLineView.bounds;
    CAShapeLayer * bottomMaskLayer = [[CAShapeLayer alloc] init];
    bottomMaskLayer.frame = self.bottomLineView.bounds;
    CAShapeLayer * leftMaskLayer = [[CAShapeLayer alloc] init];
    leftMaskLayer.frame = self.leftLineView.bounds;
    CAShapeLayer * rightMaskLayer = [[CAShapeLayer alloc] init];
    rightMaskLayer.frame = self.rightLineView.bounds;
    //赋值
    topMaskLayer.path = topMaskPath.CGPath;
    self.topLineView.layer.mask = topMaskLayer;
    bottomMaskLayer.path = bottomMaskPath.CGPath;
    self.bottomLineView.layer.mask = bottomMaskLayer;
    leftMaskLayer.path = leftMaskPath.CGPath;
    self.leftLineView.layer.mask = leftMaskLayer;
    rightMaskLayer.path = rightMaskPath.CGPath;
    self.rightLineView.layer.mask = rightMaskLayer;
}

#pragma mark ========= UICollectionViewDataSource =========
// 指定Section个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

// 指定section中的collectionViewCell的个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageSource.count;
}

// 配置section中的collectionViewCell的显示
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    XNGVideoClipViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];

    cell.imageView.image = self.imageSource[indexPath.row];

    return cell;
}

#pragma mark ========= UICollectionViewDelegateFlowLayout =========

//每个cell的大小，因为有indexPath，所以可以判断哪一组，或者哪一个item，可一个给特定的大小，等同于layout的itemSize属性
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((KScreenWidth-26)/10, 60); // 宽度不确定需要确定30面显示多少张图片，再用屏幕宽度减去20除以图片张数就是图片的宽度
}

// 设置整个组的缩进量是多少
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

// 设置最小行间距，也就是前一行与后一行的中间最小间隔
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.1f;
}

// 设置最小列间距，也就是左行与右一行的中间最小间隔
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.1f;
}

#pragma mark ========= UICollectionViewDelegate =========

// 选中操作
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];

}

#pragma mark ========= UIScrollViewDelegate =========

// 当开始滚动视图时，执行该方法。一次有效滑动（开始滑动，滑动一小段距离，只要手指不松开，只算一次滑动），只执行一次。
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    NSLog(@"scrollViewWillBeginDragging");
    [self sliderInitialStatus];
}

//scrollView滚动时，就调用该方法。任何offset值改变都调用该方法。即滚动过程中，调用多次
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoClipViewDidScroll:contentOffsetX:)]) {
        [self.delegate videoClipViewDidScroll:self contentOffsetX:scrollView.contentOffset.x];
    }
}

// 滑动scrollView，并且手指离开时执行。一次有效滑动，只执行一次。
// 当pagingEnabled属性为YES时，不调用，该方法
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    NSLog(@"scrollViewWillEndDragging");
    
}

// 阻止scrollview的惯性滑动、 要在主线程执行，才有效果
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoClipViewDidEndDragging:contentOffsetX:)]) {
        [self.delegate videoClipViewDidEndDragging:self contentOffsetX:scrollView.contentOffset.x];
    }
}

@end