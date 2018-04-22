//
//  VerifyCodeViewController.swift
//  Buzzler
//
//  Created by 진형탁 on 2018. 4. 21..
//  Copyright © 2018년 Maru. All rights reserved.
//

import UIKit
import Moya
import RxSwift
import RxCocoa
import RxKeyboard

class VerifyCodeViewController: UIViewController {

    @IBOutlet weak var txt_code: UITextField!
    @IBOutlet weak var btn_next: UIButton!
    
    fileprivate let disposeBag = DisposeBag()
    
    let router = SignUpRouter()
    let viewModel = VerifyCodeViewModel(provider: BuzzlerProvider)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // remove "Back" text
        self.navigationController?.navigationBar.topItem?.title = " "
        bindToRx()
        setUI()
    }
    
    func bindToRx() {
        txt_code.rx.text.orEmpty.bind(to: viewModel.code).addDisposableTo(disposeBag)
        btn_next.rx.tap.bind(to: viewModel.nextTaps).addDisposableTo(disposeBag)
        
        viewModel.nextEnabled
            .drive(onNext: { (valid) in
                self.btn_next.isEnabled = valid
                self.btn_next.layer.borderColor = valid ? Config.UI.buttonActiveColor.cgColor : Config.UI.buttonInActiveColor.cgColor
            })
            .addDisposableTo(disposeBag)
        
        viewModel.nextExecuting.drive(onNext: { (executing) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = executing
        }).addDisposableTo(disposeBag)
        
        viewModel.nextFinished.drive(onNext: { [weak self] loginResult in
            // push view controller
            guard let strongSelf = self else { return }
            strongSelf.router.perform(.done, from: strongSelf)
        }).addDisposableTo(disposeBag)

    }
    
    override func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension VerifyCodeViewController {
    
    func setUI() {
        // button
        btn_next.setTitleColor(Config.UI.buttonActiveColor, for: UIControlState.normal)
        btn_next.setTitleColor(Config.UI.buttonInActiveColor, for: UIControlState.disabled)
        btn_next.layer.borderWidth = 2.5
        btn_next.layer.borderColor = Config.UI.buttonInActiveColor.cgColor
        
        setBorderAndCornerRadius(layer: txt_code.layer, width: 1, radius: 15, color: Config.UI.textFieldColor)
        setLeftPadding(textField: txt_code)
    }
    
}


