#import "AppDelegate.h"
#import "ViewController.h"


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[LTranslationsController sharedTranslationsController] loadTranslationsWithUrl:@"http://lukagabric.com/wp-content/uploads/other/translationssample/" andSupportedLanguages:@[@"en", @"de", @"fr"]];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [ViewController new];
    [self.window makeKeyAndVisible];
    return YES;
}


@end