//
// MLNetworkingConfigurationUploadMultipart.h
// MLNetworking
//
// Created by Nicolas Andres Suarez on 1/3/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import <MLNetworking/MLNetworkingConfiguration.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Create an NSURLRequest for multipart request.
 *  Allow add parts for files or form data.
 */
@interface MLNetworkingConfigurationUploadMultipart : MLNetworkingConfiguration

/**
 *  Appends the HTTP header `Content-Disposition: form-data; name=#{name}; filename=#{filename};` and `Content-Type: #{mimeType}`, followed by the encoded file data and the multipart form boundary.
 *
 *  @param inputStream The input stream to be appended to the form data
 *  @param length The length of the specified input stream in bytes.
 *  @param name The name to be associated with the specified file. This parameter must not be `nil`.
 *  @param fileName The filename to be used in the `Content-Disposition` header. This parameter must not be `nil`.
 *  @param mimeType mimeType The MIME type of the specified data. (For example, the MIME type for a JPEG image is image/jpeg.) For a list of valid MIME types, see http://www.iana.org/assignments/media-types/. This parameter must not be `nil`.
 */
- (void)addPartWithStream:(NSInputStream *)inputStream
                   length:(int64_t)length
                     name:(NSString *)name
                 fileName:(NSString *)fileName
                 mimeType:(NSString *)mimeType;

/**
 *  Appends the HTTP header `Content-Disposition: form-data; name=#{name}; filename=#{filename};` and `Content-Type: #{mimeType}`, followed by the encoded file data and the multipart form boundary.
 *
 *  @param fileUrl The URL corresponding to the file whose content will be appended to the form.
 *  @param name The name to be associated with the specified file. This parameter must not be `nil`.
 *  @param fileName The filename to be used in the `Content-Disposition` header. This parameter must not be `nil`.
 *  @param mimeType mimeType The MIME type of the specified data. (For example, the MIME type for a JPEG image is image/jpeg.) For a list of valid MIME types, see http://www.iana.org/assignments/media-types/. This parameter must not be `nil`.
 *  @param error    error If an error occurs, upon return contains an `NSError` object that describes the problem.
 *
 *  @return `YES` if the file data was successfully appended otherwise `NO`.
 */
- (BOOL)addPartWithFileURL:(NSURL *)fileUrl
                      name:(NSString *)name
                  fileName:(NSString *)fileName
                  mimeType:(NSString *)mimeType
                     error:(NSError *__autoreleasing *)error;

/**
 *  Appends the HTTP header `Content-Disposition: form-data; name=#{name}; filename=#{filename};` and `Content-Type: #{mimeType}`, followed by the encoded file data and the multipart form boundary.
 *
 *  @param fileData The data to be encoded and appended to the form data.
 *  @param name The name to be associated with the specified file. This parameter must not be `nil`.
 *  @param fileName The filename to be used in the `Content-Disposition` header. This parameter must not be `nil`.
 *  @param mimeType mimeType The MIME type of the specified data. (For example, the MIME type for a JPEG image is image/jpeg.) For a list of valid MIME types, see http://www.iana.org/assignments/media-types/. This parameter must not be `nil`.
 *
 */
- (void)addPartWithFileData:(NSData *)fileData
                       name:(NSString *)name
                   fileName:(NSString *)fileName
                   mimeType:(NSString *)mimeType;

/**
 *  Appends the HTTP header `Content-Disposition: form-data; name=#{name};`, followed by the data and the multipart form boundary.
 *
 *  @param data The data to be encoded and appended to the form data.
 *  @param name The name to be associated with the specified file. This parameter must not be `nil`.
 *
 */
- (void)addPartWithFormData:(NSData *)data
                       name:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
