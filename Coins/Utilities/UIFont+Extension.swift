//
//  UIFont+Extension.swift
//  Coins
//
//  Created by Gyorgy Borz on 10/02/2024.
//

import UIKit

extension UIFont {
    static func poppinsBold(ofSize fontSize: CGFloat) -> UIFont {
        if let poppins = UIFont(name: "Poppins-Bold", size: fontSize) {
            return poppins
        }
        return .systemFont(ofSize: fontSize, weight: .bold)
    }

    static func poppinsRegular(ofSize fontSize: CGFloat) -> UIFont {
        if let poppins = UIFont(name: "Poppins-Regular", size: fontSize) {
            return poppins
        }
        return .systemFont(ofSize: fontSize)
    }
}
