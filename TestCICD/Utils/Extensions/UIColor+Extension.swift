//
//  UIColor+Extension.swift
//  EVP4
//
//  Created by Stone Zhang on 9/1/22.
//

import Foundation
import UIKit

extension UIColor {
    convenience init?(hex: String) {
        guard hex.hasPrefix("#") else { return nil }
        let hexColor = hex.dropFirst()
        guard hexColor.count == 8 else { return nil }
        let scanner = Scanner(string: String(hexColor))
        var hexNumber: UInt64 = 0
        guard scanner.scanHexInt64(&hexNumber) else { return nil }
        let red = CGFloat((hexNumber & 0xFF000000) >> 24) / 255
        let green = CGFloat((hexNumber & 0x00FF0000) >> 16) / 255
        let blue = CGFloat((hexNumber & 0x0000FF00) >> 8) / 255
        let alpha = CGFloat(hexNumber & 0x000000FF) / 255
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
