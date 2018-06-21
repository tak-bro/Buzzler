//
//  ManuallyEnterViewController.swift
//  Buzzler
//
//  Created by 진형탁 on 21/06/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import UIKit
import Moya
import RxSwift
import RxCocoa
import RxKeyboard
import SVProgressHUD


class ManuallyEnterViewController: UIViewController {

    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var txt_major: UITextField!
    @IBOutlet weak var txt_college: UITextField!
    @IBOutlet weak var btn_next: UIButton!
    
    let viewModel = ManuallyEnterViewModel(provider: BuzzlerProvider)
    
    fileprivate let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = " "
        bindToRx()
        setUI()
    }
    
    func bindToRx() {
        
        btn_next.rx.tap
            .bind(to:self.viewModel.inputs.nextTaps)
            .disposed(by: disposeBag)
        
        txt_college.rx.text.orEmpty
            .bind(to:self.viewModel.inputs.college)
            .disposed(by: disposeBag)
        
        txt_major.rx.text.orEmpty
            .bind(to:self.viewModel.inputs.major)
            .disposed(by: disposeBag)
        
        self.viewModel.outputs.enableNextButton.drive(onNext: { enable in
            self.btn_next.isEnabled = enable
            self.btn_next.layer.borderColor = enable ? Config.UI.buttonActiveColor.cgColor : Config.UI.buttonInActiveColor.cgColor
        }).disposed(by: disposeBag)
        
        self.viewModel.outputs.setErrorMessage.drive(onNext: { message in
            print(message)
            // self.lbl_error.text = message
        }).disposed(by: disposeBag)
        
        self.viewModel.outputs.validatedCollege
            .drive()
            .disposed(by: disposeBag)
        
        self.viewModel.outputs.validatedMajor
            .drive()
            .disposed(by: disposeBag)
        
        self.viewModel.outputs.enableNextButton
            .drive()
            .disposed(by: disposeBag)
        
        self.viewModel.outputs.createCategory
            .drive(onNext: { signedIn in
                if signedIn == true {
                    print(signedIn)
                    // TODO: add push view controller
                } else {
                    SVProgressHUD.showError(withStatus: "Server Error")
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
}

extension ManuallyEnterViewController {
    
    func setUI() {
        // button
        btn_next.isEnabled = false
        btn_next.setTitleColor(Config.UI.buttonActiveColor, for: UIControlState.normal)
        btn_next.setTitleColor(Config.UI.buttonInActiveColor, for: UIControlState.disabled)
        btn_next.layer.borderWidth = 2.5
        btn_next.layer.borderColor = Config.UI.buttonInActiveColor.cgColor
        
        setBorderAndCornerRadius(layer: txt_college.layer, width: 1, radius: 20, color: Config.UI.textFieldColor)
        setBorderAndCornerRadius(layer: txt_major.layer, width: 1, radius: 20, color: Config.UI.textFieldColor)

        setLeftPadding(textField: txt_college)
        setLeftPadding(textField: txt_major)
    }
}


