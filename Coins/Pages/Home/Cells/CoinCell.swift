//
//  CoinCell.swift
//  Coins
//
//  Created by Gyorgy Borz on 10/02/2024.
//

import Combine
import SwiftUI
import UIKit

final class CoinCellViewModel: TableCellDescriptor {
    let coin: Coin
    let tapSubject: PassthroughSubject<String, Never>

    init(coin: Coin, tapSubject: PassthroughSubject<String, Never>, cellType: UITableViewCell.Type) {
        self.coin = coin
        self.tapSubject = tapSubject
        super.init(id: "\(coin.rank)_\(coin.priceUsd)_\(coin.changePercent24Hr)", cell: cellType)
    }
}

final class CoinCell: BaseTableViewCell {
    private lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .white.withAlphaComponent(0.4)
        containerView.layer.cornerRadius = 16
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        containerView.addGestureRecognizer(tapGesture)
        return containerView
    }()

    private let coinImageView = AsyncUIImage()
    private lazy var coinImageViewController: UIHostingController = {
        UIHostingController(rootView: coinImageView).apply {
            $0.view.backgroundColor = .clear
            $0.view.layer.cornerRadius = coinImageSize / 2
            $0.view.clipsToBounds = true
        }
    }()

    private let nameLabel = UILabel().apply {
        $0.font = .poppinsBold(ofSize: 20)
        $0.textColor = .aBlack
    }

    private let symbolLabel = UILabel().apply {
        $0.font = .poppinsRegular(ofSize: 16)
        $0.textColor = .aBlack
    }

    private let priceLabel = UILabel().apply {
        $0.font = .poppinsBold(ofSize: 16)
        $0.textColor = .aBlack
        $0.textAlignment = .right
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    private let percentageLabel = UILabel().apply {
        $0.font = .poppinsBold(ofSize: 16)
        $0.textAlignment = .right
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    private let navigationImageView = UIImageView(image: .arrowRight.withRenderingMode(.alwaysTemplate).withConfiguration(UIImage.SymbolConfiguration(pointSize: 17))).apply {
        $0.contentMode = .scaleAspectFill
        $0.tintColor = .aBlack
    }

    private let containerSideOffset: CGFloat = 16
    private let coinImageSize: CGFloat = 56
    private let containerInnerTrailingOffset: CGFloat = 16
    private let navigationImageViewSize: CGFloat = 24

    private let tapSubject = PassthroughSubject<Void, Never>()
    private var disposeBag = Set<AnyCancellable>()

    override var viewModel: TableCellDescriptor? {
        didSet {
            guard let viewModel = viewModel as? CoinCellViewModel else { return }
            nameLabel.text = viewModel.coin.name.uppercased()
            symbolLabel.text = viewModel.coin.symbol
            priceLabel.text = viewModel.coin.formattedPrice
            percentageLabel.text = viewModel.coin.formattedPercentage
            coinImageView.viewModel.imageURL = viewModel.coin.icon

            if viewModel.coin.changePercent24Hr >= 0 {
                percentageLabel.textColor = .aGreen
            } else {
                percentageLabel.textColor = .aRed
            }

            disposeBag = Set<AnyCancellable>()
            tapSubject.map { _ in viewModel.coin.id }.forward(to: viewModel.tapSubject).store(in: &disposeBag)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(containerView)
        containerView.addSubview(coinImageViewController.view)
        containerView.addSubview(nameLabel)
        containerView.addSubview(symbolLabel)
        containerView.addSubview(priceLabel)
        containerView.addSubview(percentageLabel)
        containerView.addSubview(navigationImageView)

        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: containerSideOffset),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: containerSideOffset),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -containerSideOffset),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])

        coinImageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            coinImageViewController.view.widthAnchor.constraint(equalToConstant: coinImageSize),
            coinImageViewController.view.heightAnchor.constraint(equalToConstant: coinImageSize),
            coinImageViewController.view.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            coinImageViewController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
        ])

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: coinImageViewController.view.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: priceLabel.leadingAnchor, constant: -12),
        ])

        symbolLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            symbolLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6),
            symbolLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            symbolLabel.trailingAnchor.constraint(lessThanOrEqualTo: percentageLabel.leadingAnchor, constant: -12),
        ])

        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            priceLabel.bottomAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -containerInnerTrailingOffset),
        ])

        percentageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            percentageLabel.centerYAnchor.constraint(equalTo: symbolLabel.centerYAnchor),
            percentageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -containerInnerTrailingOffset),
        ])

        navigationImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            navigationImageView.widthAnchor.constraint(equalToConstant: navigationImageViewSize),
            navigationImageView.heightAnchor.constraint(equalToConstant: navigationImageViewSize),
            navigationImageView.topAnchor.constraint(equalTo: percentageLabel.bottomAnchor, constant: 10),
            navigationImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -containerInnerTrailingOffset),
            navigationImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -containerSideOffset),
        ])
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        tapSubject.send(())
    }
}
