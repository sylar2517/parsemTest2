//
//  QRFromImageTVC.m
//  QRApp
//
//  Created by Сергей Семин on 01/08/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "QRFromImageTVC.h"
#import "Color.h"
#import "QRPost+CoreDataClass.h"
#import "DataManager.h"
typedef enum {
    ColorSchemeTypeRGB = 0,
    ColorSchemeTypeHSV = 1
} ColorSchemeType;

@interface QRFromImageTVC ()
@property (strong, nonatomic) Color* backgroundColor;
@end

@implementation QRFromImageTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem* rigthItem = [[UIBarButtonItem alloc] initWithTitle:@"Сохранить" style:(UIBarButtonItemStyleDone) target:self action:@selector(actionSave:)];
    self.navigationItem.rightBarButtonItem = rigthItem;
    
   

    if (self.titleText && self.transferImage) {
        
        self.titleLabel.text = self.titleText;
        
        UIImage* image1 = [self makeQRFromString:self.titleText];
        UIImage* image2 = self.transferImage;
    
        self.QRImageView.image = [self imageByCombiningImage:image2 withImage:image1];
    }
    
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
            UIAlertController* ac = [UIAlertController alertControllerWithTitle:@"Данный цвет или фон не подходит" message:nil preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction* aa = [UIAlertAction actionWithTitle:@"Ок" style:(UIAlertActionStyleCancel) handler:nil];
            [ac addAction:aa];
            [self presentViewController:ac animated:YES completion:nil];
        }
    
    
}
#pragma mark - Actions
- (IBAction)actionSlider:(UISlider *)sender {
 
    [self refreshScreen];
   
}

- (IBAction)actionChangeColorScheme:(UISegmentedControl *)sender {
    
 
    
    [self changeColorFor:sender.selectedSegmentIndex];
    
}
#pragma mark - Methods
-(void)initColors{
    Color* back = [[Color alloc] init];
    
    self.backgroundColor = back;
    
    
    self.backgroundColor.red = self.redComponentSlider.value/255;
    self.backgroundColor.green = self.greenComponentSlider.value/255;
    self.backgroundColor.blue = self.blueComponentSlider.value/255;
    

    
    self.hexBackTextField.text =  [self hexFromUIColor:[UIColor colorWithRed:self.redComponentSlider.value/255
                                                                       green:self.greenComponentSlider.value/255
                                                                        blue:self.blueComponentSlider.value/255
                                                                       alpha:1]];

    
    
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
-(void)refreshScreen {
    //с помощью крутилок меняем цвет главного экрана
    CGFloat red = self.redComponentSlider.value/255;
    CGFloat green = self.greenComponentSlider.value/255;
    CGFloat blue = self.blueComponentSlider.value/255;
   
    
    UIColor *color = nil;
    
    NSInteger result = self.colorSchemeControl.selectedSegmentIndex;
    
    
    if(result == 0) {
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
        
        
        UIImage* image1 = [self makeColorQRFromString:self.titleText];
        UIImage* image2 = self.transferImage;
        
        self.QRImageView.image = [self imageByCombiningImage:image2 withImage:image1];
   
        //[self makeColorQRFromString:self.titleText];
        
    } else {
        
        CGFloat hue;
        CGFloat saturation;
        CGFloat brightness;
        CGFloat alpha;
        
        color = [UIColor colorWithHue:red saturation:green brightness:blue alpha:1];
        if ([color getRed:&hue green:&saturation blue:&brightness alpha:&alpha]) {
    
            self.RInfoLable.text = @"H";
            self.GInfoLable.text = @"S";
            self.BInfoLable.text = @"B";
            
            self.backgroundColor.red = hue;
            self.backgroundColor.green = saturation;
            self.backgroundColor.blue = brightness;
            
            self.hexBackTextField.text =  [self hexFromUIColor:color];
                
            UIImage* image1 = [self makeColorQRFromString:self.titleText];
            UIImage* image2 = self.transferImage;
            
            self.QRImageView.image = [self imageByCombiningImage:image2 withImage:image1];
        }
        
        
    }

    self.rTextField.text = [NSString stringWithFormat:@"%3.f", self.redComponentSlider.value];
    self.gTextField.text = [NSString stringWithFormat:@"%3.f", self.greenComponentSlider.value];
    self.bTextField.text = [NSString stringWithFormat:@"%3.f", self.blueComponentSlider.value];  
}






-(UIImage*)makeColorQRFromString:(NSString*)string{

    NSData *stringData = [string dataUsingEncoding: NSUTF8StringEncoding];

    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];

    CIFilter* colorFilter =  [CIFilter filterWithName:@"CIFalseColor"];
    [colorFilter setValue:qrFilter.outputImage forKey:@"inputImage"];

    if (self.background) {
        [colorFilter setValue:[CIColor colorWithRed:self.backgroundColor.red green:self.backgroundColor.green blue:self.backgroundColor.blue] forKey:@"inputColor0"];
        [colorFilter setValue:[CIColor clearColor] forKey:@"inputColor1"]; //back
    } else {
        [colorFilter setValue:[CIColor clearColor] forKey:@"inputColor0"];
        [colorFilter setValue:[CIColor colorWithRed:self.backgroundColor.red green:self.backgroundColor.green blue:self.backgroundColor.blue] forKey:@"inputColor1"];
    }

    CIImage *qrImage = colorFilter.outputImage;


    float scaleX = self.QRImageView.frame.size.width / qrImage.extent.size.width;
    float scaleY = self.QRImageView.frame.size.height / qrImage.extent.size.height;

    qrImage = [qrImage imageByApplyingTransform:CGAffineTransformMakeScale(scaleX, scaleY)];

    return [UIImage imageWithCIImage:qrImage
                                                 scale:[UIScreen mainScreen].scale
                                           orientation:UIImageOrientationUp];

}
-(void)changeColorFor:(NSInteger)interValue {
    //с помощью крутилок меняем цвет главного экрана
    CGFloat red;
    CGFloat green;
    CGFloat blue;

    red = self.redComponentSlider.value/255;
    green = self.greenComponentSlider.value/255;
    blue = self.blueComponentSlider.value/255;

    
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

    self.redComponentSlider.value = hue * 255;
    self.greenComponentSlider.value = saturation * 255;
    self.blueComponentSlider.value = brightness * 255;
  
    
    [self refreshScreen];
    
}

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

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

-(UIImage*) makeQRFromString:(NSString*)string{
    NSData *stringData = [string dataUsingEncoding: NSUTF8StringEncoding];
    
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    CIFilter* colorFilter =  [CIFilter filterWithName:@"CIFalseColor"];
    [colorFilter setValue:qrFilter.outputImage forKey:@"inputImage"];
    
    
    if (self.background) {
        [colorFilter setValue:[CIColor whiteColor] forKey:@"inputColor0"];
        [colorFilter setValue:[CIColor clearColor] forKey:@"inputColor1"]; //back
    } else {
        [colorFilter setValue:[CIColor clearColor] forKey:@"inputColor0"];
        [colorFilter setValue:[CIColor whiteColor] forKey:@"inputColor1"]; //back
    }
 
    CIImage *qrImage = colorFilter.outputImage;
    
    
    float scaleX = self.QRImageView.frame.size.width / qrImage.extent.size.width;
    float scaleY = self.QRImageView.frame.size.height / qrImage.extent.size.height;
    
    qrImage = [qrImage imageByApplyingTransform:CGAffineTransformMakeScale(scaleX, scaleY)];
    
    return [UIImage imageWithCIImage:qrImage
                               scale:[UIScreen mainScreen].scale
                         orientation:UIImageOrientationUp];
}

- (UIImage*)imageByCombiningImage:(UIImage*)firstImage withImage:(UIImage*)secondImage {
    UIImage *image = nil;
    
    CGSize size = self.QRImageView.frame.size;
    
    // UIGraphicsBeginImageContext(size);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [firstImage drawInRect:CGRectMake(0,0,size.width, size.height)];
    [secondImage drawInRect:CGRectMake(0,0,size.width, size.height)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


#pragma mark - datasourse
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

#pragma mark - TextField delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if ([textField isEqual:self.hexBackTextField]) {
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
    
    if (![textField isEqual:self.hexBackTextField]) {
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

        
        [self refreshScreen];
  
    }
    
    [textField resignFirstResponder];
    
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (![textField isEqual:self.hexBackTextField]) {
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

@end
