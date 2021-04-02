#import <dlfcn.h>
#import <objc/runtime.h>
#import <sys/stat.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#import <Social/Social.h>
#import <SafariServices/SafariServices.h>
#import "dimentio/libdimentio.h"
#import "MobileGestalt.h"
#import "prefs.h"

@protocol SFSafariViewControllerDelegate;
@import SafariServices;

@interface PSController : PSListController <SFSafariViewControllerDelegate>
{
    CGRect topFrame;
    UILabel *bannerTitle;
    UILabel *footerLabel;
    UILabel *titleLabel;
    UILabel *_label;
    UILabel *underLabel;
}
@property (nonatomic, strong) id<SFSafariViewControllerDelegate> delegate;
@property(retain) UIView *bannerView;
@property (nonatomic, copy) NSString *valueStr;
+ (PSController*)shared;
@end

@interface PSAppDelegate : UIApplication <UIApplicationDelegate>
{
    UIWindow *_window;
    UIViewController *_viewController;
}
@property (nonatomic, retain) UIWindow *window;
@end

@interface UIProgressHUD : UIView
- (void)showInView:(UIView *)view;
- (void)setText:(NSString *)text;
- (void)done;
- (void)hide;
@end

@interface UIApplication (Private)
- (void)suspend;
- (void)terminateWithSuccess;
@end

@interface UIApplication (AnimatedExitToSpringBoard)
- (void)closeAppAnimatedExit;
@end

@implementation UIApplication (AnimatedExitToSpringBoard)
- (void)closeAppAnimatedExit {
    BOOL multitaskingSupported = NO;
    if ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)]) {
        multitaskingSupported = [UIDevice currentDevice].multitaskingSupported;
    }
    if ([self respondsToSelector:@selector(suspend)]) {
        if (multitaskingSupported) {
            [self beginBackgroundTaskWithExpirationHandler:^{}];
            [self performSelector:@selector(exit) withObject:nil afterDelay:0.4];
        }
        [self suspend];
    } else {
        [self exit];
    }
}

- (void)exit {
    if ([self respondsToSelector:@selector(terminateWithSuccess)]) {
        [self terminateWithSuccess];
    } else {
        exit(0);
    }
}
@end
