//
//  SportLineView.h
//  BLECharts
//
//  Created by Eleven on 7/31/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN



typedef NS_ENUM(NSUInteger, ChartType) {
    /** 四边形*/
    QuadrilateralType = 1,
    /** 三角形 */
    TriangleType = 2
};

@interface SportLineView : UIView
// x轴值
@property (nonatomic, copy) NSArray *xValues;

// y轴值
@property (nonatomic, copy) NSArray *yValues;

// 绘图数组
@property (strong, nonatomic) NSMutableArray *pointArray;

// 是否显示方格
@property (nonatomic, assign) bool isShowLine;

// 初始化折线图所在视图
+ (instancetype)lineChartViewWithFrame:(CGRect)frame;
// 画图表
- (void)drawChartWithLineChart;

// 封闭图形类型
@property (nonatomic, assign) ChartType type;

// 即时更新折线图
- (void)exchangeLineAnyTime;

// 一类肌疲劳度
- (CGFloat)getFirstMuscleLevel;
// 二类肌疲劳度
- (CGFloat)getSecondMuscleLevel;

@end
NS_ASSUME_NONNULL_END
