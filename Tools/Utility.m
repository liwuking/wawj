//
//  Utility.m
//  juhuayou
//
//  Created by AaronRuan on 15-1-18.
//  Copyright (c) 2015年 juhuayou. All rights reserved.
//

#import "Utility.h"
#import "AppDelegate.h"
//#import "LogInViewController.h"
//#import "HomeViewController.h"
#define clientNo  @"jhy0002"
//#define key @"32f68f1cb9e3af72f64735f4fa07d806"
#define version @"1"


@implementation Utility



+(NSString *)getDayWeek{
    
    NSString *weekDay;
    NSDate *dateNow = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];//设置成中国阳历
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;//这句我也不明白具体时用来做什么。。。
    comps = [calendar components:unitFlags fromDate:dateNow];
    
    long weekNumber = [comps weekday]; //获取星期对应的长整形字符串

    switch (weekNumber) {
        case 1:
            weekDay= SUNDAY;
            break;
        case 2:
            weekDay= MONDAY;
            break;
        case 3:
            weekDay= TUESDAY;
            break;
        case 4:
            weekDay= WEDNESDAY;
            break;
        case 5:
            weekDay= THURSDAY;
            break;
        case 6:
            weekDay= FRIDAY;
            break;
        case 7:
            weekDay= SATURDAY;
            break;
            
        default:
            break;
    }
    
    return weekDay;
}


#pragma mark - 验证输入手机号码
+ (BOOL)isValidatePhone:(NSString *)phone
{
    NSString *phoneRegex = @"^1[0-9]\\d{9}$";
    
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [phoneTest evaluateWithObject:phone];
}

+ (NSString *)currentDateWithFormatter:(NSString *)formatter
{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:formatter];
    NSString *weekString = [dateformatter stringFromDate:date];
    return weekString;
}

//判断登陆时效是否超过30分钟，超过则弹出重新登陆
+ (void)intervalSinceNow:(NSString *)theDate {
    //NSLog(@"DATE  = %@",theDate);
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
    //NSLog(@"timeString = %@",timeString);
    
    if ([timeString integerValue]>=30) {
        
        //提示用户太久没操作了 需重新登录
        /*
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                       message:@"您太久没操作了,需要重新登录"
                                                      delegate:nil
                                             cancelButtonTitle:@"确定"
                                             otherButtonTitles: nil];
        [alert showAlertWithBlock:^(NSInteger buttonIndex) {
            if (buttonIndex==0) {
                [CoreArchive setBool:NO key:@"ifLogin"];
                [CoreArchive setBool:NO key:@"certifyCode"];
                [CoreArchive removeStrForKey:@"logInID"];
                [CoreArchive removeStrForKey:@"realnameAuthFlag"];
                [CoreArchive removeStrForKey:@"branchId"];
                [CoreArchive removeStrForKey:@"brokerId"];
                [CoreArchive removeStrForKey:@"phone"];
                [CoreArchive removeStrForKey:@"currentTime"];
                
                LogInViewController *loginVC= [[LogInViewController alloc]init];
                loginVC.isPresent = @"yes";
                
                AppDelegate *myApp = [[UIApplication sharedApplication] delegate];
                if ([CoreArchive boolForKey:@"ifJujianren"] == YES) {
                    //登出去，必须去掉居间人业务栏目
                    [CoreArchive setBool:NO key:@"ifJujianren"];
                }
                
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:loginVC];
                
                
                HomeViewController *homeVC = myApp.phTabbarController.viewControllers[0];
                
                [homeVC presentViewController:nav animated:YES completion:^{
                    
                }];
                
            }

        }];
      */
    } else {
        /*
        //没有超过30分钟就保存最新时间
        NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *currentTime = [formatter stringFromDate:[NSDate date]];
        
        [CoreArchive setStr:currentTime key:@"currentTime"];
        //[[Utility getUserinfo] setObject:currentTime forKey:@"currentTime"];
        */
    }
}



+ (NSString *)getCurrentTime{
    //获得系统日期
    NSDate *  senddate=[NSDate date];
    NSCalendar  * cal=[NSCalendar  currentCalendar];
    NSUInteger  unitFlags=NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay ;
    NSDateComponents * conponent= [cal components:unitFlags fromDate:senddate];
    NSInteger year=[conponent year];
    NSInteger month=[conponent month];
    NSInteger day=[conponent day];
    NSString *DateString= [NSString  stringWithFormat:@"%ld年%ld月%ld日",(long)year,(long)month,(long)day];


    return DateString;
    
}

+ (NSString * )getNowTime{
    //创建一个日期格式化对象：
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];//2014-11-15 13:17:47.0
    //创建了两个日期对象：
    NSDate *dateNow=[NSDate date];

    NSString *dateNowString = [dateFormatter stringFromDate:dateNow];

    return dateNowString;

}

+ (NSString * )getDate{
    //创建一个日期格式化对象：
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];//2014-11-15 13:17:47.0
    //创建了两个日期对象：
    NSDate *dateNow=[NSDate date];
    
    NSString *dateNowString = [dateFormatter stringFromDate:dateNow];
    
    return dateNowString;
    
}


+(NSString *) md5: (NSString *) inPutText
{
    const char *cStr = [inPutText UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    
    return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] lowercaseString];
}

+(NSString *) md5_32: (NSString *) inPutText
{
    const char *cStr = [inPutText UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    
    return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15],result[16], result[17],
             result[18], result[19], result[20], result[21],
             result[22], result[23], result[24], result[25],
             result[26], result[27], result[28], result[29],result[30], result[31]
             ] lowercaseString];
}


+(NSString *) md5HexDigest:(NSString *) inPutText

{
    
    const char *original_str = [inPutText UTF8String];
    
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(original_str, (CC_LONG)strlen(original_str), result);
    
    NSMutableString *hash = [NSMutableString string];
    
    for (int i = 0; i < 16; i++)
        
        [hash appendFormat:@"%02X", result[i]];
    
    return [hash lowercaseString];
    
}


//+(CDPMenuViewController *)getCDPMenuVC{
//    UIApplication * app = [UIApplication sharedApplication];
//    AppDelegate * appDelegate = app.delegate;
//    return appDelegate.menuViewController;
//}

/**取得app当前版本号*/
+(NSString *)getCurrentAppVersion{
   
    NSString *Version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return Version;
}



+(NSString *)changetochinese:(NSString *)numstr
{
    double numberals=[numstr doubleValue];
    NSArray *numberchar = @[@"零",@"壹",@"贰",@"叁",@"肆",@"伍",@"陆",@"柒",@"捌",@"玖"];
    NSArray *inunitchar = @[@"",@"拾",@"佰",@"仟"];
    NSArray *unitname = @[@"",@"万",@"亿",@"万亿"];
    //金额乘以100转换成字符串（去除圆角分数值）
    NSString *valstr=[NSString stringWithFormat:@"%.2f",numberals];
    NSString *prefix;
    NSString *suffix;
    if (valstr.length<=2) {
        prefix=@"零圆";
        if (valstr.length==0) {
            suffix=@"零角零分";
        }
        else if (valstr.length==1)
        {
            suffix=[NSString stringWithFormat:@"%@分",[numberchar objectAtIndex:[valstr intValue]]];
        }
        else
        {
            NSString *head=[valstr substringToIndex:1];
            NSString *foot=[valstr substringFromIndex:1];
            suffix=[NSString stringWithFormat:@"%@角%@分",[numberchar objectAtIndex:[head intValue]],[numberchar objectAtIndex:[foot intValue]]];
        }
    }
    else
    {
        prefix=@"";
        suffix=@"";
        int flag=(int)valstr.length-2;
        NSString *head=[valstr substringToIndex:flag-1];
        NSString *foot=[valstr substringFromIndex:flag];
        if (head.length>13) {
            return@"数值太大（最大支持13位整数），无法处理";
        }
        //处理整数部分
        NSMutableArray *ch=[[NSMutableArray alloc]init];
        for (int i = 0; i < head.length; i++) {
            NSString * str=[NSString stringWithFormat:@"%x",[head characterAtIndex:i]-'0'];
            [ch addObject:str];
        }
        int zeronum=0;
        
        for (int i=0; i<ch.count; i++) {
            int index=(ch.count -i-1)%4;//取段内位置
            int indexloc=(int)(ch.count -i-1)/4;//取段位置
            if ([[ch objectAtIndex:i]isEqualToString:@"0"]) {
                zeronum++;
            }
            else
            {
                if (zeronum!=0) {
                    if (index!=3) {
                        prefix=[prefix stringByAppendingString:@"零"];
                    }
                    zeronum=0;
                }
                prefix=[prefix stringByAppendingString:[numberchar objectAtIndex:[[ch objectAtIndex:i]intValue]]];
                prefix=[prefix stringByAppendingString:[inunitchar objectAtIndex:index]];
            }
            if (index ==0 && zeronum<4) {
                prefix=[prefix stringByAppendingString:[unitname objectAtIndex:indexloc]];
            }
        }
        prefix =[prefix stringByAppendingString:@"元"];
        //处理小数位
        if ([foot isEqualToString:@"00"]) {
            suffix =[suffix stringByAppendingString:@"整"];
        }
        else if ([foot hasPrefix:@"0"])
        {
            NSString *footch=[NSString stringWithFormat:@"%x",[foot characterAtIndex:1]-'0'];
            suffix=[NSString stringWithFormat:@"%@分",[numberchar objectAtIndex:[footch intValue] ]];
        }
        else
        {
            NSString *headch=[NSString stringWithFormat:@"%x",[foot characterAtIndex:0]-'0'];
            NSString *footch=[NSString stringWithFormat:@"%x",[foot characterAtIndex:1]-'0'];
            suffix=[NSString stringWithFormat:@"%@角%@分",[numberchar objectAtIndex:[headch intValue]],[numberchar objectAtIndex:[footch intValue]]];
        }
    }
    return [prefix stringByAppendingString:suffix];
}



#pragma mark - InterpolatedUIImage
+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // create a bitmap image that we'll draw into a bitmap context at the desired size;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // Create an image with the contents of our bitmap
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    // Cleanup
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

#pragma mark - QRCodeGenerator
+ (CIImage *)createQRForString:(NSString *)qrString {
    // Need to convert the string to a UTF-8 encoded NSData object
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    // Create the filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // Set the message content and error-correction level
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    // Send the image back
    return qrFilter.outputImage;
}

#pragma mark - imageToTransparent
void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}
+ (UIImage*)imageBlackToTransparent:(UIImage*)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue{
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t      bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    // create context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    // traverse pixe
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++){
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900){
            // change color
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = red; //0~255
            ptr[2] = green;
            ptr[1] = blue;
        }else{
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    // context to image
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    // release
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return resultUIImage;
}


/**ycy 颜色生成图片**/
+(UIImage*) createImageWithColor:(UIColor*)color
{
    
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    
    CGContextFillRect(context, rect);
    
    UIImage*theImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return theImage;
    
}


@end
