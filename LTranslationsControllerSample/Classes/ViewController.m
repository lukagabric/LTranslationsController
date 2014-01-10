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
    
    [self bindLabel];
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