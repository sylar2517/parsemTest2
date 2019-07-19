//
//  CustomQRTableViewController.m
//  QRApp
//
//  Created by Сергей Семин on 18/07/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "CustomQRTableViewController.h"
typedef enum {
    ColorSchemeTypeRGB = 0,
    ColorSchemeTypeHSV = 1
} ColorSchemeType;

@interface CustomQRTableViewController () <UITextFieldDelegate>
@property (strong, nonatomic) NSOperation* currentOperation;
@end

@implementation CustomQRTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    
    
    [self refreshScreen];
    
}
#pragma mark - UIBarButtonItem
-(void)actionSave:(UIBarButtonItem*)sender{
    
    
#warning SAVING
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Methods
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

-(void)makeQRFromString:(NSString*)string forColorRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue forBackGround:(BOOL)boolVal{

    NSData *stringData = [string dataUsingEncoding: NSUTF8StringEncoding];

    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];

    CIFilter* colorFilter =  [CIFilter filterWithName:@"CIFalseColor"];
    [colorFilter setValue:qrFilter.outputImage forKey:@"inputImage"];

    
    if (boolVal) {
            [colorFilter setValue:[CIColor colorWithRed:red green:green blue:blue] forKey:@"inputColor1"];//back
            [colorFilter setValue:[CIColor blackColor] forKey:@"inputColor0"]; // front
    } else {
        [colorFilter setValue:[CIColor colorWithRed:red green:green blue:blue] forKey:@"inputColor0"];
        [colorFilter setValue:[CIColor blackColor] forKey:@"inputColor1"];
    }
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
    CGFloat red = self.redComponentSlider.value/255;
    CGFloat green = self.greenComponentSlider.value/255;
    CGFloat blue = self.blueComponentSlider.value/255;
    //UIColor *color = nil;
    
    if(self.colorSchemeControl.selectedSegmentIndex == ColorSchemeTypeRGB) {
        [self makeQRFromString:self.titleText forColorRed:red green:green blue:blue forBackGround:YES];
        self.RInfoLable.text = @"R";
        self.GInfoLable.text = @"G";
        self.BInfoLable.text = @"B";
        
    } else {
        //color = [UIColor colorWithHue:red saturation:green brightness:blue alpha:1];
        self.RInfoLable.text = @"H";
        self.GInfoLable.text = @"S";
        self.BInfoLable.text = @"B";
    }

    self.rTextField.text = [NSString stringWithFormat:@"%3.f", self.redComponentSlider.value];
    self.gTextField.text = [NSString stringWithFormat:@"%3.f", self.greenComponentSlider.value];
    self.bTextField.text = [NSString stringWithFormat:@"%3.f", self.blueComponentSlider.value];
    //self.view.backgroundColor = color;
#warning метод для ЗАДНЕГО ЦВЕТА


}

-(void)changeColorFor:(NSInteger)interValue {
    //с помощью крутилок меняем цвет главного экрана
    CGFloat red = self.redComponentSlider.value/255;
    CGFloat green = self.greenComponentSlider.value/255;
    CGFloat blue = self.blueComponentSlider.value/255;
    
    UIColor *color = nil;
    
    CGFloat hue;
    CGFloat saturation;
    CGFloat brightness;
    CGFloat alpha;
    
    if (interValue != ColorSchemeTypeRGB) {
        color = [UIColor colorWithRed:red green:green blue:blue alpha:1];
        if ([color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
            color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
            self.redComponentSlider.value = hue * 255;
            self.greenComponentSlider.value = saturation * 255;
            self.blueComponentSlider.value = brightness * 255;
        }
    } else {
        color = [UIColor colorWithHue:red saturation:green brightness:blue alpha:1];
        if ([color getRed:&hue green:&saturation blue:&brightness alpha:&alpha]) {
            color = [UIColor colorWithRed:hue green:saturation blue:brightness alpha:1];
            self.redComponentSlider.value = hue * 255;
            self.greenComponentSlider.value = saturation * 255;
            self.blueComponentSlider.value = brightness * 255;
        }
    }
    
    [self refreshScreen];
 
}

#pragma mark - Actions
- (IBAction)actionSlider:(UISlider *)sender {
    [self refreshScreen];
}

- (IBAction)actionChangeColorScheme:(UISegmentedControl *)sender {
    [self changeColorFor:sender.selectedSegmentIndex];
    
}
#pragma mark - Table view delegate
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
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
