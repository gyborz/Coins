//
//  CoinAgent.swift
//  Coins
//
//  Created by Gyorgy Borz on 10/02/2024.
//

import Foundation

protocol CoinsAgentProtocol {
    func getAllCoins() async throws -> [Coin]
    func getCoin(with id: String) async throws -> Coin
}

final class CoinsAgent: CoinsAgentProtocol {
    private let requestBuilder: BaseAPIRequests?
    private let agent: Agent

    init(requestBuilder: BaseAPIRequests?, agent: Agent) {
        self.requestBuilder = requestBuilder
        self.agent = agent
    }

    func getAllCoins() async throws -> [Coin] {
        let request = requestBuilder?.buildRequest(path: "/v2/assets")
        let coins = try await agent.run(request) { (dto: CoinsDTO) in
            dto.data.map { Coin(dto: $0) }
        }
        return coins
    }

    func getCoin(with id: String) async throws -> Coin {
        let request = requestBuilder?.buildRequest(path: "/v2/assets/\(id)")
        let coin = try await agent.run(request) { (dto: CoinDetailDTO) in
            Coin(dto: dto.data)
        }
        return coin
    }
}

final class CoinsAgentMock: CoinsAgentProtocol {
    private let coinsResourceName: String = "coinsTestData"
    private let coinResourceName: String = "coinTestData"

    func getAllCoins() async throws -> [Coin] {
        guard let coinsData = try getTestDataFromBundle(for: coinsResourceName) else { return [] }
        let coinsTestData = try JSONDecoder().decode(CoinsDTO.self, from: coinsData)
        return coinsTestData.data.map { Coin(dto: $0) }
    }

    func getCoin(with id: String) async throws -> Coin {
        guard let coinData = try getTestDataFromBundle(for: coinResourceName) else { return .mock1 }
        let coinTestData = try JSONDecoder().decode(CoinDetailDTO.self, from: coinData)
        return Coin(dto: coinTestData.data)
    }

    private func getTestDataFromBundle(for resource: String) throws -> Data? {
        guard let filepath = Bundle.main.url(forResource: resource, withExtension: "txt") else { return nil }
        return try Data(contentsOf: filepath)
    }
}
