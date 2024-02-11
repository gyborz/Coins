//
//  Optional+Extension.swift
//  Coins
//
//  Created by Gyorgy Borz on 10/02/2024.
//

import Foundation

extension Optional {
    func orThrow(_ errorExpression: @autoclosure () -> Error) throws -> Wrapped {
        switch self {
        case let .some(value):
            return value
        case .none:
            throw errorExpression()
        }
    }
}
