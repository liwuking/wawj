
#import <UIKit/UIKit.h>
@interface SpeakingView : UIView
{
    IBOutlet UIView         *_bgView;
    IBOutlet UIImageView    *_volumeImageView;
    NSTimer                 *_timer;
}

@property (strong, nonatomic) IBOutlet UILabel *statusLabel;

- (void)endSpeak;
- (void)cannelSpeak;
- (void)startAction;

@end

