//
//  Double+Extension.swift
//  Coins
//
//  Created by Gyorgy Borz on 11/02/2024.
//

import Foundation

extension Double {
    func formatAndAbbreviate() -> String {
        let thousand: Double = 1000
        let million: Double = 1000000
        let billion: Double = 1000000000

        switch self {
        case thousand ..< million:
            return "\((self / thousand).formatted(.number.precision(.fractionLength(0 ... 2))))K"
        case million ..< billion:
            return "\((self / million).formatted(.number.precision(.fractionLength(0 ... 2))))M"
        case billion...:
            return "\((self / billion).formatted(.number.precision(.fractionLength(0 ... 2))))B"
        default:
            return formatted(.number.precision(.fractionLength(0 ... 2)))
        }
    }
}
