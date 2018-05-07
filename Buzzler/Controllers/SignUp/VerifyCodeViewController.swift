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
import SwiftyAttributes

class VerifyCodeViewController: UIViewController {

    @IBOutlet weak var txt_code: UITextField!
    @IBOutlet weak var btn_next: UIButton!
    @IBOutlet weak var lbl_timer: UILabel!
    @IBOutlet weak var ind_activity: UIActivityIndicatorView!
    
    //timer
    var mTimer: Timer?
    var remainTime: Int = 180
    var inputUserInfo = UserInfo()

    fileprivate let disposeBag = DisposeBag()
    
    let router = SignUpRouter()
    var viewModel: VerifyCodeViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // remove "Back" text
        self.navigationController?.navigationBar.topItem?.title = " "
        bindToRx()
        setUI()
        setTimer()
    }
    
    func bindToRx() {
        self.viewModel = VerifyCodeViewModel(provider: BuzzlerProvider, userInfo: inputUserInfo)
        
        guard let viewModel = self.viewModel else { return }
        
        txt_code.rx.text.orEmpty.bind(to: viewModel.code).addDisposableTo(disposeBag)
        btn_next.rx.tap.bind(to: viewModel.nextTaps).addDisposableTo(disposeBag)
        
        viewModel.activityIndicator
            .distinctUntilChanged()
            .drive(onNext: { [unowned self] active in
                self.hideKeyboard()
                self.ind_activity.isHidden = !active
                active ? self.ind_activity.startAnimating() : self.ind_activity.stopAnimating()
                self.btn_next.isEnabled = !active
                self.btn_next.layer.borderColor = !active ? Config.UI.buttonActiveColor.cgColor : Config.UI.buttonInActiveColor.cgColor
            })
            .addDisposableTo(disposeBag)
        
        
        viewModel.nextEnabled
            .drive(onNext: { (valid) in
                self.btn_next.isEnabled = valid
                self.btn_next.layer.borderColor = valid ? Config.UI.buttonActiveColor.cgColor : Config.UI.buttonInActiveColor.cgColor
            })
            .addDisposableTo(disposeBag)
        
        btn_next.rx.tap
            .withLatestFrom(viewModel.nextEnabled)
            .filter { $0 }
            .flatMapLatest { [unowned self] valid -> Observable<VerifyResult> in
                viewModel.verifyCode(self.txt_code.text!)
                    .trackActivity(viewModel.activityIndicator)
            }
            .subscribe(onNext: { [unowned self] verifyResult in
                switch verifyResult {
                case .ok:
                    // push view controller
                    self.router.perform(.done, from: self)
                    break
                case .failed(let message):
                    self.resetTextField()
                    
                    let alert = UIAlertController(title: "Error!", message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
                    self.present(alert, animated: true, completion: nil)
                    break
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    override func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func pressResend(_ sender: UIButton) {
        remainTime = 180
        setTimer()
    }
}

extension VerifyCodeViewController {
    
    func setUI() {
        // button
        btn_next.setTitleColor(Config.UI.buttonActiveColor, for: UIControlState.normal)
        btn_next.setTitleColor(Config.UI.buttonInActiveColor, for: UIControlState.disabled)
        btn_next.layer.borderWidth = 2.5
        btn_next.layer.borderColor = Config.UI.buttonInActiveColor.cgColor
        
        setBorderAndCornerRadius(layer: txt_code.layer, width: 1, radius: 20, color: Config.UI.textFieldColor)
        setLeftPadding(textField: txt_code)
    }

    func setTimer() {
        if let timer = mTimer {
            if !timer.isValid {
                mTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
            }
        } else {
            mTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
        }
    }

    func timerCallback() {
        remainTime -= 1
        lbl_timer.text = seconds2Timestamp(intSeconds: remainTime)
        if (remainTime <= 0) {
            // show invalidate text
            let invalidateText = "invalidated".withAttributes([
                .textColor(UIColor.red),
                .font(.AvenirNext(type: .Book, size: 12))
                ])
            lbl_timer.attributedText = invalidateText
            timerEnd()
        }
    }
    
    func timerEnd() {
        if let timer = mTimer {
            if (timer.isValid) {
                timer.invalidate()
            }
        }
        remainTime = 0
    }
    
    fileprivate func hideKeyboard() {
        self.txt_code.resignFirstResponder()
    }
    
    fileprivate func resetTextField() {
        self.txt_code.text = ""
    }

}

