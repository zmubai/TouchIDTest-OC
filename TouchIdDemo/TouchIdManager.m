//
//  TouchIdManager.m
//  TouchIdDemo
//
//  Created by zmubai on 2018/5/9.
//  Copyright © 2018年 zmubai. All rights reserved.
//

#import "TouchIdManager.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "SAMKeychain.h"

static NSString *const TOUCH_ID_DATA_SERVICE = @"TOUCH_ID_DATA_SERVICE";

static NSString *CURRENT_TOUCH_ID_IDENTITY = nil;

static NSString *const CURRENT_TOUCH_ID_IDENTITY_PERFIX = @"TOUCH_ID@";

@implementation TouchIdManager

#pragma mark - open
//设置当前touchId的身份 切换身份的时候需要调用此方法
+ (void)setCurrentTouchIdDataIdentity:(NSString *)identity
{
    CURRENT_TOUCH_ID_IDENTITY = identity;
}

+ (NSString*)currentTouchIdDataIdentity
{
    return CURRENT_TOUCH_ID_IDENTITY;
}

+ (BOOL)setCurrentIdentityTouchIdData
{
    if (CURRENT_TOUCH_ID_IDENTITY == nil) {
        NSLog(@"[touchId]:currentIdentity not set");
        return NO;
    }
    else
    {
        return [self setCurrentIdentityTouchIdData:[self currentOriTouchIdData]];
    }
}

+ (BOOL)touchIdInfoDidChange
{
    NSData *data = [self currentTouchIdDataForCompare];
    if (!data && [self isErrorTouchIDLockout]) {
        //输入次数过多被锁定，此时指纹并没有变更
        return NO;
    }
    NSData *oldData = [self currentIdentityTouchIdData];
    if (oldData == nil) {
        //应用内该账号未设置过指纹
        return NO;
    }
    else if ([oldData isEqual:data]) {
        //没有变化
        return NO;
    }
    else
    {
        //指纹信息发生变化
        return YES;
    }
}

+ (void)showTouchIdWithTitle:(NSString *)title falldBackTitle:(NSString *)falllBackTitle fallBackBlock:(TouchIdFallBackBlock)fallBackBlock resultBlock:(TouchIdResultBlock)resultBlock
{
    //初始化上下文对象
    LAContext *context = [[LAContext alloc] init];
    context.localizedFallbackTitle = falllBackTitle;
    //错误对象
    NSError* error = nil;
    NSString* result = title;
    //首先使用canEvaluatePolicy 判断设备支持状态
    if ([context canEvaluatePolicy:kLAPolicyDeviceOwnerAuthenticationWithBiometrics
                             error:&error]) {
        [context evaluatePolicy:kLAPolicyDeviceOwnerAuthenticationWithBiometrics
                localizedReason:result reply:^(BOOL success, NSError * _Nullable error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (success) {
                            !resultBlock ?: resultBlock(YES, YES,nil);
                        } else {
                            if (error.code == LAErrorTouchIDLockout) {
                                [self tryShowTouchIdOrPwdInterface:title resultBlock:resultBlock];
                            }
                            else if (error.code == LAErrorUserFallback)
                            {
                                if (fallBackBlock) {
                                    fallBackBlock();
                                }
                            }
                            else
                            {
                                !resultBlock ?: resultBlock(YES, NO, error);
                            }
                        }
                    });
                }];
    } else {
        if (error.code == LAErrorTouchIDLockout) {
            [self tryShowTouchIdOrPwdInterface:title resultBlock:resultBlock];
        }
        else
        {
            !resultBlock ?: resultBlock(NO, NO,error);
        }
    }
}

+ (void)tryShowTouchIdOrPwdInterface:(NSString *)title resultBlock:(TouchIdResultBlock)resultBlock
{
    //初始化上下文对象
    LAContext *context = [[LAContext alloc] init];
    context.localizedFallbackTitle = @"";//不显示falldBack 按钮
    //错误对象
    NSError* error = nil;
    NSString* result = title;
    //使用kLAPolicyDeviceOwnerAuthentication才能弹出密码解锁界面
    if ([context canEvaluatePolicy:kLAPolicyDeviceOwnerAuthentication
                             error:&error]) {
        [context evaluatePolicy:kLAPolicyDeviceOwnerAuthentication
                localizedReason:result reply:^(BOOL success, NSError * _Nullable error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        !resultBlock ?: resultBlock(YES, success,error);
                    });
                }];
    } else {
        !resultBlock ?: resultBlock(NO, NO,error);
    }
}

#pragma mark - currentTouchIdData
+ (NSString*)accountForKeychainWithIdentify
{
    if ([self currentTouchIdDataIdentity]) {
        return [CURRENT_TOUCH_ID_IDENTITY_PERFIX stringByAppendingString:[self currentTouchIdDataIdentity]];
    }
    else
    {
        return nil;
    }
}
+ (NSData*)currentTouchIdDataForCompare
{
    return  [self currentOriTouchIdData];
}

+ (NSData*)currentOriTouchIdData
{
    //实测不同app返回的值不一样,这个不能做担保。
    LAContext *context = [[LAContext alloc] init];
    NSError *error;
    if (![context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        NSLog(@"error:%@",error);
    }
    return context.evaluatedPolicyDomainState;
}

#pragma mark - identityTouchData
+ (NSData*)currentIdentityTouchIdData
{
    if ([self accountForKeychainWithIdentify]) {
        return [SAMKeychain passwordDataForService:TOUCH_ID_DATA_SERVICE account:[self accountForKeychainWithIdentify]];
    }
    else
    {
        return nil;
    }
}

+ (BOOL)setCurrentIdentityTouchIdData:(NSData *)data
{
    if ([self accountForKeychainWithIdentify]) {
        NSError *error;
        [SAMKeychain setPasswordData:data forService:TOUCH_ID_DATA_SERVICE account:[self accountForKeychainWithIdentify] error:&error];
        if (!error) {
            return YES;
        }
        else
        {
            return NO;
        }
    }
    else
    {
        return NO;
    }
    
}

#pragma mark -
+ (BOOL)isErrorTouchIDLockout
{
    LAContext *context = [[LAContext alloc] init];
    NSError *error;
    [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
    return error.code == kLAErrorTouchIDLockout ? YES : NO;
}

@end
