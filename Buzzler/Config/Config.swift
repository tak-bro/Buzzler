// swiftlint:disable type_name

import Foundation
import UIKit

struct Config {

    struct UI {
        /// Gank's Navgation Title Color
        static let themeColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.00)
        /// Gank‘s ThemeColor
        static let titleColor = UIColor(red:0.71, green:0.86, blue:0.87, alpha:1.00)
    }
}

extension Notification.Name {
    /// Gank post when home category change
    static let category = Notification.Name(rawValue: "homeCategory")
}
