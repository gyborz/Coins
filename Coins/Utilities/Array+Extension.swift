//
//  Array+Extension.swift
//  Coins
//
//  Created by Gyorgy Borz on 10/02/2024.
//

import Foundation

extension Array {
    func indexOfItem<T: Equatable>(_ element: T) -> Int? {
        if let arrayIndex = firstIndex(where: { $0 as? T == element }) {
            return distance(from: startIndex, to: arrayIndex)
        }
        return nil
    }
}

extension Array where Element: Comparable {
    func isAscending() -> Bool {
        return zip(self, dropFirst()).allSatisfy(<=)
    }
}
