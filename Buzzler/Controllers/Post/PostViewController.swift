//
//  PostViewController.swift
//  Buzzler
//
//  Created by 진형탁 on 2018. 4. 17..
//  Copyright © 2018년 Maru. All rights reserved.
//

import UIKit

class PostViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var lbl_univ: UILabel!
    @IBOutlet weak var btn_post: UIButton!
    @IBOutlet weak var btn_dismiss: UIButton!
    @IBOutlet weak var txt_title: UITextField!
    @IBOutlet weak var txt_contents: UITextField!
    
   let viewModel = PostViewModel(provider: BuzzlerProvider)
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindToRx()
    }
    
    override func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Actions
    
    @IBAction func pressDismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension PostViewController {
    
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
    
}
