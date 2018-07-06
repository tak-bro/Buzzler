//
//  FirstStepViewController.swift
//  Buzzler
//
//  Created by 진형탁 on 18/05/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import UIKit
import Moya
import RxSwift
import RxCocoa
import RxKeyboard
import SVProgressHUD

class FirstStepViewController: UIViewController, ShowsAlert {
    
    @IBOutlet weak var lbl_error: UILabel!
    @IBOutlet weak var btn_next: UIButton!
    @IBOutlet weak var txt_email: UITextField!
    
    let router = ResetPasswordRouter()
    let viewModel = FirstStepViewModel(provider: BuzzlerProvider)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // remove "Back" text
        self.navigationController?.navigationBar.topItem?.title = " "
        setUI()
        bindToRx()
    }
    
    func bindToRx() {
        
        btn_next.rx.tap
            .bind(to:self.viewModel.inputs.nextTaps)
            .disposed(by: disposeBag)
        
        txt_email.rx.text.orEmpty
            .bind(to:self.viewModel.inputs.email)
            .disposed(by: disposeBag)
        
        self.viewModel.outputs.enableNextButton.drive(onNext: { enable in
            self.btn_next.isEnabled = enable
            self.btn_next.layer.borderColor = enable ? Config.UI.buttonActiveColor.cgColor : Config.UI.buttonInActiveColor.cgColor
        }).disposed(by: disposeBag)
        
        self.viewModel.outputs.setErrorMessage.drive(onNext: { message in
            self.lbl_error.text = message
        }).disposed(by: disposeBag)
        
        self.viewModel.outputs.validatedEmail
            .drive()
            .disposed(by: disposeBag)
        
        self.viewModel.outputs.enableNextButton
            .drive()
            .disposed(by: disposeBag)
        
        self.viewModel.outputs.requestCode
            .drive(onNext: { isSuccess in
                if isSuccess {
                    // push view controller
                    self.router.email = self.txt_email.text!
                    self.router.perform(.secondStep, from: self)
                } else {
                    self.showAlert(message: "Server Error!")
                }
            }).disposed(by: disposeBag)
        
        self.viewModel.isLoading
            .drive(onNext: { isLoading in
                switch isLoading {
                case true:
                    SVProgressHUD.show()
                    break
                case false:
                    SVProgressHUD.dismiss()
                    break
                }
            }).disposed(by: disposeBag)
        
        RxKeyboard.instance.visibleHeight
            .drive(onNext: { [weak self] keyboardVisibleHeight in
                guard let `self` = self else { return }
                self.view.bounds.origin.y = keyboardVisibleHeight * 0.5
                self.view.layoutIfNeeded()
            })
            .addDisposableTo(disposeBag)
    }
    
    @IBAction func pressDimiss(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension FirstStepViewController {
    
    func setUI() {
        // remove "Back" text
        self.navigationController?.navigationBar.topItem?.title = " "
        
        // button
        btn_next.isEnabled = false
        btn_next.setTitleColor(Config.UI.buttonActiveColor, for: UIControlState.normal)
        btn_next.setTitleColor(Config.UI.buttonInActiveColor, for: UIControlState.disabled)
        btn_next.layer.borderWidth = 2.5
        btn_next.layer.borderColor = Config.UI.buttonInActiveColor.cgColor
        
        // textField
        setBorderAndCornerRadius(layer: txt_email.layer, width: 1, radius: 20, color: Config.UI.textFieldColor)
        setLeftPadding(textField: txt_email)
    }
}
