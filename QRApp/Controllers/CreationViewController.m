//
//  CreationViewController.m
//  QRApp
//
//  Created by Сергей Семин on 01/07/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "CreationViewController.h"
#import "QRCollectionViewCell.h"
#import "DataManager.h"
#import <CoreData/CoreData.h>

#import "HistoryPost+CoreDataClass.h"

@interface CreationViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property(strong, nonatomic)NSArray* history;
@end

@implementation CreationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = YES;
    
    
    NSArray* array = [[NSArray alloc] initWithObjects:self.simpleQR, self.customQR, nil];
    for (UIButton* object in array) {
        object.layer.cornerRadius = 10;
        object.layer.masksToBounds = YES;
    }
    self.createView.layer.cornerRadius = 10;
    self.createView.layer.masksToBounds = YES;
    
    self.collectionView.layer.cornerRadius = 20;
    self.collectionView.layer.masksToBounds = YES;
    
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self loadBase];
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:NO];
    [self reload];
}
-(void)loadBase{
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    NSEntityDescription* description = [NSEntityDescription entityForName:@"HistoryPost" inManagedObjectContext:[DataManager sharedManager].persistentContainer.viewContext];
    [request setEntity:description];
    [request setFetchBatchSize:20];
    NSSortDescriptor* sdName = [NSSortDescriptor sortDescriptorWithKey:@"dateOfCreation" ascending:NO];
    [request setSortDescriptors:@[sdName]];
    NSError* reqestError = nil;
    NSArray* resultArray = [[DataManager sharedManager].persistentContainer.viewContext executeFetchRequest:request error:&reqestError];
    if (reqestError) {
        NSLog(@"%@", [reqestError localizedDescription]);
    }
    self.history = resultArray;
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.history.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    QRCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(QRCollectionViewCell *)cell atIndexPath:(NSIndexPath*)indexPath{
    HistoryPost* post = [self.history objectAtIndex:indexPath.row];
    
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd/MM/yy HH:mm"];
    cell.dateLabel.text = [NSString stringWithFormat:@"%@  %@", [df stringFromDate:post.dateOfCreation], post.type];
    
    if ([post.type isEqualToString:@"QR"]) {
        cell.infoLabel.text = post.value;
        NSData* dataPicture = post.picture;
       
        cell.imageCell.layer.magnificationFilter = kCAFilterNearest;
         cell.imageCell.image = [UIImage imageWithData:dataPicture];
    } else if ([post.type isEqualToString:@"PDF"]){
        cell.infoLabel.text = post.value;
        cell.imageCell.image = [UIImage imageNamed:@"pdf"];
        cell.imageCell.backgroundColor = [UIColor redColor];
        
    }
    
}
#pragma mark - Methods

-(UIImage*)makeQRFromText:(NSString*)text from:(UIImageView*)imageView{
    
    NSData *stringData = [text dataUsingEncoding: NSUTF8StringEncoding];
    
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    CIImage *qrImage = qrFilter.outputImage;
    float scaleX = imageView.frame.size.width / qrImage.extent.size.width;
    float scaleY = imageView.frame.size.height / qrImage.extent.size.height;
    
    qrImage = [qrImage imageByApplyingTransform:CGAffineTransformMakeScale(scaleX, scaleY)];
    
    return [UIImage imageWithCIImage:qrImage
                               scale:[UIScreen mainScreen].scale
                         orientation:UIImageOrientationUp];
    
}

-(void) reload{
    [self loadBase];
    [self.collectionView reloadData];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//- (IBAction)test:(id)sender {
//    [self loadBase];
//    [self.collectionView reloadData];
//}
@end
