//
//  DIManager.swift
//  Coins
//
//  Created by Gyorgy Borz on 10/02/2024.
//

import Foundation

class DIManager {
    private var factory: DefaultFactory.Type
    private static var sharedManager: DIManager?

    private static func shared() -> DIManager {
        guard let manager = sharedManager else {
            sharedManager = DIManager()
            return sharedManager!
        }

        return manager
    }

    private init<T>(factory: T.Type = T.self) where T: DefaultFactory {
        self.factory = T.self
    }

    static func setupOnce<T>(factory: T.Type = T.self) where T: DefaultFactory {
        if sharedManager == nil {
            sharedManager = DIManager(factory: factory)
        }
    }

    static var factory: DefaultFactory.Type {
        DIManager.shared().factory
    }
}
