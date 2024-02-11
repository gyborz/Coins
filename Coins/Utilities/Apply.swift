//
//  Apply.swift
//  Coins
//
//  Created by Gyorgy Borz on 10/02/2024.
//

import UIKit

protocol Apply {}
extension Apply where Self: Any {
    /// Apply changes to Self
    /// ```swift
    /// let view = UIView().apply {
    ///     $0.backgroundColor = .clear
    /// }
    /// ```
    /// - Parameter block: Closure block that's applied to Self
    /// - Returns: Self
    func apply(_ block: (inout Self) -> Void) -> Self {
        var copy = self
        block(&copy)
        return copy
    }
}

extension NSObject: Apply {}
extension Array: Apply {}
extension Dictionary: Apply {}
extension String: Apply {}
extension Int: Apply {}
extension Double: Apply {}
extension Bool: Apply {}
extension URL: Apply {}
extension Data: Apply {}
extension CGPoint: Apply {}
extension CGSize: Apply {}
extension CGRect: Apply {}
extension URLComponents: Apply {}
extension URLRequest: Apply {}
extension PersonNameComponents: Apply {}
extension DateComponents: Apply {}
extension UIEdgeInsets: Apply {}
extension JSONEncoder: Apply {}
extension JSONDecoder: Apply {}
