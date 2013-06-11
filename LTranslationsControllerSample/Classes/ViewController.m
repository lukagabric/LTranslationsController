#import "ViewController.h"


@implementation ViewController


- (id)init
{
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoadTranslationsDict) name:kDidLoadTranslationsDict object:nil];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    NSString *lang = [[LTranslationsController sharedTranslationsController] language];
    
    if ([lang isEqualToString:@"en"])
        _segmentedControl.selectedSegmentIndex = 0;
    else if ([lang isEqualToString:@"de"])
        _segmentedControl.selectedSegmentIndex = 1;
    else
        _segmentedControl.selectedSegmentIndex = 2;

    [self bindLabel];
}


- (IBAction)segmentChanged:(id)sender
{
    NSString *lang = @"en";
    
    if (_segmentedControl.selectedSegmentIndex == 1)
        lang = @"de";
    else if (_segmentedControl.selectedSegmentIndex == 2)
        lang = @"fr";
    
    [[LTranslationsController sharedTranslationsController] setLanguage:lang];
}


- (void)didLoadTranslationsDict
{
    [self bindLabel];
}


- (void)bindLabel
{
    _label.text = Translate(@"kHelloWorld");
}


@end