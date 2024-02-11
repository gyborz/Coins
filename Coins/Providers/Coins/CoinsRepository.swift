//
//  CoinsRepository.swift
//  Coins
//
//  Created by Gyorgy Borz on 10/02/2024.
//

import Combine
import Foundation

protocol CoinsRepositoryProtocol: BaseRepository<[Coin]> {
    var updateAllCoinsWithNewCoin: PassthroughSubject<Coin, Never> { get }
}

class CoinsRepository: BaseRepository<[Coin]>, CoinsRepositoryProtocol {
    override var fileName: String {
        "coins.json"
    }

    override var directory: PersistenceDirectory {
        .caches
    }

    override var defaultData: BaseRepository<[Coin]>.DataType {
        []
    }

    var updateAllCoinsWithNewCoin = PassthroughSubject<Coin, Never>()

    override init() {
        super.init()
        updateAllCoinsWithNewCoin.withLatestFrom(dataPublisher)
            .map { newCoin, allCoins in
                var mutableCoins = allCoins
                if let matchingExistingCoin = mutableCoins.first(where: { $0.id == newCoin.id }),
                   let index = mutableCoins.indexOfItem(matchingExistingCoin) {
                    _ = mutableCoins.remove(at: index)
                    mutableCoins.insert(newCoin, at: index)
                    mutableCoins = mutableCoins.sorted(by: { $0.rank < $1.rank })
                }
                return mutableCoins
            }.forward(to: addNewData)
            .store(in: &disposeBag)
    }
}

final class CoinsRepositoryMock: CoinsRepository { 
    override var fileName: String {
        "coinsTest.json"
    }
}
