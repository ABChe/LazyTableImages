//
//  RunLoopTableViewCell.h
//  LazyTableImages
//
//  Created by 车 on 2018/4/22.
//  Copyright © 2018年 车. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppRecord.h"

@interface RunLoopTableViewCell : UITableViewCell

- (void)setModel:(AppRecord *)model indexPath:(NSIndexPath *)indexPath;

@end
