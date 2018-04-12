//
//  IconDownloader.m
//  LazyTableImages
//
//  Created by 车 on 2018/4/11.
//  Copyright © 2018年 车. All rights reserved.
//

#import "IconDownloader.h"
#import "AppRecord.h"
#import <UIKit/UIKit.h>

#define kAppIconSize 48

@interface IconDownloader ()

@property (nonatomic, strong) NSURLSessionDataTask *sessionTask;

@end

@implementation IconDownloader

- (void)startDownload {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.appRecord.imageURLString]];
    
    _sessionTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                   completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                       
       if (error != nil) {
           if ([error code] == NSURLErrorAppTransportSecurityRequiresSecureConnection) {
               abort();
           }
       }
                                                       
       [[NSOperationQueue mainQueue] addOperationWithBlock:^{
           UIImage *image = [[UIImage alloc] initWithData:data];
           
           if (image.size.width != kAppIconSize || image.size.height != kAppIconSize) {
               CGSize itemSize = CGSizeMake(kAppIconSize, kAppIconSize);
               UIGraphicsBeginImageContextWithOptions(itemSize, NO, 0.0f);
               CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
               [image drawInRect:imageRect];
               self.appRecord.appIcon = UIGraphicsGetImageFromCurrentImageContext();
               UIGraphicsEndImageContext();
           } else {
               self.appRecord.appIcon = image;
           }
           
           if (self.completionHandler != nil)
           {
               self.completionHandler();
           }
       }];
    }];
    
    [self.sessionTask resume];
}

- (void)cancelDownload {
    [self.sessionTask cancel];
    self.sessionTask = nil;
}

@end
