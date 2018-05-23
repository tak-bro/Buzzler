//
//  SelectUnivViewController.swift
//  Buzzler
//
//  Created by 진형탁 on 21/05/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import UIKit
import Moya
import RxSwift
import RxCocoa
import RxKeyboard
import SVProgressHUD

class SelectUnivViewController: UIViewController {
    
    @IBOutlet weak var btn_univChecked: UIButton!
    @IBOutlet weak var btn_next: UIButton!
    @IBOutlet weak var txt_univ: UITextField!
    
    var inputUserInfo = UserInfo()
    var viewModel: SelectUnivViewModel?
    
    fileprivate let disposeBag = DisposeBag()
    let router = SignUpRouter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindToRx()
        setUI()
    }
    
    func bindToRx() {
        self.viewModel = SelectUnivViewModel(provider: BuzzlerProvider, userInfo: inputUserInfo)
        
        guard let selectUnivViewModel = self.viewModel else { return }
        
        btn_next.rx.tap
            .bind(to: selectUnivViewModel.inputs.nextTaps)
            .disposed(by: disposeBag)
        
        txt_univ.rx.text.orEmpty
            .bind(to: selectUnivViewModel.inputs.univ)
            .disposed(by: disposeBag)
        
        selectUnivViewModel.outputs.enableNextButton.drive(onNext: { enable in
            self.btn_next.isEnabled = enable
            self.btn_next.layer.borderColor = enable ? Config.UI.buttonActiveColor.cgColor : Config.UI.buttonInActiveColor.cgColor
        }).disposed(by: disposeBag)
        
        selectUnivViewModel.outputs.validatedUniv
            .drive()
            .disposed(by: disposeBag)
        
        selectUnivViewModel.outputs.enableNextButton
            .drive()
            .disposed(by: disposeBag)
        
        selectUnivViewModel.outputs.getMajorList
            .drive(onNext: { list in
                // push view controller
                print(list)
                self.router.perform(.selectMajor, from: self)
            }).disposed(by: disposeBag)
        
        selectUnivViewModel.outputs.setUniv
            .drive(onNext: { univName in
                self.txt_univ.text = univName
                if univName == "Error" {
                    self.txt_univ.isEnabled = true
                    self.btn_univChecked.isHidden = true
                }
            }).disposed(by: disposeBag)
        
        selectUnivViewModel.isLoading
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
    }
    
}

extension SelectUnivViewController {
    
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
        setBorderAndCornerRadius(layer: txt_univ.layer, width: 1, radius: 20, color: Config.UI.textFieldColor)
        setLeftPadding(textField: txt_univ)
        self.txt_univ.isEnabled = false
    }
    
}
