//
//  CoinsProvider.swift
//  Coins
//
//  Created by Gyorgy Borz on 10/02/2024.
//

import Combine
import Foundation

protocol CoinsProviderProtocol: BaseProvider<[Coin]> {
    func getAllCoins()
    func getCoin(with id: String)
    var topCoins: AnyPublisher<[Coin], Never> { get }
    var selectedCoin: AnyPublisher<Coin, Never> { get }
}

final class CoinsProvider: BaseProvider<[Coin]>, CoinsProviderProtocol {
    private let repository: CoinsRepositoryProtocol
    private let coinsAgent: CoinsAgentProtocol

    // MARK: - INPUT

    func getAllCoins() {
        loadingSubject.send(true)
        Task {
            do {
                let coins = try await coinsAgent.getAllCoins()
                self.updateSubject.send(coins)
            } catch {
                self.errorSubject.send(error)
            }
        }
    }

    func getCoin(with id: String) {
        loadingSubject.send(true)
        selectedCoinIdSubject.send(id)
        Task {
            do {
                let coin = try await coinsAgent.getCoin(with: id)
                self.repository.updateAllCoinsWithNewCoin.send(coin)
            } catch {
                self.errorSubject.send(error)
            }
        }
    }

    // MARK: - OUTPUT

    var topCoins: AnyPublisher<[Coin], Never> {
        updatedPublisher.dropFirst().map { Array($0.prefix(10)) }.eraseToAnyPublisher()
    }

    private let selectedCoinIdSubject = CurrentValueSubject<String, Never>("")
    var selectedCoin: AnyPublisher<Coin, Never> {
        updatedPublisher.dropFirst().withLatestFrom(selectedCoinIdSubject)
            .map { allCoins, selectedCoinId -> Coin? in
                allCoins.first(where: { $0.id == selectedCoinId })
            }.compactMap { $0 }
            .eraseToAnyPublisher()
    }

    init(repository: CoinsRepositoryProtocol, coinAgent: CoinsAgentProtocol) {
        self.repository = repository
        self.coinsAgent = coinAgent
        super.init(repository: repository)

        errorPublisher.toFalse()
            .merge(with: topCoins.filter { !$0.isEmpty }.toFalse(),
                   selectedCoin.toFalse())
            .delay(for: 0.5, scheduler: DispatchQueue.main)
            .forward(to: loadingSubject)
            .store(in: &disposeBag)
    }
}
