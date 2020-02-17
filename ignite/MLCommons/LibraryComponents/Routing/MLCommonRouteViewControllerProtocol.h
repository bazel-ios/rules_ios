//
// MLCommonRouteViewControllerProtocol.h
// MLCommons
//
// Created by ITAY BRENNER WERTHEIN on 29/11/17.
//

NS_ASSUME_NONNULL_BEGIN

@protocol MLCommonRouteViewControllerProtocol

/**
 *  @brief Returns a newly initialized view controller
 *
 *  @param dictionary dictionary with a "params" and "query" dictionary obtained from the NSURL that requested this object
 *
 *  @return a newly initialized view controller
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
