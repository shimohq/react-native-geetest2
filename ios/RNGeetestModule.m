#import "RNGeetestModule.h"
#import <GTFramework/GTFramework.h>
#import <React/RCTConvert.h>
#import <React/RCTEventDispatcher.h>

@implementation RNGeetestModule

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(setDebugMode:(BOOL)debugMode) {
  // debug配置
  [self.manager enableDebugMode:debugMode];
}

RCT_EXPORT_METHOD(useSecurityAuthentication:(BOOL)ssl) {
  // https配置
  [self.manager useSecurityAuthentication:ssl];
}

RCT_EXPORT_METHOD(setPresentType:(GTPresentType)type) {
  [self.manager useGTViewWithPresentType:type];
}

RCT_EXPORT_METHOD(configure:(NSString *)captchaId
                  challenge:(NSString *)challenge
                  success:(NSInteger)successCode
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
  if ([self.manager configureGTest:captchaId challenge:challenge success:@(successCode)]) {
    if (resolve) {
      resolve(@{});
    }
  } else {
    if (reject) {
        reject(@"config", @"config failed", nil);
    }
  }
}

RCT_EXPORT_METHOD(openGTView:(BOOL)animated
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    GTCallFinishBlock finishBlock = ^(NSString *code, NSDictionary *result, NSString *message) {
        if ([code isEqualToString:@"1"]) {
            if (resolve) {
                resolve(@{
                          @"code": code,
                          @"result": result,
                          @"message": message
                          });
            }
        } else {
            NSLog(@"[GeetestModule]: code : %@, message : %@", code, message);
        }
    };
    
    // 用户取消验证时调用
    GTCallCloseBlock closeBlock = ^{
        NSLog(@"[GeetestModule]: close");
        if (reject) {
            reject(@"E_CANCEL", @"User cancel validation", nil);
        }
    };
    [self.manager openGTViewAddFinishHandler:finishBlock
                            closeHandler:closeBlock
                                animated:(BOOL)animated];
}

#pragma mark - GTManageDelegate

- (void)GTNetworkErrorHandler:(NSError *)error {
    NSLog(@"[GeetestModule]: network error: %@", error.localizedDescription);
}

#pragma mark - Getter

- (GTManager *)manager {
  if (!_manager) {
    _manager = [[GTManager alloc] init];
    [_manager setGTDelegate:self];
    //多语言配置
    [_manager languageSwitch:LANGTYPE_AUTO];
    //配置布局方式
    [_manager useGTViewWithPresentType:GTPopupCenterType];
    //验证高度约束
    [_manager useGTViewWithHeightConstraintType:GTViewHeightConstraintLargeViewWithLogo];
    //使用背景模糊
    [_manager useVisualViewWithEffect:nil];
    //验证背景颜色(例:yellow rgb(255,200,50))
    [_manager setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
  }
  return _manager;
}

@end

