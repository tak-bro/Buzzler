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
import DKImagePickerController
import Toaster

class WritePostViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var vw_cntContainer: UIView!
    @IBOutlet weak var lbl_imgCnt: UILabel!
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
    
    let viewModel = WritePostViewModel()
    fileprivate let disposeBag = DisposeBag()
    
    var varAssets = Variable<[DKAsset]?>([]) // picked images from picker
    let pickerController = DKImagePickerController()
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindToRx()
        setUI()
        setToolbar()
    }
    
    func addImage() {
        showAlbum()
    }
    
    // MARK: - Actions
    
    @IBAction func pressDismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pickImage(_ sender: UIButton) {
        addImage()
    }
    @IBAction func pressPosting(_ sender: UIButton) {
        // force set value for ViewModel
        if (self.varAssets.value?.count == 0) {
            self.varAssets.value = [DKAsset]()
        }
        self.dismiss(animated: true, completion: nil)
    }
}

extension WritePostViewController {
    
    func bindToRx() {
        
        btn_post.rx.tap
            .bind(to: self.viewModel.inputs.postTaps)
            .disposed(by: disposeBag)
        
        txt_title.rx.text.orEmpty
            .bind(to: self.viewModel.inputs.title)
            .disposed(by: disposeBag)
        
        txt_contents.rx.text.orEmpty
            .bind(to: self.viewModel.inputs.contents)
            .disposed(by: disposeBag)
        
        // set asset to observable
        self.varAssets.asObservable()
            .bind(to: self.viewModel.inputs.images)
            .disposed(by: disposeBag)

        self.viewModel.outputs.encodedImages
            .drive()
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
                print("posting result", posting)
                DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                    if posting == true {
                        Toast(text: "포스트 등록이 완료되었습니다.").show()
                    } else {
                        Toast(text: "Posting Error!!").show()
                    }
                })
            }).disposed(by: disposeBag)
        
        self.viewModel.isLoading
            .drive(onNext: { isLoading in
                switch isLoading {
                case true:
                    //SVProgressHUD.show()
                    break
                case false:
                    //SVProgressHUD.dismiss()
                    break
                }
            }).disposed(by: disposeBag)
        
    }
    
    func setUI() {
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
        let addButton  = UIBarButtonItem(image: UIImage(named: "btn_upload_img"), style: .plain, target: self, action: #selector(addImage))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
  
        toolbar.setItems([fixedSpaceButton, addButton, flexSpace, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        txt_title.inputAccessoryView = toolbar
        txt_contents.inputAccessoryView = toolbar
    }

    func doneButtonAction() {
        view.endEditing(true)
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

// MARK: - ImagePickerViewController

extension WritePostViewController {
    
    func showAlbum() {
        self.pickerController.sourceType = .photo
        self.pickerController.showsCancelButton = true
        self.pickerController.maxSelectableCount = 3
        
        self.pickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
            self.updateAssets(assets: assets)
        }
        self.present(pickerController, animated: true) {}
    }
    
    func updateAssets(assets: [DKAsset]) {
        self.varAssets.value = assets

        if assets.count > 0 {
            // set imageView
            assets[0].fetchOriginalImage(true, completeBlock: { image, info in
                self.img_upload.image = image
                self.lbl_imgCnt.text = "+" + String(assets.count-1)
                self.vw_cntContainer.isHidden = assets.count == 1 ? true : false
                
                let imageSize = self.view.frame.size.height
                self.imgVwConstraint.constant = imageSize / 3
                self.vw_imgContainer.isHidden = false
            })
        }
    }
    
}
