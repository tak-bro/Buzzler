//
//  PostViewController.swift
//  Buzzler
//
//  Created by 진형탁 on 2018. 4. 25..
//  Copyright © 2018년 Maru. All rights reserved.
//

import UIKit
import EZSwiftExtensions
import Reusable
import RxSwift
import RxCocoa
import RxDataSources
import SVProgressHUD
import RxKeyboard

class PostViewController: UIViewController {
    
    @IBOutlet weak var vw_writeComment: UIView!
    @IBOutlet weak var txt_vw_comment: UITextView!
    @IBOutlet weak var tbl_post: UITableView!
    @IBOutlet weak var commentViewHeight: NSLayoutConstraint!
    @IBOutlet weak var commentBottom: NSLayoutConstraint!
    @IBOutlet weak var btn_writeComment: UIButton!

    // to show parent comment info
    @IBOutlet weak var lbl_parentAuthor: UILabel!
    @IBOutlet weak var vw_parentComment: UIView!
    @IBOutlet weak var btn_dismissParentComment: UIButton!
    @IBOutlet weak var lbl_parentCommentId: UILabel!
    
    var placeholderLabel : UILabel!
    var viewModel: DetailPostViewModel?
    var refreshControl: UIRefreshControl?
    
    let disposeBag = DisposeBag()
    let dataSource = RxTableViewSectionedReloadDataSource<MultipleSectionModel>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        addPlaceHolderToTextView()
        configTableUI()
        configBinding()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.lbl_parentCommentId.text = ""
    }
    
    @IBAction func pressedDismiss(_ sender: UIButton) {
        resetCommentInfo()
        self.txt_vw_comment.text = ""
        self.txt_vw_comment.resignFirstResponder()
    }
}

extension PostViewController: UITableViewDelegate {
    
    // MARK: - Private Method
    
    fileprivate func configTableUI() {
        // set tableView UI
        title = "Post"
        tbl_post.register(cellType: HomeTableViewCell.self)
        tbl_post.register(cellType: HomeImageTableViewCell.self)
        tbl_post.register(cellType: CommentTableViewCell.self)
        tbl_post.register(cellType: ReCommentTableViewCell.self)
        tbl_post.allowsSelection = false
        tbl_post.backgroundColor = Config.UI.themeColor
        tbl_post.rowHeight = UITableViewAutomaticDimension
        tbl_post.estimatedRowHeight = 200
        tbl_post.separatorStyle = .none
        tbl_post.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        self.refreshControl = UIRefreshControl()
        if let refreshControl = self.refreshControl {
            refreshControl.backgroundColor = .clear
            refreshControl.tintColor = .lightGray
            if #available(iOS 10.0, *) {
                tbl_post.refreshControl = refreshControl
            } else {
                tbl_post.addSubview(refreshControl)
            }
        }
        
        // add footer view
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 73))
        footerView.backgroundColor = Config.UI.themeColor
        tbl_post.tableFooterView = footerView
        
        vw_writeComment.dropShadow(width: -1, height: 1)
    }
    
    fileprivate func configBinding() {
        guard let viewModel = self.viewModel else { return }
        viewModel.inputs.refresh()
        
        lbl_parentCommentId.rx.observe(String.self, "text")
            .bind(to: viewModel.inputs.parentId)
            .disposed(by: disposeBag)
        
        // write comment
        btn_writeComment.rx.tap
            .bind(to: viewModel.inputs.writeCommentTaps)
            .disposed(by: disposeBag)
        
        txt_vw_comment.rx.text.orEmpty
            .bind(to: viewModel.inputs.inputtedComment)
            .disposed(by: disposeBag)
        
        viewModel.outputs.enableWriteButton.drive(onNext: { enable in
            self.btn_writeComment.isEnabled = enable
        }).disposed(by: disposeBag)
        
        viewModel.outputs.validatedComment
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.outputs.enableWriteButton
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.outputs.requestWriteComment
            .drive(onNext: { res in
                if res == true {
                    self.txt_vw_comment.text = ""
                    self.txt_vw_comment.resignFirstResponder()
                    // refresh manually
                    self.tbl_post.setContentOffset(CGPoint(x: 0, y: self.tbl_post.contentOffset.y - (self.refreshControl!.frame.size.height)), animated: false)
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
                        self.refreshControl?.sendActions(for: .valueChanged)
                    })
                    self.resetCommentInfo()
                } else {
                    SVProgressHUD.showError(withStatus: "Server Error")
                }
            }).disposed(by: disposeBag)
        
        // set table
        dataSource.configureCell = { dataSource, tableView, indexPath, item in
            let defaultCell: UITableViewCell
            
            switch dataSource[indexPath] {
            case let .PostItem(item):
                if item.imageUrls.count > 0 {
                    let imgCell = tableView.dequeueReusableCell(for: indexPath, cellType: HomeImageTableViewCell.self)
                    imgCell.lbl_title.text = item.title
                    imgCell.lbl_content.text = item.content
                    imgCell.lbl_time.text = item.createdAt.toString(format: "YYYY/MM/DD")
                    imgCell.lbl_likeCount.text = String(item.likeCount)
                    imgCell.lbl_author.text = "익명"
                    imgCell.lbl_remainImgCnt.text = "+" + String(item.imageUrls.count-1)
                    if item.imageUrls.count == 1 {
                        imgCell.vw_remainLabelContainer.isHidden = true
                    } else {
                        imgCell.vw_remainLabelContainer.isHidden = false
                    }
                    defaultCell = imgCell
                } else {
                    let cell = tableView.dequeueReusableCell(for: indexPath, cellType: HomeTableViewCell.self)
                    cell.lbl_title.text = item.title
                    cell.lbl_content.text = item.content
                    cell.lbl_time.text = item.createdAt.toString(format: "YYYY/MM/DD")
                    cell.lbl_likeCount.text = String(item.likeCount)
                    cell.lbl_author.text = "익명"
                    defaultCell = cell
                }
                return defaultCell
            case let .CommentItem(item):
                let cell = tableView.dequeueReusableCell(for: indexPath, cellType: CommentTableViewCell.self)
                cell.lbl_comment.text = item.content
                cell.lbl_comment.numberOfLines = 0
                
                // define action to write comment
                cell.btn_writeRecomment.rx.tap.asDriver()
                    .drive(onNext: { _ in
                        // open input view
                        self.txt_vw_comment.becomeFirstResponder()
                        // set parent comment Info
                        self.lbl_parentCommentId.text = item.id.toString
                        self.vw_parentComment.isHidden = false
                        self.lbl_parentAuthor.text = item.authorId.toString
                    }).disposed(by: cell.bag)
                
                return cell
            case let .ReCommentItem(item):
                let cell = tableView.dequeueReusableCell(for: indexPath, cellType: ReCommentTableViewCell.self)
                cell.lbl_recomment.text = item.content
                cell.lbl_recomment.numberOfLines = 0
                return cell
            }
        }
        
        self.refreshControl?.rx.controlEvent(.valueChanged)
            .bind(to: viewModel.inputs.loadDetailPostTrigger)
            .disposed(by: disposeBag)
        
        viewModel.outputs.elements.asDriver()
            .map({ (items) -> [MultipleSectionModel] in
                return items
            })
            .drive(self.tbl_post.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        self.tbl_post.rx.itemSelected
            .map { (at: $0, animated: true) }
            .subscribe(onNext: tbl_post.deselectRow)
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .drive(onNext: { isLoading in
                switch isLoading {
                case true:
                    self.refreshControl?.endRefreshing()
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
                self.commentBottom.constant = keyboardVisibleHeight
                self.view.layoutIfNeeded()
            })
            .addDisposableTo(disposeBag)
    }
    
}

extension PostViewController: UITextViewDelegate {
    
    func setUI() {
        self.vw_parentComment.isHidden = true
        resetNavBar()
    }
    
    func resetNavBar() {
        self.navigationController?.navigationBar.topItem?.title = " "
        self.navigationController?.navigationBar.barTintColor = Config.UI.themeColor
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.clear.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 0.0
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.0
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        // to set height of TextView
        if textView.contentSize.height <= 100 {
            self.commentViewHeight.constant = textView.contentSize.height + 30
            textView.setContentOffset(CGPoint.zero, animated: false)
        }
        self.view.layoutIfNeeded()
    }
    
    func addPlaceHolderToTextView() {
        txt_vw_comment.delegate = self
        
        // set placeholder for textView
        placeholderLabel = UILabel()
        placeholderLabel.text = "댓글달기.."
        placeholderLabel.textColor = Config.UI.placeholderColor
        placeholderLabel.font = UIFont(name: "NotoSans-Regular", size: 14)
        placeholderLabel.sizeToFit()
        txt_vw_comment.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (txt_vw_comment.font?.pointSize)! / 2)
        placeholderLabel.isHidden = !txt_vw_comment.text.isEmpty
    }
    
    func resetCommentInfo() {
        // reset parentId Info
        self.vw_parentComment.isHidden = true
        self.lbl_parentCommentId.text = ""
        self.lbl_parentAuthor.text = ""
    }
}
