//
//  CoinMocks.swift
//  Coins
//
//  Created by Gyorgy Borz on 10/02/2024.
//

import Foundation

extension Coin {
    static let mock1: Coin = Coin(id: "bitcoin",
                                  rank: 1,
                                  symbol: "BTC",
                                  name: "Bitcoin",
                                  supply: 19623800,
                                  marketCapUsd: 922608342780.8895,
                                  volumeUsd24Hr: 17696760333.3806,
                                  priceUsd: 47014.7648,
                                  changePercent24Hr: 0.8625)
}
