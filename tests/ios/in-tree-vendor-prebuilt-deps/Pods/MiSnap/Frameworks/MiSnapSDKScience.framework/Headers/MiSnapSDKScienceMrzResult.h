//
//  MiSnapSDKScienceMrzResult.h
//  MiSnapSDKScience
//
//  Created by Stas Tsuprenko on 11/4/19.
//  Copyright © 2019 miteksystems. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 * MobileFlowMicrResult stores the value from a passport or an id card as the result
 * of the MiSnapScienceSDK analyzeFrame method
 *
*/
@interface MiSnapSDKScienceMrzResult : NSObject

/*!
 *  The confidence that the MRZ was found
 */
@property (nonatomic, assign) NSInteger confidence;

/*!
 *  The MRZ string
 */
@property (nonatomic, strong) NSString *mrzString;

/*!
 *  Document number parsed from the `mrzString`
 */
@property (nonatomic, strong) NSString *docNumber;

/*!
 *  Date of birth parsed from the `mrzString` in format YYMMDD
 */
@property (nonatomic, strong) NSString *dob;

/*!
 *  Date of expiry parsed from the `mrzString` in format YYMMDD
 */
@property (nonatomic, strong) NSString *doe;

/*!
 *  First name parsed from the `mrzString`
 */
@property (nonatomic, strong) NSString *firstName;

/*!
 *  Last name parsed from the `mrzString`
 */
@property (nonatomic, strong) NSString *lastName;

@end

NS_ASSUME_NONNULL_END
