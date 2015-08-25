//
//  OurMessageView.m
//  surespot
//
//  Created by Adam on 10/30/13.
//  Copyright (c) 2013 2fours. All rights reserved.
//

#import "MessageView.h"
#import "UIUtils.h"

@implementation MessageView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.bubbleView.layer.cornerRadius = 10;
    self.uiImageView.layer.cornerRadius = 10;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (highlighted) {
        [super setHighlighted:highlighted animated:animated];
        self.uiImageView.layer.contents = nil;
    }
    else {
        self.uiImageView.layer.contents = nil;
        [super setHighlighted:highlighted animated:animated];
    }
    
}
//
//-(void) setSelected:(BOOL)selected animated:(BOOL)animated
//{
//    [super setSelected:selected animated:animated];
//    self.uiImageView.layer.contents = nil;
//}
//
//-(void) layoutSubviews {
//    self.uiImageView.layer.contents = nil;
//    [self.uiImageView layoutSubviews];
//}

-(void) setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    self.uiImageView.layer.contents = nil;
}
@end

