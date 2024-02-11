//
//  GradientView.swift
//  Coins
//
//  Created by Gyorgy Borz on 10/02/2024.
//

import UIKit

final class GradientView: UIView {
    override class var layerClass: AnyClass { CAGradientLayer.self }

    var colors: [CGColor] = [] {
        didSet {
            guard let gradientLayer = layer as? CAGradientLayer else { return }
            gradientLayer.colors = colors
        }
    }

    var startPoint: CGPoint = .zero {
        didSet {
            guard let gradientLayer = layer as? CAGradientLayer else { return }
            gradientLayer.startPoint = startPoint
        }
    }

    var endPoint: CGPoint = .zero {
        didSet {
            guard let gradientLayer = layer as? CAGradientLayer else { return }
            gradientLayer.endPoint = endPoint
        }
    }

    var locations: [NSNumber] = [] {
        didSet {
            guard let gradientLayer = layer as? CAGradientLayer else { return }
            gradientLayer.locations = locations
        }
    }

    public init() {
        super.init(frame: .zero)
        guard let gradientLayer = layer as? CAGradientLayer else { return }
        gradientLayer.frame = bounds
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let gradientLayer = layer as? CAGradientLayer else { return }
        gradientLayer.frame = bounds
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
