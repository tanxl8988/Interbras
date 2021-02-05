//
//  APKGuideViewController.m
//  万能AIT
//
//  Created by mac on 2020/7/13.
//  Copyright © 2020 APK. All rights reserved.
//

#import "APKGuideViewController.h"

@interface APKGuideViewController ()
@property (weak, nonatomic) IBOutlet UIButton *connectBtn;
@property (weak, nonatomic) IBOutlet UILabel *tipL;
@property (weak, nonatomic) IBOutlet UILabel *tipL2;
@property (nonatomic,retain) UILabel *titleL;

@end

@implementation APKGuideViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tipL.text = @"Precisamos cinectar na câmera paracomeçãr!";
    
    self.tipL2.attributedText = [self getTipL2Text];
    
    self.navigationItem.titleView = self.titleL;
    
    // Do any additional setup after loading the view.
}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(NSMutableAttributedString*)getTipL2Text
{
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"1.Clique no botão 'Conectar Wi-Fi' ou vá para as configurações de Wi-Fi do seu celular\n2.Selecione a rede com o nome DC3102_xxxx\n3.Utilize a senha 12345678"];
    NSString *strCopy = @"1.Clique no botão 'Conectar Wi-Fi' ou vá para as configurações de Wi-Fi do seu celular\n2.Selecione a rede com o nome DC3102_xxxx\n3.Utilize a senha 12345678";
    NSRange range = [strCopy rangeOfString:@"'Conectar Wi-Fi'"];
    NSRange range2 = [strCopy rangeOfString:@"DC3102_xxxx"];
    NSRange range3 = [strCopy rangeOfString:@"12345678"];

    [string addAttribute:NSExpansionAttributeName value:@(0.1) range:range];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:81.f/255.f green:192.f/255.f blue:172.f/255.f alpha:1] range:range];
    
    [string addAttribute:NSExpansionAttributeName value:@(0.1) range:range2];
     [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:81.f/255.f green:192.f/255.f blue:172.f/255.f alpha:1] range:range2];
    
    [string addAttribute:NSExpansionAttributeName value:@(0.1) range:range3];
     [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:81.f/255.f green:192.f/255.f blue:172.f/255.f alpha:1] range:range3];
    return string;
}

- (IBAction)clickConnectBtn:(UIButton *)sender {
    
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if (@available(iOS 11.0, *)) {
        if ([[UIApplication sharedApplication] canOpenURL:url]){
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    } else {
        if ([[UIApplication sharedApplication] canOpenURL:url]){
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
            } else {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
    }
    
    [self.navigationController popViewControllerAnimated:NO];

    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"FIRSTJOINAPP"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

-(UILabel *)titleL
{
    if (!_titleL) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, -20, 200, 40)];
        label.text = @"Conexão com a câmera";
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor colorWithRed:81.f/255.f green:192.f/255.f blue:172.f/255.f alpha:1];
        label.font = [UIFont systemFontOfSize:18.0];
        _titleL = label;
    }
    return _titleL;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
