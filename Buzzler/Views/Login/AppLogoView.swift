//
//  AppLogoView.swift
//  Buzzler
//
//  Created by 진형탁 on 26/07/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import UIKit

class AppLogoView: UIView {

    class func instanceFromNib() -> UIView {
        return UINib(nibName: "AppLogoView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
}
