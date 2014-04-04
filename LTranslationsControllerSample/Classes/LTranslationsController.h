//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import <Foundation/Foundation.h>


#define Translate(KEY) [[LTranslationsController sharedTranslationsController] translate:KEY]
#define getCurrentLanguage() [LTranslationsController getCurrentLanguage]
#define kDidLoadTranslationsDict @ "kDidLoadTranslationsDict"


@interface LTranslationsController : NSObject
{
	NSDictionary *_translationsDict;
	NSArray *_supportedLanguages;
    NSString *_language;
    BOOL _useRemoteTranslations;
    NSString *_remoteTranslationsUrl;
}


@property (readonly, nonatomic) NSString *language;


+ (LTranslationsController *)sharedTranslationsController;
+ (NSString *)getCurrentLanguage;

- (void)initializeWithSupportedLanguages:(NSArray *)supportedLanguages;
- (void)initializeRemoteTranslationsWithUrl:(NSString *)url andSupportedLanguages:(NSArray *)supportedLanguages;
- (NSString *)translate:(NSString *)key;


@end