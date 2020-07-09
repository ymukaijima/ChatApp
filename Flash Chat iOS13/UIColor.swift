//
//  File.swift
//  Flash Chat iOS13
//
//  Created by yumi on 2020/07/01.
//  Copyright © 2020 Angela Yu. All rights reserved.
//

import UIKit

extension UIColor {
    
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return self.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
    }
    
}
