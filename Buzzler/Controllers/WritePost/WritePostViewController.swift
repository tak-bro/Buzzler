//
//  WritePostViewController.swift
//  Buzzler
//
//  Created by 진형탁 on 2018. 4. 17..
//  Copyright © 2018년 Maru. All rights reserved.
//

import UIKit

class WritePostViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var vw_container: UIView!
    @IBOutlet weak var lbl_univ: UILabel!
    @IBOutlet weak var btn_post: UIButton!
    @IBOutlet weak var btn_dismiss: UIButton!
    @IBOutlet weak var txt_title: UITextField!
    @IBOutlet weak var txt_contents: UITextView!
    
   let viewModel = WritePostViewModel(provider: BuzzlerProvider)
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindToRx()
        setUI()
        setToolbar()
    }
    
    override func dismissKeyboard() {
        view.endEditing(true)
    }

    func addImage() {
        print("test")
    }
    
    // MARK: - Actions
    
    @IBAction func pressDismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension WritePostViewController {
    
    func bindToRx() {
        txt_title.rx.text.orEmpty.bind(to: viewModel.title).addDisposableTo(disposeBag)
        txt_contents.rx.text.orEmpty.bind(to: viewModel.content).addDisposableTo(disposeBag)
        btn_post.rx.tap.bind(to: viewModel.postTaps).addDisposableTo(disposeBag)
        
        viewModel.postExecuting.drive(onNext: { (executing) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = executing
        }).addDisposableTo(disposeBag)
        
        viewModel.postFinished.drive(onNext: { [weak self] postResult in
            switch postResult {
            case .failed(let message):
                let alert = UIAlertController(title: "Oops!", message:message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
                self?.present(alert, animated: true, completion: nil)
            case .ok:
                self?.dismiss(animated: true, completion: nil)
            }
        }).addDisposableTo(disposeBag)
    }
    
    func setUI() {
        txt_title.addBorderBottom(height: 1.0, color: Config.UI.textFieldColor)
        vw_container.dropShadow(color: UIColor.black, offSet: CGSize(width: -1, height: 1))
        vw_container.setCornerRadius(radius: 10)
    }
    
    func setToolbar() {
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.sizeToFit()
        
        let fixedSpaceButton = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        let nextButton  = UIBarButtonItem(image: UIImage(named: "btn_upload_img"), style: .plain, target: self, action: #selector(addImage))
  
        toolbar.setItems([fixedSpaceButton, nextButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        txt_title.inputAccessoryView = toolbar
        txt_contents.inputAccessoryView = toolbar
    }
    
}
