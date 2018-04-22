 /*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Object encapsulating information about an iOS app in the 'Top Paid Apps' RSS feed.
  Each one corresponds to a row in the app's table.
 */

//#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JSONModel.h"

@interface AppRecord : JSONModel

@property (nonatomic, strong) NSString *appName;
@property (nonatomic, strong) UIImage *appIcon;
@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *imageURLString;
@property (nonatomic, strong) NSString *appURLString;

@end
