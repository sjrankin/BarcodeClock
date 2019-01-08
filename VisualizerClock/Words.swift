//
//  Words.swift
//  Visualizer Clock
//
//  Created by Stuart Rankin on 12/2/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation

class Words
{
    /// Supported languages for word functions.
    ///
    /// - English: English.
    /// - Japanese: Japanese.
    public enum Languages
    {
        case English
        case Japanese
    }
    
    /// Dictionary of numbers to Japanese words.
    private static let JapaneseNumbers =
    [
        0: "０",
        1: "一",
        2: "二",
        3: "三",
        4: "四",
        5: "五",
        6: "六",
        7: "七",
        8: "八",
        9: "九",
        10: "十",
        11: "十一",
        12: "十二",
        13: "十三",
        14: "十四",
        15: "十五",
        16: "十六",
        17: "十七",
        18: "十八",
        19: "十九",
        20: "二十",
        21: "二十一",
        22: "二十二",
        23: "二十三",
        24: "二十四",
        25: "二十五",
        26: "二十六",
        27: "二十七",
        28: "二十八",
        29: "二十九",
        30: "三十",
        31: "三十一",
        32: "三十二",
        33: "三十三",
        34: "三十四",
        35: "三十五",
        36: "三十六",
        37: "三十七",
        38: "三十八",
        39: "三十九",
        40: "四十",
        41: "四十一",
        42: "四十二",
        43: "四十三",
        44: "四十四",
        45: "四十五",
        46: "四十六",
        47: "四十七",
        48: "四十八",
        49: "四十九",
        50: "五十",
        51: "五十一",
        52: "五十二",
        53: "五十三",
        54: "五十四",
        55: "五十五",
        56: "五十六",
        57: "五十七",
        58: "五十八",
        59: "五十九",
        60: "六十",
        61: "六十一",
        62: "六十二",
        63: "六十三",
        64: "六十四",
        65: "六十五",
        66: "六十六",
        67: "六十七",
        68: "六十八",
        69: "六十九",
        70: "七十",
        71: "七十一",
        72: "七十二",
        73: "七十三",
        74: "七十四",
        75: "七十五",
        76: "七十六",
        77: "七十七",
        78: "七十八",
        79: "七十九",
        80: "八十",
        81: "八十一",
        82: "八十二",
        83: "八十三",
        84: "八十四",
        85: "八十五",
        86: "八十六",
        87: "八十七",
        88: "八十八",
        89: "八十九",
        90: "九十",
        91: "九十一",
        92: "九十二",
        93: "九十三",
        94: "九十四",
        95: "九十五",
        96: "九十六",
        97: "九十七",
        98: "九十八",
        99: "九十九",
    ]
    
    /// Dictionary of numbers to English words.
    private static let EnglishNumbers =
    [
        0: "Zero",
        1: "One",
        2: "Two",
        3: "Three",
        4: "Four",
        5: "Five",
        6: "Six",
        7: "Seven",
        8: "Eight",
        9: "Nine",
        10: "Ten",
        11: "Eleven",
        12: "Twelve",
        13: "Thirteen",
        14: "Fourteen",
        15: "Fifteen",
        16: "Sixteen",
        17: "Seventeen",
        18: "Eighteen",
        19: "Nineteen",
        20: "Twenty",
        21: "Twenty-One",
        22: "Twenty-Two",
        23: "Twenty-Three",
        24: "Twenty-Four",
        25: "Twenty-Five",
        26: "Twenty-Six",
        27: "Twenty-Seven",
        28: "Twenty-Eight",
        29: "Twenty-Nine",
        30: "Thirty",
        31: "Thirty-One",
        32: "Thirty-Two",
        33: "Thirty-Three",
        34: "Thirty-Four",
        35: "Thirty-Five",
        36: "Thirty-Six",
        37: "Thirty-Seven",
        38: "Thirty-Eight",
        39: "Thirty-Nine",
        40: "Forty",
        41: "Forty-One",
        42: "Forty-Two",
        43: "Forty-Three",
        44: "Forty-Four",
        45: "Forty-Five",
        46: "Forty-Six",
        47: "Forty-Seven",
        48: "Forty-Eight",
        49: "Forty-Nine",
        50: "Fifty",
        51: "Fifty-One",
        52: "Fifty-Two",
        53: "Fifty-Three",
        54: "Fifty-Four",
        55: "Fifty-Five",
        56: "Fifty-Six",
        57: "Fifty-Seven",
        58: "Fifty-Eight",
        59: "Fifty-Nine",
        60: "Sixty",
        61: "Sixty-One",
        62: "Sixty-Two",
        63: "Sixty-Three",
        64: "Sixty-Four",
        65: "Sixty-Five",
        66: "Sixty-Six",
        67: "Sixty-Seven",
        68: "Sixty-Eight",
        69: "Sixty-Nine",
        70: "Seventy",
        71: "Seventy-One",
        72: "Seventy-Two",
        73: "Seventy-Three",
        74: "Seventy-Four",
        75: "Seventy-Five",
        76: "Seventy-Six",
        77: "Seventy-Seven",
        78: "Seventy-Eight",
        79: "Seventy-Nine",
        80: "Eighty",
        81: "Eighty-One",
        82: "Eighty-Two",
        83: "Eighty-Three",
        84: "Eighty-Four",
        85: "Eighty-Five",
        86: "Eighty-Six",
        87: "Eighty-Seven",
        88: "Eighty-Eight",
        89: "Eighty-Nine",
        90: "Ninety",
        91: "Eighty-One",
        92: "Eighty-Two",
        93: "Eighty-Three",
        94: "Eighty-Four",
        95: "Eighty-Five",
        96: "Eighty-Six",
        97: "Eighty-Seven",
        98: "Eighty-Eight",
        99: "Eighty-Nine",
    ]
    
    /// Table of tables - contains a dictionary of numbers-to-words for each supported language.
    private static let NumberTable: [Languages: [Int: String]] =
    [
        .English: EnglishNumbers,
        .Japanese: JapaneseNumbers
    ]
    
    /// Return a number in the form of a word (eg, 27 is returned as "Twenty-Seven").
    ///
    /// - Parameters:
    ///   - Value: The value to return. Valid values are in the range 0 to 99.
    ///   - Language: The language to return.
    /// - Returns: The string representation of the passed number on success, nil if invalid language or value out of range.
    public static func GetWordFor(Value: Int, Language: Languages = .English) -> String?
    {
        if let Words = NumberTable[Language]
        {
            if let Word = Words[Value]
            {
                return Word
            }
        }
        return nil
    }
}
