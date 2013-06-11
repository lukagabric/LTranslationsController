#import "LTranslationsController.h"
#import "ASIDownloadCache.h"
#import "ASIHTTPRequest.h"


#define kTranslationsFilePrefix @"Translations_"
#define kSavedLanguageKey @"kSavedLanguageKey"


@implementation LTranslationsController


#pragma mark - Singleton


+ (LTranslationsController *)sharedTranslationsController
{
    __strong static LTranslationsController *sharedTranslationsController = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTranslationsController = [LTranslationsController new];
    });
    
    return sharedTranslationsController;
}


#pragma mark - init


- (id)init
{
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}


- (void)loadTranslationsWithUrl:(NSString *)url andSupportedLanguages:(NSArray *)supportedLanguages
{
    _url = url;
    _supportedLanguages = supportedLanguages;
    
    NSString *language;
    
    NSString *savedLanguage = [[NSUserDefaults standardUserDefaults] stringForKey:kSavedLanguageKey];
    
	if (savedLanguage && [supportedLanguages containsObject:savedLanguage])
	{
		language = savedLanguage;
	}
	else
	{
		NSArray *appleLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
		
        language = [appleLanguages firstObjectCommonWithArray:supportedLanguages];
        
		if (!language)
        {
            if ([supportedLanguages count] > 0)
                language = [supportedLanguages objectAtIndex:0];
            else
                language = [appleLanguages objectAtIndex:0];
        }
	}
    
    self.language = language;
    
    [self downloadAllTranslations];
}


#pragma mark - Notification Center


- (void)applicationWillEnterForeground
{
    [self downloadAllTranslations];
}


#pragma mark - Load translations


- (void)loadTranslationsForCurrentLanguage
{
    _translationsDict = nil;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self getTranslationsFilePathForCurrentLanguage]])
        _translationsDict = [NSDictionary dictionaryWithContentsOfFile:[self getTranslationsFilePathForCurrentLanguage]];

    if (!_translationsDict)
        _translationsDict = [NSDictionary dictionaryWithContentsOfURL:[[NSBundle mainBundle] URLForResource:[NSString stringWithFormat:@"%@%@", kTranslationsFilePrefix, _language] withExtension:@"plist"]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidLoadTranslationsDict object:self];
}


#pragma mark - Setters


- (void)setLanguage:(NSString *)language
{
    _language = language;
    
    [[NSUserDefaults standardUserDefaults] setObject:_language forKey:kSavedLanguageKey];
    [[NSUserDefaults standardUserDefaults] setObject:@[_language] forKey:@"AppleLanguages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self loadTranslationsForCurrentLanguage];
}


#pragma mark - Download & File Management


- (void)downloadAllTranslations
{
    for (NSString *lang in _supportedLanguages)
    {
        [self downloadTranslationsForLanguage:lang];
    }
}


- (void)downloadTranslationsForLanguage:(NSString *)language
{
    ASIHTTPRequest *languageRequest = [ASIHTTPRequest requestWithURL:[self getUrlForLanguage:language]];
    __weak ASIHTTPRequest *weakRequest = languageRequest;
    
    [languageRequest setCachePolicy:ASIAskServerIfModifiedCachePolicy];
    [languageRequest setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [languageRequest setDownloadCache:[ASIDownloadCache sharedCache]];
    [languageRequest setCompletionBlock:^{
        if ([language isEqualToString:_language] && !weakRequest.error && !weakRequest.didUseCachedResponse && weakRequest.responseData)
            [self loadTranslationsForCurrentLanguage];
    }];
    
    [languageRequest startAsynchronous];
}


#pragma mark - Getters


- (NSString *)translate:(NSString *)key
{
    NSString *translationString = nil;
    
    if (_translationsDict)
        translationString = [_translationsDict objectForKey:key];
    
    return translationString ? translationString : key;
}


- (NSURL *)getTranslationsFileURLForCurrentLanguage
{
    return [NSURL URLWithString:[self getTranslationsFilePathForCurrentLanguage]];
}


- (NSString *)getTranslationsFilePathForCurrentLanguage
{
    return [[ASIDownloadCache sharedCache] pathToCachedResponseDataForURL:[self getUrlForLanguage:_language]];
}


- (NSURL *)getUrlForLanguage:(NSString *)language
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@.plist", [NSURL URLWithString:_url], kTranslationsFilePrefix, language];
    NSURL *url = [NSURL URLWithString:urlString];
    
    return url;
}


#pragma mark -


@end