//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "LTranslationsController.h"
#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"


#define kTranslationsFilePrefix @"Translations_"
#define kSavedLanguageKey       @"kSavedLanguageKey"


@implementation LTranslationsController


#pragma mark - Synthesize


@synthesize language = _language;


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


- (void)initializeWithSupportedLanguages:(NSArray *)supportedLanguages
{
    [self initializeWithSupportedLanguages:supportedLanguages useRemoteTranslations:NO];
}


- (void)initializeRemoteTranslationsWithUrl:(NSString *)url andSupportedLanguages:(NSArray *)supportedLanguages;
{
    _remoteTranslationsUrl = url;
    [self initializeWithSupportedLanguages:supportedLanguages useRemoteTranslations:YES];
}


- (void)initializeWithSupportedLanguages:(NSArray *)supportedLanguages useRemoteTranslations:(BOOL)useRemoteTranslations
{
	_supportedLanguages = supportedLanguages;
    _useRemoteTranslations = useRemoteTranslations;
    
    NSArray *appleLanguages = [NSLocale preferredLanguages];
    
    if ([supportedLanguages count] > 0)
    {
        _language = [appleLanguages firstObjectCommonWithArray:supportedLanguages];
        
        if (!_language)
            _language = [supportedLanguages objectAtIndex:0];
    }
    else
    {
        _language = [appleLanguages objectAtIndex:0];
    }
    
    if (_useRemoteTranslations)
    {
        [self loadTranslationsForCurrentLanguage];
        [self downloadAllTranslations];
    }
}


#pragma mark - dealloc


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Notification Center


- (void)applicationWillEnterForeground
{
    if (_useRemoteTranslations)
        [self downloadAllTranslations];
}


#pragma mark - Load translations


- (void)loadTranslationsForCurrentLanguage
{
	_translationsDict = nil;
    
	if ([[NSFileManager defaultManager] fileExistsAtPath:[self getTranslationsFilePathForCurrentLanguage]])
	{
		_translationsDict = [NSDictionary dictionaryWithContentsOfFile:[self getTranslationsFilePathForCurrentLanguage]];
	}
    
	if (!_translationsDict)
	{
		_translationsDict = [NSDictionary dictionaryWithContentsOfURL:[[NSBundle mainBundle] URLForResource:[NSString stringWithFormat:@"%@%@", kTranslationsFilePrefix, _language] withExtension:@"plist"]];
	}
    
	[[NSNotificationCenter defaultCenter] postNotificationName:kDidLoadTranslationsDict object:self];
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
        {
            [self loadTranslationsForCurrentLanguage];
        }
    }];
    
	[languageRequest startAsynchronous];
}


#pragma mark - Getters


- (NSString *)translate:(NSString *)key
{
	NSString *translationString;
    
    if (_useRemoteTranslations)
    {
        if (_translationsDict)
            translationString = [_translationsDict objectForKey:key];
    }
    else
    {
        translationString = [[NSBundle mainBundle] localizedStringForKey:key value:@"TranslationDoesNotExist" table:nil];
        if ([translationString isEqualToString:@"TranslationDoesNotExist"])
            translationString = nil;
    }
    
    if (!translationString)
        NSLog(@"Missing translation for key '%@'", key);
    
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
    NSString *urlString = [_remoteTranslationsUrl stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.plist", kTranslationsFilePrefix, language]];
	NSURL *url = [NSURL URLWithString:urlString];
    
	return url;
}


#pragma mark -


@end