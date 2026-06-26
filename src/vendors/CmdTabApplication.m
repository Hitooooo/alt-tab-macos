@import Cocoa;
#import "CmdTabApplication.h"

@implementation CmdTabApplication

- (void)sendEvent:(NSEvent *)theEvent {
    @try {
        [super sendEvent:theEvent];
    } @catch (NSException *exception) {
        [super reportException:exception];
    }
}

@end
