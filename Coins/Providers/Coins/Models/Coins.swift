//
//  Coins.swift
//  Coins
//
//  Created by Gyorgy Borz on 10/02/2024.
//

import Foundation

struct CoinsDTO: Codable {
    let data: [CoinDTO]
}

struct CoinDetailDTO: Codable {
    let data: CoinDTO
}

struct CoinDTO: Codable {
    let id: String
    let rank: String
    let symbol: String?
    let name: String?
    let supply: String?
    let marketCapUsd: String?
    let volumeUsd24Hr: String?
    let priceUsd: String?
    let changePercent24Hr: String?
}

struct Coin: Persistable, Equatable {
    let id: String
    let rank: Int
    let symbol: String
    let name: String
    let supply: Double
    let marketCapUsd: Double
    let volumeUsd24Hr: Double
    let priceUsd: Double
    let changePercent24Hr: Double

    var formattedPrice: String {
        "$\(priceUsd.formatAndAbbreviate())"
    }

    var formattedPercentage: String {
        changePercent24Hr.formatted(.number.precision(.fractionLength(0 ... 2))) + "%"
    }

    var formattedMarketCap: String {
        "$\(marketCapUsd.formatAndAbbreviate())"
    }

    var formattedVolume24Hr: String {
        "$\(volumeUsd24Hr.formatAndAbbreviate())"
    }

    var formattedSupply: String {
        supply.formatAndAbbreviate()
    }

    var icon: URL? {
        // could not find any icon or image related data in the original api
        // so in order to demo the proper UI of the cells I simply hardcoded an url
        URL(string: "https://placekitten.com/100/100")
    }

    init(dto: CoinDTO) {
        id = dto.id
        rank = Int(dto.rank) ?? 1
        symbol = dto.symbol ?? "n/a"
        name = dto.name ?? "n/a"
        supply = Double(dto.supply ?? "0") ?? 0
        marketCapUsd = Double(dto.marketCapUsd ?? "0") ?? 0
        volumeUsd24Hr = Double(dto.volumeUsd24Hr ?? "0") ?? 0
        priceUsd = Double(dto.priceUsd ?? "0") ?? 0
        changePercent24Hr = Double(dto.changePercent24Hr ?? "0") ?? 0
    }

    init(
        id: String,
        rank: Int,
        symbol: String,
        name: String,
        supply: Double,
        marketCapUsd: Double,
        volumeUsd24Hr: Double,
        priceUsd: Double,
        changePercent24Hr: Double
    ) {
        self.id = id
        self.rank = rank
        self.symbol = symbol
        self.name = name
        self.supply = supply
        self.marketCapUsd = marketCapUsd
        self.volumeUsd24Hr = volumeUsd24Hr
        self.priceUsd = priceUsd
        self.changePercent24Hr = changePercent24Hr
    }
}
