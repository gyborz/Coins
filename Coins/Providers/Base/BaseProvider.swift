//
//  BaseProvider.swift
//  Coins
//
//  Created by Gyorgy Borz on 10/02/2024.
//

import Combine
import Foundation

protocol BaseProviderProtocol {
    associatedtype DataType: Codable
    var errorPublisher: AnyPublisher<Error, Never> { get }
    var isLoading: AnyPublisher<Bool, Never> { get }
    var updatedPublisher: AnyPublisher<DataType, Never> { get }
    var updateSubject: CurrentValueSubject<DataType, Never> { get }
}

class BaseProvider<T: Persistable>: BaseProviderProtocol {
    private var repository: BaseRepository<T>
    var disposeBag = Set<AnyCancellable>()
    let errorSubject = PassthroughSubject<Error, Never>()
    let loadingSubject = PassthroughSubject<Bool, Never>()

    var errorPublisher: AnyPublisher<Error, Never> {
        errorSubject.eraseToAnyPublisher()
    }

    var isLoading: AnyPublisher<Bool, Never> {
        loadingSubject.removeDuplicates().eraseToAnyPublisher()
    }

    var updatedPublisher: AnyPublisher<T, Never> {
        repository.dataPublisher.share().eraseToAnyPublisher()
    }

    let updateSubject: CurrentValueSubject<T, Never>

    init(repository: BaseRepository<T>) {
        self.repository = repository

        updateSubject = CurrentValueSubject<T, Never>(repository.currentData)
        updateSubject.forward(to: repository.addNewData).store(in: &disposeBag)
    }
}
