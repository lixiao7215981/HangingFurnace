//
//  UtilConversion.m
//  HangingFurnace
//
//  Created by ybyao07 on 15/9/24.
//  Copyright (c) 2015年 skyware. All rights reserved.
//

#import "UtilConversion.h"

@implementation UtilConversion
//多个16进制字节转成十进制数
+(long)toDecimalFromHex:(NSString *)hexStr
{
    NSArray *strArr = [hexStr componentsSeparatedByString:@"0x"];
    NSMutableString *hexJoinString= [NSMutableString new];
    [strArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [hexJoinString appendString:obj];
    }];
    long num = 0;
    num = [self numFromString:hexJoinString];
    return num;
}
//十六进制数转十进制数
+(long)numFromString:(NSString *)str
{
    long num = strtoul([str UTF8String], 0, 16);
    return num;
}


+(NSString *)stringFromHexCharacter:(NSString *)strChar{
    NSString *charStr;
    if ([strChar isEqualToString:@"f"] || [strChar isEqualToString:@"F"]) {
        charStr = @"1111";
    }else if ([strChar isEqualToString:@"e"] || [strChar isEqualToString:@"E"]){
        charStr = @"1110";
    }else if ([strChar isEqualToString:@"d"] || [strChar isEqualToString:@"D"]){
        charStr = @"1101";
    }else if ([strChar isEqualToString:@"c"] || [strChar isEqualToString:@"C"]){
        charStr = @"1100";
    }else if ([strChar isEqualToString:@"b"] || [strChar isEqualToString:@"B"]){
        charStr = @"1011";
    }else if ([strChar isEqualToString:@"a"] || [strChar isEqualToString:@"A"]){
        charStr = @"1010";
    }else if ([strChar isEqualToString:@"9"]){
        charStr = @"1001";
    }else if ([strChar isEqualToString:@"8"]){
        charStr = @"1000";
    }else if ([strChar isEqualToString:@"7"]){
        charStr = @"0111";
    }else if ([strChar isEqualToString:@"6"]){
        charStr = @"0110";
    }else if ([strChar isEqualToString:@"5"]){
        charStr = @"0101";
    }else if ([strChar isEqualToString:@"4"]){
        charStr = @"0100";
    }else if ([strChar isEqualToString:@"3"]){
        charStr = @"0011";
    }else if ([strChar isEqualToString:@"2"]){
        charStr = @"0010";
    }else if ([strChar isEqualToString:@"1"]){
        charStr = @"0001";
    }else if ([strChar isEqualToString:@"0"]){
        charStr = @"0000";
    }
    return charStr;
}


+(NSString *)decimalToHex:(NSInteger)num
{
    NSString *nLetterValue;
    NSString *str =@"";
    uint16_t ttmpig;
    if (num < 16) {//只有一位数 返回 @“0X”
        switch (num)
        {
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
            default:
                nLetterValue = [NSString stringWithFormat:@"%ld",(long)num];
        }
        str = [str stringByAppendingString:@"0"];
        str = [str stringByAppendingString:nLetterValue];
    }else{
        for (int i = 0; i<9; i++) {
            ttmpig=num%16;
            num=num/16;
            switch (ttmpig)
            {
                case 10:
                    nLetterValue =@"A";break;
                case 11:
                    nLetterValue =@"B";break;
                case 12:
                    nLetterValue =@"C";break;
                case 13:
                    nLetterValue =@"D";break;
                case 14:
                    nLetterValue =@"E";break;
                case 15:
                    nLetterValue =@"F";break;
                default:
                    nLetterValue = [NSString stringWithFormat:@"%u",ttmpig];
            }
            str = [nLetterValue stringByAppendingString:str];
            if (num == 0) {
                break;
            }
        }
    }
    return str;
}


@end
