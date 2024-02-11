//
//  HomeViewModel.swift
//  Coins
//
//  Created by Gyorgy Borz on 10/02/2024.
//

import Combine
import Foundation

final class HomeViewModel {
    private let coinsProvider: CoinsProviderProtocol
    private var disposeBag = Set<AnyCancellable>()

    private let coinTapSubject = PassthroughSubject<String, Never>()

    var cellModels: AnyPublisher<[TableCellDescriptor], Never> {
        coinsProvider.topCoins
            .map { coins -> [TableCellDescriptor] in
                var cellModels: [TableCellDescriptor] = []

                for coin in coins {
                    cellModels.append(
                        CoinCellViewModel(
                            coin: coin,
                            tapSubject: self.coinTapSubject,
                            cellType: CoinCell.self
                        )
                    )
                }

                return cellModels
            }.eraseToAnyPublisher()
    }

    var isLoadingPublisher: AnyPublisher<Bool, Never> {
        coinsProvider.isLoading.prepend(true).eraseToAnyPublisher()
    }

    init(coinsProvider: CoinsProviderProtocol) {
        self.coinsProvider = coinsProvider

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // some delay so the data doesn't load instantly upon app start
            // thus the whole 'loading' state can be simulated
            coinsProvider.getAllCoins()
        }

        coinTapSubject
            .map { id in Page.coinDetail(id: id) }
            .forward(to: NavigationProvider.page)
            .store(in: &disposeBag)
    }
}
