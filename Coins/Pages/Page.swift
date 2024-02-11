//
//  Page.swift
//  Coins
//
//  Created by Gyorgy Borz on 10/02/2024.
//

import Combine
import Foundation

enum Page: Equatable {
    case home
    case coinDetail(id: String)
    case back(_ isSwipe: Bool, _ isAnimate: Bool = true)

    static func == (lhs: Page, rhs: Page) -> Bool {
        switch (lhs, rhs) {
        case (.home, .home):
            return true
        case (.coinDetail, .coinDetail):
            return true
        case (.back(_, _), .back(_, _)):
            return false
        default:
            return false
        }
    }
}

final class NavigationProvider {
    static var page = CurrentValueSubject<Page, Never>(.home)
}
