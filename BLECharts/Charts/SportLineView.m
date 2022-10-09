//
//  SportLineView.m
//  BLECharts
//
//  Created by Eleven on 7/31/22.
//

#import "SportLineView.h"

static CGRect myFrame;
static int count;   // 点个数，x轴格子数
static int yCount;  // y轴格子数
static CGFloat everyX;  // x轴每个格子宽度
static CGFloat everyY;  // y轴每个格子高度
static CGFloat maxY;    // 最大的y值
static CGFloat allH;    // 整个图表高度
static CGFloat allW;    // 整个图表宽度
#define kMargin 30
#define SSColorA(r, g, b, a) [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:(a) / 100.0]  //RGB颜色

@interface SportLineView()
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (strong, nonatomic) NSMutableArray *xLabels;

@end

@implementation SportLineView

+ (instancetype)lineChartViewWithFrame:(CGRect)frame{
    SportLineView *lineChartView = [[NSBundle mainBundle] loadNibNamed:@"SportLineView" owner:self options:nil].lastObject;
    lineChartView.frame = frame;
    
    myFrame = frame;
    
    return lineChartView;
}

#pragma mark - 计算

- (void)doWithCalculate{
    if (!self.xValues || !self.xValues.count || !self.yValues || !self.yValues.count) {
        return;
    }
    // 移除多余的值，计算点个数
    if (self.xValues.count > self.yValues.count) {
        NSMutableArray * xArr = [self.xValues mutableCopy];
        for (int i = 0; i < self.xValues.count - self.yValues.count; i++){
            [xArr removeLastObject];
        }
        self.xValues = [xArr mutableCopy];
    }else if (self.xValues.count < self.yValues.count){
        NSMutableArray * yArr = [self.yValues mutableCopy];
        for (int i = 0; i < self.yValues.count - self.xValues.count; i++){
            [yArr removeLastObject];
        }
        self.yValues = [yArr mutableCopy];
    }
    
    count = (int)self.xValues.count;
    
    everyX = (CGFloat)(CGRectGetWidth(myFrame) - kMargin * 2) / count;
    
    // y轴最多分5部分
    yCount = count <= 10 ? count : 10;
    
    everyY =  (CGRectGetHeight(myFrame) - kMargin * 2) / yCount;
    
    maxY = CGFLOAT_MIN;
    for (int i = 0; i < count; i ++) {
        if ([self.yValues[i] floatValue] > maxY) {
            maxY = [self.yValues[i] floatValue];
        }
    }
    
    allH = CGRectGetHeight(myFrame) - kMargin * 2;
    allW = CGRectGetWidth(myFrame) - kMargin * 2;
}

#pragma mark - 画X、Y轴
- (void)drawXYLine{
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    [path moveToPoint:CGPointMake(kMargin, kMargin / 2.0 - 5)];
    
    [path addLineToPoint:CGPointMake(kMargin, CGRectGetHeight(myFrame) - kMargin)];
    [path addLineToPoint:CGPointMake(CGRectGetWidth(myFrame) - kMargin / 2.0 + 5, CGRectGetHeight(myFrame) - kMargin)];
    
    // 加箭头
    [path moveToPoint:CGPointMake(kMargin - 5, kMargin/ 2.0 + 4)];
    [path addLineToPoint:CGPointMake(kMargin, kMargin / 2.0 - 4)];
    [path addLineToPoint:CGPointMake(kMargin + 5, kMargin/ 2.0 + 4)];
    
    [path moveToPoint:CGPointMake(CGRectGetWidth(myFrame) - kMargin / 2.0 - 4, CGRectGetHeight(myFrame) - kMargin - 5)];
    [path addLineToPoint:CGPointMake(CGRectGetWidth(myFrame) - kMargin / 2.0 + 5, CGRectGetHeight(myFrame) - kMargin)];
    [path addLineToPoint:CGPointMake(CGRectGetWidth(myFrame) - kMargin / 2.0 - 4, CGRectGetHeight(myFrame) - kMargin + 5)];
    
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.path = path.CGPath;
    layer.strokeColor = [UIColor brownColor].CGColor;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.lineWidth = 2.0;
    
    [self.layer addSublayer:layer];
}

#pragma mark - 添加label
- (void)drawLabels{
    
    
    //Y轴
    for(int i = 0; i <= yCount; i ++){
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, kMargin  + everyY * i - everyY / 2, kMargin - 1, everyY)];
        lbl.textColor = [UIColor blackColor];
        lbl.font = [UIFont systemFontOfSize:10];
        lbl.textAlignment = NSTextAlignmentRight;
        
        lbl.text = [NSString stringWithFormat:@"%d%%", (int)(maxY / yCount * (yCount - i)) ];
        
        [self addSubview:lbl];
    }
    
    // X轴
    for(int i = 1; i <= count; i ++){
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(kMargin + everyX * i - everyX / 2, CGRectGetHeight(myFrame) - kMargin, everyX, kMargin)];
        
        lbl.textColor = [UIColor blackColor];
        lbl.font = [UIFont systemFontOfSize:12];
        lbl.textAlignment = NSTextAlignmentCenter;
        
        [self.xLabels addObject:lbl];
        // 如果起点不是0,计算横轴的坐标值
        NSValue *pointObj = [self.pointArray lastObject];
        CGPoint pointRestored = [pointObj CGPointValue];
        
        CGFloat maxX = pointRestored.x;
        int maxValueX = (int)maxX;
        CGFloat xfloat = maxX - maxValueX;
        if (xfloat > 0) {
            maxValueX += 1;
        }
        
        //        NSValue *firstPointObj = [self.pointArray firstObject];
        //        CGPoint firstPointRestored = [firstPointObj CGPointValue];
        
        if (maxValueX <= count) {
            lbl.text = [NSString stringWithFormat:@"%@", self.xValues[i - 1]];
        }else{
            lbl.text = [NSString stringWithFormat:@"%d", maxValueX - count + i];
        }
        
        [self addSubview:lbl];
    }
    
}

#pragma mark - 画网格
- (void)drawLines{
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    // 横线
    for (int i = 0; i < yCount; i ++) {
        [path moveToPoint:CGPointMake(kMargin , kMargin + everyY * i)];
        [path addLineToPoint:CGPointMake(kMargin + allW ,  kMargin + everyY * i)];
    }
    // 竖线
    for (int i = 1; i <= count; i ++) {
        [path moveToPoint:CGPointMake(kMargin + everyX * i, kMargin)];
        [path addLineToPoint:CGPointMake( kMargin + everyX * i,  kMargin + allH)];
    }
    
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.path = path.CGPath;
    layer.strokeColor = [UIColor lightGrayColor].CGColor;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.lineWidth = 0.5;
    [self.layer addSublayer:layer];
    
}

#pragma mark - 画折线\曲线
- (void)drawFoldLineWithLineChart{
    
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    NSValue *pointObj = [self.pointArray firstObject];
    CGPoint pointRestored = [pointObj CGPointValue];
    CGFloat xpoint = pointRestored.x;
    CGFloat ypoint = pointRestored.y;
    int maxValueX = count;
    
    CGFloat Xwidth = (CGFloat)(CGRectGetWidth(myFrame) - kMargin * 2);
    
    if (xpoint <= 0) {
        [path moveToPoint:CGPointMake(kMargin, kMargin + allH)];
    }else{
        // 如果起点不是0,计算横轴的坐标值
        
        NSValue *MaxpointObj = [self.pointArray lastObject];
        CGPoint MaxpointRestored = [MaxpointObj CGPointValue];
        
        CGFloat maxX = MaxpointRestored.x;
        maxValueX = (int)maxX;
        CGFloat xfloat = maxX - maxValueX;
        if (xfloat > 0) {
            maxValueX += 1;
        }
        
        if (maxValueX <= count) {
            [path moveToPoint:CGPointMake(kMargin + xpoint * Xwidth / count, kMargin + (1 - ypoint / maxY) * allH)];
            
        }else{
            for (int i = 1; i < self.pointArray.count; i ++) {
                NSValue *pointObj = self.pointArray[i];
                CGPoint pointRestored = [pointObj CGPointValue];
                
                
                if (pointRestored.x >= (maxValueX - count)) {
                    [path moveToPoint:CGPointMake(kMargin + (pointRestored.x - (maxValueX - count))* Xwidth / count, kMargin + (1 - pointRestored.y / maxY) * allH)];
                    i = (int)(self.pointArray.count + 1);
                    
                }
            }
        }
        
        
        
    }
    for (int i = 1; i < self.pointArray.count; i ++) {
        NSValue *pointObj = self.pointArray[i];
        CGPoint pointRestored = [pointObj CGPointValue];
        
        
        if (maxValueX <= count) {
            [path addLineToPoint:CGPointMake(kMargin + pointRestored.x* Xwidth / count, kMargin + (1 - pointRestored.y / maxY) * allH)];
        }else{
            if (pointRestored.x >= (maxValueX - count)) {
                [path addLineToPoint:CGPointMake(kMargin + (pointRestored.x - (maxValueX - count))* Xwidth / count, kMargin + (1 - pointRestored.y / maxY) * allH)];
            }
        }
    }
    
    if (self.pointArray.count == 0) {
        [path addLineToPoint:CGPointMake(kMargin, kMargin + allH)];
    }
    
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.path = path.CGPath;
    layer.strokeColor = [UIColor redColor].CGColor;
    layer.fillColor = [UIColor clearColor].CGColor;
    
    [self.bgView.layer addSublayer:layer];
    
}

#pragma mark - 整合 画图表
- (void)drawChartWithLineChart{
    
    // 计算赋值
    [self doWithCalculate];
    
    // 画网格线
    if (self.isShowLine) {
        [self drawLines];
    }
    
    // 画X、Y轴
    [self drawXYLine];
    
    // 添加文字
    [self drawLabels];
    
    // 画封闭图形
    if (self.type == QuadrilateralType) {
        NSMutableArray *points = [NSMutableArray array];
        CGPoint point1 = CGPointMake(1.5, 0);
        NSValue *pointObj1 = [NSValue valueWithCGPoint:point1];
        [points addObject:pointObj1];
        
        CGPoint point2 = CGPointMake(2, 45);
        NSValue *pointObj2 = [NSValue valueWithCGPoint:point2];
        [points addObject:pointObj2];
        
        CGPoint point3 = CGPointMake(8, 45);
        NSValue *pointObj3 = [NSValue valueWithCGPoint:point3];
        [points addObject:pointObj3];
        
        CGPoint point4 = CGPointMake(8.5, 0);
        NSValue *pointObj4 = [NSValue valueWithCGPoint:point4];
        [points addObject:pointObj4];
        
        [self drawClosedQuadrilateralChartWithArray:points];
    }else if(self.type == TriangleType){
        
        for (int i = 0; i < 5; i ++) {
            NSMutableArray *points = [NSMutableArray array];
            CGPoint point1 = CGPointMake(2 * (i+ 1), 0);
            NSValue *pointObj1 = [NSValue valueWithCGPoint:point1];
            [points addObject:pointObj1];
            
            CGPoint point2 = CGPointMake(2 * (i+ 1) + 0.5, 100);
            NSValue *pointObj2 = [NSValue valueWithCGPoint:point2];
            [points addObject:pointObj2];
            
            CGPoint point3 = CGPointMake(2 * (i+ 1) + 1, 0);
            NSValue *pointObj3 = [NSValue valueWithCGPoint:point3];
            [points addObject:pointObj3];
            [self drawClosedQuadrilateralChartWithArray:points];
        }
    }
    
    
    
}
// 更新折线图, X轴坐标
- (void)exchangeLineAnyTime{
    // 计算赋值
    [self doWithCalculate];
    
    NSArray *layers = [self.bgView.layer.sublayers mutableCopy];
    
    for (CAShapeLayer *layer in layers) {
        [layer removeFromSuperlayer];
    }
    // 画折线
    [self drawFoldLineWithLineChart];
    
    [self exchangeXlabels];
}
- (void)exchangeXlabels{
    NSValue *pointObj = [self.pointArray lastObject];
    CGPoint pointRestored = [pointObj CGPointValue];
    
    CGFloat maxX = pointRestored.x;
    int maxValueX = (int)maxX;
    CGFloat xfloat = maxX - maxValueX;
    if (xfloat > 0) {
        maxValueX += 1;
    }
    
    if (maxValueX > count) {
        for (int i = 0; i < self.xLabels.count; i ++) {
            UILabel *label = self.xLabels[i];
            label.text = [NSString stringWithFormat:@"%d", maxValueX - count + i + 1];
        }
    }
    
}

// 封闭图形
- (void)drawClosedQuadrilateralChartWithArray:(NSArray *)points{
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat Xwidth = (CGFloat)(CGRectGetWidth(myFrame) - kMargin * 2);
    
    for (int i = 0; i < points.count; i ++) {
        NSValue *pointObj = points[i];
        CGPoint pointRestored = [pointObj CGPointValue];
        if (i == 0) {
            [path moveToPoint:CGPointMake(kMargin + pointRestored.x * Xwidth / count, kMargin + (1 - pointRestored.y / maxY) * allH)];
        }else{
            [path addLineToPoint:CGPointMake(kMargin + pointRestored.x * Xwidth / count, kMargin + (1 - pointRestored.y / maxY) * allH)];
        }
    }
    
    [path closePath];
    
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.path = path.CGPath;
    layer.strokeColor = [UIColor lightGrayColor].CGColor;
    layer.fillColor = SSColorA(255, 255, 155, 100.0).CGColor;
    
    [self.layer addSublayer:layer];
    
}
#pragma mark -- 一类肌疲劳度
- (CGFloat)getFirstMuscleLevel{
    
    CGPoint startPoint = [self exchangeXYValuePoint:CGPointMake(2, 40)];
    CGPoint endPoint = [self exchangeXYValuePoint:CGPointMake(7, 40)];
    
    CGFloat totalArea = (endPoint.x - startPoint.x) * endPoint.y;
    
    CGFloat trapezoidal = 0;
    for (int i = 0; i < self.pointArray.count; i ++) {
        NSValue *pointObj = self.pointArray[i];
        CGPoint pointRestored = [pointObj CGPointValue];
        
        
        if (pointRestored.x >= 2 && pointRestored.x <= 7) {
            
            NSValue *pointObj2 = self.pointArray[i + 1];
            CGPoint pointRestored2 = [pointObj2 CGPointValue];
            
            CGPoint point1 = pointRestored;
            CGPoint point2 = pointRestored2;
            
            CGFloat area = [self getTrapezoidalAreaWithPoint1:point1 poit2:point2];
            trapezoidal += area;
        }
    }
    
    // 计算肌力疲劳度
    
    CGFloat level = trapezoidal / totalArea;
    
    return level;
}
#pragma mark -- 二类肌疲劳度
- (CGFloat)getSecondMuscleLevel{
    CGPoint startPoint = [self exchangeXYValuePoint:CGPointMake(2, 0)];
    CGPoint endPoint = [self exchangeXYValuePoint:CGPointMake(3, 0)];
    CGPoint topPoint = [self exchangeXYValuePoint:CGPointMake(2.5, 100)];
    
    CGFloat triangle = (endPoint.x - startPoint.x) * topPoint.y * 0.5;
    CGFloat totalArea = 5 * triangle;
    
    CGFloat trapezoidal = 0;
    
    for (int i = 0; i < self.pointArray.count; i ++) {
        NSValue *pointObj = self.pointArray[i];
        CGPoint pointRestored = [pointObj CGPointValue];
        
        if (pointRestored.x >= 2 && pointRestored.x <= 3) {
            
            NSValue *pointObj2 = self.pointArray[i + 1];
            CGPoint pointRestored2 = [pointObj2 CGPointValue];
            
            CGPoint point1 = pointRestored;
            CGPoint point2 = pointRestored2;
            
            CGFloat area = [self getTrapezoidalAreaWithPoint1:point1 poit2:point2];
            trapezoidal += area;
            
        }else if (pointRestored.x >= 4 && pointRestored.x <= 5){
            NSValue *pointObj2 = self.pointArray[i + 1];
            CGPoint pointRestored2 = [pointObj2 CGPointValue];
            
            CGPoint point1 = pointRestored;
            CGPoint point2 = pointRestored2;
            
            CGFloat area = [self getTrapezoidalAreaWithPoint1:point1 poit2:point2];
            trapezoidal += area;
        }else if (pointRestored.x >= 6 && pointRestored.x <= 7){
            NSValue *pointObj2 = self.pointArray[i + 1];
            CGPoint pointRestored2 = [pointObj2 CGPointValue];
            
            CGPoint point1 = pointRestored;
            CGPoint point2 = pointRestored2;
            
            CGFloat area = [self getTrapezoidalAreaWithPoint1:point1 poit2:point2];
            trapezoidal += area;
        }else if (pointRestored.x >= 8 && pointRestored.x <= 9){
            NSValue *pointObj2 = self.pointArray[i + 1];
            CGPoint pointRestored2 = [pointObj2 CGPointValue];
            
            CGPoint point1 = pointRestored;
            CGPoint point2 = pointRestored2;
            
            CGFloat area = [self getTrapezoidalAreaWithPoint1:point1 poit2:point2];
            trapezoidal += area;
        }else if (pointRestored.x >= 10 && pointRestored.x <= 11){
            NSValue *pointObj2 = self.pointArray[i + 1];
            CGPoint pointRestored2 = [pointObj2 CGPointValue];
            
            CGPoint point1 = pointRestored;
            CGPoint point2 = pointRestored2;
            
            CGFloat area = [self getTrapezoidalAreaWithPoint1:point1 poit2:point2];
            trapezoidal += area;
        }
    }
    // 计算肌力疲劳度
    
    CGFloat level = trapezoidal / totalArea;
    
    return level;
}

// 计算两坐标点之间的梯形面积
- (CGFloat)getTrapezoidalAreaWithPoint1:(CGPoint)point1 poit2:(CGPoint)point2{
    
    CGPoint expoint1 = [self exchangeXYValuePoint:point1];
    CGPoint expoint2 = [self exchangeXYValuePoint:point2];
    
    CGFloat expoint1X = expoint1.x;
    CGFloat expoint1y = expoint1.y;
    
    CGFloat expoint2X = expoint2.x;
    CGFloat expoint2y = expoint2.y;
    
    CGFloat area = (expoint1y + expoint2y) * (expoint2X - expoint1X) * 0.5;
    
    return area;
}
// 根据一个点转换坐标值
- (CGPoint)exchangeXYValuePoint:(CGPoint)point{
    
    CGFloat Xwidth = (CGFloat)(CGRectGetWidth(myFrame) - kMargin * 2);
    
    CGPoint zeroPoint;
    zeroPoint.x = kMargin + 0 * Xwidth / count;
    zeroPoint.y =  kMargin + (1 - 0 / maxY) * allH;
    
    CGPoint linePoint;
    linePoint.x = kMargin + point.x * Xwidth / count - zeroPoint.x;
    linePoint.y = zeroPoint.y - ( kMargin + (1 - point.y / maxY) * allH );
    return linePoint;
}
#pragma mark -- 懒加载
- (NSMutableArray *)pointArray{
    if (!_pointArray) {
        _pointArray = [NSMutableArray array];
    }
    return _pointArray;
}
- (NSMutableArray *)xLabels{
    if (!_xLabels) {
        _xLabels = [NSMutableArray array];
    }
    return _xLabels;
}

@end
