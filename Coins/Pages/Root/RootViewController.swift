//
//  RootViewController.swift
//  Coins
//
//  Created by Gyorgy Borz on 10/02/2024.
//

import Combine
import UIKit

final class RootViewController: BasePage<RootViewModel> {
    private var currentVC: UINavigationController?
    private var currentViewController: UIView { self.view }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        subscribeToPage()
    }

    private func subscribeToPage() {
        viewModel.currentPagePublisher
            .receive(on: DispatchQueue.main)
            .sink { page in

                switch page {
                case .home:
                    break

                case let .coinDetail(id: id):
                    let coinDetailVC = CoinDetailViewController(
                        viewModel: CoinDetailViewModel(
                            coinId: id,
                            coinsProvider: DIManager.factory.dependency()
                        )
                    )
                    self.currentVC?.pushViewController(coinDetailVC, animated: true)

                case let .back(isSwipe, isAnimate):
                    if !isSwipe {
                        let isModal = self.currentVC?.presentedViewController != nil
                        if isModal, self.presentedViewController != nil {
                            self.presentedViewController?.dismiss(animated: true, completion: nil)
                        } else if isModal, self.currentVC?.topViewController != nil {
                            self.currentVC?.topViewController?.dismiss(animated: isAnimate, completion: nil)
                        } else {
                            self.currentVC?.popViewController(animated: true)
                        }
                    }
                }
            }.store(in: &disposeBag)
    }

    private func setupLayout() {
        view.backgroundColor = .clear

        currentVC = UINavigationController(
            rootViewController: HomeViewController(
                viewModel: HomeViewModel(coinsProvider: DIManager.factory.dependency())
            )
        )
        if let currentVC = currentVC {
            currentVC.willMove(toParent: self)
            currentViewController.addSubview(currentVC.view)
            currentVC.view.frame = currentViewController.frame
            currentVC.didMove(toParent: self)
        }
    }
}

extension RootViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let coordinator = navigationController.topViewController?.transitionCoordinator {
            coordinator.notifyWhenInteractionChanges { context in
                if !context.isCancelled {
                    NavigationProvider.page.send(.back(true))
                }
            }
        }
    }
}
