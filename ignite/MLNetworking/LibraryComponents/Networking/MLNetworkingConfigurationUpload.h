//
// MLNetworkingConfigurationUpload.h
// MLNetworking
//
// Created by Fabian Celdeiro on 12/5/14.
// Copyright (c) 2014 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLNetworkingConfiguration.h"

__deprecated_msg("Use `MLNetworkingConfigurationUploadMultipart` instead")
NS_SWIFT_UNAVAILABLE("Use `MLNetworkingConfigurationUploadMultipart` instead")
@interface MLNetworkingConfigurationUpload : MLNetworkingConfiguration

/**
   Appends the HTTP header `Content-Disposition: file; filename=#{filename}; name=#{name}"` and `Content-Type: #{mimeType}`, followed by the encoded file data and the multipart form boundary.

   @param data The data to be encoded and appended to the form data.
   @param name The name to be associated with the specified data. This parameter must not be `nil`.
   @param fileName The filename to be associated with the specified data. This parameter must not be `nil`.
   @param mimeType The MIME type of the specified data. (For example, the MIME type for a JPEG image is image/jpeg.) For a list of valid MIME types, see http://www.iana.org/assignments/media-types/. This parameter must not be `nil`.
 */
- (void)setUploadData:(NSData *)data
                 name:(NSString *)name
             fileName:(NSString *)fileName
             mimeType:(NSString *) mimeType __deprecated_msg("Use `MLNetworkingConfigurationUploadMultipart` instead");

@end
