LTranslationsController
=======================

iOS Translations Controller - remotely change application localization strings.

The translation plist files are bundled in the app and on a server. Translations are bundeled in the app just in case there is no internet connection on app start or something is wrong with remote translation files so there are original translations. On every app start or when application enters foreground translations are downloaded from the server if the files have been modified.

Sample usage
------------

AppDelegate:

    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
    {
        [[LTranslationsController sharedTranslationsController] loadTranslationsWithUrl:@"http://lukagabric.com/wp-content/uploads/other/translationssample/" andSupportedLanguages:@[@"en", @"de", @"fr"]];
        
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.window.rootViewController = [ViewController new];
        [self.window makeKeyAndVisible];
        return YES;
    }
    
Translation:

    - (void)bindLabel
    {
        _label.text = Translate(@"kHelloWorld");
    }

To change language:

    [[LTranslationsController sharedTranslationsController] setLanguage:@"en"];
    
A notification with name kDidLoadTranslationsDict is sent whenever the translation dictionary changes, e.g. when new localization file is downloaded. A View (Controller) may be registered as an observer to the notification and bind the UI according to the new translations.

----------

Check the sample project for complete implementation.
