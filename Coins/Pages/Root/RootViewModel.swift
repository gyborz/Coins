//
//  RootViewModel.swift
//  Coins
//
//  Created by Gyorgy Borz on 10/02/2024.
//

import Combine
import Foundation

final class RootViewModel {
    private var disposeBag = Set<AnyCancellable>()

    var currentPagePublisher: AnyPublisher<Page, Never> {
        NavigationProvider.page.eraseToAnyPublisher()
    }

    let changePage = PassthroughSubject<Page, Never>()

    init() {
        changePage.forward(to: NavigationProvider.page).store(in: &disposeBag)
    }
}
