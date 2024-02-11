//
//  CombineUtils.swift
//  Coins
//
//  Created by Gyorgy Borz on 10/02/2024.
//

import Combine
import Foundation
import UIKit

extension Publisher {
    /// Connect a subject to another subject which can't fail
    /// ```
    /// let firstSubject = PassthroughSubject<Void, Never>()
    /// let secondsSubject = PassthroughSubject<Void, Never>()
    ///
    /// var cancellable = firstSubject.bind(to: secondsSubject)
    /// ```
    /// - Parameter subject: Subject to connect to
    /// - Returns: AnyCancellable
    func forward<S: Subject>(to subject: S) -> AnyCancellable where S.Output == Output {
        sink(receiveCompletion: { _ in }, receiveValue: subject.send)
    }

    /// Connect a subject to another (optional) subject which can't fail
    /// ```
    /// let firstSubject = PassthroughSubject<Void, Never>()
    /// let secondsSubject = PassthroughSubject<Void, Never>()
    ///
    /// var cancellable = firstSubject.bind(to: secondsSubject)
    /// ```
    /// - Parameter subject: Subject to connect to
    /// - Returns: AnyCancellable
    func forward<S: Subject>(to subject: S) -> AnyCancellable where S.Output == Optional<Output> {
        sink(receiveCompletion: { _ in }, receiveValue: subject.send)
    }

    /// Maps value into Void
    /// - Returns: Publisher
    func toVoid() -> Publishers.Map<Self, Void> {
        return map({ _ in })
    }

    /// Maps value into true
    /// - Returns: Publisher
    func toTrue() -> Publishers.Map<Self, Bool> {
        return map { _ in true }
    }

    /// Maps value into false
    /// - Returns: Publisher
    func toFalse() -> Publishers.Map<Self, Bool> {
        return map { _ in false }
    }

    func withLatestFrom<P>(_ other: P) -> AnyPublisher<(Self.Output, P.Output), Failure> where P: Publisher, Self.Failure == P.Failure {
        map { ($0, arc4random()) }
            .combineLatest(other)
            .removeDuplicates(by: { old, new -> Bool in
                let lhs = old.0, rhs = new.0
                return lhs.1 == rhs.1
            })
            .map { ($0.0, $1) }
            .eraseToAnyPublisher()
    }

    func map<T>(_ object: T) -> Publishers.Map<Self, T> {
        return map { _ in object }
    }
}
