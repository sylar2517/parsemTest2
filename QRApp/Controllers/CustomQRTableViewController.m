//
//  CustomQRTableViewController.m
//  QRApp
//
//  Created by Сергей Семин on 18/07/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "CustomQRTableViewController.h"
#import "Color.h"
#import "QRPost+CoreDataClass.h"
#import "DataManager.h"

typedef enum {
    ColorSchemeTypeRGB = 0,
    ColorSchemeTypeHSV = 1
} ColorSchemeType;

@interface CustomQRTableViewController () <UITextFieldDelegate>

@property (assign, nonatomic) BOOL isBackground;
@property (strong, nonatomic) Color* backgroundColor;
@property (strong, nonatomic) Color* frontColor;
@property (assign, nonatomic) BOOL cutBackgroundColorRow;
@property (assign, nonatomic) BOOL cutFrontColorRow;
@end

@implementation CustomQRTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.cutBackgroundColorRow = NO;
    self.cutFrontColorRow = NO;
    
    self.navigationController.navigationBar.topItem.title = @"Назад";
    if (self.titleText){
        if (![self.typeQR isEqualToString:@"contact"]) {
            self.titleLabel.text = self.titleText;
        } else {
             self.titleLabel.text = @"Контакт";
        }
       
        [self makeQRFromString:self.titleText];
    }
    
    UIBarButtonItem* rigthItem = [[UIBarButtonItem alloc] initWithTitle:@"Сохранить" style:(UIBarButtonItemStyleDone) target:self action:@selector(actionSave:)];
    self.navigationItem.rightBarButtonItem = rigthItem;
    

    self.addIconButton.layer.cornerRadius = 15;
    self.addIconButton.layer.masksToBounds = YES;
    
    [self initColors];
    
    [self refreshScreen];
    
}
#pragma mark - UIBarButtonItem
-(void)actionSave:(UIBarButtonItem*)sender{
    
    #warning SAVING
    
    QRPost* post = [NSEntityDescription insertNewObjectForEntityForName:@"QRPost" inManagedObjectContext:[DataManager sharedManager].persistentContainer.viewContext];
    NSDate* now = [NSDate date];
    post.dateOfCreation = now;
    post.type = self.typeQR;
    post.value = self.titleText;
    
    UIImage* image = self.QRImageView.image;
    
    UIGraphicsBeginImageContext(CGSizeMake(400, 400));
    [image drawInRect:CGRectMake(0, 0, 400, 400)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *imageData = UIImagePNGRepresentation(newImage);
    post.data = imageData;
    
    [[DataManager sharedManager] saveContext];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Methods
-(void)initColors{
    Color* back = [[Color alloc] init];
    Color* front = [[Color alloc] init];
    self.backgroundColor = back;
    self.frontColor = front;
    
    self.backgroundColor.red = self.redComponentSlider.value/255;
    self.backgroundColor.green = self.greenComponentSlider.value/255;
    self.backgroundColor.blue = self.blueComponentSlider.value/255;
    
    self.frontColor.red = self.frontRedComponentSlider.value/255;
    self.frontColor.green = self.frontGreenComponentSlider.value/255;
    self.frontColor.blue = self.frontBlueComponentSlider.value/255;
}
-(void)makeQRFromString:(NSString*)string{
    NSData *stringData = [string dataUsingEncoding: NSUTF8StringEncoding];
    
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    CIImage *qrImage = qrFilter.outputImage;
    float scaleX = self.QRImageView.frame.size.width / qrImage.extent.size.width;
    float scaleY = self.QRImageView.frame.size.height / qrImage.extent.size.height;
    
    qrImage = [qrImage imageByApplyingTransform:CGAffineTransformMakeScale(scaleX, scaleY)];
    
    self.QRImageView.image = [UIImage imageWithCIImage:qrImage
                                                     scale:[UIScreen mainScreen].scale
                                               orientation:UIImageOrientationUp];
}

-(void)makeColorQRFromString:(NSString*)string{

    NSData *stringData = [string dataUsingEncoding: NSUTF8StringEncoding];

    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];

    CIFilter* colorFilter =  [CIFilter filterWithName:@"CIFalseColor"];
    [colorFilter setValue:qrFilter.outputImage forKey:@"inputImage"];

    [colorFilter setValue:[CIColor colorWithRed:self.frontColor.red green:self.frontColor.green blue:self.frontColor.blue] forKey:@"inputColor0"];
    [colorFilter setValue:[CIColor colorWithRed:self.backgroundColor.red green:self.backgroundColor.green blue:self.backgroundColor.blue] forKey:@"inputColor1"];

    CIImage *qrImage = colorFilter.outputImage;
    
    
    float scaleX = self.QRImageView.frame.size.width / qrImage.extent.size.width;
    float scaleY = self.QRImageView.frame.size.height / qrImage.extent.size.height;

    qrImage = [qrImage imageByApplyingTransform:CGAffineTransformMakeScale(scaleX, scaleY)];

    self.QRImageView.image = [UIImage imageWithCIImage:qrImage
                                                 scale:[UIScreen mainScreen].scale
                                           orientation:UIImageOrientationUp];

}

-(void)refreshScreen {
    //с помощью крутилок меняем цвет главного экрана
//    CGFloat red = self.redComponentSlider.value/255;
//    CGFloat green = self.greenComponentSlider.value/255;
//    CGFloat blue = self.blueComponentSlider.value/255;
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    
    if (self.isBackground) {
        red = self.redComponentSlider.value/255;
        green = self.greenComponentSlider.value/255;
        blue = self.blueComponentSlider.value/255;
        
    } else {
        red = self.frontRedComponentSlider.value/255;
        green = self.frontGreenComponentSlider.value/255;
        blue = self.frontBlueComponentSlider.value/255;
        
    }
    
    UIColor *color = nil;
    
    NSInteger result;
    if (self.isBackground) {
        result = self.colorSchemeControl.selectedSegmentIndex;
    } else {
        result = self.frontColorSchemeControl.selectedSegmentIndex;
    }
    
    
    if(result == 0) { //RGB

        if (self.isBackground) {
            self.RInfoLable.text = @"R";
            self.GInfoLable.text = @"G";
            self.BInfoLable.text = @"B";
            
            self.backgroundColor.red = red;
            self.backgroundColor.green = green;
            self.backgroundColor.blue = blue;
        } else {
            self.frontRInfoLable.text = @"R";
            self.frontGInfoLable.text = @"G";
            self.frontBInfoLable.text = @"B";
            
            self.frontColor.red = red;
            self.frontColor.green = green;
            self.frontColor.blue = blue;
        }
        
        [self makeColorQRFromString:self.titleText];
        
    } else {
        
        CGFloat hue;
        CGFloat saturation;
        CGFloat brightness;
        CGFloat alpha;
        
        color = [UIColor colorWithHue:red saturation:green brightness:blue alpha:1];
        if ([color getRed:&hue green:&saturation blue:&brightness alpha:&alpha]) {
            if (self.isBackground) {
                self.RInfoLable.text = @"H";
                self.GInfoLable.text = @"S";
                self.BInfoLable.text = @"B";
                
                self.backgroundColor.red = hue;
                self.backgroundColor.green = saturation;
                self.backgroundColor.blue = brightness;
            } else {
                self.frontColor.red = hue;
                self.frontColor.green = saturation;
                self.frontColor.blue = brightness;
                
                self.frontRInfoLable.text = @"H";
                self.frontGInfoLable.text = @"S";
                self.frontBInfoLable.text = @"B";
                
            }

            [self makeColorQRFromString:self.titleText];
        }
        

    }

    if (self.isBackground) {
        self.rTextField.text = [NSString stringWithFormat:@"%3.f", self.redComponentSlider.value];
        self.gTextField.text = [NSString stringWithFormat:@"%3.f", self.greenComponentSlider.value];
        self.bTextField.text = [NSString stringWithFormat:@"%3.f", self.blueComponentSlider.value];
    } else {
        self.frontrTextField.text = [NSString stringWithFormat:@"%3.f", self.frontRedComponentSlider.value];
        self.frontgTextField.text = [NSString stringWithFormat:@"%3.f", self.frontGreenComponentSlider.value];
        self.frontbTextField.text = [NSString stringWithFormat:@"%3.f", self.frontBlueComponentSlider.value];
    }



}

-(void)changeColorFor:(NSInteger)interValue {
    //с помощью крутилок меняем цвет главного экрана
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    
    if (self.isBackground) {
        red = self.redComponentSlider.value/255;
        green = self.greenComponentSlider.value/255;
        blue = self.blueComponentSlider.value/255;
    } else {
        red = self.frontRedComponentSlider.value/255;
        green = self.frontGreenComponentSlider.value/255;
        blue = self.frontBlueComponentSlider.value/255;
    }

    
    UIColor *color = nil;
    
    CGFloat hue;
    CGFloat saturation;
    CGFloat brightness;
    CGFloat alpha;
    
    if (interValue != ColorSchemeTypeRGB) {
        color = [UIColor colorWithRed:red green:green blue:blue alpha:1];
        if ([color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
            color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
//            self.redComponentSlider.value = hue * 255;
//            self.greenComponentSlider.value = saturation * 255;
//            self.blueComponentSlider.value = brightness * 255;
        }
    } else {
        color = [UIColor colorWithHue:red saturation:green brightness:blue alpha:1];
        if ([color getRed:&hue green:&saturation blue:&brightness alpha:&alpha]) {
            color = [UIColor colorWithRed:hue green:saturation blue:brightness alpha:1];
//            self.redComponentSlider.value = hue * 255;
//            self.greenComponentSlider.value = saturation * 255;
//            self.blueComponentSlider.value = brightness * 255;
        }
        
    }
    
    if (self.isBackground) {
        self.redComponentSlider.value = hue * 255;
        self.greenComponentSlider.value = saturation * 255;
        self.blueComponentSlider.value = brightness * 255;

    } else {
        
        self.frontRedComponentSlider.value = hue * 255;
        self.frontGreenComponentSlider.value = saturation * 255;
        self.frontBlueComponentSlider.value = brightness * 255;

    }
    
    [self refreshScreen];
 
}

#pragma mark - Actions
- (IBAction)actionSlider:(UISlider *)sender {
    if (sender.tag <= 2) {
        self.isBackground = YES;
    } else {
        self.isBackground = NO;
    }
    [self refreshScreen];
}

- (IBAction)actionChangeColorScheme:(UISegmentedControl *)sender {

    if ([sender isEqual:self.colorSchemeControl]) {
        self.isBackground = YES;
    } else {
        self.isBackground = NO;
    }
    
    [self changeColorFor:sender.selectedSegmentIndex];
}

- (IBAction)actionRollUP:(UIButton *)sender {
    self.cutBackgroundColorRow = !self.cutBackgroundColorRow;
    
    self.RInfoLable.hidden = self.cutBackgroundColorRow;
    self.GInfoLable.hidden = self.cutBackgroundColorRow;
    self.BInfoLable.hidden = self.cutBackgroundColorRow;
    self.rTextField.hidden = self.cutBackgroundColorRow;
    self.gTextField.hidden = self.cutBackgroundColorRow;
    self.bTextField.hidden = self.cutBackgroundColorRow;
    self.redComponentSlider.hidden = self.cutBackgroundColorRow;
    self.greenComponentSlider.hidden = self.cutBackgroundColorRow;
    self.blueComponentSlider.hidden = self.cutBackgroundColorRow;
    self.colorSchemeControl.hidden = self.cutBackgroundColorRow;
    
    if (self.cutBackgroundColorRow) {
        [sender setTitle:@"Развернуть" forState:(UIControlStateNormal)];
    } else {
         [sender setTitle:@"Свернуть" forState:(UIControlStateNormal)];
    }
    [self.tableView reloadData];
   
}

- (IBAction)actionRollFrontPanel:(UIButton *)sender {
    self.cutFrontColorRow = !self.cutFrontColorRow;
    
    self.frontRInfoLable.hidden = self.frontGInfoLable.hidden = self.frontBInfoLable.hidden =
    self.frontrTextField.hidden = self.frontgTextField.hidden = self.frontbTextField.hidden =
    self.frontRedComponentSlider.hidden = self.frontGreenComponentSlider.hidden = self.frontBlueComponentSlider.hidden = self.cutFrontColorRow;
    self.frontColorSchemeControl.hidden = self.cutFrontColorRow;
    
    if (self.cutFrontColorRow) {
        [sender setTitle:@"Развернуть" forState:(UIControlStateNormal)];
    } else {
        [sender setTitle:@"Свернуть" forState:(UIControlStateNormal)];
    }
    [self.tableView reloadData];
}
#pragma mark - Table view delegate
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 300;
    } else if (indexPath.row == 1 || indexPath.row == 2){
        
        if (indexPath.row == 1 && self.cutBackgroundColorRow) {
            return 38;
        }
        if (indexPath.row == 2 && self.cutFrontColorRow) {
            return 38;
        }
        
        return 199;
    }
    
    return 50;
}
#pragma mark - TextField delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    textField.text = @"";
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSInteger value = [textField.text integerValue];
    if (value > 255) {
        UIAlertController* ac = [UIAlertController alertControllerWithTitle:@"Значения не должны превышать 255" message:nil preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction* aa = [UIAlertAction actionWithTitle:@"Ок" style:(UIAlertActionStyleCancel) handler:nil];
        [ac addAction:aa];
        [self presentViewController:ac animated:YES completion:nil];
        return NO;
    }

    [(UISlider*)[self.backGroundSliders objectAtIndex:textField.tag] setValue:value];
    [self refreshScreen];
    
    [textField resignFirstResponder];
    
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{

    if (range.length > 3 || range.location > 2) {
        return NO;
    }
  
    NSCharacterSet* validationSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSArray* components =[string componentsSeparatedByCharactersInSet:validationSet];
    if ([components count] > 1){
        return NO;
    } else {
        return YES;
    }
}

//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
//    return 0;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
