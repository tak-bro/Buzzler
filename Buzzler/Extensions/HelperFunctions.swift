//
//  HelperFunctions.swift
//  Buzzler
//
//  Created by 진형탁 on 2018. 4. 22..
//  Copyright © 2018년 Maru. All rights reserved.
//

import Foundation
import UIKit

func setBorderAndCornerRadius(layer: CALayer, width: CGFloat, radius: CGFloat, color: UIColor) {
    layer.borderColor = color.cgColor
    layer.borderWidth = width
    layer.cornerRadius = radius
    layer.masksToBounds = true
}

func setLeftPadding(textField: UITextField) {
    let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
    textField.leftView = paddingView
    textField.leftViewMode = UITextFieldViewMode.always
}

