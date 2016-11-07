//
//  TMRGBA.swift
//  TrueFalseStarter
//
//  Created by redBred LLC on 10/28/16.
//  Copyright © 2016 redBred LLC. All rights reserved.
//

import UIKit

extension UIColor {
    
    static func TMRGBA(red: Int, green:Int, blue: Int, alpha: Int) -> UIColor {
        
        return UIColor(red: CGFloat(red)/CGFloat(255), green: CGFloat(green)/CGFloat(255), blue: CGFloat(blue)/CGFloat(255), alpha: CGFloat(alpha)/CGFloat(255))
    }
}
