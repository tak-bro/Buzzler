//
//  WritePostViewController.swift
//  Buzzler
//
//  Created by 진형탁 on 2018. 4. 17..
//  Copyright © 2018년 Maru. All rights reserved.
//

import UIKit
import Moya
import RxSwift
import RxCocoa
import RxKeyboard
import SVProgressHUD
import Photos

struct PostImage {
    var fileName: String
    var encodedImgData: String
}

class WritePostViewController: UIViewController, ShowsAlert {

    // MARK: - Outlets
    
    @IBOutlet weak var imgVwConstraint: NSLayoutConstraint!
    @IBOutlet weak var img_upload: UIImageView!
    @IBOutlet weak var vw_imgContainer: UIView!
    @IBOutlet weak var vw_container: UIView!
    @IBOutlet weak var lbl_univ: UILabel!
    @IBOutlet weak var btn_post: UIButton!
    @IBOutlet weak var btn_dismiss: UIButton!
    @IBOutlet weak var txt_title: UITextField!
    @IBOutlet weak var txt_contents: UITextView!
    var placeholderLabel : UILabel!
    
    let viewModel = WritePostViewModel(provider: BuzzlerProvider)
    fileprivate let disposeBag = DisposeBag()
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindToRx()
        setUI()
        setToolbar()
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
        
        btn_post.rx.tap
            .bind(to:self.viewModel.inputs.postTaps)
            .disposed(by: disposeBag)
        
        txt_title.rx.text.orEmpty
            .bind(to:self.viewModel.inputs.title)
            .disposed(by: disposeBag)
        
        txt_contents.rx.text.orEmpty
            .bind(to:self.viewModel.inputs.contents)
            .disposed(by: disposeBag)
        
        self.viewModel.outputs.enablePost.drive(onNext: { enable in
            self.btn_post.isEnabled = enable
        }).disposed(by: disposeBag)
        
        self.viewModel.outputs.validatedTitle
            .drive()
            .disposed(by: disposeBag)
        
        self.viewModel.outputs.validatedContents
            .drive()
            .disposed(by: disposeBag)
        
        self.viewModel.outputs.enablePost
            .drive()
            .disposed(by: disposeBag)
        
        self.viewModel.outputs.posting
            .drive(onNext: { [weak self] posting in
                if posting == true {
                    print(posting)
                    self?.dismiss(animated: true, completion: nil)
                } else {
                    self.showAlert(message: "Failed to post")
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
        
    }
    
    func setUI() {
        txt_title.addBorderBottom(height: 1.0, color: Config.UI.textFieldColor)
        vw_container.dropShadow(color: UIColor.black, offSet: CGSize(width: -1, height: 1))
        vw_container.setCornerRadius(radius: 10)
        
        addPlaceHolderToTextView()
        
        // set imageView
        self.imgVwConstraint.constant = 0
        self.vw_imgContainer.isHidden = true
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

extension WritePostViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !txt_contents.text.isEmpty
    }
    
    func addPlaceHolderToTextView() {
        txt_contents.delegate = self
        
        // set placeholder for textView
        placeholderLabel = UILabel()
        placeholderLabel.text = "글쓰기..."
        placeholderLabel.textColor = Config.UI.placeholderColor
        placeholderLabel.font = UIFont(name: "NotoSans-Regular", size: 14)
        placeholderLabel.sizeToFit()
        txt_contents.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (txt_contents.font?.pointSize)! / 2)
        placeholderLabel.isHidden = !txt_contents.text.isEmpty
    }
    
}
