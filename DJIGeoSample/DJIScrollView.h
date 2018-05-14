//
//  DJIScrollView.h
//  DJISdkDemo
//
//  Created by DJI on 16/2/29.
//  Copyright © 2016年 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DJIScrollView : UIView

@property(nonatomic, assign) float fontSize;

@property(nonatomic, strong) NSString* title;

-(void) writeStatus:(NSString*)status;

-(void) show;

-(void)setDefaultSize; 

+(instancetype)viewWithViewController:(UIViewController *)viewController;

@end
