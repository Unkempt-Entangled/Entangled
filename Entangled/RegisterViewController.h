//
//  ViewController.h
//  Entangled
//
//  Created by Matthew Taylor on 3/14/15.
//  Copyright (c) 2015 Unkempt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *registerName;
@property (weak, nonatomic) IBOutlet UITextField *registerCode;
@property (weak, nonatomic) IBOutlet UILabel *registerFieldsRequired;

@end

