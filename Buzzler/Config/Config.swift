// swiftlint:disable type_name

import Foundation
import UIKit

struct Config {

    struct UI {
        static let themeColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.00)
        static let titleColor = UIColor(red: 0.71, green: 0.86, blue: 0.87, alpha: 1.00)
        static let textFieldColor = UIColor(white: 235.0 / 255.0, alpha: 1.0)
        static let buttonActiveColor = UIColor(red: 165.0 / 255.0, green: 213.0 / 255.0, blue: 214.0 / 255.0, alpha: 1.0)
        static let buttonInActiveColor = UIColor(white: 216.0 / 255.0, alpha: 1.0)
        static let fontColor = UIColor(white: 68.0 / 255.0, alpha: 1.0)
        static let lightFontColor =  UIColor(white: 136.0 / 255.0, alpha: 1.0)

    }
}

extension Notification.Name {
    /// Buzzler post when home category change
    static let category = Notification.Name(rawValue: "homeCategory")
}
