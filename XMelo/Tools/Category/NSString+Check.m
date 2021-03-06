//
//  NSString+Check.m
//  YiWei
//
//  Created by X.Melody on 17/5/2.
//  Copyright © 2017年 X.Melody. All rights reserved.
//

#import "NSString+Check.h"

@implementation NSString (Check)


#pragma mark- 字符串为空判断
- (BOOL)isEmptyString{
    if (self == nil || self == NULL) return YES;
    if ([self isKindOfClass:[NSNull class]]) return YES;
    if ([[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) return YES;
    return NO;
}

#pragma mark- 字符串是否为数字
- (BOOL)isIntegerString{
    if([self stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]].length > 0){
        return NO;
    }
    return YES;
}

- (BOOL)isNunmberString {
    NSCharacterSet *cs;
    cs = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789.\n"] invertedSet];
    NSString *filtered = [[self componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    BOOL basicTest = [self isEqualToString:filtered];

    return basicTest;
}

-(BOOL)isChineseStr {
    BOOL isFullChinese = NO;
    for (int index = 0; index < [self length]; index ++) {
        int a = [self characterAtIndex:index];
        if( a > 0x4e00 && a < 0x9fff) {
            isFullChinese = YES;
        }else{
            isFullChinese = NO;
        }
    }
    return isFullChinese;
}

#pragma mark- 银行卡码验证
/** 银行卡号有效性问题Luhn算法
 *  现行 16 位银联卡现行卡号开头 6 位是 622126～622925 之间的，7 到 15 位是银行自定义的，
 *  可能是发卡分行，发卡网点，发卡序号，第 16 位是校验码。
 *  16 位卡号校验位采用 Luhm 校验方法计算：
 *  1，将未带校验位的 15 位卡号从右依次编号 1 到 15，位于奇数位号上的数字乘以 2
 *  2，将奇位乘积的个十位全部相加，再加上所有偶数位上的数字
 *  3，将加法和加上校验位能被 10 整除。
 */
- (BOOL)isValidBankCardNumberString{
    
    if (self.longLongValue == 0) {
        return NO;
    }
    
    int oddsum = 0;     //奇数求和
    int evensum = 0;    //偶数求和
    int allsum = 0;
    int cardNoLength = (int)[self length];
    int lastNum = [[self substringFromIndex:cardNoLength-1] intValue];
    
    NSString *cNo = [self substringToIndex:cardNoLength - 1];
    for (int i = cardNoLength -1 ; i>=1;i--) {
        NSString *tmpString = [cNo substringWithRange:NSMakeRange(i-1, 1)];
        int tmpVal = [tmpString intValue];
        if (cardNoLength % 2 ==1 ) {
            if((i % 2) == 0){
                tmpVal *= 2;
                if(tmpVal>=10)
                    tmpVal -= 9;
                evensum += tmpVal;
            }else{
                oddsum += tmpVal;
            }
        }else{
            if((i % 2) == 1){
                tmpVal *= 2;
                if(tmpVal>=10)
                    tmpVal -= 9;
                evensum += tmpVal;
            }else{
                oddsum += tmpVal;
            }
        }
    }
    
    allsum = oddsum + evensum;
    allsum += lastNum;
    if((allsum % 10) == 0) {
        return YES;
    } else {
        return NO;
    }
}


//备用
- (BOOL)bankCardluhmCheck{
    
    if (self.longLongValue == 0) {
        return NO;
    }
    
    NSString * lastNum = [[self substringFromIndex:(self.length-1)] copy];//取出最后一位
    NSString * forwardNum = [[self substringToIndex:(self.length -1)] copy];//前15或18位
    
    NSMutableArray * forwardArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i=0; i<forwardNum.length; i++) {
        NSString * subStr = [forwardNum substringWithRange:NSMakeRange(i, 1)];
        [forwardArr addObject:subStr];
    }
    
    NSMutableArray * forwardDescArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = (int)(forwardArr.count-1); i> -1; i--) {//前15位或者前18位倒序存进数组
        [forwardDescArr addObject:forwardArr[i]];
    }
    
    NSMutableArray * arrOddNum = [[NSMutableArray alloc] initWithCapacity:0];//奇数位*2的积 < 9
    NSMutableArray * arrOddNum2 = [[NSMutableArray alloc] initWithCapacity:0];//奇数位*2的积 > 9
    NSMutableArray * arrEvenNum = [[NSMutableArray alloc] initWithCapacity:0];//偶数位数组
    
    for (int i=0; i< forwardDescArr.count; i++) {
        NSInteger num = [forwardDescArr[i] intValue];
        if (i%2) {//偶数位
            [arrEvenNum addObject:[NSNumber numberWithInteger:num]];
        }else{//奇数位
            if (num * 2 < 9) {
                [arrOddNum addObject:[NSNumber numberWithInteger:num * 2]];
            }else{
                NSInteger decadeNum = (num * 2) / 10;
                NSInteger unitNum = (num * 2) % 10;
                [arrOddNum2 addObject:[NSNumber numberWithInteger:unitNum]];
                [arrOddNum2 addObject:[NSNumber numberWithInteger:decadeNum]];
            }
        }
    }
    
    __block  NSInteger sumOddNumTotal = 0;
    [arrOddNum enumerateObjectsUsingBlock:^(NSNumber * obj, NSUInteger idx, BOOL *stop) {
        sumOddNumTotal += [obj integerValue];
    }];
    
    __block NSInteger sumOddNum2Total = 0;
    [arrOddNum2 enumerateObjectsUsingBlock:^(NSNumber * obj, NSUInteger idx, BOOL *stop) {
        sumOddNum2Total += [obj integerValue];
    }];
    
    __block NSInteger sumEvenNumTotal =0 ;
    [arrEvenNum enumerateObjectsUsingBlock:^(NSNumber * obj, NSUInteger idx, BOOL *stop) {
        sumEvenNumTotal += [obj integerValue];
    }];
    
    NSInteger lastNumber = [lastNum integerValue];
    
    NSInteger luhmTotal = lastNumber + sumEvenNumTotal + sumOddNum2Total + sumOddNumTotal;
    
    return (luhmTotal%10 ==0)?YES:NO;
}

#pragma mark- 手机号码验证
- (BOOL)isValidPhoneNumberString{
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";//整体
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";//移动
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";//联通
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";//电信
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if ([regextestmobile evaluateWithObject:self]||
        [regextestcm evaluateWithObject:self]||
        [regextestct evaluateWithObject:self]||
        [regextestcu evaluateWithObject:self]){
        return YES;
    }else{
        return NO;
    }
}

#pragma mark- 身份号码验证
- (BOOL)isValidIDCardNumberString{
    if (self.length != 18) return  NO;
    NSArray *codeArray = @[@"7",@"9",@"10",@"5",@"8",@"4",@"2",@"1",@"6",@"3",@"7",@"9",@"10",@"5",@"8",@"4",@"2"];
    NSArray *arr1 = @[@"1",@"0",@"X",@"9",@"8",@"7",@"6",@"5",@"4",@"3",@"2"];
    NSArray *arr2 = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10"];
    NSDictionary *checkCodeDic = [NSDictionary dictionaryWithObjects:arr1 forKeys:arr2];
    NSScanner *scan = [NSScanner scannerWithString:[self substringToIndex:17]];
    
    int val;
    BOOL isNum = [scan scanInt:&val] && [scan isAtEnd];
    if (!isNum) return NO;
    int sumValue = 0;
    for (int i = 0; i < 17; i++) {
        NSString *str1 = [self substringWithRange:NSMakeRange(i,1)];
        NSString *str2 = [codeArray objectAtIndex:i];
        sumValue += [str1 intValue] * [str2 intValue];
    }
    NSString *strlast = [checkCodeDic objectForKey:[NSString stringWithFormat:@"%d",sumValue%11]];
    if ([strlast isEqualToString: [[self substringWithRange:NSMakeRange(17, 1)]uppercaseString]]) {
        return YES;
    }
    return  NO;
}
    
    

@end
