//
//  TableCellDescriptor.swift
//  Coins
//
//  Created by Gyorgy Borz on 10/02/2024.
//

import UIKit

class TableCellDescriptor: Identifiable, Hashable {
    let id: String
    let cell: UITableViewCell.Type

    var reuseIdentifier: String {
        cell.reuseIdentifier
    }

    init(id: String, cell: UITableViewCell.Type) {
        self.id = id
        self.cell = cell
    }

    static func == (lhs: TableCellDescriptor, rhs: TableCellDescriptor) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
