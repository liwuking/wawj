//
//  stringUtil.m
//  Sign on
//
//  Created by 曾勇兵 on 15-1-20.
//  Copyright (c) 2015年 zengyongbing. All rights reserved.
//

#import "stringUtil.h"
#import "Utility.h"
@implementation stringUtil
#pragma mark - 输入是否为电子邮箱的验证
+ (BOOL)isValidateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

#pragma mark - 验证输入手机号码
+ (BOOL)isValidatePhone:(NSString *)phone
{
    NSString *phoneRegex = @"^1[0-9]\\d{9}$";

    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [phoneTest evaluateWithObject:phone];
}


#pragma mark - 验证电话号码
+ (BOOL)isValidTel:(NSString *)tel
{

//    NSString *telPhone = @"^((d{3,4})|d{3,4}-)?d{7,8}$"; [1-9]{1}(\d){5}
       NSString *telPhone =@"^((\\d{7,8})|(\\d{4}|\\d{3})-(\\d{7,8})|(\\d{4}|\\d{3})-(\\d{7,8})-(\\d{4}|\\d{3}|\\d{2}|\\d{1})|(\\d{7,8})-(\\d{4}|\\d{3}|\\d{2}|\\d{1}))$";
    
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", telPhone];

    return [phoneTest evaluateWithObject:tel];
}

#pragma mark - 验证邮编
+ (BOOL)isValidYoubian:(NSString *)youbian
{
    //0755-8888888 

    NSString *telPhone =@"^[1-9]{1}(\\d){5}$";
    
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", telPhone];

    return [phoneTest evaluateWithObject:telPhone];
}


#pragma mark - 身份证号
+ (BOOL)validateIdentityCard:(NSString *)cardNo
{
   
    if (cardNo.length != 18) {
        return  NO;
    }
    NSArray* codeArray = [NSArray arrayWithObjects:@"7",@"9",@"10",@"5",@"8",@"4",@"2",@"1",@"6",@"3",@"7",@"9",@"10",@"5",@"8",@"4",@"2", nil];
    NSDictionary* checkCodeDic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"1",@"0",@"X",@"9",@"8",@"7",@"6",@"5",@"4",@"3",@"2", nil]  forKeys:[NSArray arrayWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10", nil]];
    
    NSScanner* scan = [NSScanner scannerWithString:[cardNo substringToIndex:17]];
    
    int val;
    BOOL isNum = [scan scanInt:&val] && [scan isAtEnd];
    if (!isNum) {
        return NO;
    }
    int sumValue = 0;
    
    for (int i =0; i<17; i++) {
        sumValue+=[[cardNo substringWithRange:NSMakeRange(i , 1) ] intValue]* [[codeArray objectAtIndex:i] intValue];
    }
    
    NSString* strlast = [checkCodeDic objectForKey:[NSString stringWithFormat:@"%d",sumValue%11]];
    
    if ([strlast isEqualToString: [[cardNo substringWithRange:NSMakeRange(17, 1)]uppercaseString]]) {
        return YES;
    }
    return  NO;
    
}




#pragma mark - 校验生日
+ (BOOL)isValidBirthday:(NSString*)birthday
{
    BOOL result = FALSE;
    if (birthday && 10 == [birthday length])
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *date = [formatter dateFromString:birthday];
        if (date)
        {
            result = TRUE;
        }
    }
    return result;
}


//银行卡
+ (BOOL)validateBankCardNumber: (NSString *)bankCardNumber
{
    BOOL flag;
    if (bankCardNumber.length <= 0) {
        flag = NO;
        return flag;
    }
    NSString *regex2 = @"^(\\d{16,30})";
    NSPredicate *bankCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [bankCardPredicate evaluateWithObject:bankCardNumber];
}


//银行卡后四位
+ (BOOL) validateBankCardLastNumber:(NSString *)bankCardNumber
{
    BOOL flag;
    if (bankCardNumber.length != 4) {
        flag = NO;
        return flag;
    }
    NSString *regex2 = @"^(\\d{4})";
    NSPredicate *bankCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [bankCardPredicate evaluateWithObject:bankCardNumber];
}

//匹配帐号是否合法(字母开头，允许5-16字节
+(BOOL)checkAccount:(NSString *)account
{
//    BOOL flag;
//    if (account.length <= 5) {
//        flag = NO;
//        return flag;
//    }
//    //6-20位数字和字母组成
//    NSString *regex = @"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,20}$";
//    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
//
//    return[pred evaluateWithObject:account];
    
    NSString * regex= @"^[a-zA-Z]\\w{5,19}$";
    NSPredicate * pred= [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch= [pred evaluateWithObject:account];
    if (isMatch) {
        return YES;
    }else{
        return NO;
    }

   
}

//iOS正则表达式判断密码
+(BOOL)checkPassWord:(NSString *)password
{
    BOOL flag;
    if (password.length <= 0) {
        flag = NO;
        return flag;
    }
    //6-20位数字和字母组成
    NSString *regex = @"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{8,20}$";

    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];

    return [pred evaluateWithObject:password] ;


}
//是否是纯数字
+ (BOOL)isNumText:(NSString *)str{
    NSString * regex= @"(/^[0-9]*$/){0,6}$";
    NSPredicate * pred= [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch= [pred evaluateWithObject:str];
    if (isMatch) {
        return YES;
    }else{
        return NO;
    }
    
}


+(BOOL)validateNickname:(NSString *)nickname {
    // 不包含特殊字符
    // 特殊字符包含`、-、=、\、[、]、;、'、,、.、/、~、!、@、#、$、%、^、&、*、(、)、_、+、|、?、>、<、"、:、{、}
    NSString *nicknameRegex = @".*[-`=\\\[\\];',./~!@#$%^&*()_+|{}:\"<>?]+.*";
    NSPredicate *nicknamePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", nicknameRegex];
    return ![nicknamePredicate evaluateWithObject:nickname];
}


//字符串的是否包含空格判断
+(BOOL)isNull:(NSString *)str {
    
    NSString * regex= @"^[^ ]+$";
    NSPredicate * pred= [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch= [pred evaluateWithObject:str];
    if (isMatch) {
        return YES;
    }else{
        return NO;
    }

}

//必须全是中文[\u4e00-\u9fa5]有中文
+(BOOL)isChinese:(NSString *)str {
    
    NSString * regex= @"^[\u4E00-\u9FA5]*$";
    NSPredicate * pred= [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch= [pred evaluateWithObject:str];
    if (isMatch) {
        return YES;
    }else{
        return NO;
    }
    
}

+(BOOL)isRangeChinese:(NSString *)str {
    
    NSString * regex = @"^[A-Za-z0-9]+$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:str];
    if (isMatch) {
        return YES;
    }else{
        return NO;
    }
    
}
//
+(BOOL)iscontract:(NSString *)str {
    
    NSString * regex = @"[A-Z]{4}\\d{12}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:str];
    if (isMatch) {
        return YES;
    }else{
        return NO;
    }
    
}

//判断登陆时效是否超过30分钟，超过则弹出重新登陆
+ (void)intervalSinceNow:(NSString *)theDate {
        NSDateFormatter *date=[[NSDateFormatter alloc] init];
        [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *d=[date dateFromString:theDate];
        NSTimeInterval late=[d timeIntervalSince1970]*1;
        
        NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval now=[dat timeIntervalSince1970]*1;
        NSString *timeString=@"";
        NSTimeInterval cha=now-late;

        timeString = [NSString stringWithFormat:@"%f",cha/60.0f];
        timeString = [timeString substringToIndex:timeString.length -7];


    
        NSLog(@"...%ld",(long)[timeString integerValue]);
        if ([timeString integerValue]>=30) {
            
            
            
//            //出现提示框告知用户需要重新登录，调出登录界面，让用户重新登录
//            
//            
//            [STAlertView showTitle:@"提示" image:nil message:@"超时请重新登陆" buttonTitles:@[@"确定"]handler:^(NSInteger index) {
//                
//                if (index==0) {
//                    [CoreArchive setBool:NO key:@"ifLogin"];
//                    [CoreArchive setBool:NO key:@"certifyCode"];
//                    LoginViewController *loginVC= [[LoginViewController alloc]init];
//                    loginVC.sourse = @"mine";
//                    
//                    
//                    if ([CoreArchive boolForKey:@"ifJujianren"] == YES) {
//                        //登出去，必须去掉居间人业务栏目
//                        MainTabBarController * mainTabBarVC = (MainTabBarController*)[[Utility getCDPMenuVC] midViewController];
//                        [mainTabBarVC delInvesVC];
//                        [CoreArchive setBool:NO key:@"ifJujianren"];
//                        
//                    }
//                    
//                    BaseNavigationController *nav = [[BaseNavigationController alloc]initWithRootViewController:loginVC];
//                    
//                    [[Utility getCDPMenuVC] presentViewController:nav animated:YES completion:^{
//                        
//                    }];
//                    
//                }
//            
//            }];
        } else {
        
            /*
            //没有超过30分钟就保存最新时间
            NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *currentTime = [formatter stringFromDate:[NSDate date]];
            [CoreArchive setStr:currentTime key:@"currentTime"];
//            [[Utility getUserinfo] setObject:currentTime forKey:@"currentTime"];
            */
        }

    
}



@end
