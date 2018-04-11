//
//  ParseOperation.h
//  LazyTableImages
//
//  Created by 车 on 2018/4/11.
//  Copyright © 2018年 车. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParseOperation : NSOperation

@property (nonatomic, copy) void(^errorHandler)(NSError *error);

@property (nonatomic, strong, readonly) NSArray *appRecordList;

- (instancetype)initWithData:(NSData *)data;

@end
