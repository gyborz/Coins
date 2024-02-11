//
//  CoinDetailViewController.swift
//  Coins
//
//  Created by Gyorgy Borz on 10/02/2024.
//

import Combine
import UIKit

final class CoinDetailViewController: BasePage<CoinDetailViewModel> {
    private let gradientView = GradientView().apply {
        $0.colors = [UIColor.aCyan.cgColor, UIColor.aBlue.cgColor]
        $0.startPoint = CGPoint(x: 0.5, y: 0)
        $0.endPoint = CGPoint(x: 0.5, y: 1)
        $0.alpha = 0.3
    }

    private let headerView = UIView().apply {
        $0.backgroundColor = .aCyan.withAlphaComponent(0.3)
    }

    private let titleLabel = UILabel().apply {
        $0.font = .poppinsBold(ofSize: 32)
        $0.textColor = .aBlack
        $0.text = " "
    }

    private lazy var backButton: HitAreaButton = {
        let button = HitAreaButton(margin: 20)
        button.setImage(.chevronLeft.withRenderingMode(.alwaysTemplate).withConfiguration(UIImage.SymbolConfiguration(pointSize: 23, weight: .bold)), for: .normal)
        button.tintColor = .aBlue
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        return button
    }()

    private let contentBackgroundView = UIView().apply {
        $0.backgroundColor = .white.withAlphaComponent(0.4)
        $0.layer.cornerRadius = 16
    }

    private let priceLabel = UILabel().apply {
        $0.font = .poppinsRegular(ofSize: 16)
        $0.textColor = .aBlack
        $0.text = "Price"
    }

    private let percentageLabel = UILabel().apply {
        $0.font = .poppinsRegular(ofSize: 16)
        $0.textColor = .aBlack
        $0.text = "Change (24hr)"
    }

    private let priceValueLabel = UILabel().apply {
        $0.font = .poppinsBold(ofSize: 16)
        $0.textColor = .aBlack
        $0.textAlignment = .right
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        $0.text = " "
    }

    private let percentageValueLabel = UILabel().apply {
        $0.font = .poppinsBold(ofSize: 16)
        $0.textAlignment = .right
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        $0.text = " "
    }

    private let topContentHorizontalStackView = UIStackView().apply {
        $0.axis = .horizontal
        $0.spacing = 0
        $0.distribution = .fill
    }

    private let topContentLabelVerticalStackView = UIStackView().apply {
        $0.axis = .vertical
        $0.spacing = 12
        $0.distribution = .equalSpacing
    }

    private let topContentValueVerticalStackView = UIStackView().apply {
        $0.axis = .vertical
        $0.spacing = 12
        $0.distribution = .equalSpacing
    }

    private let separatorLine = UIView().apply {
        $0.backgroundColor = .aBlue
    }

    private let marketCapLabel = UILabel().apply {
        $0.font = .systemFont(ofSize: 16)
        $0.textColor = .aBlack
        $0.text = "Market Cap"
    }

    private let volumeLabel = UILabel().apply {
        $0.font = .systemFont(ofSize: 16)
        $0.textColor = .aBlack
        $0.text = "Volume (24hr)"
    }

    private let supplyLabel = UILabel().apply {
        $0.font = .systemFont(ofSize: 16)
        $0.textColor = .aBlack
        $0.text = "Supply"
    }

    private let marketCapValueLabel = UILabel().apply {
        $0.font = .poppinsBold(ofSize: 16)
        $0.textColor = .aBlack
        $0.textAlignment = .right
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        $0.text = " "
    }

    private let volumeValueLabel = UILabel().apply {
        $0.font = .poppinsBold(ofSize: 16)
        $0.textColor = .aBlack
        $0.textAlignment = .right
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        $0.text = " "
    }

    private let supplyValueLabel = UILabel().apply {
        $0.font = .poppinsBold(ofSize: 16)
        $0.textColor = .aBlack
        $0.textAlignment = .right
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        $0.text = " "
    }

    private let bottomContentHorizontalStackView = UIStackView().apply {
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.spacing = 0
    }

    private let bottomContentLabelVerticalStackView = UIStackView().apply {
        $0.axis = .vertical
        $0.distribution = .equalSpacing
        $0.spacing = 12
    }

    private let bottomContentValueVerticalStackView = UIStackView().apply {
        $0.axis = .vertical
        $0.distribution = .equalSpacing
        $0.spacing = 12
    }

    private let loadingBackgroundView = UIView().apply {
        $0.backgroundColor = .white.withAlphaComponent(0.7)
        $0.layer.cornerRadius = 16
    }

    private let activityIndicator = UIActivityIndicatorView(style: .large)

    private let contentSideOffset: CGFloat = 16
    private let contentVerticalOffset: CGFloat = 24
    private let contentInnerSideOffset: CGFloat = 24

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }

    override func viewModelDidSet() {
        super.viewModelDidSet()

        viewModel.coinDetail
            .receive(on: DispatchQueue.main)
            .sink { [weak self] coin in
                guard let self else { return }
                titleLabel.text = coin.name.uppercased()
                priceValueLabel.text = coin.formattedPrice
                percentageValueLabel.text = coin.formattedPercentage
                marketCapValueLabel.text = coin.formattedMarketCap
                volumeValueLabel.text = coin.formattedVolume24Hr
                supplyValueLabel.text = coin.formattedSupply

                if coin.changePercent24Hr >= 0 {
                    percentageValueLabel.textColor = .aGreen
                } else {
                    percentageValueLabel.textColor = .aRed
                }
            }.store(in: &disposeBag)

        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self else { return }
                isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
                UIView.animate(withDuration: 0.2) {
                    self.loadingBackgroundView.alpha = isLoading ? 1 : 0
                }
            }.store(in: &disposeBag)
    }

    private func setupLayout() {
        view.backgroundColor = .white
        view.addSubview(gradientView)
        view.addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(backButton)
        view.addSubview(contentBackgroundView)

        contentBackgroundView.addSubview(topContentHorizontalStackView)

        topContentHorizontalStackView.addArrangedSubview(topContentLabelVerticalStackView)
        topContentLabelVerticalStackView.addArrangedSubview(priceLabel)
        topContentLabelVerticalStackView.addArrangedSubview(percentageLabel)

        topContentHorizontalStackView.addArrangedSubview(topContentValueVerticalStackView)
        topContentValueVerticalStackView.addArrangedSubview(priceValueLabel)
        topContentValueVerticalStackView.addArrangedSubview(percentageValueLabel)

        contentBackgroundView.addSubview(separatorLine)

        contentBackgroundView.addSubview(bottomContentHorizontalStackView)

        bottomContentHorizontalStackView.addArrangedSubview(bottomContentLabelVerticalStackView)
        bottomContentLabelVerticalStackView.addArrangedSubview(marketCapLabel)
        bottomContentLabelVerticalStackView.addArrangedSubview(volumeLabel)
        bottomContentLabelVerticalStackView.addArrangedSubview(supplyLabel)

        bottomContentHorizontalStackView.addArrangedSubview(bottomContentValueVerticalStackView)
        bottomContentValueVerticalStackView.addArrangedSubview(marketCapValueLabel)
        bottomContentValueVerticalStackView.addArrangedSubview(volumeValueLabel)
        bottomContentValueVerticalStackView.addArrangedSubview(supplyValueLabel)

        contentBackgroundView.addSubview(loadingBackgroundView)
        contentBackgroundView.addSubview(activityIndicator)

        gradientView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            gradientView.topAnchor.constraint(equalTo: view.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        headerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
        ])

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -36),
        ])

        backButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 9),
            backButton.widthAnchor.constraint(equalToConstant: 18),
            backButton.heightAnchor.constraint(equalToConstant: 24),
        ])

        contentBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentBackgroundView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: contentVerticalOffset),
            contentBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: contentSideOffset),
            contentBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -contentSideOffset),
            contentBackgroundView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -contentVerticalOffset),
        ])

        topContentHorizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topContentHorizontalStackView.topAnchor.constraint(equalTo: contentBackgroundView.topAnchor, constant: 24),
            topContentHorizontalStackView.leadingAnchor.constraint(equalTo: contentBackgroundView.leadingAnchor, constant: contentInnerSideOffset),
            topContentHorizontalStackView.trailingAnchor.constraint(equalTo: contentBackgroundView.trailingAnchor, constant: -contentInnerSideOffset),
        ])

        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            separatorLine.topAnchor.constraint(equalTo: topContentHorizontalStackView.bottomAnchor, constant: 32),
            separatorLine.leadingAnchor.constraint(equalTo: contentBackgroundView.leadingAnchor, constant: contentInnerSideOffset),
            separatorLine.trailingAnchor.constraint(equalTo: contentBackgroundView.trailingAnchor, constant: -contentInnerSideOffset),
            separatorLine.heightAnchor.constraint(equalToConstant: 1),
        ])

        bottomContentHorizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomContentHorizontalStackView.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: 32),
            bottomContentHorizontalStackView.leadingAnchor.constraint(equalTo: contentBackgroundView.leadingAnchor, constant: contentInnerSideOffset),
            bottomContentHorizontalStackView.trailingAnchor.constraint(equalTo: contentBackgroundView.trailingAnchor, constant: -contentInnerSideOffset),
            bottomContentHorizontalStackView.bottomAnchor.constraint(lessThanOrEqualTo: contentBackgroundView.bottomAnchor),
        ])

        loadingBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingBackgroundView.topAnchor.constraint(equalTo: contentBackgroundView.topAnchor),
            loadingBackgroundView.leadingAnchor.constraint(equalTo: contentBackgroundView.leadingAnchor),
            loadingBackgroundView.trailingAnchor.constraint(equalTo: contentBackgroundView.trailingAnchor),
            loadingBackgroundView.bottomAnchor.constraint(equalTo: contentBackgroundView.bottomAnchor),
        ])

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: contentBackgroundView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentBackgroundView.centerYAnchor),
        ])
    }

    @objc private func handleTap(_ sender: UIButton) {
        viewModel.navigationSubject.send(.back(false))
    }
}
