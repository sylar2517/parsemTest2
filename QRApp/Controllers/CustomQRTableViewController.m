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

@interface CustomQRTableViewController () <UITextFieldDelegate,UINavigationControllerDelegate , UIImagePickerControllerDelegate>

@property (assign, nonatomic) BOOL isBackground;
@property (strong, nonatomic) Color* backgroundColor;
@property (strong, nonatomic) Color* frontColor;
@property (assign, nonatomic) BOOL cutBackgroundColorRow;
@property (assign, nonatomic) BOOL cutFrontColorRow;

@property(strong, nonatomic)UIImagePickerController* imagePickerController;
@property(strong, nonatomic)UIImage* selectedImage;

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
    

    self.addIconButton.layer.cornerRadius = self.makePhotoButton.layer.cornerRadius = 15;
    self.addIconButton.layer.masksToBounds  = self.makePhotoButton.layer.masksToBounds = YES;
    
    [self initColors];
    
    [self refreshScreen];
    
}
#pragma mark - UIBarButtonItem
-(void)actionSave:(UIBarButtonItem*)sender{
    
    if ([self getQRCode]) {
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
    } else {
        UIAlertController* ac = [UIAlertController alertControllerWithTitle:@"Данные цвета не подходят" message:nil preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction* aa = [UIAlertAction actionWithTitle:@"Ок" style:(UIAlertActionStyleCancel) handler:nil];
        [ac addAction:aa];
        [self presentViewController:ac animated:YES completion:nil];
    }
    
    
}

#pragma mark - Methods
-(BOOL)getQRCode{
    @autoreleasepool {
        
        NSData* imageData = UIImagePNGRepresentation(self.QRImageView.image);
        CIImage* ciImage = [CIImage imageWithData:imageData];
        CIContext* context = [CIContext context];
        NSDictionary* options = @{ CIDetectorAccuracy : CIDetectorAccuracyHigh }; // Slow but thorough
        
        CIDetector* qrDetector = [CIDetector detectorOfType:CIDetectorTypeQRCode
                                                    context:context
                                                    options:options];
        if ([[ciImage properties] valueForKey:(NSString*) kCGImagePropertyOrientation] == nil) {
            options = @{ CIDetectorImageOrientation : @1};
        } else {
            options = @{ CIDetectorImageOrientation : [[ciImage properties] valueForKey:(NSString*) kCGImagePropertyOrientation]};
        }
        
        NSArray * features = [qrDetector featuresInImage:ciImage
                                                 options:options];
        if (features != nil && features.count > 0) {
            for (CIQRCodeFeature* qrFeature in features) {
                if (qrFeature.messageString) {
                    return YES;
                }
            }
        }
        
        return NO;
    }
    
}


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
    
    
    self.hexBackTextField.text =  [self hexFromUIColor:[UIColor colorWithRed:self.redComponentSlider.value/255
                                                                       green:self.greenComponentSlider.value/255
                                                                        blue:self.blueComponentSlider.value/255
                                                                       alpha:1]];
    
    self.hexFrontTextField.text =  [self hexFromUIColor:
                                    [UIColor colorWithRed:self.frontRedComponentSlider.value/255
                                                   green:self.frontRedComponentSlider.value/255
                                                    blue:self.frontRedComponentSlider.value/255
                                                   alpha:1]];
    
    
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
            
            self.hexBackTextField.text =  [self hexFromUIColor:[UIColor colorWithRed:red
                                                                               green:green
                                                                                blue:blue
                                                                               alpha:1]];
            
        } else {
            self.frontRInfoLable.text = @"R";
            self.frontGInfoLable.text = @"G";
            self.frontBInfoLable.text = @"B";
            
            self.frontColor.red = red;
            self.frontColor.green = green;
            self.frontColor.blue = blue;
            
            self.hexFrontTextField.text =  [self hexFromUIColor:[UIColor colorWithRed:red
                                                                               green:green
                                                                                blue:blue
                                                                               alpha:1]];
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
                
                
                self.hexBackTextField.text =  [self hexFromUIColor:color];
                
            } else {
                self.frontColor.red = hue;
                self.frontColor.green = saturation;
                self.frontColor.blue = brightness;
                
                self.frontRInfoLable.text = @"H";
                self.frontGInfoLable.text = @"S";
                self.frontBInfoLable.text = @"B";
                
                self.hexFrontTextField.text =  [self hexFromUIColor:color];
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
        [color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    } else {
        color = [UIColor colorWithHue:red saturation:green brightness:blue alpha:1];
        [color getRed:&hue green:&saturation blue:&brightness alpha:&alpha];
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

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (NSString *) hexFromUIColor:(UIColor *)color {
    
    if (CGColorGetNumberOfComponents(color.CGColor) < 4) {
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        color = [UIColor colorWithRed:components[30] green:components[141] blue:components[13] alpha:components[1]];
    }
    if (CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)) != kCGColorSpaceModelRGB) {
        return [NSString stringWithFormat:@"#FFFFFF"];
    }
    return [NSString stringWithFormat:@"#%02X%02X%02X", (int)((CGColorGetComponents(color.CGColor))[0]*255.0), (int)((CGColorGetComponents(color.CGColor))[1]*255.0), (int)((CGColorGetComponents(color.CGColor))[2]*255.0)];
    
}
#pragma mark - Actions
- (IBAction)actionSlider:(UISlider *)sender {
    if (sender.tag <= 2) {
        self.isBackground = YES;
    } else {
        self.isBackground = NO;
    }
    [self refreshScreen];
    if (self.selectedImage) {
        self.QRImageView.image = [self imageByCombiningImage:self.QRImageView.image withImage:self.selectedImage];
    }
}

- (IBAction)actionChangeColorScheme:(UISegmentedControl *)sender {

    if ([sender isEqual:self.colorSchemeControl]) {
        self.isBackground = YES;
    } else {
        self.isBackground = NO;
    }
    
    [self changeColorFor:sender.selectedSegmentIndex];
    if (self.selectedImage) {
        self.QRImageView.image = [self imageByCombiningImage:self.QRImageView.image withImage:self.selectedImage];
    }
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

- (IBAction)actionAddLogo:(UIButton *)sender {
    UIImagePickerController* vc = [[UIImagePickerController alloc] init];
    vc.delegate = self;
    
    vc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    vc.allowsEditing = NO;
    self.imagePickerController =vc;
    [self presentViewController:vc animated:YES completion:nil];   
}

- (IBAction)actionTakePhoto:(UIButton *)sender {
    UIImagePickerController* vc = [[UIImagePickerController alloc] init];
    vc.delegate = self;
    vc.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:vc animated:YES completion:nil];
}
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    if (image) {
        self.selectedImage = image;
        [picker dismissViewControllerAnimated:YES completion:^{
            self.QRImageView.image = [self imageByCombiningImage:self.QRImageView.image withImage:image];
        }];
        
    }
}

- (UIImage*)imageByCombiningImage:(UIImage*)firstImage withImage:(UIImage*)secondImage {
    UIImage *image = nil;
    
    CGSize size = self.QRImageView.frame.size;

   // UIGraphicsBeginImageContext(size);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [firstImage drawInRect:CGRectMake(0,0,size.width, size.height)];
    
    CGFloat widthSecondImage = 0.3 * CGRectGetWidth(self.QRImageView.frame);
    CGRect rectForsecondImage = CGRectMake(size.width / 2 - widthSecondImage/2,size.width / 2 - widthSecondImage/2,widthSecondImage, widthSecondImage);
    [[UIColor colorWithRed:self.backgroundColor.red green:self.backgroundColor.green blue:self.backgroundColor.blue alpha:1] setFill];
    [[UIBezierPath bezierPathWithOvalInRect:rectForsecondImage] fill];
    
    CGRect interiorBox = CGRectInset(rectForsecondImage, 1, 1);
    UIBezierPath *interior = [UIBezierPath bezierPathWithOvalInRect:interiorBox];
    [interior addClip];
    
    [secondImage drawInRect:rectForsecondImage];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:NO completion:nil];
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
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
    
    return 75;
}
#pragma mark - TextField delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField.tag == 10 || textField.tag == 11) {
        textField.text = @"#";
    } else {
        textField.text = @"";
    }
    
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField.tag != 10 && textField.tag != 11) {
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
        
    } else {
        if ([textField isEqual:self.hexBackTextField]) {
            UIColor* color = [self colorFromHexString:textField.text];
            //
            CGFloat red;
            CGFloat green;
            CGFloat blue;
            CGFloat alpha;
            
            [color getRed:&red green:&green blue:&blue alpha:&alpha];
            
            self.redComponentSlider.value = red * 255;
            self.greenComponentSlider.value = green * 255;
            self.blueComponentSlider.value = blue * 255;
            
            self.isBackground = YES;
            
            [self refreshScreen];
            
            if (self.selectedImage) {
                self.QRImageView.image = [self imageByCombiningImage:self.QRImageView.image withImage:self.selectedImage];
            }
            //
            //
            
        } else {
            UIColor* color = [self colorFromHexString:textField.text];
            
            CGFloat red;
            CGFloat green;
            CGFloat blue;
            CGFloat alpha;
            
            [color getRed:&red green:&green blue:&blue alpha:&alpha];
            
            self.frontRedComponentSlider.value = red * 255;
            self.frontGreenComponentSlider.value = green * 255;
            self.frontBlueComponentSlider.value = blue * 255;
            
            self.isBackground = NO;
            
            [self refreshScreen];
            
            if (self.selectedImage) {
                self.QRImageView.image = [self imageByCombiningImage:self.QRImageView.image withImage:self.selectedImage];
            }
        }
    }
    
   [textField resignFirstResponder];
    
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (textField.tag != 10 && textField.tag != 11) {
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
    } else {
        if (range.length > 7 || range.location > 6) {
            return NO;
        } else {
            return YES;
        }
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
//-(void)makeQRWithLogo:(NSString*)string{
//
//    if (self.selectedImage) {
//        NSData *stringData = [string dataUsingEncoding: NSUTF8StringEncoding];
//
//        CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
//        [qrFilter setValue:stringData forKey:@"inputMessage"];
//        [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
//
//        CIFilter* colorFilter =  [CIFilter filterWithName:@"CIFalseColor"];
//        [colorFilter setValue:qrFilter.outputImage forKey:@"inputImage"];
//
//        [colorFilter setValue:[CIColor colorWithRed:self.frontColor.red green:self.frontColor.green blue:self.frontColor.blue] forKey:@"inputColor0"];
//        [colorFilter setValue:[CIColor colorWithRed:self.backgroundColor.red green:self.backgroundColor.green blue:self.backgroundColor.blue] forKey:@"inputColor1"];
//        [colorFilter setValue:[CIColor colorWithRed:self.backgroundColor.red green:self.backgroundColor.green blue:self.backgroundColor.blue] forKey:@"inputColor1"];
//
//        CIFilter* filter = [CIFilter filterWithName:@"CISourceOverCompositing"];
//        //[filter setValue:colorFilter.outputImage forKey:@"inputImage"];
//        CGAffineTransform test = CGAffineTransformMakeTranslation((CGRectGetMidX(self.QRImageView.frame) - self.selectedImage.size.width/2),
//                                                                   (CGRectGetMidY(self.QRImageView.frame) - self.selectedImage.size.height/2));
//        [filter setValue:self.selectedImage forKey:@"inputBackgroundImage"];
////        [filter setValue: forKey:@"inputImage"];
//        CIImage *qrImage = filter.outputImage;
//        qrImage = [qrImage imageByApplyingTransform:test];
//
////        float scaleX = 0.5*self.QRImageView.frame.size.width / qrImage.extent.size.width;
////        float scaleY = 0.5*self.QRImageView.frame.size.height / qrImage.extent.size.height;
////
////        qrImage = [qrImage imageByApplyingTransform:CGAffineTransformMakeScale(scaleX, scaleY)];
//
//        self.QRImageView.image = [UIImage imageWithCIImage:qrImage
//                                                     scale:[UIScreen mainScreen].scale
//                                               orientation:UIImageOrientationUp];
//        #warning TEST2
//    } else {
//        return;
//    }
//
//
//}

@end
