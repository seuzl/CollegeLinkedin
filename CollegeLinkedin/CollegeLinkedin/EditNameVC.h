//
//  EditNameVC.h
//  CollegeLinkedin
//
//  Created by 赵磊 on 15/12/26.
//  Copyright © 2015年 赵磊. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^GetNameBKT) (NSString *str);

@interface EditNameVC : UIViewController

@property(nonatomic,strong) GetNameBKT getNameBK;

@end
