//
//  TestServer.m
//  TestingStoreiPhoneEdition
//
//  Created by HongDi Huang on 8/23/16.
//  Copyright © 2016 HongDi Huang. All rights reserved.
//

#import "Server.h"
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#include <CFNetwork/CFSocketStream.h>

void ListeningSocketCallback(CFSocketRef sock,
                             CFSocketCallBackType type,
                             CFDataRef address,
                             const void *data,
                             void *info);

@interface Server()<NSNetServiceDelegate, NSStreamDelegate>{
    NSString *_serviceName;
    uint16_t _port;
    NSData *_sendingData;
    NSNetService *_service;
    NSNetService *_currentlyResolvingService; // the service we are currently trying to resolve
    NSUInteger _payloadSize; // the size you expect to be sending
    CFSocketRef _socket; // the socket that data is sent over
    NSInputStream *_inputStream; // stream that this side reads from
    NSOutputStream *_outputStream; // stream that this side writes two
    BOOL _inputStreamReady; // when input stream is ready to read from this turns to YES
    BOOL _outputStreamReady; // when output stream is ready to read from this turns to YES
    BOOL _outputStreamHasSpace; // when there is space in the output s
    
}
@end

@interface Server(Privite)

- (void)_streamCompletedOpening:(NSStream *)stream;
- (void)_streamHasBytes:(NSStream *)stream;
- (void)_streamHasSpace:(NSStream *)stream;
- (void)_streamEncounteredEnd:(NSStream *)stream;
- (void)_streamEncounteredError:(NSStream *)stream;
- (void)_remoteServiceResolved:(NSNetService *)remoteService;
- (void)_connectedToInputStream:(NSInputStream *)inputStream
                   outputStream:(NSOutputStream *)outputStream;
- (void)_stopStreams;
- (void)_stopNetService;
@end

@implementation Server

- (instancetype)init
{
    self = [super init];
    if (self) {
        _payloadSize = 2048;
        _outputStreamHasSpace = NO;
    }
    return self;
}

-(void)dealloc{
    [self stop];
    [self stopAllNetService];
}

// star the server, returns YES if successful and NO if not
// if NO is returned there will be more detail in the error object
// if you don't care about the error you can pass NULL
- (BOOL)start:(NSString *)name error:(NSError **)error {
    _serviceName = name;
    BOOL successful = YES;
    CFSocketContext socketCtxt = {0, (__bridge void *)(self), NULL, NULL, NULL};
    _socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM,
                             IPPROTO_TCP,
                             kCFSocketAcceptCallBack,
                             ListeningSocketCallback,
                             &socketCtxt);
    
    if (NULL == _socket) {
        if (nil != error) {
            *error = [[NSError alloc]
                      initWithDomain:_serviceName
                      code:kServerNoSocketsAvailable
                      userInfo:nil];
        }
        successful = NO;
    }
    
    if(YES == successful) {
        // enable address reuse
        int yes = 1;
        setsockopt(CFSocketGetNative(_socket),
                   SOL_SOCKET, SO_REUSEADDR,
                   (void *)&yes, sizeof(yes));
        // set the packet size for send and receive
        // cuts down on latency and such when sending
        // small packets
        uint8_t packetSize = _payloadSize;
        setsockopt(CFSocketGetNative(_socket),
                   SOL_SOCKET, SO_SNDBUF,
                   (void *)&packetSize, sizeof(packetSize));
        setsockopt(CFSocketGetNative(_socket),
                   SOL_SOCKET, SO_RCVBUF,
                   (void *)&packetSize, sizeof(packetSize));
        
        // set up the IPv4 endpoint; use port 0, so the kernel
        // will choose an arbitrary port for us, which will be
        // advertised through Bonjour
        struct sockaddr_in addr4;
        memset(&addr4, 0, sizeof(addr4));
        addr4.sin_len = sizeof(addr4);
        addr4.sin_family = AF_INET;
        addr4.sin_port = 0; // since we set it to zero the kernel will assign one for us
        addr4.sin_addr.s_addr = htonl(INADDR_ANY);
        NSData *address4 = [NSData dataWithBytes:&addr4 length:sizeof(addr4)];
        
        if (kCFSocketSuccess != CFSocketSetAddress(_socket, (CFDataRef)address4)) {
            if (error) *error = [[NSError alloc]
                                 initWithDomain:_serviceName
                                 code:kServerCouldNotBindToIPv4Address
                                 userInfo:nil];
            if (_socket) CFRelease(_socket);
            _socket = NULL;
            successful = NO;
        } else {
            // now that the binding was successful, we get the port number
            NSData *addr = (NSData *)CFBridgingRelease(CFSocketCopyAddress(_socket));
            memcpy(&addr4, [addr bytes], [addr length]);
            _port = ntohs(addr4.sin_port);
            
            // set up the run loop sources for the sockets
            CFRunLoopRef cfrl = CFRunLoopGetCurrent();
            CFRunLoopSourceRef source4 = CFSocketCreateRunLoopSource(kCFAllocatorDefault, _socket, 0);
            CFRunLoopAddSource(cfrl, source4, kCFRunLoopCommonModes);
            CFRelease(source4);
            
            if(![self publishService:name]) {
                successful = NO;
            }
        }
    }
    
    return successful;
}


// stop the server
// turns off the netService
// closes the socket
// stops the streams
// tells the delegate that the server has stoped
- (void)stop {
    if(nil != _service) {
        [self _stopNetService];
    }
    if(NULL != _socket) {
        CFSocketInvalidate(_socket);
        CFRelease(_socket);
        _socket = NULL;
    }
    [self _stopStreams];
}

- (void)stopAllNetService{
    [self _stopNetService];
    [_currentlyResolvingService stop];
    [_currentlyResolvingService removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    _currentlyResolvingService = nil;
}

#pragma mark -<Server side>
- (BOOL)publishService:(NSString *)name{
    
    BOOL successful = NO;
    
    NSString *serviceName = [NSString stringWithFormat:@"_%@HHD._tcp.", name];
    NSLog(@"Start Service Name: %@", serviceName);
    _service = [[NSNetService alloc] initWithDomain:@""//pick all domain it works
                                               type:serviceName
                                               name:@""
                                               port:_port];
    if (_service != nil) {
        successful = YES;
        [_service scheduleInRunLoop:[NSRunLoop currentRunLoop]
                           forMode:NSRunLoopCommonModes];
        [_service setDelegate:self];
        [_service publish];
    }
    return successful;
}
// send data to the remote side of the server
// on success returns YES, other wise returns NO
// if NO is returned more detail will be in the error
// if you don't care about the error you can pass NULL
- (BOOL)sendData:(NSData *)data error:(NSError **)error {
    BOOL successful = NO;
    _sendingData = data;
    if(_outputStreamHasSpace) {
        // push the whole gob of data onto the output stream
        // TODO: check to see if data is longer than the payloadSize
        // and break it up if so
        NSInteger len = [_outputStream write:[data bytes] maxLength:[data length]];
        if(-1 == len) {
            // error occured
            *error = [[NSError alloc]
                      initWithDomain:_serviceName
                      code:kServerNoSpaceOnOutputStream
                      userInfo:[[_outputStream streamError] userInfo]];
        } else if(0 == len) {
            // stream has reached capacity
            *error = [[NSError alloc]
                      initWithDomain:_serviceName
                      code:kServerOutputStreamReachedCapacity
                      userInfo:[[_outputStream streamError] userInfo]];
        } else {
            successful = YES;
        }
    } else {
        *error = [[NSError alloc] initWithDomain:_serviceName
                                            code:kServerNoSpaceOnOutputStream
                                        userInfo:nil];
    }
    return successful;
}

// call this when the user has selected the remote service they want to connect to
// should be one of the services sent to the delegate method
// serviceAdded:moreComing: method
- (void)connectToRemoteService:(NSNetService *)selectedService{
    [_currentlyResolvingService stop];
    _currentlyResolvingService = nil;
    
    _currentlyResolvingService = selectedService;
    _currentlyResolvingService.delegate = self;
    [_currentlyResolvingService resolveWithTimeout:0.0];
}



#pragma -<NSNetServiceDelegate>
- (void)netServiceDidPublish:(NSNetService *)sender {
    NSString *name = [sender name];
    NSLog(@"My name is: %@", name);
    if (self.delegate) {
        [self.delegate serverDidpublished:sender];
    }
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict {
    NSLog(@"Error publishing: %@", errorDict);
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender{
    assert(sender == _currentlyResolvingService);
    
    [_currentlyResolvingService stop];
    _currentlyResolvingService = nil;
    
    [self _remoteServiceResolved:sender];

}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary<NSString *,NSNumber *> *)errorDict{
    [_currentlyResolvingService stop];
    _currentlyResolvingService = nil;
}



#pragma mark -<StreamDelegate>

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode{
    
    switch (eventCode) {
        case NSStreamEventOpenCompleted: {
            [self _streamCompletedOpening:aStream];
            break;
        }
        case NSStreamEventHasBytesAvailable: {
            NSLog(@"%d", [(NSInputStream*)aStream hasBytesAvailable]);
            [self _streamHasBytes:aStream];
            break;
        }
        case NSStreamEventHasSpaceAvailable: {
            NSLog(@"%@", [aStream class]);
            [self _streamHasSpace:aStream];
            break;
        }
        case NSStreamEventEndEncountered: {
            [self _streamEncounteredEnd:aStream];
            break;
        }
        case NSStreamEventErrorOccurred: {
            [self _streamEncounteredError:aStream];
            break;
        }
        default:
            break;
    }

}

#pragma mark -<WhenUserChooseService>

- (void)whenUserChooseOneService:(NSNetService *)service{
    
    NSInputStream  * inStream;
    NSOutputStream * outStream;
    [service getInputStream:&inStream
               outputStream:&outStream];
    inStream.delegate = self;
    outStream.delegate = self;
    [inStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                        forMode:NSDefaultRunLoopMode];
    [outStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                         forMode:NSDefaultRunLoopMode];
    [inStream open];
    [outStream open];
}

@end

@implementation Server(Privite)

- (void)_streamCompletedOpening:(NSStream *)stream {
    if(stream == _inputStream) {
        _inputStreamReady = YES;
    }
    if(stream == _outputStream) {
        _outputStreamReady = YES;
    }
    
    if(YES == _inputStreamReady && YES == _outputStreamReady) {
        if (self.connectCompleteCallBack) {
            self.connectCompleteCallBack();
        }
        [self _stopNetService];
    }
}

- (void)_streamHasBytes:(NSStream *)stream {
    NSMutableData *data = [NSMutableData data];
    uint8_t *buf = calloc(_payloadSize, sizeof(uint8_t));
    NSUInteger len = 0;
    while([(NSInputStream*)stream hasBytesAvailable]) {
        len = [_inputStream read:buf maxLength:_payloadSize];
        if(len > 0) {
            [data appendBytes:buf length:len];
        }
    }
    if (data.length && self.didRecieveDataCallback) {
        self.didRecieveDataCallback(data);
    }
    free(buf);
//    [self.delegate server:self didAcceptData:data];
}

- (void)_streamHasSpace:(NSStream *)stream {
    _outputStreamHasSpace = YES;
}

- (void)_streamEncounteredEnd:(NSStream *)stream {
    // remote side died, tell the delegate then restart my local
    // service looking for some other server to connect to
//    [self.delegate server:self lostConnection:nil];
    [self _stopStreams];
    [self publishService:_serviceName];
}

- (void)_streamEncounteredError:(NSStream *)stream {
    [self stop];
}

- (void)_remoteServiceResolved:(NSNetService *)remoteService {
    NSInputStream *inputStream = nil;
    NSOutputStream *outputStream = nil;
    
    if([remoteService getInputStream:&inputStream outputStream:&outputStream]) {
        [self _connectedToInputStream:inputStream outputStream:outputStream];
    }
    
    inputStream = nil;
    outputStream = nil;
}

- (void)_connectedToInputStream:(NSInputStream *)inputStream
                   outputStream:(NSOutputStream *)outputStream {
    // need to close existing streams
    [self _stopStreams];
    
    _inputStream = inputStream;
    _inputStream.delegate = self;
    [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                forMode:NSDefaultRunLoopMode];
    [_inputStream open];
    
    _outputStream = outputStream;
    _outputStream.delegate = self;
    [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                 forMode:NSDefaultRunLoopMode];
    [_outputStream open];
}

- (void)_stopStreams {
    if(nil != _inputStream) {
        [_inputStream close];
        [_inputStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                                    forMode:NSRunLoopCommonModes];
        _inputStream = nil;
        _inputStreamReady = NO;
    }
    if(nil != _outputStream) {
        [_outputStream close];
        [_outputStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                                     forMode:NSRunLoopCommonModes];
        _outputStream = nil;
        _outputStreamReady = NO;
    }
}

- (void)_stopNetService {
    [_service stop];
    [_service removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    _service = nil;
}

@end

void ListeningSocketCallback(CFSocketRef sock,
                             CFSocketCallBackType type,
                             CFDataRef address,
                             const void *data,
                             void *info){
    // the server's socket has accepted a connection request
    // this function is called because it was registered in the
    // socket create method
    if (kCFSocketAcceptCallBack == type) {
        Server *server = (__bridge Server *)info;
        // on an accept the data is the native socket handle
        CFSocketNativeHandle nativeSocketHandle = *(CFSocketNativeHandle *)data;
        // create the read and write streams for the connection to the other process
        CFReadStreamRef   readStream;
        CFWriteStreamRef  writeStream;
        CFStreamCreatePairWithSocket(kCFAllocatorDefault, nativeSocketHandle, &readStream, &writeStream);
        if(NULL != readStream && NULL != writeStream) {
            
            CFReadStreamSetProperty(readStream,
                                    kCFStreamPropertyShouldCloseNativeSocket,
                                    kCFBooleanTrue);
            CFWriteStreamSetProperty(writeStream,
                                     kCFStreamPropertyShouldCloseNativeSocket,
                                     kCFBooleanTrue);
            [server _connectedToInputStream:(__bridge NSInputStream *)readStream
                              outputStream:(__bridge NSOutputStream *)writeStream];
        }else{
            // on any failure, need to destroy the CFSocketNativeHandle
            // since we are not going to use it any more
            close(nativeSocketHandle);
        }
        if (readStream) CFRelease(readStream);
        if (writeStream) CFRelease(writeStream);
    }
}