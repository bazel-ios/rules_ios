//
// MLNetworkingOperationDelegate.h
// MLNetworking
//
// Created by Fabian Celdeiro on 12/7/14.
// Copyright (c) 2014 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MLNetworkingOperation;
@class MLNetworkingOperationResponse;
@class MLNetworkingOperationError;

@protocol MLNetworkingOperationDelegate <NSObject>

@required
/**
 *  Se invoca cuando una operación termina con éxito
 *
 *  @param operation La operación que realizo el request
 *  @param response  La respuesta obtenida.
 */
- (void)mlNetworkingOperation:(MLNetworkingOperation *)operation
        didFinishWithResponse:(MLNetworkingOperationResponse *)response;

/**
 *  Se invoca cuando una operación termina con error
 *
 *  @param operation La operación que realizó el request.
 *  @param error An error object indicating how the transfer failed.
 */
- (void)mlNetworkingOperation:(MLNetworkingOperation *)operation
             didFailWithError:(MLNetworkingOperationError *)error;

@optional

- (void)mlNetworkingOperation:(MLNetworkingOperation *)operation wasInvalidatedWithNewOperation:(MLNetworkingOperation *)newOperation;

/**
 *  Se invoca cuando una operación termina por cancelación
 *
 *  @param operation La operación que realizó el request
 *  @param error An error object indicating how the transfer was cancelled.
 */
- (void)mlNetworkingOperation:(MLNetworkingOperation *)operation
           didCancelWithError:(MLNetworkingOperationError *)error;

/* Sent periodically to notify the delegate of upload progress.  This
 * information is also available as properties of the operation.
 */
- (void)mlNetworkingOperation:(MLNetworkingOperation *)operation
              didSendBodyData:(int64_t)bytesSent
               totalBytesSent:(int64_t)totalBytesSent
     totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend;

/* Sent periodically to notify the delegate of download progress. */
- (void)mlNetworkingOperation:(MLNetworkingOperation *)operation
                 didWriteData:(int64_t)bytesWritten
            totalBytesWritten:(int64_t)totalBytesWritten
    totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;

/* Sent when a download has been resumed. If a download failed with an
 * error, the -userInfo dictionary of the error will contain an
 * NSURLSessionDownloadTaskResumeData key, whose value is the resume
 * data.
 */
- (void)mlNetworkingOperation:(MLNetworkingOperation *)operation
           didCancelWithError:(MLNetworkingOperationError *)error
            didResumeAtOffset:(int64_t)fileOffset
           expectedTotalBytes:(int64_t)expectedTotalBytes;

@end
