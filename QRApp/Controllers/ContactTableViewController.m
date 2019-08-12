//
//  ContactTableViewController.m
//  QRApp
//
//  Created by Сергей Семин on 19/07/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "ContactTableViewController.h"
#import "EnterTextViewController.h"
#import "CustomQRTableViewController.h"
#import "ZoomViewController.h"


#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
@interface ContactTableViewController () <UITextFieldDelegate, EnterTextViewControllerDelegate, CNContactPickerDelegate, CNContactViewControllerDelegate>

@property (strong, nonatomic)NSString* result;
@property (strong, nonatomic) CNContactViewController *cncVC;
@end

@implementation ContactTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.contactButton.layer.cornerRadius = 10;
    self.contactButton.layer.masksToBounds = YES;
    self.navigationController.navigationBar.topItem.title = @"Назад";
    self.navigationController.navigationBarHidden = NO;
    
    
    for (UITextField* textField in self.textFields) {
        textField.delegate = self;
    }
    
    if (self.meCard) {
        self.navigationController.navigationBar.tintColor = [UIColor lightGrayColor];
        [self.contactButton setTitle:@"Сохранить контакт" forState:(UIControlStateNormal)];
        
        if (self.imageData) {
            UIBarButtonItem* qr = [[UIBarButtonItem alloc] initWithTitle:@"Открыть QR" style:(UIBarButtonItemStyleDone) target:self action:@selector(actionOpenQR:)];
            //@selector(actionGo:)];
            self.navigationItem.rightBarButtonItem = qr;
        }
        
        NSArray* array = [self.meCard componentsSeparatedByString:@";"];
        
        for (NSString* str in array) {
            if ([str rangeOfString:@"N:"].location != NSNotFound) {
                NSString* test = [str substringFromIndex:[str rangeOfString:@"N:"].location + 2];
               
                NSArray* nameAndLastName = [test componentsSeparatedByString:@","];
                if (nameAndLastName.count == 2) {
                    if (test) {
                        [self.navigationItem setTitle:[NSString stringWithFormat:@"%@ %@", nameAndLastName.firstObject, nameAndLastName.lastObject]];
                    } else {
                        [self.navigationItem setTitle:@"Контакт"];
                    }
                    [(UITextField*)[self.textFields objectAtIndex:1] setText:[nameAndLastName firstObject]];
                    [(UITextField*)[self.textFields objectAtIndex:0] setText:[nameAndLastName lastObject]];
                } else {
                    nameAndLastName = [test componentsSeparatedByString:@" "];
                    if (nameAndLastName.count == 2) {
                        if (test) {
                            [self.navigationItem setTitle:[NSString stringWithFormat:@"%@ %@", nameAndLastName.firstObject, nameAndLastName.lastObject]];
                        } else {
                            [self.navigationItem setTitle:@"Контакт"];
                        }
                        [(UITextField*)[self.textFields objectAtIndex:1] setText:[nameAndLastName firstObject]];
                        [(UITextField*)[self.textFields objectAtIndex:0] setText:[nameAndLastName lastObject]];
                    } else {
                        if (test) {
                            [self.navigationItem setTitle:test];
                        } else {
                            [self.navigationItem setTitle:@"Контакт"];
                        }
                        [(UITextField*)[self.textFields objectAtIndex:0] setText:test];
                    }
                }
            } else if ([str rangeOfString:@"TEL:"].location != NSNotFound){
                NSString* test = [str substringFromIndex:[str rangeOfString:@"TEL:"].location + 4];
                [(UITextField*)[self.textFields objectAtIndex:2] setText:test];
            } else if ([str rangeOfString:@"EMAIL:"].location != NSNotFound){
                NSString* test = [str substringFromIndex:[str rangeOfString:@"EMAIL:"].location + 6];
                [(UITextField*)[self.textFields objectAtIndex:3] setText:test];
            } else if ([str rangeOfString:@"URL:"].location != NSNotFound){
                NSString* test = [str substringFromIndex:[str rangeOfString:@"URL:"].location + 4];
                [(UITextField*)[self.textFields objectAtIndex:4] setText:test];
            } else if ([str rangeOfString:@"NOTE:"].location != NSNotFound){
                NSString* test = [str substringFromIndex:[str rangeOfString:@"NOTE:"].location + 5];
                [(UITextField*)[self.textFields objectAtIndex:5] setText:test];
            } else if ([str rangeOfString:@"NICKNAME:"].location != NSNotFound){
                NSString* test = [str substringFromIndex:[str rangeOfString:@"NICKNAME:"].location + 9];
                [(UITextField*)[self.textFields objectAtIndex:6] setText:test];
            } else if ([str rangeOfString:@"ADR:"].location != NSNotFound){
                NSString* test = [str substringFromIndex:[str rangeOfString:@"ADR:"].location + 4];
                [(UITextField*)[self.textFields objectAtIndex:7] setText:test];
            }  else if ([str rangeOfString:@"BDAY:"].location != NSNotFound){
                NSString* test = [str substringFromIndex:[str rangeOfString:@"BDAY:"].location + 5];
                [(UITextField*)[self.textFields objectAtIndex:8] setText:test];
            }
            
        }
        
    } else {
        UIBarButtonItem* go = [[UIBarButtonItem alloc] initWithTitle:@"Далее" style:(UIBarButtonItemStyleDone) target:self action:@selector(actionGo:)];
        self.navigationItem.rightBarButtonItem = go;
    }
    
    
    
}

#pragma mark - UIBarButtonItem
-(void)actionOpenQR:(UIBarButtonItem*)sender{
    
    ZoomViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ZoomVC"];
    UIImage* image = [UIImage imageWithData:self.imageData];
    UIGraphicsBeginImageContext(CGSizeMake(400, 400));
    [image drawInRect:CGRectMake(0, 0, 400, 400)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    vc.transferedImage = newImage;
    [self presentViewController:vc animated:YES completion:nil];
    
}
-(void)actionGo:(UIBarButtonItem*)sender{
    NSInteger counter = 0;
    for (UITextField* textField in self.textFields) {
        if (textField.text.length > 1) {
            counter++;
        }
    }
    
    if (counter >= 1) {
        NSString* date = [[self.textFields objectAtIndex:8] valueForKey:@"text"];
        if (date.length > 1) {
            NSRange yearRange = NSMakeRange(6, 4);
            NSRange mounthRange = NSMakeRange(3, 2);
            NSRange dayRange = NSMakeRange(0, 2);
            NSString* year = [date substringWithRange:yearRange];
            NSString* mounth = [date substringWithRange:mounthRange];
            NSString* day = [date substringWithRange:dayRange];
            date = [[year stringByAppendingString:mounth] stringByAppendingString:day];
            NSLog(@"%@", date);
        }
        
    
        
        CustomQRTableViewController* tvc = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateQRTVC"];
        NSLog(@"%@", [[self.textFields objectAtIndex:2] valueForKey:@"text"]);
        NSString* result = [NSString stringWithFormat:@"MECARD:N:%@, %@;TEL:%@;EMAIL:%@;URL:%@;ADR:%@;BDAY:%@;NOTE:%@;NICKNAME:%@;;",
                            [[self.textFields objectAtIndex:1] valueForKey:@"text"],
                            [[self.textFields objectAtIndex:0] valueForKey:@"text"],
                            [[self.textFields objectAtIndex:2] valueForKey:@"text"],
                            [[self.textFields objectAtIndex:3] valueForKey:@"text"],
                            [[self.textFields objectAtIndex:4] valueForKey:@"text"],
                            [[self.textFields objectAtIndex:7] valueForKey:@"text"],
                            date,
                            [[self.textFields objectAtIndex:5] valueForKey:@"text"],
                            [[self.textFields objectAtIndex:6] valueForKey:@"text"]];
        tvc.titleText = result;
        tvc.typeQR = @"contact";
        [self.navigationController pushViewController:tvc animated:YES];
    } else {
        UIAlertController* ac = [UIAlertController alertControllerWithTitle:@"Заполните поля" message:nil preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction* aa = [UIAlertAction actionWithTitle:@"Ок" style:(UIAlertActionStyleCancel) handler:nil];
        [ac addAction:aa];
        [self presentViewController:ac animated:YES completion:nil];

    }
    
}
#pragma mark - Action
- (IBAction)actionSelectContact:(UIButton *)sender {
    if (!self.meCard) {
        CNContactPickerViewController* vc = [[CNContactPickerViewController alloc] init];
        vc.delegate = self;
        [self presentViewController:vc animated:YES completion:nil];
    } else {
        CNContactStore *store = [[CNContactStore alloc] init];
        
        // create contact
       
        CNMutableContact *contact = [[CNMutableContact alloc] init];
        contact.familyName = [[self.textFields objectAtIndex:1] valueForKey:@"text"];
        contact.givenName = [[self.textFields objectAtIndex:0] valueForKey:@"text"];
        
        CNLabeledValue *homePhone = [CNLabeledValue labeledValueWithLabel:CNLabelHome value:[CNPhoneNumber phoneNumberWithStringValue:[[self.textFields objectAtIndex:2] valueForKey:@"text"]]];
        contact.phoneNumbers = @[homePhone];
        
        CNLabeledValue *email = [CNLabeledValue labeledValueWithLabel:CNLabelHome value:[[self.textFields objectAtIndex:3] valueForKey:@"text"] ];
        contact.emailAddresses = @[email];
        
        CNLabeledValue *url = [CNLabeledValue labeledValueWithLabel:CNLabelHome value:[[self.textFields objectAtIndex:3] valueForKey:@"text"] ];
        contact.urlAddresses = @[url];
       
        contact.note = [[self.textFields objectAtIndex:5] valueForKey:@"text"];
        
        contact.nickname = [[self.textFields objectAtIndex:6] valueForKey:@"text"];

        
        
        CNContactViewController *controller = [CNContactViewController viewControllerForUnknownContact:contact];
        
        controller.contactStore = store;
        controller.delegate = self;
        
        self.cncVC = controller;
        UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:controller];
        [self presentViewController:nav animated:YES completion:^{
            controller.navigationController.navigationBarHidden = NO;
            UIBarButtonItem* go = [[UIBarButtonItem alloc] initWithTitle:@"Назад" style:(UIBarButtonItemStyleDone) target:self action:@selector(actionBackFromCNC:)];
            controller.navigationItem.leftBarButtonItem = go;
        }];
    }
    
}
-(void)actionBackFromCNC:(UIBarButtonItem*)sender{
    [self.cncVC dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - CNContactViewControllerDelegate
- (void)contactViewController:(CNContactViewController *)viewController didCompleteWithContact:(nullable CNContact *)contact{
    [viewController dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}
//-(BOOL)contactViewController:(CNContactViewController *)viewController shouldPerformDefaultActionForContactProperty:(CNContactProperty *)property{
//    return YES;
//}
#pragma mark - CNContactPickerDelegate
- (void)contactPickerDidCancel:(CNContactPickerViewController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact{
    
    [(UITextField*)[self.textFields objectAtIndex:0] setText:contact.givenName];
    [(UITextField*)[self.textFields objectAtIndex:1] setText:contact.familyName];
    [(UITextField*)[self.textFields objectAtIndex:5] setText:contact.nickname];
    [(UITextField*)[self.textFields objectAtIndex:6] setText:contact.note];
    
    NSArray* phoneNumbers = contact.phoneNumbers;
    CNLabeledValue* number = [phoneNumbers firstObject];;
    CNPhoneNumber* phone = number.value;
    [(UITextField*)[self.textFields objectAtIndex:2] setText:phone.stringValue];
    
    NSArray* addressesArray = contact.postalAddresses;
    CNLabeledValue* adressValue = [addressesArray firstObject];
    CNPostalAddress* address = adressValue.value;
    NSString* addressStr = [[address.city stringByAppendingString:@" "] stringByAppendingString:address.street];
    [(UITextField*)[self.textFields objectAtIndex:7] setText:addressStr];

    NSArray* urlAddresses = contact.urlAddresses;
    CNLabeledValue* urlValue = [urlAddresses firstObject];;
    NSString* URL = urlValue.value;
    [(UITextField*)[self.textFields objectAtIndex:4] setText:URL];

    NSArray* emailAddresses = contact.emailAddresses;
    CNLabeledValue* emailValue = [emailAddresses firstObject];;
    NSString* email = emailValue.value;
    [(UITextField*)[self.textFields objectAtIndex:3] setText:email];
    
    
  
    NSDateComponents* test = contact.birthday;
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate* date = [gregorianCalendar dateFromComponents:test];
    NSLog(@"%@ AAA %@", test, date);
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateStyle:(NSDateFormatterShortStyle)];
    [(UITextField*)[self.textFields objectAtIndex:8] setText:[df stringFromDate:date]];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
//    if (phoneNumbers.count > 1) {
//        UIAlertController* ac = [UIAlertController alertControllerWithTitle:@"Выберете номер" message:nil preferredStyle:(UIAlertControllerStyleAlert)];
//        for (CNLabeledValue* number in phoneNumbers) {
//            CNPhoneNumber* phone = number.value;
//            UIAlertAction* add = [UIAlertAction actionWithTitle:phone.stringValue style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
//                UITextField* textField = [self.textFields objectAtIndex:2];
//                textField.text = phone.stringValue;
//            }];
//            [ac addAction:add];
//        }
//        __weak __block CNContactPickerViewController* blokPicker = picker;
//        __weak __block CNContact* blokContact = contact;
//        [picker dismissViewControllerAnimated:YES completion:^{
//            [self presentViewController:ac animated:YES completion:^{
//                [self parseAdressForContactPicker:blokPicker didSelectContact:blokContact];
//            }];
//        }];
//
//
//    } else {
//        CNLabeledValue* number = [phoneNumbers firstObject];;
//        CNPhoneNumber* phone = number.value;
//        UITextField* textField = [self.textFields objectAtIndex:2];
//        textField.text = phone.stringValue;
//        //[picker dismissViewControllerAnimated:YES completion:nil];
//        [picker dismissViewControllerAnimated:YES completion:^{
//            [self parseAdressForContactPicker:picker didSelectContact:contact];
//        }];
//    }
 
//    NSArray* addressesArray = contact.postalAddresses;
//    if (addressesArray.count > 1) {
//        UIAlertController* ac = [UIAlertController alertControllerWithTitle:@"Выберете адресс" message:nil preferredStyle:(UIAlertControllerStyleAlert)];
//        for (CNLabeledValue* number in addressesArray) {
//            CNPostalAddress* address = number.value;
//            NSString* addressStr = [[address.city stringByAppendingString:@" "] stringByAppendingString:address.street];
//            UIAlertAction* add = [UIAlertAction actionWithTitle:addressStr style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
//                UITextField* textField = [self.textFields objectAtIndex:7];
//                textField.text = addressStr;
//            }];
//            [ac addAction:add];
//        }
//
//
//        [picker dismissViewControllerAnimated:YES completion:^{
//            [self presentViewController:ac animated:YES completion:nil];
//        }];
//
//    } else {
//        CNPostalAddress* address = [addressesArray firstObject];;
//        NSString* addressStr = [[address.city stringByAppendingString:@" "] stringByAppendingString:address.street];
//        UITextField* textField = [self.textFields objectAtIndex:7];
//        textField.text = addressStr;
//        [picker dismissViewControllerAnimated:YES completion:nil];
//    }
    
}


//-(void)parseAdressForContactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact{
//    NSArray* addressesArray = contact.postalAddresses;
//    if (addressesArray.count > 1) {
//        UIAlertController* ac = [UIAlertController alertControllerWithTitle:@"Выберете адресс" message:nil preferredStyle:(UIAlertControllerStyleAlert)];
//        for (CNLabeledValue* number in addressesArray) {
//            CNPostalAddress* address = number.value;
//            NSString* addressStr = [[address.city stringByAppendingString:@" "] stringByAppendingString:address.street];
//            UIAlertAction* add = [UIAlertAction actionWithTitle:addressStr style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
//                UITextField* textField = [self.textFields objectAtIndex:7];
//                textField.text = addressStr;
//            }];
//            [ac addAction:add];
//        }
//
//
//                [picker dismissViewControllerAnimated:YES completion:^{
//        [self presentViewController:ac animated:YES completion:nil];
//                }];
//
//    } else {
//        CNPostalAddress* address = [addressesArray firstObject];;
//        NSString* addressStr = [[address.city stringByAppendingString:@" "] stringByAppendingString:address.street];
//        UITextField* textField = [self.textFields objectAtIndex:7];
//        textField.text = addressStr;
//        [picker dismissViewControllerAnimated:YES completion:nil];
//    }
//}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([textField isEqual:[self.textFields objectAtIndex:7]]) {
        [textField resignFirstResponder];
        EnterTextViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"EnterTextViewController"];
        vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
        vc.delegate = self;
        vc.type = @"date";
        
        CATransition *transition = [[CATransition alloc] init];
        transition.duration = 0.8;
        transition.type = kCATransitionFade;
        transition.subtype = kCATransitionFromTop;
        [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        
        [self presentViewController:vc animated:YES completion:nil];
        
        
    } else if (![textField isEqual:[self.textFields objectAtIndex:8]]) {
        [[self.textFields objectAtIndex:textField.tag+1] becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if ([textField isEqual:[self.textFields objectAtIndex:8]]) {
        for (UITextField* textField in self.textFields) {
            if (textField.isFirstResponder) {
                [textField resignFirstResponder];
            }
        }
        EnterTextViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"EnterTextViewController"];
        vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
        vc.delegate = self;
        vc.type = @"date";
        
        CATransition *transition = [[CATransition alloc] init];
        transition.duration = 0.8;
        transition.type = kCATransitionFade;
        transition.subtype = kCATransitionFromTop;
        [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        
        [self presentViewController:vc animated:YES completion:nil];
        return NO;
    }
    //else {
//        EnterTextViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"EnterTextViewController"];
//        vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//        vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
//        vc.delegate = self;
//        vc.type = @"date";
//
//        CATransition *transition = [[CATransition alloc] init];
//        transition.duration = 0.8;
//        transition.type = kCATransitionFade;
//        transition.subtype = kCATransitionFromTop;
//        [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
//
//        [self presentViewController:vc animated:YES completion:nil];
   // [textField isEqual:[self.textFields objectAtIndex:8]] ? NO :
   // }
    return YES;
}

#pragma mark - Table view delegate
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}
#pragma mark - EnterTextViewControllerDelegate
-(void)textTransfer:(NSString*)string forType:(NSString*)type{
    //NSLog(@"AAA - %@", type);
    UITextField* textField = [self.textFields objectAtIndex:8];
    textField.text = string;

}
//#pragma mark - touches
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    for (UITextField* textField in self.textFields) {
//        if (textField.isFirstResponder) {
//            [textField resignFirstResponder];
//        }
//    }
//}
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
