
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

extern NSString * const SPMJPGStreamUserKey;
extern NSString * const SPMJPGStreamPasswordKey;
extern NSString * const SPMJPGStreamURLKey;
extern NSString * const SPMJPGStreamCompressionKey;
extern NSString * const SPMJPGStreamFPSKey;
extern NSString * const SPMJPGStreamResolutionKey;

@class RACSignal;

@interface SPMJPGStream : NSObject

@property (readonly) NSDictionary *options;
@property (readonly, getter=isStreaming) BOOL streaming;

@property (readonly) RACSignal *signal;

- (instancetype)initWithOptions:(NSDictionary *)options;

- (void)start;
- (void)stop;

@end
