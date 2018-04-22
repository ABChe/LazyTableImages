//
//  RunLoopTableViewCell.m
//  LazyTableImages
//
//  Created by 车 on 2018/4/22.
//  Copyright © 2018年 车. All rights reserved.
//

#import "RunLoopTableViewCell.h"
#import "UIImageView+WebCache.h"

@implementation RunLoopTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setModel:(AppRecord *)model indexPath:(NSIndexPath *)indexPath{
    self.textLabel.text = model.appName;
    self.imageView.image = [UIImage imageNamed:@"Placeholder"];
    
    NSDictionary *dic = @{
                          @"model" : model,
                          @"indexPath" : indexPath
                          };
    NSURL *imageURL = [NSURL URLWithString:model.imageURLString];

    [[SDWebImageManager sharedManager] diskImageExistsForURL:imageURL completion:^(BOOL isInCache) {
        if (!isInCache) {
            [self performSelector:@selector(setCellImageViewWithobject:)
                       withObject:dic
                       afterDelay:0.2f
                          inModes:@[NSDefaultRunLoopMode]];
            
        } else {
            [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.imageURLString]
                              placeholderImage:[UIImage imageNamed:@"Placeholder"]];
        }
    }];
}

- (void)setCellImageViewWithobject:(NSDictionary *)dic{
    AppRecord *model = dic[@"model"];
    NSIndexPath *indexPath = dic[@"indexPath"];
    UITableView *tableView = (UITableView *)self.superview;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    dispatch_async(dispatch_get_main_queue(), ^{
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:model.imageURLString]
                          placeholderImage:[UIImage imageNamed:@"Placeholder"]];
    });
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
