//
// MLNetworkingMultipartBodyStream.h
// MLNetworking
//
// Created by Nicolas Andres Suarez on 1/3/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLNetworkingBodyPart.h"

/**
 *  This class is reposible to create the body for a multipart request.
 *  Is a subclass from NSInputStream, so you can set as HTTPBodyStream in an NSURLRequest.
 */
@interface MLNetworkingMultipartBodyStream : NSInputStream <NSCopying>

@property (nonatomic, strong) NSMutableArray <MLNetworkingBodyPart *> *bodyParts;
@property (nonatomic, copy) NSString *boundary;

/**
 *  Add a MLNetworkingBodyPart
 *
 *  @param bodyPart MLNetworkingBodyPart object
 */
- (void)addBodyPart:(MLNetworkingBodyPart *)bodyPart;

/**
 *  Calculates lenght of multipart body
 *
 *  @return content lenght or zero if no has parts
 */
- (uint64_t)contentLength;

@end
