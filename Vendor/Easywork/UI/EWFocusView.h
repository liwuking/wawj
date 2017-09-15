

#import <UIKit/UIKit.h>
@protocol EWFocusViewDataSource;
@protocol EWFocusViewDelegate;

@interface EWFocusView : UIView

@property (nonatomic, assign) NSTimeInterval timeInterval;
@property (nonatomic, assign) id<EWFocusViewDelegate>delegate;
@property (nonatomic, assign) id<EWFocusViewDataSource>dataSource;


- (id)initWithFrame:(CGRect)frame showPageIndicator:(BOOL)show;

- (void)hideTitleBar;
- (void)showTitleBar;

- (void)reloadData;
- (void)startAutoRun;
- (void)stopAutoRun;

@end


@protocol EWFocusViewDataSource <NSObject>

@required

- (NSInteger)numberOfPages:(EWFocusView *)focusView;
- (UIView *)focusView:(EWFocusView *)focusView pageAtIndex:(NSInteger)index;
- (NSString *)focusView:(EWFocusView *)focusView titleForPageAtIndex:(NSInteger)index;

@end

@protocol EWFocusViewDelegate <NSObject>

@required

- (void)focusView:(EWFocusView *)focusView didSelectAtIndex:(NSInteger)index;

@end
