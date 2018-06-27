//
//  HTBodyfat.h
//
//  Created by Holtek on 17/01/10.
//  Copyright © 2016年 Holtek. All rights reserved.
//
//  Version: 2.01, lib for armV7、arm64、i386、x86_x64
//
#import <UIKit/UIKit.h>


///性別
typedef NS_ENUM(NSInteger, HTSexType){
    HTSexTypeFemale,        //!< 女性
    HTSexTypeMale           //!< 男性
};

///エラー種類(入力パラメータのため)
typedef NS_ENUM(NSInteger, HTBodyfatErrorType){
    HTBodyfatErrorTypeNone,         //!< エラーなし
    HTBodyfatErrorTypeImpedance,    //!< 抵抗に誤りがあり：BMI/idealWeightKg以外のデータは計算しない
    HTBodyfatErrorTypeAge,          //!< 年齢(6~99)に誤りがあり：BMI/idealWeightKg以外のデータは計算しない
    HTBodyfatErrorTypeWeight,       //!< 体重(10~200kg)に誤りがあり：すべてのデータは計算しない
    HTBodyfatErrorTypeHeight        //!< 身長(90~220cm)に誤りがあり：すべてのデータは計算しない
};

#pragma mark - HTPeopleGeneral

@interface HTPeopleGeneral : NSObject

@property (nonatomic,assign) HTSexType            htSex;         //!< 性別
@property (nonatomic,assign) NSInteger            htHeightCm;    //!< 身長(cm)，範囲：90 ~ 220cm
@property (nonatomic,assign) CGFloat              htWeightKg;    //!< 体重(kg)，範囲：10  ~ 200kg
@property (nonatomic,assign) NSInteger            htAge;         //!< 年齢(才)，範囲：6 ~ 99才
@property (nonatomic,assign) CGFloat              htZTwoLegs;    //!< 抵抗(Ω),  範囲：200.0 ~ 1200.0

@property (nonatomic,assign) CGFloat              htproteinPercentage;    //!< タンパク質、能力：0.1, 範囲：2.0% ~ 30.0%
@property (nonatomic,copy) NSDictionary*          htproteinRatingList;    //!< タンパク質標準："足りない－標準"“標準－優秀”

@property (nonatomic,assign) NSInteger            htBodyAge;      //!< 身体年齢：6~99才
@property (nonatomic,assign) CGFloat              htIdealWeightKg;//!< 理想体重(kg)

@property (nonatomic,assign) CGFloat              htBMI;                  //!< Body Mass Index 能力：0.1, 範囲：10.0 ~ 90.0
@property (nonatomic,copy) NSDictionary*          htBMIRatingList;        //!< BMI標準："痩せ－普通"“普通－肥満予備軍”“肥満予備軍－肥満”

@property (nonatomic,assign) NSInteger            htBMR;                  //!< Basal Metabolic Rate基礎代謝, 能力：1, 範囲：500 ~ 10000
@property (nonatomic,copy) NSDictionary*          htBMRRatingList;        //!< 基礎代謝標準:"低い－普通"

@property (nonatomic,assign) NSInteger            htVFAL;                 //!< Visceral fat area leverl内臓脂肪, 能力：1, 範囲：1 ~ 60
@property (nonatomic,copy) NSDictionary*          htVFALRatingList;       //!< 内臓脂肪標準："標準-警戒""警戒-危険"

@property (nonatomic,assign) CGFloat              htBoneKg;               //!< 骨量(kg), 能力：0.1, 範囲：0.5 ~ 8.0
@property (nonatomic,copy) NSDictionary*          htBoneRatingList;       //!< 骨量範囲："足りない－標準"“標準－優秀”


@property (nonatomic,assign) CGFloat              htBodyfatPercentage;    //!< 体脂肪率(%), 能力：0.1, 範囲：5.0% ~ 75.0%
@property (nonatomic,copy) NSDictionary*          htBodyfatRatingList;    //!< 体脂肪率標準："痩せきみ－標準"“標準－警戒”“警戒－肥満予備軍”“肥満予備軍－肥満”

@property (nonatomic,assign) CGFloat              htWaterPercentage;      //!< 水分率(%), 能力：0.1, 範囲：35.0% ~ 75.0%
@property (nonatomic,copy) NSDictionary*          htWaterRatingList;      //!< 水分率標準："足りない－標準"“標準－優秀”

@property (nonatomic,assign) CGFloat              htMuscleKg;             //!< 筋肉量(kg), 能力：0.1, 範囲：10.0 ~ 120.0
@property (nonatomic,copy) NSDictionary*          htMuscleRatingList;     //!< 筋肉量標準："足りない－標準"“標準－優秀”


/**
 *  身体解析API
 *
 *  @param weightKg   体重(kg)
 *  @param heightCm   身長(cm)
 *  @param sex        性別
 *  @param age        年齢
 *  @param impedance  抵抗
 *
 *  @return エラー種類、成功の場合：HTBodyfatErrorTypeNone
 */

- (HTBodyfatErrorType )getBodyfatWithweightKg:(CGFloat)weightKg heightCm:(CGFloat)heightCm sex:(HTSexType)sex age:(NSInteger)age impedance:(NSInteger)impedance;

@end

