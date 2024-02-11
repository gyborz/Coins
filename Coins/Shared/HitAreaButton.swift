//
//  HitAreaButton.swift
//  Coins
//
//  Created by Gyorgy Borz on 10/02/2024.
//

import UIKit

final class HitAreaButton: UIButton {
    private let margin: CGFloat
    override func point(inside point: CGPoint, with _: UIEvent?) -> Bool {
        let area = bounds.insetBy(dx: -margin, dy: -margin)
        return area.contains(point)
    }

    init(margin: CGFloat) {
        self.margin = margin
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
