// swiftlint:disable type_name

import Foundation
import UIKit

struct Config {

    struct UI {
        static let themeColor = UIColor(red: 244.0 / 255.0, green: 246.0 / 255.0, blue: 246.0 / 255.0, alpha: 1.0)
        static let titleColor = UIColor(red: 0.71, green: 0.86, blue: 0.87, alpha: 1.00)
        static let textFieldColor = UIColor(white: 235.0 / 255.0, alpha: 1.0)
        static let buttonActiveColor = UIColor(red: 165.0 / 255.0, green: 213.0 / 255.0, blue: 214.0 / 255.0, alpha: 1.0)
        static let buttonInActiveColor = UIColor(white: 216.0 / 255.0, alpha: 1.0)
        static let fontColor = UIColor(white: 68.0 / 255.0, alpha: 1.0)
        static let lightFontColor =  UIColor(white: 136.0 / 255.0, alpha: 1.0)
        static let commentViewColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.00)
        static let errorFontColor = UIColor(red: 240.0 / 255.0, green: 99.0 / 255.0, blue: 99.0 / 255.0, alpha: 1.0)
        static let placeholderColor = UIColor(red:0.78, green:0.78, blue:0.80, alpha:1.00)
        static let heartColor = UIColor(red:0.95, green:0.36, blue:0.45, alpha:1.00)
        
        static let blackTransparencyColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
    }
}

extension Notification.Name {
    /// Buzzler post when home category change
    static let category = Notification.Name(rawValue: "homeCategory")
    static let myPage = Notification.Name(rawValue: "myPage")
    static let settings = Notification.Name(rawValue: "settings")
}
