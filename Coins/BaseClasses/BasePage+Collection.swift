//
//  BasePage+Collection.swift
//  Coins
//
//  Created by Gyorgy Borz on 10/02/2024.
//

import Combine
import UIKit

enum SingleSection: Hashable {
    case main
}

extension BasePage {
    func dataSource(for tableView: UITableView) -> UITableViewDiffableDataSource<SingleSection, TableCellDescriptor> {
        let dataSource = UITableViewDiffableDataSource<SingleSection, TableCellDescriptor>(tableView: tableView) { tableView, indexPath, descriptor in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: descriptor.reuseIdentifier, for: indexPath) as? BaseTableViewCell else { return UITableViewCell() }
            cell.viewModel = descriptor
            return cell
        }
        return dataSource
    }

    func subscribe(tableView: UITableView, on cellModels: AnyPublisher<[TableCellDescriptor], Never>, shouldAnimate: Bool = true, defaultRowAnimation: UITableView.RowAnimation = .automatic) {
        let dataSource = dataSource(for: tableView)
        let dataSourcePublisher = cellModels
            .receive(on: DispatchQueue.main)
            .flatMap(tableView.registerCells(_:))
            .share()

        dataSourcePublisher
            .sink { descriptors in
                var snapshot = NSDiffableDataSourceSnapshot<SingleSection, TableCellDescriptor>()
                snapshot.appendSections([.main])
                snapshot.appendItems(descriptors)
                dataSource.apply(snapshot, animatingDifferences: shouldAnimate)
                dataSource.defaultRowAnimation = defaultRowAnimation
            }.store(in: &disposeBag)
    }
}
