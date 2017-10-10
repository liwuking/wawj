

#import "RemindCell.h"

@implementation RemindCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    
//    _cellBgView.layer.cornerRadius = 4;
//
//    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, SCREEN_WIDTH-20, _cellBgView.frame.size.height)];
//    _cellBgView.layer.masksToBounds = NO;
//    _cellBgView.layer.shadowColor = RGB_COLOR(220, 220, 200).CGColor;
//    _cellBgView.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
//    _cellBgView.layer.shadowOpacity = 0.5f;
//    _cellBgView.layer.shadowPath = shadowPath.CGPath;
//
    
}


- (IBAction)readAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableViewCell:AndIndexPath:)]) {
        [self.delegate tableViewCell:self AndIndexPath:self.cellIndexPath];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
