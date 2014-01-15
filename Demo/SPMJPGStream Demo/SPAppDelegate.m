
#import "SPAppDelegate.h"

#import "SPViewController.h"

@implementation SPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    SPViewController *vc = [[SPViewController alloc] initWithNibName:@"SPViewController" bundle:nil];

    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];

    return YES;
}

@end
