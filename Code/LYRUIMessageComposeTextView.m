 //
//  UIMessageComposeTextView.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/31/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIMessageComposeTextView.h"
#import "LYRUIMediaAttachment.h"
#import "LYRUIConstants.h"
#import "LYRUIMessagingUtilities.h"

@interface LYRUIMessageComposeTextView () <UITextViewDelegate>

@property (nonatomic) CGFloat contentHeight;

@end

@implementation LYRUIMessageComposeTextView

NSString *const LYRUIPlaceHolderText = @"Enter Message";

- (id)init
{
    self = [super init];
    if (self) {
        
        self.textContainerInset = UIEdgeInsetsMake(6, 0, 8, 0);
        self.font = [UIFont systemFontOfSize:14];
        self.textColor = [UIColor lightGrayColor];
        self.allowsEditingTextAttributes = YES;
        self.dataDetectorTypes = UIDataDetectorTypeLink;
        [self layoutSubviews];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textViewBeganEditing)
                                                     name:UITextViewTextDidBeginEditingNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textViewDidChange)
                                                     name:UITextViewTextDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (CGSize)intrinsicContentSize
{
    CGFloat currentWidth = self.contentSize.width;
    CGFloat currentHeight = self.contentSize.height;
    CGSize contentSize;
    if (self.maxHeight + 12 > currentHeight) {
        contentSize = CGSizeMake(currentWidth, currentHeight);
    } else {
        contentSize = CGSizeMake(currentWidth, self.maxHeight + 12);
    }
    return contentSize;
}

- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated
{
    // Don't do anything here to prevent auto-scrolling.
}

- (void)insertImage:(UIImage *)image
{
    // Create a text attachement with the image
    LYRUIMediaAttachment *textAttachment = [[LYRUIMediaAttachment alloc] init];
    textAttachment.image = image;
    
    // Create a mutable attributed string with an attachment
    NSMutableAttributedString *attachmentString = [[NSMutableAttributedString attributedStringWithAttachment:textAttachment] mutableCopy];
    [attachmentString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(attachmentString.length, 0)];
    
    NSMutableAttributedString *mutableAttributedString;
    if ([self.text isEqualToString:LYRUIPlaceHolderText]) {
        mutableAttributedString = attachmentString;
    } else {
        mutableAttributedString = [self.attributedText mutableCopy];
        if (mutableAttributedString.length > 0) {
            [self insertLineBreak:mutableAttributedString];
        }
        [mutableAttributedString replaceCharactersInRange:NSMakeRange(mutableAttributedString.length, 0)
                                     withAttributedString:attachmentString];
    }
    self.attributedText = mutableAttributedString;
    
    [self layoutIfNeeded];
}

- (void)insertVideoAtPath:(NSString *)videoPath
{
    [self layoutIfNeeded];
}

- (void)insertLocation:(CLLocationCoordinate2D)location
{
    [self layoutIfNeeded];
}

- (void)removeAttachements
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.text attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]}];
    self.attributedText = attributedString;
    [self layoutIfNeeded];
}

- (void)insertLineBreak:(NSMutableAttributedString *)mutableAttributedString
{
    [mutableAttributedString insertAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\r\n"] atIndex:mutableAttributedString.length];
    [mutableAttributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, mutableAttributedString.length)];
}

- (BOOL)previousIndexIsAttachement
{
    if (!(self.attributedText.length > 0)) return FALSE;
    NSDictionary *theAttributes = [self.attributedText attributesAtIndex:self.attributedText.length - 1
                                                   longestEffectiveRange:nil
                                                                 inRange:NSMakeRange(0, self.attributedText.length)];
    NSTextAttachment *theAttachment = [theAttributes objectForKey:NSAttachmentAttributeName];
    if (theAttachment != NULL) {
        return TRUE;
    } else {
        return FALSE;
    }
}

- (void)displayPlaceHolderText:(BOOL)displayPlaceHolderText
{
    if ([self.text isEqualToString:LYRUIPlaceHolderText]) {
        if (displayPlaceHolderText) {
            self.text = @"Enter Message";
        } else {
            self.text = @"";
        }
    }
}

- (void)textViewBeganEditing
{
    [self displayPlaceHolderText:NO];
    if ([self previousIndexIsAttachement]) {
        NSMutableAttributedString *mutableAttributedString = [self.attributedText mutableCopy];
        [self insertLineBreak:mutableAttributedString];
        self.attributedText = mutableAttributedString;
        [self layoutIfNeeded];
        [self.delegate textViewDidChange:self];
    }
    self.textColor = [UIColor blackColor];
}

- (void)textViewDidChange
{
    self.font = [UIFont systemFontOfSize:14];
}

- (void)paste:(id)sender
{
    UIImage *image = [[UIPasteboard generalPasteboard] image];
    if (image) {
        [self insertImage:image];
        [self.delegate textViewDidChange:self];
    } else {
        [super paste:sender];
    }
}
@end
