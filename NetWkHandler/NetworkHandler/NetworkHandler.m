//
//  NetworkHandler.m
//  NetworkHandler
//
//  Created by Vaisakh krishnan on 3/9/15.
//  Copyright (c) 2015 CL. All rights reserved.
//

#import "AFNetworking.h"
#import "NetworkHandler.h"

#import "Reachability.h"
#import "RequestBodyGenerator.h"
#import "AFHTTPRequestOperationManager.h"

#define CLNetworkErrorMessage @"No internet Access"

NSString * const kNetworkFailFailNotification = @"com.CL.NetworkHandler.fail";

@interface NetworkHandler()

@property (nonatomic, strong) NSURL * requestUrl;
@property (nonatomic, assign) MethodType methodType;

@property (nonatomic, strong) NSString * accesstoken;
@property (nonatomic, strong) NSString * imgIndex;

@property (nonatomic, strong) NSMutableDictionary *bodyDictionary;
@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;

@end

@implementation NetworkHandler

+(NetworkHandler *) sharedHandler{
    static NetworkHandler *handler;
    static dispatch_once_t OnceToken;
    dispatch_once(&OnceToken, ^{
        handler = [[self alloc] init];

    });
    return handler;
}

#pragma mark- Network Check

+ (BOOL)networkUnavalible {
    Reachability *connectionMonitor = [Reachability reachabilityForInternetConnection];
    BOOL  hasInet = YES ;//= [connectionMonitor currentReachabilityStatus] != NotReachable;
    
    if ((connectionMonitor.isConnectionRequired) || (NotReachable == connectionMonitor.currentReachabilityStatus)) {
        hasInet = NO;
        
    } else if((ReachableViaWiFi == connectionMonitor.currentReachabilityStatus) || (ReachableViaWWAN == connectionMonitor.currentReachabilityStatus)){
        hasInet = YES;
    }
    return hasInet;
}

#pragma mark - 

- (void)checkNetwrokAvailability {
   
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:self.requestUrl];
    NSOperationQueue *operationQueue = manager.operationQueue;
    [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status){
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi: {
               // NSLog(@"SO REACHABLE");
                [operationQueue setSuspended:NO];
                break;
            }
            case AFNetworkReachabilityStatusNotReachable:
            default: {
               // NSLog(@"SO UNREACHABLE");
                [[NSNotificationCenter defaultCenter] postNotificationName:kNetworkFailFailNotification object:nil];
                [operationQueue setSuspended:YES];
                break;
            }
        }
    }];
    [manager.reachabilityManager startMonitoring];
}

#pragma mark - init Service Handler

- (id)initWithRequestUrl:(NSURL *) requestUrl withBody:(NSMutableDictionary *) data withMethodType:(MethodType) method withAccessToken:(NSString *)accesstoken{
    self = [super init];
    if(self) {
        [self checkNetwrokAvailability];
        self.requestUrl = requestUrl;
        self.bodyDictionary = data;
        self.methodType = method;
        self.accesstoken =accesstoken;
    }
    return self;
}


-(void)requestWithRequestUrl:(NSURL *)requestUrl withBody:(NSMutableDictionary *) data withMethodType:(MethodType) method withAccessToken:(NSString *)accesstoken{
    [self checkNetwrokAvailability];
    self.requestUrl = requestUrl;
    self.bodyDictionary = data;
    self.methodType = method;
    self.accesstoken =accesstoken;
}


#pragma mark - Statr Api Call

-(void)startServieRequestWithSucessBlockSuccessBlock:(void (^)( id responseObject))success FailureBlock:(void (^)( NSString *errorDescription,id errorResponse))failure{
    
    if (![NetworkHandler networkUnavalible]) {
        failure(@"No internet Access",nil);
        return;
    }
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:self.requestUrl];
    [urlRequest setHTTPMethod:[self httpMethodForRequest:self.methodType]];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    if(self.accesstoken.length!=0)
        [urlRequest setValue:self.accesstoken forHTTPHeaderField:@"access-token"];
    if(self.bodyDictionary.count !=0) {
        [urlRequest setHTTPBody:[[RequestBodyGenerator sharedBodyGenerator]requestBodyGeneratorWith:self.bodyDictionary]];
    }
    urlRequest.timeoutInterval = 100;
    self.requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [self.requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        success([NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil]);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //NSLog(@"Erro Description:%@",error.localizedDescription);
        if(operation.responseObject){
            failure([error localizedDescription],[NSJSONSerialization JSONObjectWithData:operation.responseObject options:NSJSONReadingAllowFragments error:nil]);
        }
        else{
            failure([error localizedDescription],nil);
        }
    }];
    [self.requestOperation start];
    
}



#pragma mark - Image Download

-(void)startDownloadRequestSuccessBlock:(void (^)( id responseObject))success FailureBlock:(void (^)( NSString *errorDescription))failure  ProgressBlock:(void (^)( NSUInteger bytesWritten,long long totalBytesWritten, long long totalBytesExpectedToWrite))progress {
    if (![NetworkHandler networkUnavalible]) {
        failure(CLNetworkErrorMessage);
        return;
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.requestUrl];
    [request setHTTPMethod:[self httpMethodForRequest:self.methodType]];
    if (self.bodyDictionary.count != 0) {
        [request setHTTPBody:[[RequestBodyGenerator sharedBodyGenerator]requestBodyGeneratorWith:self.bodyDictionary]];
    }
    self.requestOperation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    self.requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
    [self.requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure([error localizedDescription]);
    }];
    [self.requestOperation start];
}

#pragma mark - File Upload

-(void)startUploadRequest:(NSString *)filename withData:(NSData *)Data withType:(FileType)fileType withUrlParameter:(NSString *)urlParameter withImgIndex:(NSString*)mgIndex
             SuccessBlock:(void (^)( id responseObject))success
            ProgressBlock:(void (^)( NSUInteger bytesWritten,long long totalBytesWritten, long long totalBytesExpectedToWrite))progress
             FailureBlock:(void (^)( NSString *errorDescription,id errorResponse))failure {
    
    if (![NetworkHandler networkUnavalible]) {
        failure(CLNetworkErrorMessage,nil);
        return;
    }
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:self.requestUrl];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain", nil];
    [manager.requestSerializer setValue:self.accesstoken forHTTPHeaderField:@"access-token" ];
   // NSLog(@"Body dictionary:%@",self.bodyDictionary);
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    AFHTTPRequestOperation *op = [manager POST:urlParameter parameters:self.bodyDictionary constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        if (Data != nil) {
            [formData appendPartWithFileData:Data name:mgIndex fileName:filename mimeType:[self mimeTypeOfFile:fileType]];
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
       // NSLog(@"Success: %@ ***** %@", operation.responseString, responseObject );
       // NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(operation.responseObject){
            failure([error localizedDescription],[NSJSONSerialization JSONObjectWithData:operation.responseObject options:NSJSONReadingAllowFragments error:nil]);
        }
        else{
            failure([error localizedDescription],nil);
        }
    }];
    [self.requestOperation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        progress(bytesWritten,totalBytesWritten,totalBytesExpectedToWrite);
    }];
    [op start];
}


#pragma mark - Cancell All Operations

- (void)cancellAllOperations {
    [self.requestOperation cancel];
}

- (NSString *)httpMethodForRequest:(MethodType) method {
    NSString *type = nil;
    switch (method) {
        case HTTPMethodPOST:
            type = @"POST";
            break;
        case HTTPMethodGET:
            type = @"GET";
            break;
        case HTTPMethodPUT:
            type = @"DELETE";
            break;
            
        default:
            break;
    }
    return type;
}

-(NSString *)mimeTypeOfFile:(FileType)file{
    NSString *type = nil;
    switch (file) {
        case fileTypeJPGImage:
            type = @"image/jpeg";
            break;
        case fileTypePNGImage:
            type = @"image/png";
            break;
        case fileTypeDocument:
            type = @"application/msword";
            break;
        case fileTypePowerPoint:
            type = @"application/vnd.ms-powerpoint";
            break;
        case fileTypeHTML:
            type = @"text/html";
            break;
        case fileTypePDF:
            type = @"application/pdf";
            break;
        default:
            break;
    }
    return type;
}

-(NSString *)extensionOfFile:(FileType)file{
    NSString *extension = nil;
    switch (file) {
        case fileTypeJPGImage:
            extension = @".jpg";
            break;
        case fileTypePNGImage:
            extension = @".png";
            break;
        case fileTypeDocument:
            extension = @".doc";
            break;
        case fileTypeHTML:
            extension = @".html";
            break;
        case fileTypePDF:
            extension = @".pdf";
            break;
        case fileTypePowerPoint:
            extension = @".ppt";
            break;
        default:
            break;
    }
    return extension;
}

#pragma mark - NetworkHandler Observer

- (void)addNetworkHandlerobserver:(id)observer  {
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:@selector(netWorkChanged:) name:kNetworkFailFailNotification object:nil];
}

- (void)removeNetworkHandlerObserver:(id)observer {
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:kNetworkFailFailNotification object:nil];
}

- (void)netWorkChanged:(NSNotification *)notification {
    
}
@end
