
#import "SPMJPGStream.h"

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <libextobjc/EXTScope.h>

NSString * const SPMJPGStreamUserKey         = @"SPMJPGStreamUser";
NSString * const SPMJPGStreamPasswordKey     = @"SPMJPGStreamPasswordKey";
NSString * const SPMJPGStreamURLKey          = @"SPMJPGStreamURLKey";
NSString * const SPMJPGStreamCompressionKey  = @"SPMJPGStreamCompressionKey";
NSString * const SPMJPGStreamFPSKey          = @"SPMJPGStreamFPSKey";
NSString * const SPMJPGStreamResolutionKey   = @"SPMJPGStreamResolutionKey";

@interface SPMJPGStream ()

@property (strong) NSDictionary *options;
@property (strong) NSMutableData *data;
@property (strong) NSURLConnection *connection;
@property (assign) BOOL streaming;
@property (strong) RACReplaySubject *subject;
@property (strong) dispatch_queue_t queue;
@property (strong) dispatch_queue_t imqueue;

@end

@implementation SPMJPGStream

- (instancetype)initWithOptions:(NSDictionary *)options
{
    if ( self = [self init] )
    {
        NSAssert( options[SPMJPGStreamURLKey], @"SPMJPGStreamURLKey is required" );
        self.options = options;
        self.queue = dispatch_queue_create( "com.spiideo.spmjpgstream.runloop", NULL );
        self.imqueue = dispatch_queue_create( "com.spiideo.spmjpgstream.image", NULL );
    }

    return self;
}

- (void)dealloc
{
    [self stop];
}

- (RACSignal *)start
{
    if ( self.streaming )
    {
        NSLog(@"SPMJPGStream->can start while already streaming");
        return nil;
    }

    self.subject = [RACReplaySubject replaySubjectWithCapacity:4];

    id x;
    self.data = [[NSMutableData alloc] init];

    NSMutableArray *params = [NSMutableArray array];

    if ( (x = self.options[SPMJPGStreamCompressionKey]) )
    {
        [params addObject:[NSString stringWithFormat:@"compression=%@", x]];
    }

    if ( (x = self.options[SPMJPGStreamResolutionKey]) )
    {
        [params addObject:[NSString stringWithFormat:@"resolution=%@", x]];
    }

    if ( (x = self.options[SPMJPGStreamFPSKey]) )
    {
        [params addObject:[NSString stringWithFormat:@"fps=%@", x]];
    }

    NSString *pstr = @"";

    if ( [params count] > 0 )
    {
        pstr = [NSString stringWithFormat:@"?%@", [params componentsJoinedByString:@"&"]];
    }

    NSString *base = [self.options[SPMJPGStreamURLKey] absoluteString];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", base, pstr]];
    NSLog(@"SPMJPGStream->start: URL: '%@'", url);

    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0f];

    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];

    self.streaming = YES;

    @weakify(self);
    dispatch_async( self.queue, ^{
        @strongify(self);
        NSRunLoop *loop = [NSRunLoop currentRunLoop];
        [self.connection scheduleInRunLoop:loop forMode:NSRunLoopCommonModes];
        [self.connection start];
        [loop run];
    });

    return self.subject;
}

- (void)stop
{
    [self stopWithError:nil];
}

- (void)stopWithError:(NSError *)error
{
    [self.connection cancel];
    self.connection = nil;

    self.streaming = NO;

    if ( error )
    {
        [self.subject sendError:error];
    }
    else
    {
        [self.subject sendCompleted];
    }
}

#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
    NSData *data = [NSData dataWithData:self.data];

    dispatch_async( self.imqueue, ^{
#if TARGET_OS_IPHONE
        UIImage *image = [[UIImage alloc] initWithData:data];
#else
        NSImage *image = [[NSImage alloc] initWithData:data];
#endif

        if ( image )
        {
            [self.subject sendNext:image];
        }
    });

    [self.data setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.data appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self stopWithError:error];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ( [challenge previousFailureCount] == 0 )
    {
        NSAssert( self.options[SPMJPGStreamPasswordKey], @"SPMJPGStreamPasswordKey is required" );
        NSAssert( self.options[SPMJPGStreamUserKey], @"SPMJPGStreamUserKey is required" );

        NSURLCredential *newCredential = [NSURLCredential credentialWithUser:self.options[SPMJPGStreamUserKey]
                                                                    password:self.options[SPMJPGStreamPasswordKey]
                                                                 persistence:NSURLCredentialPersistenceForSession];

        [[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
    }
    else
    {
        NSError *error = [NSError errorWithDomain:@"com.spiideo.error"
                                             code:-1
                                         userInfo:@{
                                            NSLocalizedDescriptionKey : @"Authentication failure"
                                            }];

        [self stopWithError:error];
    }
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection
{
    return NO;
}

@end
