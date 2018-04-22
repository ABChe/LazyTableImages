//
//  RootViewController.m
//  LazyTableImages
//
//  Created by 车 on 2018/4/12.
//  Copyright © 2018年 车. All rights reserved.
//

#import "RootViewController.h"
#import "AppRecord.h"
#import "IconDownloader.h"
#import "ParseOperation.h"

#define kCustomRowCount 7

static NSString *CellIdentifier = @"LazyTableCell";
static NSString *PlaceholderCellIdentifier = @"PlaceholderCell";

static NSString *const TopPaidAppsFeed =
@"http://phobos.apple.com/WebObjects/MZStoreServices.woa/ws/RSS/toppaidapplications/limit=75/xml";

@interface RootViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) ParseOperation *parser;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _imageDownloadsInProgress = [NSMutableDictionary dictionary];    
    [self loadData];
}

- (void)loadData {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:TopPaidAppsFeed]];
    
    // create an session data task to obtain and the XML feed
    NSURLSessionDataTask *sessionTask =
    [[NSURLSession sharedSession] dataTaskWithRequest:request
                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                        // in case we want to know the response status code
                                        //NSInteger HTTPStatusCode = [(NSHTTPURLResponse *)response statusCode];
                                        
        if (error != nil)
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                
                if ([error code] == NSURLErrorAppTransportSecurityRequiresSecureConnection)
                {
                    // if you get error NSURLErrorAppTransportSecurityRequiresSecureConnection (-1022),
                    // then your Info.plist has not been properly configured to match the target server.
                    //
                    abort();
                }
                else
                {
                    [self handleError:error];
                }
            }];
        }
        else
        {
            // create the queue to run our ParseOperation
            self.queue = [[NSOperationQueue alloc] init];
            
            // create an ParseOperation (NSOperation subclass) to parse the RSS feed data so that the UI is not blocked
            self.parser = [[ParseOperation alloc] initWithData:data];
            
            __weak RootViewController *weakSelf = self;
            
            self.parser.errorHandler = ^(NSError *parseError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                    [weakSelf handleError:parseError];
                });
            };
            
            // referencing parser from within its completionBlock would create a retain cycle
            __weak ParseOperation *weakParser = self.parser;
            
            self.parser.completionBlock = ^(void) {
                // The completion block may execute on any thread.  Because operations
                // involving the UI are about to be performed, make sure they execute on the main thread.
                //
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                    if (weakParser.appRecordList != nil)
                    {
                        weakSelf.entries = weakParser.appRecordList;
                        
                        // tell our table view to reload its data, now that parsing has completed
                        [weakSelf.tableView reloadData];
                    }
                });
                
                // we are finished with the queue and our ParseOperation
                weakSelf.queue = nil;
            };
            
            [self.queue addOperation:self.parser]; // this will start the "ParseOperation"
        }
    }];
    
    [sessionTask resume];
    
    // show in the status bar that network activity is starting
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
}

- (void)handleError:(NSError *)error
{
    NSString *errorMessage = [error localizedDescription];
    
    // alert user that our current record was deleted, and then we leave this view controller
    //
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Cannot Show Top Paid Apps", @"")
                                                                   message:errorMessage
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         // dissmissal of alert completed
                                                     }];
    
    [alert addAction:OKAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)terminateAllDownloads {
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    
    [self.imageDownloadsInProgress removeAllObjects];
}

- (void)dealloc {
    [self terminateAllDownloads];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self terminateAllDownloads];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger count = self.entries.count;
    
    // if there's no data yet, return enough rows to fill the screen
    if (count == 0)
    {
        return kCustomRowCount;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    NSUInteger nodeCount = self.entries.count;
    
    if (nodeCount == 0 && indexPath.row == 0)
    {
        // add a placeholder cell while waiting on table data
        cell = [tableView dequeueReusableCellWithIdentifier:PlaceholderCellIdentifier forIndexPath:indexPath];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        // Leave cells empty if there's no data yet
        if (nodeCount > 0)
        {
            // Set up the cell representing the app
            AppRecord *appRecord = (self.entries)[indexPath.row];
            
            cell.textLabel.text = appRecord.appName;
            cell.detailTextLabel.text = appRecord.artist;
            
            // Only load cached images; defer new downloads until scrolling ends
            if (!appRecord.appIcon)
            {
                if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
                {
                    [self startIconDownload:appRecord forIndexPath:indexPath];
                }
                // if a download is deferred or in progress, return a placeholder image
                cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
            }
            else
            {
                cell.imageView.image = appRecord.appIcon;
            }
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSMutableDictionary *dicData = [NSMutableDictionary dictionary];
    NSMutableArray *dataArray = [NSMutableArray array];
    for (AppRecord *model in self.entries) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"appName"] = model.appName;
        dic[@"imageURLString"] = model.imageURLString;
        [dataArray addObject:dic];
    }
    dicData[@"data"] = dataArray;
    NSLog(@"%@",dicData);
    
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    //获取完整路径
    NSString *documentsPath = [path objectAtIndex:0];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"appList.plist"];
    NSMutableDictionary *usersDic = [[NSMutableDictionary alloc ] init];
    //设置属性值
    [usersDic setObject:dataArray forKey:@"data"];
    //写入文件
    [usersDic writeToFile:plistPath atomically:YES];
}
#pragma mark - Table cell image support

// -------------------------------------------------------------------------------
//    startIconDownload:forIndexPath:
// -------------------------------------------------------------------------------
- (void)startIconDownload:(AppRecord *)appRecord forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = (self.imageDownloadsInProgress)[indexPath];
    if (iconDownloader == nil)
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.appRecord = appRecord;
        [iconDownloader setCompletionHandler:^{
            
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            
            // Display the newly loaded image
            cell.imageView.image = appRecord.appIcon;
            
            // Remove the IconDownloader from the in progress list.
            // This will result in it being deallocated.
            [self.imageDownloadsInProgress removeObjectForKey:indexPath];
            
        }];
        (self.imageDownloadsInProgress)[indexPath] = iconDownloader;
        [iconDownloader startDownload];
    }
}

- (void)loadImagesForOnscreenRows
{
    if (self.entries.count > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            AppRecord *appRecord = (self.entries)[indexPath.row];
            
            if (!appRecord.appIcon)
                // Avoid the app icon download if the app already has an icon
            {
                [self startIconDownload:appRecord forIndexPath:indexPath];
            }
        }
    }
}


#pragma mark - UIScrollViewDelegate

// -------------------------------------------------------------------------------
//    scrollViewDidEndDragging:willDecelerate:
//  Load images for all onscreen rows when scrolling is finished.
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self loadImagesForOnscreenRows];
    }
}

// -------------------------------------------------------------------------------
//    scrollViewDidEndDecelerating:scrollView
//  When scrolling stops, proceed to load the app icons that are on screen.
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}


@end
