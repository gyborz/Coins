//
//  DataStorage.swift
//  Coins
//
//  Created by Gyorgy Borz on 10/02/2024.
//

import Foundation

enum PersistenceDirectory: Equatable {
    case documents
    case caches
    case applicationSupport
    case temporary

    func path() throws -> URL {
        switch self {
        case .documents:
            return try FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                .orThrow(CocoaError(.fileReadNoSuchFile))
        case .caches:
            return try FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
                .orThrow(CocoaError(.fileReadNoSuchFile))
        case .applicationSupport:
            return try FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
                .orThrow(CocoaError(.fileReadNoSuchFile))
        case .temporary:
            return FileManager.default.temporaryDirectory
        }
    }
}

protocol Persistable: Codable {
    var preservedType: String { get }
}

extension Persistable {
    var preservedType: String {
        String(describing: type(of: self))
    }
}

final class TypePreservingObject: Codable {
    var preservedType: String
    init(type: String) {
        preservedType = type
    }
}

final class TypePreservingList: Codable {
    var preservedTypes: [String]
    init() {
        preservedTypes = []
    }
}

final class TypePreservingDictionary: Codable {
    var preservedTypes: [String: String]
    init() {
        preservedTypes = [:]
    }
}

extension Array: Persistable where Element: Codable { }
extension Dictionary: Persistable where Key: Hashable & Codable, Value: Codable { }

final class DataStorage {
    class func read<T: Persistable>(_ file: String, directory: PersistenceDirectory, type: T.Type) throws -> T {
        var readPath: URL = try directory.path()
        readPath.appendPathComponent(file)

        let data = try Data(contentsOf: readPath)
        let decoded = try JSONDecoder().decode(type, from: data)

        return decoded
    }

    class func write<T: Persistable>(_ file: String, directory: PersistenceDirectory, data: T) throws {
        // print("Type: \(String(describing: data))")

        let path: URL = try directory.path()
        let writePath = path.appendingPathComponent(file)
        let typePath = path.appendingPathComponent("\(file).types")

        if let array = data as? [Persistable] {
            let typeList = TypePreservingList()
            array.forEach { persistable in
                typeList.preservedTypes.append(persistable.preservedType)
            }
            let encodedTypes = try JSONEncoder().encode(typeList)
            try encodedTypes.write(to: typePath)
        } else if let dictionary = data as? [String: Persistable] {
            let typeDictionary = TypePreservingDictionary()
            dictionary.keys.forEach { key in
                typeDictionary.preservedTypes[key] = dictionary[key]?.preservedType
            }
            let encodedTypes = try JSONEncoder().encode(typeDictionary)
            try encodedTypes.write(to: typePath)
        } else {
            let typeObject = TypePreservingObject(type: data.preservedType)
            let encodedTypes = try JSONEncoder().encode(typeObject)
            try encodedTypes.write(to: typePath)
        }

        let encoded = try JSONEncoder().encode(data)
        // print("Encoded: \(String(data: encoded, encoding: .ascii) ?? "")")

        try encoded.write(to: writePath)
    }
}
