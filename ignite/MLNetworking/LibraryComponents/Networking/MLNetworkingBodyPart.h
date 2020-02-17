//
// MLNetworkingBodyPart.h
// MLNetworking
//
// Created by Nicolas Andres Suarez on 1/3/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Represents a body part, which content could be read from a file or data in memory.
 */
@interface MLNetworkingBodyPart : NSObject <NSCopying>

@property (nonatomic, copy) NSString *boundary;
@property (nonatomic, strong) NSDictionary <NSString *, NSString *> *headers;
@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, assign) uint64_t bodyLength;
@property (nonatomic, assign) BOOL isFirstPart;
@property (nonatomic, assign) BOOL isLastPart;

/**
 *  Initializes the HTTP header `Content-Disposition: form-data; name=#{name}; filename=#{filename};` and `Content-Type: #{mimeType}`, followed by the encoded file data and the multipart form boundary.
 *
 *  @param inputStream The input stream to be appended to the form data
 *  @param length The length of the specified input stream in bytes.
 *  @param name The name to be associated with the specified file. This parameter must not be `nil`.
 *  @param fileName The filename to be used in the `Content-Disposition` header. This parameter must not be `nil`.
 *  @param mimeType mimeType The MIME type of the specified data. (For example, the MIME type for a JPEG image is image/jpeg.) For a list of valid MIME types, see http://www.iana.org/assignments/media-types/. This parameter must not be `nil`.
 */
- (instancetype)initWithStream:(NSInputStream *)inputStream
                        length:(int64_t)length
                          name:(NSString *)name
                      fileName:(NSString *)fileName
                      mimeType:(NSString *)mimeType;
/**
 *  Initializes a body part which content has the HTTP header `Content-Disposition: form-data; name=#{name}; filename=#{filename};` and `Content-Type: #{mimeType}`, followed by the encoded file data and the multipart form boundary.
 *
 *  @param fileUrl The URL corresponding to the file whose content will be appended to the form.
 *  @param name The name to be associated with the specified file. This parameter must not be `nil`.
 *  @param fileName The filename to be used in the `Content-Disposition` header. This parameter must not be `nil`.
 *  @param mimeType mimeType The MIME type of the specified data. (For example, the MIME type for a JPEG image is image/jpeg.) For a list of valid MIME types, see http://www.iana.org/assignments/media-types/. This parameter must not be `nil`.
 *
 */
- (instancetype)initWithFileURL:(NSURL *)fileUrl
                           name:(NSString *)name
                       fileName:(NSString *)fileName
                       mimeType:(NSString *)mimeType;

/**
 *  Initializes a body part which content has the HTTP header `Content-Disposition: form-data; name=#{name}; filename=#{filename};` and `Content-Type: #{mimeType}`, followed by the encoded file data and the multipart form boundary.
 *
 *  @param fileData The data to be encoded and appended to the form data.
 *  @param name The name to be associated with the specified file. This parameter must not be `nil`.
 *  @param fileName The filename to be used in the `Content-Disposition` header. This parameter must not be `nil`.
 *  @param mimeType mimeType The MIME type of the specified data. (For example, the MIME type for a JPEG image is image/jpeg.) For a list of valid MIME types, see http://www.iana.org/assignments/media-types/. This parameter must not be `nil`.
 *
 */
- (instancetype)initWithFileData:(NSData *)fileData
                            name:(NSString *)name
                        fileName:(NSString *)fileName
                        mimeType:(NSString *)mimeType;

/**
 *  Initializes a body part which content has the HTTP header `Content-Disposition: form-data; name=#{name};`, followed by the data and the multipart form boundary.
 *
 *  @param data The data to be encoded and appended to the form data.
 *  @param name The name to be associated with the specified file. This parameter must not be `nil`.
 *
 */
- (instancetype)initWithData:(NSData *)data
                        name:(NSString *)name;

/**
 *  Lenght of the body data
 */
- (uint64_t)contentLength;

/**
 *  Copy into buffer the content of body.
 *
 *  @param buffer Buffer where data will be copied.
 *  @param length Max amount of bytes to be copied.
 *
 *  @return Amount of bytes read.
 */
- (NSInteger)read:(uint8_t *)buffer
        maxLength:(NSUInteger)length;

/**
 *  Return YES if has bytes available to be read.
 */
- (BOOL)hasBytesAvailable;

@end
