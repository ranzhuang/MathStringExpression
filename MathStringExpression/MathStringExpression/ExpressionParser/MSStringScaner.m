//
//  MSStringScaner.m
//  MathStringProgram
//
//  Created by NOVO on 16/7/18.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import "MSStringScaner.h"
#import "MSElementTable.h"
#import "MSOperator.h"
#import "MSPairOperator.h"
#import "MSFunctionOperator.h"
#import "MSValueOperator.h"

typedef enum EnumCharType{
    EnumCharTypeNumber,
    EnumCharTypeLetter,
    EnumCharTypeOthers
}EnumCharType;


@implementation MSStringScaner
+ (void)scanString:(NSString*)string
               block:(void(^)(MSElement* value,NSUInteger idx,BOOL isEnd,BOOL* stop))block
{
    if(!block) return;
    NSMutableArray<NSString*>* splitedArr = [self scanSplitString:string];
    NSMutableArray<MSElement*>* elementArr = [NSMutableArray new];
    [splitedArr enumerateObjectsUsingBlock:^(NSString*  _Nonnull elementStr, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSMutableArray<MSElement*>* elementInArr = [[MSElementTable defaultTable] elementsFromString:elementStr];
        if(elementInArr.count==1){
            //查询到单个元素
            [elementArr addObject:elementInArr.firstObject];
        }else{
            //查询到多个元素，目前只有符号和减号需要在框架内处理，后将提供方法处理，分内部的和用户的
            if([elementInArr firstObject].elementType == EnumElementTypeOperator){
                NSString* name = ((MSOperator*)[elementInArr firstObject]).opName;
                if([name isEqualToString:@"-"]){
                    //前一个元素不存在或者是左括号则为负号
                    if(idx==0){
                        [elementArr addObject:elementInArr.firstObject];
                    }else if([[elementArr lastObject] isKindOfClass:[MSPairOperator class]]){
                        if([((MSPairOperator*)[elementArr lastObject]).opName isEqualToString:@"("]){
                            [elementArr addObject:elementInArr.firstObject];
                        }else{
                            [elementArr addObject:elementInArr.lastObject];
                        }
                    }else{
                        [elementArr addObject:elementInArr.lastObject];
                    }
                }
            }else{//未知情况
                [elementArr addObject:elementInArr.lastObject];
            }
        }
    }];
    
    [elementArr enumerateObjectsUsingBlock:^(MSElement * _Nonnull element, NSUInteger idx, BOOL * _Nonnull stop) {
        
        block(element , idx , (idx == elementArr.count-1) , stop);
    }];
}

+ (NSMutableArray<NSString*>*)scanSplitString:(NSString*)string
{
    NSMutableArray* splitedArr = [NSMutableArray new];
    if(!string.length)
        return splitedArr;
    __block EnumCharType lastType;
    NSMutableString* curString = [NSMutableString new];
    
    __block NSString* firstStr;
    __block NSUInteger firstLen;
    [string enumerateSubstringsInRange:NSMakeRange(0, string.length-1) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        firstStr = substring;
        firstLen = substringRange.length;
        *stop= YES;
    }];
    
    [curString appendString:firstStr];
    NSPredicate* checkNumber = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"[0-9\\.]"];
    NSPredicate* checkLetter = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"[A-Za-z_]"];
    if([checkNumber evaluateWithObject:firstStr]){
        
        lastType = EnumCharTypeNumber;
    }else if ([checkLetter evaluateWithObject:firstStr]){
        
        lastType = EnumCharTypeLetter;
    }else{
        
        lastType = EnumCharTypeOthers;
    }
    if(string.length==1){
        [splitedArr addObject:curString];
        return splitedArr;
    }
    [string enumerateSubstringsInRange:NSMakeRange(firstLen, string.length-1) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        
        if([checkNumber evaluateWithObject:substring]){
            if(lastType == EnumCharTypeNumber){
                [curString appendString:substring];
            }else{
                lastType = EnumCharTypeNumber;
                [splitedArr addObject:[curString copy]];
                [curString setString:substring];
            }
        }else if ([checkLetter evaluateWithObject:substring]){
            if(lastType == EnumCharTypeLetter){
                [curString appendString:substring];
            }else{
                lastType = EnumCharTypeLetter;
                [splitedArr addObject:[curString copy]];
                [curString setString:substring];
            }
        }else{
            
            lastType = EnumCharTypeOthers;
            [splitedArr addObject:[curString copy]];
            [curString setString:substring];
        }
        if(substringRange.location+substringRange.length == string.length){
            [splitedArr addObject:[curString copy]];
        }
    }];
    
    return splitedArr;
}

@end