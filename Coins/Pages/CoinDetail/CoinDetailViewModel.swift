//
//  CoinDetailViewModel.swift
//  Coins
//
//  Created by Gyorgy Borz on 10/02/2024.
//

import Combine
import Foundation

final class CoinDetailViewModel {
    private let coinsProvider: CoinsProviderProtocol
    private var disposeBag = Set<AnyCancellable>()

    var coinDetail: AnyPublisher<Coin, Never> {
        coinsProvider.selectedCoin
    }

    var isLoadingPublisher: AnyPublisher<Bool, Never> {
        coinsProvider.isLoading.prepend(true).eraseToAnyPublisher()
    }

    let navigationSubject = PassthroughSubject<Page, Never>()

    init(coinId: String, coinsProvider: CoinsProviderProtocol) {
        self.coinsProvider = coinsProvider

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // some delay so the data doesn't load instantly upon detail navigation
            // thus the whole 'loading' state can be simulated
            coinsProvider.getCoin(with: coinId)
        }

        navigationSubject.forward(to: NavigationProvider.page).store(in: &disposeBag)
    }
}
