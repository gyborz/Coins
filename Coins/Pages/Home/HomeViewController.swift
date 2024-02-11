//
//  HomeViewController.swift
//  Coins
//
//  Created by Gyorgy Borz on 10/02/2024.
//

import Combine
import UIKit

final class HomeViewController: BasePage<HomeViewModel> {
    private let gradientView = GradientView().apply {
        $0.colors = [UIColor.aCyan.cgColor, UIColor.aBlue.cgColor]
        $0.startPoint = CGPoint(x: 0.5, y: 0)
        $0.endPoint = CGPoint(x: 0.5, y: 1)
        $0.alpha = 0.3
    }

    private let headerBackgroundView = UIView().apply {
        $0.backgroundColor = .white
    }

    private let headerView = UIView().apply {
        $0.backgroundColor = .aCyan.withAlphaComponent(0.3)
    }

    private let titleLabel = UILabel().apply {
        $0.text = "COINS"
        $0.font = .poppinsBold(ofSize: 32)
        $0.textColor = .aBlack
    }

    private let activityIndicator = UIActivityIndicatorView(style: .large)

    private let tableView = UITableView().apply {
        $0.backgroundColor = .clear
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = UITableView.automaticDimension
        $0.dataSource = nil
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        $0.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        $0.separatorStyle = .none
        $0.isScrollEnabled = true
        $0.clipsToBounds = false
        $0.alpha = 0
    }

    private let sideOffset: CGFloat = 16

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        subscribeToCellModels()
        susbscribeToTableViewOffset()
    }

    override func viewModelDidSet() {
        super.viewModelDidSet()

        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { isLoading in
                isLoading ? self.activityIndicator.startAnimating() : self.activityIndicator.stopAnimating()
                UIView.animate(withDuration: 0.2) {
                    self.tableView.alpha = isLoading ? 0 : 1
                }
            }.store(in: &disposeBag)
    }

    private func setupLayout() {
        view.backgroundColor = .white
        view.addSubview(gradientView)
        view.addSubview(tableView)
        view.addSubview(headerBackgroundView)
        headerBackgroundView.addSubview(headerView)
        view.addSubview(titleLabel)
        view.addSubview(activityIndicator)

        gradientView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            gradientView.topAnchor.constraint(equalTo: view.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        headerBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            headerBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerBackgroundView.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
        ])

        headerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: headerBackgroundView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: headerBackgroundView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: headerBackgroundView.trailingAnchor),
            headerView.bottomAnchor.constraint(equalTo: headerBackgroundView.bottomAnchor),
        ])

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: sideOffset),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: sideOffset),
        ])

        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 30),
        ])
    }

    private func subscribeToCellModels() {
        subscribe(tableView: tableView, on: viewModel.cellModels, shouldAnimate: false)
    }

    private func susbscribeToTableViewOffset() {
        tableView.publisher(for: \.contentOffset)
            .sink { offset in
                if offset.y > 0 {
                    self.headerBackgroundView.alpha = 1
                } else {
                    self.headerBackgroundView.alpha = 0
                }
            }.store(in: &disposeBag)
    }
}
