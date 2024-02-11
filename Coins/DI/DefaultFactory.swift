//
//  DefaultFactory.swift
//  Coins
//
//  Created by Gyorgy Borz on 10/02/2024.
//

import Foundation
import UIKit

class DefaultFactory { }

extension DefaultFactory {
    private static let baseURL: URL? = URL(string: "https://api.coincap.io")
    private static let requestBuilder: BaseAPIRequests? = BaseAPIRequests(baseURL: baseURL)
    private static let agent: Agent = Agent()

    class func dependency() -> BaseAPIRequests? {
        requestBuilder
    }

    class func dependency() -> Agent {
        agent
    }

    private static let coinsAgent: CoinsAgentProtocol = CoinsAgent(requestBuilder: DIManager.factory.dependency(),
                                                                   agent: DIManager.factory.dependency())
    class func dependency() -> CoinsAgentProtocol {
        #if MOCK
            CoinsAgentMock()
        #else
            coinsAgent
        #endif
    }

    private static let coinsRepository: CoinsRepositoryProtocol = CoinsRepository()

    class func dependency() -> CoinsRepositoryProtocol {
        #if MOCK
            CoinsRepositoryMock()
        #else
            coinsRepository
        #endif
    }

    private static let coinsProvider: CoinsProviderProtocol = CoinsProvider(
        repository: DIManager.factory.dependency(),
        coinAgent: DIManager.factory.dependency()
    )

    class func dependency() -> CoinsProviderProtocol {
        coinsProvider
    }
}
