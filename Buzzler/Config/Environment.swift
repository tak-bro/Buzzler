//
//  Environment
//  Buzzler
//
//  Created by 진형탁 on 23/05/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Environment {

    var token: String? {
        get {
            return self.userDefaults.value(forKey: UserDefaultsKeys.Token.rawValue) as! String?
        }
        set {
            self.userDefaults.setValue(newValue, forKey: UserDefaultsKeys.Token.rawValue)
        }
    }
    
    var tokenExists: Bool {
        guard let _ = token else {
            return false
        }
        return true
    }

    var receiver: String? {
        get {
            return self.userDefaults.value(forKey: UserDefaultsKeys.Receiver.rawValue) as! String?
        }
        set {
            self.userDefaults.setValue(newValue, forKey: UserDefaultsKeys.Receiver.rawValue)
        }
    }
    
    var nickName: String? {
        get {
            return self.userDefaults.value(forKey: UserDefaultsKeys.NickName.rawValue) as! String?
        }
        set {
            self.userDefaults.setValue(newValue, forKey: UserDefaultsKeys.NickName.rawValue)
        }
    }
    
    var password: String? {
        get {
            return self.userDefaults.value(forKey: UserDefaultsKeys.Password.rawValue) as! String?
        }
        set {
            self.userDefaults.setValue(newValue, forKey: UserDefaultsKeys.Password.rawValue)
        }
    }
    
    var major: String? {
        get {
            return self.userDefaults.value(forKey: UserDefaultsKeys.Major.rawValue) as! String?
        }
        set {
            self.userDefaults.setValue(newValue, forKey: UserDefaultsKeys.Major.rawValue)
        }
    }
    
    var univ: String? {
        get {
            return self.userDefaults.value(forKey: UserDefaultsKeys.Univ.rawValue) as! String?
        }
        set {
            self.userDefaults.setValue(newValue, forKey: UserDefaultsKeys.Univ.rawValue)
        }
    }
    
    var categoryId: Int? {
        get {
            return self.userDefaults.value(forKey: UserDefaultsKeys.CategoryId.rawValue) as! Int?
        }
        set {
            self.userDefaults.setValue(newValue, forKey: UserDefaultsKeys.CategoryId.rawValue)
        }
    }
    
    private let userDefaults: UserDefaults
    
    private enum UserDefaultsKeys: String {
        case Token = "user_auth_token"
        case Authorization = "user_auth"
        // userInfo
        case Receiver = "receiver"
        case NickName = "nickName"
        case Password = "password"
        case Major = "major"
        case Univ = "univ"
        // category
        case CategoryId = "category_id"
    }
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    init() {
        self.userDefaults = UserDefaults.standard
    }
}
