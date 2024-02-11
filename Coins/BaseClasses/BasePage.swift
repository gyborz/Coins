//
//  BasePage.swift
//  Coins
//
//  Created by Gyorgy Borz on 10/02/2024.
//

import Combine
import UIKit

class BasePage<ViewModel>: UIViewController, UIGestureRecognizerDelegate {
    var disposeBag = Set<AnyCancellable>()
    var viewModel: ViewModel {
        didSet {
            viewModelDidSet()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModelDidSet()
    }

    func viewModelDidSet() {
        // OverrideThis
    }

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}
