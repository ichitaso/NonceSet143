#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//#include <spawn.h>
//#include <ifaddrs.h>
//#include <arpa/inet.h>
#import <mach/mach_host.h>
#import "PSAppDelegate.h"
#import <firmware.h>
#import <dlfcn.h>
//#include "iokit.h"
#include <mach/mach.h>

#define VERSION @"v0.0.5"

#define IS_PAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

static CGFloat const kHBFPHeaderTopInset = 64.f;
static CGFloat const kHBFPHeaderHeight = 160.f;

//static int status;
static BOOL hideEcid;
static UIWindow *window = nil;
static UIAlertController *alertController;

@interface UIDeviceHardware : NSObject
- (NSString *)platform;
@end

@implementation UIDeviceHardware
- (NSString *)platform {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}
@end

static CFStringRef (*$MGCopyAnswer)(CFStringRef);

bool vaildGenerator(NSString *generator) {
    if ([generator length] != 18 || [generator characterAtIndex:0] != '0' || [generator characterAtIndex:1] != 'x') {
        return false;
    }
    for (int i = 2; i <= 17; i++) {
        if (!isxdigit([generator characterAtIndex:i])) {
            return false;
        }
    }
    return true;
}

@implementation PSAppDelegate
@synthesize window = _window;
- (void)applicationDidFinishLaunching:(UIApplication *)application {
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _viewController = [[UINavigationController alloc] initWithRootViewController:[PSController shared]];
    [_window addSubview:_viewController.view];
    _window.rootViewController = _viewController;
    [_window makeKeyAndVisible];
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application
  supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskAll;
}
@end

static __strong PSController *PSControllerCC;
@implementation PSController
+ (PSController*)shared {
    if (!PSControllerCC) {
        PSControllerCC = [[[self class] alloc] init];
    }
    return PSControllerCC;
}

- (instancetype)init {
    self = [super init];
    // Alert Notification
//    CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), &status, CFSTR("com.ichitaso.setnonce143.alert"), NULL);
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"notifyAlertButton" object:nil];
//
//    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), &status, (CFNotificationCallback)notifyAlertButtonCallBack, CFSTR("com.ichitaso.setnonce143.alert"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyAlertButton:) name:@"notifyAlertButton" object:nil];

    return self;
}

//void notifyAlertButtonCallBack () {
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"notifyAlertButton" object:nil];
//}
//
//- (void)notifyAlertButton:(NSNotification *)notification {
//    alertController =
//    [UIAlertController alertControllerWithTitle:nil
//                                        message:@"Get root"
//                                 preferredStyle:UIAlertControllerStyleAlert];
//    [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
//                                                        style:UIAlertActionStyleDefault
//                                                      handler:^(UIAlertAction *action) {}]];
//    [self presentViewController:alertController animated:YES completion:nil];
//    [self reloadSpecifiers];
//}

- (void)loadView {
    [super loadView];

    self.title = @"NonceSet143";

    /*UINavigationItem *navigationItem = self.navigationItem;

    navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                  target:self
                                                  action:@selector(shareTweak)];*/

    CGFloat headerHeight = 0 + kHBFPHeaderHeight;
    CGRect selfFrame = [self.view frame];

    _bannerView = [[UIView alloc] init];
    _bannerView.frame = CGRectMake(0, -kHBFPHeaderHeight, selfFrame.size.width, headerHeight);
    _bannerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    [self.table addSubview:_bannerView];
    [self.table sendSubviewToBack:_bannerView];

    topFrame = CGRectMake(0, -kHBFPHeaderHeight, 414, kHBFPHeaderHeight);

    bannerTitle = [[UILabel alloc] init];
    bannerTitle.text = @"NonceSet143";
    [bannerTitle setFont:[UIFont fontWithName:@"HelveticaNeue-Ultralight" size:36]];

    [_bannerView addSubview:bannerTitle];

    [bannerTitle setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_bannerView addConstraint:[NSLayoutConstraint constraintWithItem:bannerTitle attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_bannerView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0f]];
    [_bannerView addConstraint:[NSLayoutConstraint constraintWithItem:bannerTitle attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_bannerView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:20.0f]];
    bannerTitle.textAlignment = NSTextAlignmentCenter;

    NSString *systemStr = [NSString stringWithFormat:@"%@ %@ %@ - %@",[[UIDeviceHardware alloc] platform],[[UIDevice currentDevice] systemName],[[UIDevice currentDevice] systemVersion],VERSION];

    footerLabel = [[UILabel alloc] init];
    footerLabel.text = systemStr;
    [footerLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16]];
    footerLabel.textColor = [UIColor grayColor];
    footerLabel.alpha = 1.0;

    [_bannerView addSubview:footerLabel];

    [footerLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_bannerView addConstraint:[NSLayoutConstraint constraintWithItem:footerLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_bannerView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0f]];
    [_bannerView addConstraint:[NSLayoutConstraint constraintWithItem:footerLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_bannerView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:60.0f]];
    footerLabel.textAlignment = NSTextAlignmentCenter;

    [self.table setContentInset:UIEdgeInsetsMake(kHBFPHeaderHeight-kHBFPHeaderTopInset,0,0,0)];
    [self.table setContentOffset:CGPointMake(0, -kHBFPHeaderHeight+kHBFPHeaderTopInset)];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    void *gestalt = dlopen("/usr/lib/libMobileGestalt.dylib", RTLD_GLOBAL | RTLD_LAZY);
    $MGCopyAnswer = dlsym(gestalt, "MGCopyAnswer");

//    NSURL *currentURL = [[[NSBundle mainBundle] bundleURL] URLByDeletingLastPathComponent];
//    NSString *currentStr = [currentURL absoluteString];
//    NSString *realPath = [currentStr stringByReplacingOccurrencesOfString:@"file://" withString:@""];
//
//    NSString *appPath = [realPath stringByAppendingString:@"NonceSet143.app"];
//
//    NSString *dimentioStr = [appPath stringByAppendingString:@"/libdementia.dylib"];
//
//    void *newframework = dlopen([dimentioStr UTF8String], RTLD_LAZY);
//    if (newframework == 0) {
//        NSLog(@"DLError: %s\n", dlerror());
//    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)_unloadBundleControllers {
    [super _unloadBundleControllers];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];

    if (indexPath.section == 1 && indexPath.row == 0) {

        UITableViewCell *customCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"APNonce:"];
        customCell.textLabel.text = [self getApnonce];
        customCell.textLabel.alpha = 0.8;
        customCell.textLabel.font = [UIFont systemFontOfSize:14.0];
        customCell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        customCell.textLabel.numberOfLines = 0;
        [customCell sizeToFit];
        return customCell;
    }
    // PSEDitCell Add Clear Button
    if ([cell isKindOfClass:objc_getClass("PSEditableTableCell")]) {
        PSEditableTableCell *editableCell = (PSEditableTableCell *)cell;
        if (editableCell.textField) {
            UITextField *field = editableCell.textField;
            field.clearButtonMode = UITextFieldViewModeWhileEditing;
            field.keyboardType = UIKeyboardTypeASCIICapable;
            field.returnKeyType = UIReturnKeyDone;
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == 0) {
        return 60.f;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return (action == @selector(copy:));
}
- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:)) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        [pasteBoard setString:cell.textLabel.text];
    }
}

- (id)specifiers {
    if (!_specifiers) {
        NSMutableArray* specifiers = [NSMutableArray array];
        PSSpecifier* spec;
        
        /*spec = [PSSpecifier preferenceSpecifierNamed:@"System Status"
                                              target:self
                                                 set:nil
                                                 get:nil
                                              detail:nil
                                                cell:PSGroupCell
                                                edit:nil];
        [specifiers addObject:spec];
        
        spec = [PSSpecifier preferenceSpecifierNamed:@"Root Status"
                                              target:self
                                                 set:nil
                                                 get:@selector(isRoot:)
                                              detail:nil
                                                cell:PSTitleValueCell
                                                edit:nil];
        [specifiers addObject:spec];*/
        
        spec = [PSSpecifier preferenceSpecifierNamed:@"Current Nonce"
                                              target:self
                                                 set:nil
                                                 get:nil
                                              detail:nil
                                                cell:PSGroupCell
                                                edit:nil];
        [spec setProperty:@"Current com.apple.System.boot-nonce in nvram." forKey:@"footerText"];
        [specifiers addObject:spec];
        
        spec = [PSSpecifier preferenceSpecifierNamed:@"Nonce:"
                                              target:self
                                                 set:nil
                                                 get:@selector(readNonceValue:)
                                              detail:nil
                                                cell:PSTitleValueCell
                                                edit:nil];
        [spec setProperty:@"Nonce:" forKey:@"key"];
        [specifiers addObject:spec];

        spec = [PSSpecifier preferenceSpecifierNamed:@"Current APNonce"
                                              target:self
                                                 set:nil
                                                 get:nil
                                              detail:nil
                                                cell:PSGroupCell
                                                edit:nil];
        [spec setProperty:@"APNonce value for A12+ devices" forKey:@"footerText"];
        [specifiers addObject:spec];

        spec = [PSSpecifier preferenceSpecifierNamed:@"APNonce:"
                                              target:self
                                                 set:nil
                                                 get:nil//@selector(readApNonceValue:)
                                              detail:nil
                                                cell:PSTitleValueCell
                                                edit:nil];
        [spec setProperty:@"APNonce:" forKey:@"key"];
        [specifiers addObject:spec];
        
        spec = [PSSpecifier preferenceSpecifierNamed:@"Set/Change Nonce"
                                              target:self
                                                 set:nil
                                                 get:nil
                                              detail:nil
                                                cell:PSGroupCell
                                                edit:nil];
        [spec setProperty:@"Nonce is set via dimentio." forKey:@"footerText"];
        [specifiers addObject:spec];

        PSTextFieldSpecifier *textSpecifier = [PSTextFieldSpecifier preferenceSpecifierNamed:@"SetNonce:"
                                                                                      target:self
                                                                                         set:@selector(setNonceValue:specifier:)
                                                                                         get:@selector(readValue:)
                                                                                      detail:nil
                                                                                        cell:PSEditTextCell
                                                                                        edit:nil];
        [textSpecifier setProperty:@"SetNonce" forKey:@"key"];
        [textSpecifier setPlaceholder:@"0x1111111111111111"];
        [specifiers addObject:textSpecifier];

        spec = [PSSpecifier preferenceSpecifierNamed:@"ECID"
                                              target:self
                                                 set:nil
                                                 get:nil
                                              detail:nil
                                                cell:PSGroupCell
                                                edit:nil];
        [specifiers addObject:spec];


        spec = [PSSpecifier preferenceSpecifierNamed:@"Decimal"
                                              target:self
                                                 set:nil
                                                 get:@selector(ecidValue:)
                                              detail:nil
                                                cell:PSTitleValueCell
                                                edit:nil];
        [specifiers addObject:spec];

        spec = [PSSpecifier preferenceSpecifierNamed:@"Hexadecimal"
                                              target:self
                                                 set:nil
                                                 get:@selector(ecidHexValue:)
                                              detail:nil
                                                cell:PSTitleValueCell
                                                edit:nil];
        [specifiers addObject:spec];

        spec = [PSSpecifier preferenceSpecifierNamed:@"Show/Hide ECID"
                                              target:self
                                                 set:nil
                                                 get:nil
                                              detail:nil
                                                cell:PSButtonCell
                                                edit:nil];

        spec->action = @selector(showHideEcid);
        [specifiers addObject:spec];

        spec = [PSSpecifier preferenceSpecifierNamed:@"Infomation"
                                              target:self
                                                 set:nil
                                                 get:nil
                                              detail:nil
                                                cell:PSGroupCell
                                                edit:nil];
        [spec setProperty:@"Info" forKey:@"label"];
        [spec setProperty:@"If you like my work, Please a donation by Paypal." forKey:@"footerText"];
        [specifiers addObject:spec];

        spec = [PSSpecifier preferenceSpecifierNamed:@"Device Model"
                                              target:self
                                                 set:nil
                                                 get:@selector(modelValue:)
                                              detail:nil
                                                cell:PSTitleValueCell
                                                edit:nil];
        [specifiers addObject:spec];

        spec = [PSSpecifier preferenceSpecifierNamed:@"Useful Site"
                                              target:self
                                                 set:nil
                                                 get:nil
                                              detail:nil
                                                cell:PSButtonCell
                                                edit:nil];

        spec->action = @selector(openSafari);
        [spec setProperty:@YES forKey:@"hasIcon"];
        [spec setProperty:[UIImage imageWithContentsOfFile:[[self bundle] pathForResource:@"Cannathea" ofType:@"png"]] forKey:@"iconImage"];
        [specifiers addObject:spec];

        spec = [PSSpecifier preferenceSpecifierNamed:@"Follow on Twitter"
                                              target:self
                                                 set:nil
                                                 get:nil
                                              detail:nil
                                                cell:PSButtonCell
                                                edit:nil];
        
        spec->action = @selector(openTwitter);
        [spec setProperty:@YES forKey:@"hasIcon"];
        [spec setProperty:[UIImage imageWithContentsOfFile:[[self bundle] pathForResource:@"twitter" ofType:@"png"]] forKey:@"iconImage"];
        [specifiers addObject:spec];
        
        spec = [PSSpecifier preferenceSpecifierNamed:@"Donation"
                                              target:self
                                                 set:nil
                                                 get:nil
                                              detail:nil
                                                cell:PSLinkCell
                                                edit:nil];
        
        spec->action = @selector(donate);
        [spec setProperty:@YES forKey:@"hasIcon"];
        [spec setProperty:[UIImage imageWithContentsOfFile:[[self bundle] pathForResource:@"paypal" ofType:@"png"]] forKey:@"iconImage"];
        [specifiers addObject:spec];
        
        spec = [PSSpecifier emptyGroupSpecifier];
        [spec setProperty:@"© Will feel Tips by ichitaso" forKey:@"footerText"];
        [specifiers addObject:spec];
        _specifiers = [specifiers copy];
    }
    return _specifiers;
}

- (void)_returnKeyPressed:(id)arg1 {
    [self setValue];
    [super _returnKeyPressed:arg1];
    [self.view endEditing:YES];
}

- (id)isRoot:(PSSpecifier*)specifier {
    setgid(0);
    uint32_t gid = getgid();
    NSLog(@"getgid() returns %u\n", gid);
    setuid(0);
    uint32_t uid = getuid();
    NSLog(@"getuid() returns %u\n", uid);
    return [NSString stringWithFormat:@"%@", getuid() == 0 ? @"root" : @"mobile"];
}

- (NSString *)getGenerator {
    setgid(0);
    uint32_t gid = getgid();
    NSLog(@"getgid() returns %u\n", gid);
    setuid(0);
    uint32_t uid = getuid();
    NSLog(@"getuid() returns %u\n", uid);

    if (uid != 0 && gid != 0) return @"Not root";

    NSString *generator = nil;

    if (dimentio_init(0, NULL, NULL) == KERN_SUCCESS) {
        uint8_t entangled_nonce[CC_SHA384_DIGEST_LENGTH];
        bool entangled;
        uint64_t nonce;
        if (dimentio(&nonce, false, entangled_nonce, &entangled) == KERN_SUCCESS) {
            NSLog(@"The currently generator is 0x%016" PRIX64 ".\n", nonce);
            generator = [NSString stringWithFormat:@"0x%llx", nonce];
        }
    }

    return generator ? generator : @"Nonce: Not Set Nonce";
}

- (id)readNonceValue:(PSSpecifier *)specifier {
    return [self getGenerator];
}

- (NSString *)getApnonce {
    setgid(0);
    uint32_t gid = getgid();
    NSLog(@"getgid() returns %u\n", gid);
    setuid(0);
    uint32_t uid = getuid();
    NSLog(@"getuid() returns %u\n", uid);

    if (uid != 0 && gid != 0) return @"Not root";

    NSString *apnonce = nil;

    if (dimentio_init(0, NULL, NULL) == KERN_SUCCESS) {
        uint8_t entangled_nonce[CC_SHA384_DIGEST_LENGTH];
        bool entangled;
        uint64_t nonce;
        size_t i;

        if (dimentio(&nonce, false, entangled_nonce, &entangled) == KERN_SUCCESS) {
            if (entangled) {
                printf("entangled_nonce: ");
                NSMutableString *t = [NSMutableString stringWithCapacity:MIN(sizeof(entangled_nonce), 32)];
                for(i = 0; i < MIN(sizeof(entangled_nonce), 32); ++i) {
                    printf("%02" PRIX8, entangled_nonce[i]);
                    [t appendFormat:@"%02" PRIX8, entangled_nonce[i]];
                }
                apnonce = t;
            }
        }
    }

    return apnonce ? apnonce : @"APNonce: Not Found";
}

- (id)readApNonceValue:(PSSpecifier *)specifier {
    return [self getApnonce];
}

- (id)readValue:(PSSpecifier *)specifier {
    if (!self.valueStr || [self.valueStr isEqualToString:@""]) {
        self.valueStr = @"0x1111111111111111";
    }
    return self.valueStr;
}

- (void)setValue {
    NSString *value = nil;
    if (!self.valueStr || [self.valueStr isEqualToString:@""]) {
        value = @"0x1111111111111111";
    } else {
        value = self.valueStr;
    }

    self.valueStr = value;

    [self.view endEditing:YES];

    if (!vaildGenerator(value)) {
        UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:@"Wrong Value"
                                            message:[NSString stringWithFormat:@"\"%@\"\nFormat error!", value]
                                     preferredStyle:UIAlertControllerStyleAlert];

        [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {}]];

        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:@"Set Generator"
                                            message:value
                                     preferredStyle:UIAlertControllerStyleAlert];

        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {}]];

        [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
            [self setgenerator];
        }]];

        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)setNonceValue:(id)value specifier:(PSSpecifier *)specifier {
    if (!value || [value isEqualToString:@""]) {
        value = @"0x1111111111111111";
    }

    self.valueStr = value;

    [self setValue];
}

- (void)setgenerator {
    if (getuid() != 0) {
        setuid(0);
    }

    if (getuid() != 0) {
        alertController =
        [UIAlertController alertControllerWithTitle:@"You can not set nonce"
                                            message:@"Status: mobile"
                                     preferredStyle:UIAlertControllerStyleAlert];

        [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {}]];

        [self presentViewController:alertController animated:YES completion:nil];
        // return
        return;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        uint8_t entangled_nonce[CC_SHA384_DIGEST_LENGTH];
        bool entangled;
        uint64_t nonce;
        if (dimentio_init(0, NULL, NULL) == KERN_SUCCESS) {
            char *generator = (char *)calloc(19, sizeof(char));
            char *setnonce = (char *)[self.valueStr UTF8String];
            strcpy(generator, setnonce);
            sscanf(generator, "0x%016" PRIX64, &nonce);
            free(generator);
            if (dimentio(&nonce, true, entangled_nonce, &entangled) == KERN_SUCCESS) {
                printf("Set nonce to 0x%016" PRIX64 "\n", nonce);
                if (entangled) {
                    printf("entangled_nonce: ");
                    for (size_t i = 0; i < MIN(sizeof(entangled_nonce), 32); ++i) {
                        printf("%02" PRIX8, entangled_nonce[i]);
                    }
                    putchar('\n');
                }
            }
            dimentio_term();
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadSpecifiers];
        });
    });
}

- (id)ecidValue:(PSSpecifier *)specifier {
    if (hideEcid == NO) {
        CFStringRef ecid = (CFStringRef)$MGCopyAnswer(CFSTR("UniqueChipID"));
        return [NSString stringWithFormat:@"%@", (__bridge NSString *)ecid];
    } else {
        return @"1234567890";
    }
}

- (id)ecidHexValue:(PSSpecifier *)specifier {
   return [NSString stringWithFormat:@"%lX", (unsigned long)[[self ecidValue:nil] integerValue]];
}

- (id)modelValue:(PSSpecifier *)specifier {
    CFStringRef boardId = (CFStringRef)$MGCopyAnswer(CFSTR("HWModelStr"));
    if (!boardId) return @"NULL";
    return [NSString stringWithFormat:@"%@", (__bridge NSString *)boardId];;
}

- (void)showHideEcid {
    if (hideEcid) {
        hideEcid = NO;
    } else {
        hideEcid = YES;
    }

    [self reloadSpecifiers];
}

- (void)openSafari {
    alertController = [UIAlertController
                       alertControllerWithTitle:@"Useful Site"
                       message:nil
                       preferredStyle:UIAlertControllerStyleActionSheet];

    [alertController addAction:[UIAlertAction actionWithTitle:@"SHSH Host"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self openURLInBrowser:@"https://shsh.host/"];
        });
    }]];

    [alertController addAction:[UIAlertAction actionWithTitle:@"TSS Saver"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self openURLInBrowser:@"https://tsssaver.1conan.com/v2/"];
        });
    }]];

    [alertController addAction:[UIAlertAction actionWithTitle:@"The iPhone Wiki"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self openURLInBrowser:@"https://www.theiphonewiki.com/"];
        });
    }]];

    [alertController addAction:[UIAlertAction actionWithTitle:@"My Repo"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self openURLInBrowser:@"https://cydia.ichitaso.com"];
        });
    }]];

    // Fix Crash for iPad
    if (IS_PAD) {
        CGRect rect = self.view.frame;
        alertController.popoverPresentationController.sourceView = self.view;
        alertController.popoverPresentationController.sourceRect = CGRectMake(CGRectGetMidX(rect)-60,rect.size.height-50, 120,50);
        alertController.popoverPresentationController.permittedArrowDirections = 0;
    } else {
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}]];
    }

    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)openTwitter {
    NSString *twitterID = @"ichitaso";

    alertController = [UIAlertController
                       alertControllerWithTitle:@"Follow @ichitaso"
                       message:nil
                       preferredStyle:UIAlertControllerStyleActionSheet];

    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot://"]]) {
        [alertController addAction:[UIAlertAction actionWithTitle:@"Open in Tweetbot" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tweetbot:///user_profile/%@",twitterID]]
                                               options:@{}
                                     completionHandler:nil];
        }]];
    }

    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) {
        [alertController addAction:[UIAlertAction actionWithTitle:@"Open in Twitter" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"twitter://user?screen_name=%@",twitterID]]
                                               options:@{}
                                     completionHandler:nil];
        }]];
    }

    [alertController addAction:[UIAlertAction actionWithTitle:@"Open in Browser" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self openURLInBrowser:[NSString stringWithFormat:@"https://twitter.com/%@",twitterID]];
        });
    }]];

    // Fix Crash for iPad
    if (IS_PAD) {
        CGRect rect = self.view.frame;
        alertController.popoverPresentationController.sourceView = self.view;
        alertController.popoverPresentationController.sourceRect = CGRectMake(CGRectGetMidX(rect)-60,rect.size.height-50, 120,50);
        alertController.popoverPresentationController.permittedArrowDirections = 0;
    } else {
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}]];
    }

    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)donate {
    [self openURLInBrowser:@"https://cydia.ichitaso.com/donation.html"];
}

- (void)openURLInBrowser:(NSString *)url {
    SFSafariViewControllerConfiguration *config = [[SFSafariViewControllerConfiguration alloc] init];
    config.barCollapsingEnabled = NO;
    SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:url] configuration:config];
    if (@available(iOS 13.0, *)) {
        [self presentViewController:safari animated:YES completion:nil];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }

}

//- (void)shareTweak {
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        // 画像をバックグラウンドで外部から取得
//        NSURL *url1 = [NSURL URLWithString:@"https://i.imgur.com/AQG7YJR.png"];
//        NSData *data1 = [NSData dataWithContentsOfURL:url1 options:NSDataReadingUncached error:nil];
//
//        NSURL *url2 = [NSURL URLWithString:@"https://i.imgur.com/2k2wigf.png"];
//        NSData *data2 = [NSData dataWithContentsOfURL:url2 options:NSDataReadingUncached error:nil];
//
//        NSURL *url3 = [NSURL URLWithString:@"https://i.imgur.com/bTfptAu.png"];
//        NSData *data3 = [NSData dataWithContentsOfURL:url3 options:NSDataReadingUncached error:nil];
//
//        NSURL *url4 = [NSURL URLWithString:@"https://i.imgur.com/nPeiD4H.png"];
//        NSData *data4 = [NSData dataWithContentsOfURL:url4 options:NSDataReadingUncached error:nil];
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSString *texttoshare = @"#PowerSelector by @ichitaso is awesome Jailbreak Apps!\nhttps://cydia.ichitaso.com/depiction/powerselector11.html";
//            // メインスレッドでセット
//            UIImage *image1 = [UIImage imageWithData:data1];
//            UIImage *image2 = [UIImage imageWithData:data2];
//            UIImage *image3 = [UIImage imageWithData:data3];
//            UIImage *image4 = [UIImage imageWithData:data4];
//
//            NSArray *activityItems = @[texttoshare, image1, image2, image3, image4];
//
//            UIActivityViewController *activityVC =
//            [[UIActivityViewController alloc] initWithActivityItems:activityItems
//                                              applicationActivities:nil];
//
//            // Fix Crash for iPad
//            if (IS_PAD) {
//                activityVC.popoverPresentationController.sourceView = self.view;
//                activityVC.popoverPresentationController.sourceRect = self.view.bounds;
//                activityVC.popoverPresentationController.permittedArrowDirections = 0;
//            }
//
//            [self presentViewController:activityVC animated:YES completion:nil];
//        });
//    });
//}
@end
