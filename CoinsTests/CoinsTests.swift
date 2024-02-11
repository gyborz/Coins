//
//  CoinsTests.swift
//  CoinsTests
//
//  Created by Gyorgy Borz on 11/02/2024.
//

@testable import Coins
import Combine
import XCTest

final class CoinsTests: XCTestCase {
    private var coinsProvider: CoinsProviderProtocol?
    private var coinsRepository: CoinsRepositoryProtocol?
    private var coinsAgent: CoinsAgentProtocol?
    private var disposeBag = Set<AnyCancellable>()

    override func setUpWithError() throws {
        coinsRepository = CoinsRepositoryMock()
        coinsAgent = CoinsAgentMock()
        coinsProvider = CoinsProvider(repository: coinsRepository!, coinAgent: coinsAgent!)
    }

    override func tearDownWithError() throws { }

    func testProviderUpdateWithFullTestData() throws {
        guard let coinsProvider, let coinsRepository else {
            XCTFail("Failed to initialize")
            return
        }

        coinsRepository.addNewData.send([])

        XCTAssert(coinsRepository.currentData == [], "Default current data is not empty")

        coinsProvider.getAllCoins()

        coinsProvider.updatedPublisher
            .dropFirst() // skip default data read
            .sink { coins in
                XCTAssert(!coins.isEmpty, "Repository has no data")
                XCTAssert(coins.count == 100, "Repository doesn't have full data set")
                XCTAssert(coinsRepository.currentData == coins, "Repository has different data set")
            }.store(in: &disposeBag)
    }

    func testProviderUpdateWithRealAPIFullTestData() throws {
        let realCoinsProvider: CoinsProviderProtocol = CoinsProvider(repository: CoinsRepository(),
                                                                     coinAgent: CoinsAgent(requestBuilder: DIManager.factory.dependency(), agent: DIManager.factory.dependency()))

        let expectation = expectation(description: "No response for all coins")

        realCoinsProvider.getAllCoins()

        realCoinsProvider.updatedPublisher
            .sink { coins in
                if !coins.isEmpty {
                    expectation.fulfill()
                }
            }.store(in: &disposeBag)

        waitForExpectations(timeout: 3)
    }

    func testProviderOutputNumberOfTopCoins() throws {
        guard let coinsProvider else {
            XCTFail("Failed to initialize")
            return
        }

        coinsProvider.getAllCoins()

        coinsProvider.topCoins
            .sink { topCoins in
                XCTAssert(!topCoins.isEmpty, "Top coins array is empty")
                XCTAssert(topCoins.count == 10, "Top coins array doesn't have 10 items")
            }.store(in: &disposeBag)
    }

    func testProviderOutputTopCoinsOrder() throws {
        guard let coinsProvider else {
            XCTFail("Failed to initialize")
            return
        }

        coinsProvider.getAllCoins()

        coinsProvider.topCoins
            .map { $0.map { $0.rank } }
            .sink { topCoinsRanks in
                XCTAssert(topCoinsRanks.isAscending(), "Top coins are not in order")
            }.store(in: &disposeBag)
    }

    func testProviderOutputRealAPITopCoins() throws {
        let realCoinsProvider: CoinsProviderProtocol = CoinsProvider(repository: CoinsRepository(),
                                                                     coinAgent: CoinsAgent(requestBuilder: DIManager.factory.dependency(), agent: DIManager.factory.dependency()))

        let expectation = expectation(description: "No response for top coins")

        realCoinsProvider.getAllCoins()

        realCoinsProvider.topCoins
            .sink { topCoins in
                XCTAssert(!topCoins.isEmpty, "Top coins array is empty")
                XCTAssert(topCoins.count == 10, "Top coins array doesn't have 10 items")
                if !topCoins.isEmpty {
                    expectation.fulfill()
                }
            }.store(in: &disposeBag)

        waitForExpectations(timeout: 3)
    }

    func testProviderOutputRealAPITopCoinsOrderr() throws {
        let realCoinsProvider: CoinsProviderProtocol = CoinsProvider(repository: CoinsRepository(),
                                                                     coinAgent: CoinsAgent(requestBuilder: DIManager.factory.dependency(), agent: DIManager.factory.dependency()))

        let expectation = expectation(description: "No response for top coins")

        realCoinsProvider.getAllCoins()

        realCoinsProvider.topCoins
            .map { $0.map { $0.rank }}
            .sink { topCoinsRanks in
                XCTAssert(topCoinsRanks.isAscending(), "Top coins are not in order")
                expectation.fulfill()
            }.store(in: &disposeBag)

        waitForExpectations(timeout: 3)
    }

    func testProviderOutputSelectedCoin() async throws {
        guard let coinsProvider, let coinsAgent else {
            XCTFail("Failed to initialize")
            return
        }

        let testCoinId: String = "bitcoin"
        let testCoin = try await coinsAgent.getCoin(with: testCoinId)

        coinsProvider.getCoin(with: testCoinId)

        coinsProvider.selectedCoin
            .sink { selectedCoin in
                XCTAssert(selectedCoin == testCoin, "Selected coin differs from test coin")
            }.store(in: &disposeBag)
    }

    func testProviderOutputRealAPISelectedCoin() throws {
        let realCoinsProvider: CoinsProviderProtocol = CoinsProvider(repository: CoinsRepository(),
                                                                     coinAgent: CoinsAgent(requestBuilder: DIManager.factory.dependency(), agent: DIManager.factory.dependency()))

        let expectation = expectation(description: "No response for selected coin")

        let testCoinId: String = "bitcoin"

        realCoinsProvider.getAllCoins()
        sleep(1)
        realCoinsProvider.getCoin(with: testCoinId)

        realCoinsProvider.selectedCoin
            .sink { selectedCoin in
                if selectedCoin.id == testCoinId {
                    expectation.fulfill()
                }
            }.store(in: &disposeBag)

        waitForExpectations(timeout: 3)
    }
}
