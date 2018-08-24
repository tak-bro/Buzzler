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
import SKPhotoBrowser
import SwiftMessages

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
    @IBOutlet weak var txt_isAnonymous: UITextField!
    
    fileprivate let selectAnonymous = ["소속학교 비노출", "소속학교 노출"]
    fileprivate let disposeBag = DisposeBag()
    let viewModel = WritePostViewModel()
    var placeholderLabel: UILabel!
    
    let pickerController = DKImagePickerController()
    var varAssets = Variable<[DKAsset]?>([]) // picked images from picker

    // for image viewer
    fileprivate let tapGesture = UITapGestureRecognizer()
    fileprivate var imageList = [UIImage]()

    // MARK: - is Update
    var isUpdate: Bool = false
    var originTitle: String?
    var originContents: String?
    
    var messageConfig = SwiftMessages.defaultConfig
    var messageView = MessageView.viewFromNib(layout: .statusLine)

    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindToRx()
        setUI()
        setGetureToView()
        setPicker()

        if isUpdate {
            self.txt_title.text = self.originTitle
            self.txt_contents.text = self.originContents
            
            self.viewModel.inputs.title.on(.next(self.originTitle))
            self.viewModel.inputs.contents.on(.next(self.originContents))
            
            if self.txt_contents.text.count > 0 {
                placeholderLabel.isHidden = true
            }
        }
        
        // set title
        let environment = Environment()
        self.lbl_univ.text = environment.categoryTitle
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
        guard let titleLength = self.txt_title.text?.length else { return }
        
        // force set value for ViewModel
        if self.varAssets.value?.count == 0 {
            self.varAssets.value = [DKAsset]()
        }
        
        if titleLength > 0 && self.txt_contents.text.length > 0 {
            self.dismiss(animated: true, completion: { [weak self] in
                // emit post taps event after dismissed
                self?.viewModel.inputs.postTaps.on(.next())
                }
            )
        }
    }

}

extension WritePostViewController {
    
    func bindToRx() {

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
            .drive(onNext: { res in
                print("posting result", res)
                // get error
                if let error = res.error {
                    self.messageView.backgroundView.backgroundColor = Config.UI.errorColor
                    self.messageView.bodyLabel?.textColor = UIColor.white
                    self.messageView.configureContent(body: error.message)
                } else {
                    self.messageView.backgroundView.backgroundColor = Config.UI.doneUploadColor
                    self.messageView.bodyLabel?.textColor = UIColor.white
                    self.messageView.configureContent(body: "Success to upload")
                }
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5, execute: {
                    SwiftMessages.hideAll()
                })
            }).disposed(by: disposeBag)
        
        self.viewModel.isLoading
            .drive(onNext: { isLoading in
                switch isLoading {
                case true:
                    self.messageView.backgroundView.backgroundColor = Config.UI.uploadingColor
                    self.messageView.bodyLabel?.textColor = UIColor.white
                    self.messageView.configureContent(body: "Posting...")
                    self.messageConfig.duration = .forever
                    SwiftMessages.show(config: self.messageConfig, view: self.messageView)
                    break
                case false:
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
        
        // set notification
        self.setNotificationUI()
        
        // set toolbar
        self.setToolbar()
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
    
    func setGetureToView() {
        vw_imgContainer.addGestureRecognizer(tapGesture)
        
        tapGesture.rx
            .event
            .bind(onNext: { recognizer in
                let photos = self.imageList.map { image in
                    return SKPhoto.photoWithImage(image)
                }

                SKPhotoBrowserOptions.displayAction = false
                let browser = SKPhotoBrowser(photos: photos)
                browser.initializePageIndex(0)
                self.present(browser, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }

    func doneButtonAction() {
        view.endEditing(true)
    }
    
    func setNotificationUI() {
        self.messageConfig.presentationContext = .window(windowLevel: UIWindowLevelNormal)
        self.messageConfig.preferredStatusBarStyle = .lightContent
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
        // reset image viewer data
        self.imageList.removeAll()

        if assets.count > 0 {
            // add imageViewer
            assets.enumerated()
                .map { (index, asset) in
                    asset.fetchOriginalImage(true, completeBlock: { image, info in
                        // set imageView
                        if index == 0 {
                            self.img_upload.image = image
                            self.lbl_imgCnt.text = "+" + String(assets.count-1)
                            self.vw_cntContainer.isHidden = assets.count == 1 ? true : false
                            
                            let imageSize = self.view.frame.size.height
                            self.imgVwConstraint.constant = imageSize / 3.5
                            self.vw_imgContainer.isHidden = false
                        }
                        
                        self.imageList.append(image!)
                    })
                }
        } else {
            self.imageList.removeAll()
            self.vw_imgContainer.isHidden = true
        }
    }
}

extension WritePostViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func setPicker() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        txt_isAnonymous.inputView = pickerView
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.selectAnonymous.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.selectAnonymous[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        txt_isAnonymous.text = selectAnonymous[row]
    }
}
