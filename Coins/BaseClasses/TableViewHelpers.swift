//
//  TableViewHelpers.swift
//  Coins
//
//  Created by Gyorgy Borz on 10/02/2024.
//

import Combine
import UIKit

class BaseTableViewCell: UITableViewCell {
    var viewModel: TableCellDescriptor?
}

extension UITableViewCell {
    static var reuseIdentifier: String { className }

    static func register(in tableView: UITableView) {
        let moduleName = Bundle.main.infoDictionary!["CFBundleName"] as! String
        tableView.register(NSClassFromString("\(moduleName)." + className), forCellReuseIdentifier: reuseIdentifier)
    }
}

extension UITableView {
    func dequeueCell<T: UITableViewCell>(for indexPath: IndexPath) -> T? {
        dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T
    }

    func registerCells(_ cellModels: [TableCellDescriptor]) -> AnyPublisher<[TableCellDescriptor], Never> {
        cellModels.forEach { model in
            self.register(model.cell, forCellReuseIdentifier: model.reuseIdentifier)
        }
        return Just(cellModels).eraseToAnyPublisher()
    }
}

extension UIView {
    static var className: String {
        String(describing: self)
    }
}
