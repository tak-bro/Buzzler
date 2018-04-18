// swiftlint:disable type_name

import Foundation
import UIKit

struct Config {

    struct UI {
        static let themeColor = UIColor(red: 0.96, green: 0.97, blue: 0.97, alpha: 1.00)
        static let titleColor = UIColor(red: 0.71, green: 0.86, blue: 0.87, alpha: 1.00)
        static let textFieldColor = UIColor(white: 181.0 / 255.0, alpha: 1.0)
    }
}

extension Notification.Name {
    /// Buzzler post when home category change
    static let category = Notification.Name(rawValue: "homeCategory")
}
