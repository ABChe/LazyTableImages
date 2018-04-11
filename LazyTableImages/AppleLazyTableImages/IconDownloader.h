//
//  IconDownloader.h
//  LazyTableImages
//
//  Created by 车 on 2018/4/11.
//  Copyright © 2018年 车. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AppRecord;

@interface IconDownloader : NSObject

@property (nonatomic, strong) AppRecord *appRecord;

@property (nonatomic,copy   ) void (^completionHandler)(void);

- (void)startDownload;
- (void)cancaleDownload;

@end
