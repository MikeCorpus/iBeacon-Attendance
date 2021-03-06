//
//   ______     _   _                 _          _____ _____  _  __
//  |  ____|   | | (_)               | |        / ____|  __ \| |/ /
//  | |__   ___| |_ _ _ __ ___   ___ | |_ ___  | (___ | |  | | ' /
//  |  __| / __| __| | '_ ` _ \ / _ \| __/ _ \  \___ \| |  | |  <
//  | |____\__ \ |_| | | | | | | (_) | ||  __/  ____) | |__| | . \
//  |______|___/\__|_|_| |_| |_|\___/ \__\___| |_____/|_____/|_|\_\
//
//
//  Version: 3.0.3
//  Copyright (c) 2015 Estimote. All rights reserved.

#import "ESTRule.h"

/**
 * The `ESTDateRule` class defines single rule related to time during the day.
 */
@interface ESTDateRule : ESTRule 

@property (nonatomic, strong) NSNumber *afterHour;
@property (nonatomic, strong) NSNumber *beforeHour;

/**
 *  Initialization method creating rule when targeted hour is later then.
 *
 *  @param hour hour after which rule should be fulfilled
 *
 *  @return create rule object
 */
+ (instancetype)hourLaterThan:(int)hour;

/**
 *  Initialization method creating rule when targeted hour is earlier then.
 *
 *  @param hour hour before which rule should be fulfilled
 *
 *  @return create rule object
 */
+ (instancetype)hourEarlierThan:(int)hour;

/**
 *  Initialization method creating rule when targeted hour is between hours.
 *
 *  @param firstHour  hour after which rule should be fulfilled
 *  @param secondHour hour before which rule should be fulfilled
 *
 *  @return create rule object
 */
+ (instancetype)hourBetween:(int)firstHour and:(int)secondHour;

@end
