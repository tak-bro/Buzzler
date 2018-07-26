//
//  HelperFunctions.swift
//  Buzzler
//
//  Created by 진형탁 on 2018. 4. 22..
//  Copyright © 2018년 Maru. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD
import RxSwift
import RxCocoa

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

func seconds2Timestamp(intSeconds: Int) -> String {
    let mins:Int = intSeconds/60
    let hours:Int = mins/60
    let secs:Int = intSeconds%60
    
    // let strTimestamp: String = ((hours<10) ? "0" : "") + String(hours) + ":" + ((mins<10) ? "0" : "") + String(mins) + ":" + ((secs<10) ? "0" : "") + String(secs)
    let strTimestamp = ((mins<10) ? "0" : "") + String(mins) + ":" + ((secs<10) ? "0" : "") + String(secs)
    return strTimestamp
}

func validateStudentEmail(enteredEmail: String) -> Bool {
    let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
    return emailPredicate.evaluate(with: enteredEmail)
}

func intCompare(e1: Int, e2: Int) -> ComparisonResult {
    if e1 > e2 {
        return .orderedDescending
    } else if e1 == e2 {
        return .orderedSame
    } else {
        return .orderedAscending
    }
}

func addShadowToNav(from source: UIViewController) {
    source.navigationController?.navigationBar.barTintColor = UIColor.white
    source.navigationController?.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
    source.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
    source.navigationController?.navigationBar.layer.shadowRadius = 1.0
    source.navigationController?.navigationBar.layer.shadowOpacity = 0.5
    source.navigationController?.navigationBar.layer.masksToBounds = false
}

func deleteShadow(from source: UIViewController) {
    source.navigationController?.navigationBar.barTintColor = Config.UI.themeColor
    source.navigationController?.navigationBar.layer.shadowColor = UIColor.clear.cgColor
    source.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
    source.navigationController?.navigationBar.layer.shadowRadius = 0.0
    source.navigationController?.navigationBar.layer.shadowOpacity = 0.0
}
