//
//  Config.h
//  CollegeLinkedin
//
//  Created by 赵磊 on 15/12/24.
//  Copyright © 2015年 赵磊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Realm/Realm.h>

typedef void(^SuccessBlock)(id returnValue);
typedef void(^FailureBlock)(NSError *error);

@interface Config : NSObject

+(NSString *)getMainURL;
+(UIColor *)getBackgroundColor;
+(UIView *)getTableViewFooter;
+(CGFloat)getSectionHeaderHeight;
+(NSDictionary*)getInfoPlistDict;
+(UIImage*) handlePicture:(UIImage*) originPic toAimSise:(CGSize)aimSize isZipped:(BOOL)zipped;
+(UIColor *)getTintColor;
+(void)popAlertControllerWhenGobackWithRootVC:(UIViewController*)superVC;
+(UIViewController*)getVCFromSb:(NSString*)storyboardID;
+(NSArray*)getJsonArray:(NSString*)JsonFileName;
+(BOOL)validateString:(NSString*)string withRex:(NSString*)rex;

+(void)showProgressHUDwithStatus:(NSString*) status;
+(void)dismissHUD;
+(void)showSuccessHUDwithStatus:(NSString*) status;
+(void)showErrorHUDwithStatus:(NSString*) status;

@end
