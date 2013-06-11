#import <Foundation/Foundation.h>


#define Translate(KEY) [[LTranslationsController sharedTranslationsController] translate:KEY]
#define kDidLoadTranslationsDict @"kDidLoadTranslationsDict"


@interface LTranslationsController : NSObject
{
    NSDictionary *_translationsDict;
    NSArray *_supportedLanguages;
    NSString *_url;
}


@property (strong, nonatomic) NSString *language;


+ (LTranslationsController *)sharedTranslationsController;


- (void)loadTranslationsWithUrl:(NSString *)url andSupportedLanguages:(NSArray *)supportedLanguages;
- (NSString *)translate:(NSString *)key;


@end