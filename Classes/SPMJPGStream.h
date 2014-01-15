
#import <Foundation/Foundation.h>

extern NSString * const SPMJPGStreamUserKey;
extern NSString * const SPMJPGStreamPasswordKey;
extern NSString * const SPMJPGStreamURLKey;
extern NSString * const SPMJPGStreamCompressionKey;
extern NSString * const SPMJPGStreamFPSKey;
extern NSString * const SPMJPGStreamResolutionKey;

@interface SPMJPGStream : NSObject

@property (readonly) NSDictionary *options;
@property (readonly, getter=isStreaming) BOOL streaming;

@property (readonly) RACSignal *signal;

- (instancetype)initWithOptions:(NSDictionary *)options;

- (void)start;
- (void)stop;

@end
