//
//  NetworkHandler.h
//  NetworkHandler
//
//  Created by Vaisakh krishnan on 3/9/15.
//  Copyright (c) 2015 CL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

typedef enum  {
    HTTPMethodGET,
    HTTPMethodPOST,
    HTTPMethodPUT,
}MethodType;

typedef enum{
    fileTypeJPGImage,
    fileTypePNGImage,
    fileTypeDocument,
    fileTypePowerPoint,
    fileTypeHTML,
    fileTypePDF
}FileType;

extern NSString * const kNetworkFailFailNotification;


@interface NetworkHandler : NSObject

+(BOOL)networkUnavalible;
+(NetworkHandler *) sharedHandler;

- (void)cancellAllOperations ;
- (void)addNetworkHandlerobserver:(id)observer;
- (void)removeNetworkHandlerObserver:(id)observer;
-(void)requestWithRequestUrl:(NSURL *)requestUrl withBody:(NSMutableDictionary *) data withMethodType:(MethodType) method withAccessToken:(NSString *)accesstoken;
-(void)startServieRequestWithSucessBlockSuccessBlock:(void (^)( id responseObject))success FailureBlock:(void (^)( NSString *errorDescription,id errorResponse))failure;
-(void)startUploadRequest:(NSString *)filename withData:(NSData *)Data withType:(FileType)fileType withUrlParameter:(NSString *)urlParameter withImgIndex:(NSString*)mgIndex
             SuccessBlock:(void (^)( id responseObject))success
            ProgressBlock:(void (^)( NSUInteger bytesWritten,long long totalBytesWritten, long long totalBytesExpectedToWrite))progress
             FailureBlock:(void (^)( NSString *errorDescription,id errorResponse))failure;
-(void)startDownloadRequestSuccessBlock:(void (^)( id responseObject))success FailureBlock:(void (^)( NSString *errorDescription))failure  ProgressBlock:(void (^)( NSUInteger bytesWritten,long long totalBytesWritten, long long totalBytesExpectedToWrite))progress;


@end
