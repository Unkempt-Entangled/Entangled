//
//  PhotoViewController.h
//  Entangled
//
//  Created by Tim Mickel on 3/18/15.
//  Copyright (c) 2015 Unkempt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *captionField;
@property (weak, nonatomic) IBOutlet UILabel *captionRequiredLabel;
@property (weak, nonatomic) IBOutlet UILabel *photoSuccess;

@end

