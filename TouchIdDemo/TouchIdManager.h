//
//  TouchIdManager.h
//  TouchIdDemo
//
//  Created by zmubai on 2018/5/9.
//  Copyright © 2018年 zmubai. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^TouchIdFallBackBlock)(void);
typedef void(^TouchIdResultBlock)(BOOL useable, BOOL success, NSError *error);

@interface TouchIdManager : NSObject

/**
 设置当前身份用于绑定touchIdData的操作

 @param identity <#identity description#>
 */
+ (void)setCurrentTouchIdDataIdentity:(NSString *)identity;


/**
 获取当前touchIdData绑定的身份

 @return <#return value description#>
 */
+ (NSString*)currentTouchIdDataIdentity;


/**
 为当前身份绑定touchIdData，需先调用setCurrentTouchIdDataIdentity绑定身份

 @return <#return value description#>
 */
+ (BOOL)setCurrentIdentityTouchIdData;


/**
 检测当前身份的touchId信息是否变更，需先设置setCurrentTouchIdDataIdentity绑定身份

 @return <#return value description#>
 */
+ (BOOL)touchIdInfoDidChange;


/**
 显示指纹解锁

 @param title 指纹解锁副标题
 @param falllBackTitle fallBack标题
 @param fallBackBlock fallBack回调
 @param resultBlock 解锁回调
 */
+ (void)showTouchIdWithTitle:(NSString *)title falldBackTitle:(NSString *)falllBackTitle fallBackBlock:(TouchIdFallBackBlock)fallBackBlock resultBlock:(TouchIdResultBlock)resultBlock;

@end
