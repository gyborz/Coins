//
//  BaseRepository.swift
//  Coins
//
//  Created by Gyorgy Borz on 10/02/2024.
//

import Combine
import Foundation

protocol BaseRepositoryProtocol {
    associatedtype DataType
    var addNewData: PassthroughSubject<DataType, Never> { get }
    var dataPublisher: AnyPublisher<DataType, Never> { get }
}

class BaseRepository<T: Persistable>: BaseRepositoryProtocol {
    typealias DataType = T
    var disposeBag = Set<AnyCancellable>()
    var dataSubject: CurrentValueSubject<DataType, Never>!
    lazy var dataPublisher: AnyPublisher<DataType, Never> = {
        dataSubject.eraseToAnyPublisher()
    }()

    var fileName: String {
        fatalError("Override this")
    }

    var directory: PersistenceDirectory {
        return .caches
    }

    var defaultData: DataType {
        fatalError("Override this")
    }

    var addNewData = PassthroughSubject<DataType, Never>()

    init() {
        do {
            let stateFromStorage = try DataStorage.read(fileName, directory: directory, type: DataType.self)
            dataSubject = CurrentValueSubject<DataType, Never>(stateFromStorage)
        } catch {
            dataSubject = CurrentValueSubject<DataType, Never>(defaultData)
        }

        dataSubject.sink { data in
            do {
                try DataStorage.write(self.fileName, directory: self.directory, data: data)
            } catch {
                print("\(error.localizedDescription)")
            }
        }.store(in: &disposeBag)

        addNewData.forward(to: dataSubject).store(in: &disposeBag)
    }

    var currentData: DataType {
        dataSubject.value
    }
}
