//
//  MSElement.h
//  MathStringProgram
//
//  Created by NOVO on 16/7/18.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum EnumElementType{
    EnumElementTypeUndefine,
    EnumElementTypeNumber,
    EnumElementTypeOperator,
}EnumElementType;

@interface MSElement : NSObject
@property (nonatomic,assign) EnumElementType elementType;
/** 输入的原始值 */
@property (nonatomic,copy) NSString* stringValue;

- (NSString *)description;
- (NSString *)debugDescription;
@end