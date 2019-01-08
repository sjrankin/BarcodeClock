//
//  UIColorExtensions.swift
//  GradientTestBed
//
//  Created by Stuart Rankin on 10/26/18.
//  Copyright © 2018 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Extensions related to UIColor.
extension UIColor
{
    /// Returns an object whose color is aero (124,185,232).
    public static var aero: UIColor
    {
        get
        {
            return UIColor(red: 124.0 / 255.0, green: 185.0 / 255.0, blue: 232.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is antique fuschia (145,92,131).
    public static var antiquefuschia: UIColor
    {
        get
        {
            return UIColor(red: 145.0 / 255.0, green: 92.0 / 255.0, blue: 131.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is atomic tangerine (255,153,102).
    public static var atomictangerine: UIColor
    {
        get
        {
            return UIColor(red: 1.0, green: 153.0 / 255.0, blue: 102.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is carrot orange (237,145,33).
    public static var carrotorange: UIColor
    {
        get
        {
            return UIColor(red: 237.0 / 255.0, green: 145.0 / 255.0, blue: 33.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns a transparent object of black color (0,0,0).
    public static var clearblack: UIColor
    {
        get
        {
            return UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        }
    }
    
    /// Returns a transparent object of black color (255,255,255).
    public static var clearwhite: UIColor
    {
        get
        {
            return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0)
        }
    }
    
    /// Returns an object whose color is kombu green (53,66,48).
    public static var kombugreen: UIColor
    {
        get
        {
            return UIColor(red: 53.0 / 255.0, green: 66.0 / 255.0, blue: 48.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is avocado (86,130,3).
    public static var avocado: UIColor
    {
        get
        {
            return UIColor(red: 86.0 / 255.0, green: 130.0 / 255.0, blue: 3.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is gold (or golden) (255,215,0).
    public static var gold: UIColor
    {
        get
        {
            return UIColor(red: 1.0, green: 215.0 / 255.0, blue: 0.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is maroon (174,48,96).
    public static var maroon: UIColor
    {
        get
        {
            return UIColor(red: 174.0 / 255.0, green: 48.0 / 255.0, blue: 96.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is pink (255,192,203).
    public static var pink: UIColor
    {
        get
        {
            return UIColor(red: 1.0, green: 192.0 / 255.0, blue: 203.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is whitesmoke (245,245,245).
    public static var whitesmoke: UIColor
    {
        get
        {
            return UIColor(red: 245.0 / 255.0, green: 245.0 / 255.0, blue: 245.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is canary yellow (255,255,153).
    public static var canaryyellow: UIColor
    {
        get
        {
            return UIColor(red: 1.0, green: 1.0, blue: 153.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is blue-gray (102,153,204).
    public static var bluegray: UIColor
    {
        get
        {
            return UIColor(red: 102.0 / 255.0, green: 153.0 / 255.0, blue: 204.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is lemon (245,199,26).
    public static var lemon: UIColor
    {
        get
        {
            return UIColor(red: 245.0 / 255.0, green: 199.0 / 255.0, blue: 26.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is crimson (220,20,60).
    public static var crimson: UIColor
    {
        get
        {
            return UIColor(red: 220.0 / 255.0, green: 20.0 / 255.0, blue: 60.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is slate blue (106,90,193).
    public static var slateblue: UIColor
    {
        get
        {
            return UIColor(red: 106.0 / 255.0, green: 90.0 / 255.0, blue: 193.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is steel blue (70,130,180).
    public static var steelblue: UIColor
    {
        get
        {
            return UIColor(red: 70.0 / 255.0, green: 130.0 / 255.0, blue: 180.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is cadet gray (145,163,176).
    public static var cadetgray: UIColor
    {
        get
        {
            return UIColor(red: 145.0 / 255.0, green: 163.0 / 255.0, blue: 176.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is lavender (web) (230,230,250).
    public static var lavender_web: UIColor
    {
        get
        {
            return UIColor(red: 230.0 / 255.0, green: 230.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is lavender (floral) (181,126,220).
    public static var lavender_floral: UIColor
    {
        get
        {
            return UIColor(red: 181.0 / 255.0, green: 126.0 / 255.0, blue: 220.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is mint green (152,251,152).
    public static var mintgreen: UIColor
    {
        get
        {
            return UIColor(red: 152.0 / 255.0, green: 251.0 / 255.0, blue: 152.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is tea green (208,240,192).
    public static var teagreen: UIColor
    {
        get
        {
            return UIColor(red: 208.0 / 255.0, green: 240.0 / 255.0, blue: 192.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is teal (0,128,128).
    public static var teal: UIColor
    {
        get
        {
            return UIColor(red: 0.0, green: 128.0 / 255.0, blue: 128.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is olive (128,128,0).
    public static var olive: UIColor
    {
        get
        {
            return UIColor(red: 128.0 / 255.0, green: 128.0 / 255.0, blue: 0.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is celadon (172,225,175).
    public static var celadon: UIColor
    {
        get
        {
            return UIColor(red: 172.0 / 255.0, green: 225.0 / 255.0, blue: 175.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is green-yellow (173,255,47).
    public static var greenyellow: UIColor
    {
        get
        {
            return UIColor(red: 173.0 / 255.0, green: 1.0, blue: 47.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is chartreuse (web) (128,255,0).
    public static var chartreuse_web: UIColor
    {
        get
        {
            return UIColor(red: 128.0 / 255.0, green: 1.0, blue: 0.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is chartreuse (traditional) (223,255,0).
    public static var chartreuse_traditional: UIColor
    {
        get
        {
            return UIColor(red: 223.0 / 255.0, green: 1.0, blue: 0.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is china rose (168,81,110).
    public static var chinarose: UIColor
    {
        get
        {
            return UIColor(red: 168.0 / 255.0, green: 81.0 / 255.0, blue: 110.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is rose quartz (170,152,169).
    public static var rosequartz: UIColor
    {
        get
        {
            return UIColor(red: 170.0 / 255.0, green: 152.0 / 255.0, blue: 169.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is plum (221,160,221).
    public static var plum: UIColor
    {
        get
        {
            return UIColor(red: 221.0 / 255.0, green: 160.0 / 255.0, blue: 221.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is emerald (80,200,120).
    public static var emerald: UIColor
    {
        get
        {
            return UIColor(red: 80.0 / 255.0, green: 200.0 / 255.0, blue: 120.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is ghost white (248,248,255).
    public static var ghostwhite: UIColor
    {
        get
        {
            return UIColor(red: 248.0 / 255.0, green: 248.0 / 255.0, blue: 1.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is golden poppy (252,194,0).
    public static var goldenpoppy: UIColor
    {
        get
        {
            return UIColor(red: 252.0 / 255.0, green: 194.0 / 255.0, blue: 0.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is indigo (web) (75,0,130).
    public static var indigo_web: UIColor
    {
        get
        {
            return UIColor(red: 75.0 / 255.0, green: 0.0, blue: 130.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is tropical indigo (150,131,236).
    public static var tropicalindigo: UIColor
    {
        get
        {
            return UIColor(red: 150.0 / 255.0, green: 131.0 / 255.0, blue: 236.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is indigo (dye) (0,65,106).
    public static var indigo_dye: UIColor
    {
        get
        {
            return UIColor(red: 0.0 / 255.0, green: 65.0 / 255.0, blue: 106.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is azure (0,127,255).
    public static var azure: UIColor
    {
        get
        {
            return UIColor(red: 0.0, green: 127.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is midnight blue (25,25,112).
    public static var midnightblue: UIColor
    {
        get
        {
            return UIColor(red: 25.0 / 255.0, green: 25.0 / 255.0, blue: 112.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is charcoal (54,69,79).
    public static var charcoal: UIColor
    {
        get
        {
            return UIColor(red: 54.0 / 255.0, green: 69.0 / 255.0, blue: 79.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is jet (52,52,52).
    public static var jet: UIColor
    {
        get
        {
            return UIColor(red: 52.0 / 255.0, green: 52.0 / 255.0, blue: 52.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is licorice (26,17,16).
    public static var licorice: UIColor
    {
        get
        {
            return UIColor(red: 26.0 / 255.0, green: 17.0 / 255.0, blue: 16.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is beige (245,245,220).
    public static var beige: UIColor
    {
        get
        {
            return UIColor(red: 245.0 / 255.0, green: 245.0 / 255.0, blue: 220.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is khaki (196,176,145).
    public static var khaki: UIColor
    {
        get
        {
            return UIColor(red: 196.0 / 255.0, green: 176.0 / 255.0, blue: 145.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is tan (208,240,192).
    public static var tan: UIColor
    {
        get
        {
            return UIColor(red: 210.0 / 255.0, green: 180.0 / 255.0, blue: 140.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is coral pink (248,131,121).
    public static var coralpink: UIColor
    {
        get
        {
            return UIColor(red: 248.0 / 255.0, green: 131.0 / 255.0, blue: 121.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is cinnabar (228,77,48).
    public static var cinnabar: UIColor
    {
        get
        {
            return UIColor(red: 228.0 / 255.0, green: 77.0 / 255.0, blue: 48.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is mikado yellow (255,196,12).
    public static var mikadoyellow: UIColor
    {
        get
        {
            return UIColor(red: 1.0, green: 196.0 / 255.0, blue: 12.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is baby blue (137,207,240).
    public static var babyblue: UIColor
    {
        get
        {
            return UIColor(red: 137.0 / 255.0, green: 207.0 / 255.0, blue: 240.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is powder blue (176,224,230).
    public static var powderblue: UIColor
    {
        get
        {
            return UIColor(red: 176.0 / 255.0, green: 224.0 / 255.0, blue: 230.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is navy blue (0,0,128).
    public static var navyblue: UIColor
    {
        get
        {
            return UIColor(red: 0.0, green: 0.0, blue: 128.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is sapphire (8,37,103).
    public static var sapphire: UIColor
    {
        get
        {
            return UIColor(red: 8.0 / 255.0, green: 37.0 / 255.0, blue: 103.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is sienna (136,45,23).
    public static var sienna: UIColor
    {
        get
        {
            return UIColor(red: 136.0 / 255.0, green: 45.0 / 255.0, blue: 23.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is alice blue (240,248,255).
    public static var aliceblue: UIColor
    {
        get
        {
            return UIColor(red: 240.0 / 255.0, green: 248.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is cornflower (X11) (100,149,237).
    public static var cornflower_x11: UIColor
    {
        get
        {
            return UIColor(red: 100.0 / 255.0, green: 149.0 / 255.0, blue: 237.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is cornflower (Crayola) (154,206,235).
    public static var cornflower_crayola: UIColor
    {
        get
        {
            return UIColor(red: 154.0 / 255.0, green: 206.0 / 255.0, blue: 235.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is goldenrod (218,165,32).
    public static var goldenrod: UIColor
    {
        get
        {
            return UIColor(red: 218.0 / 255.0, green: 165.0 / 255.0, blue: 32.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is light goldenrod yellow (250,250,210).
    public static var lightgoldenrodyellow: UIColor
    {
        get
        {
            return UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 210.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is light goldenrod (238,232,170).
    public static var lightgoldenrod: UIColor
    {
        get
        {
            return UIColor(red: 238.0 / 255.0, green: 232.0 / 255.0, blue: 170.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is dark goldenrod (184,134,11).
    public static var darkgoldenrod: UIColor
    {
        get
        {
            return UIColor(red: 184.0 / 255.0, green: 134.0 / 255.0, blue: 11.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is honeydew (240,255,240).
    public static var honeydew: UIColor
    {
        get
        {
            return UIColor(red: 240.0 / 255.0, green: 255.0 / 255.0, blue: 240.0 / 255.0, alpha: 1.0)
        }
    }
    
    /// Returns an object whose color is papaya whip (255,239,213).
    public static var papayawhip: UIColor
    {
        get
        {
            return UIColor(red: 255.0 / 255.0, green: 239.0 / 255.0, blue: 213.0 / 255.0, alpha: 1.0)
        }
    }
}
