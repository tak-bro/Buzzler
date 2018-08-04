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
import PopoverSwift
import SKPhotoBrowser

class PostViewController: UIViewController, ShowsAlert {
    
    @IBOutlet weak var img_heartPopup: UIImageView!
    @IBOutlet weak var vw_writeComment: UIView!
    @IBOutlet weak var txt_vw_comment: UITextView!
    @IBOutlet weak var tbl_post: UITableView!
    @IBOutlet weak var commentViewHeight: NSLayoutConstraint!
    @IBOutlet weak var commentBottom: NSLayoutConstraint!
    @IBOutlet weak var btn_writeComment: UIButton!
    @IBOutlet weak var vw_dimmed: UIView!
    
    // to show parent comment info
    @IBOutlet weak var lbl_parentAuthor: UILabel!
    @IBOutlet weak var vw_parentComment: UIView!
    @IBOutlet weak var btn_dismissParentComment: UIButton!
    @IBOutlet weak var lbl_parentCommentId: UILabel!
    
    var placeholderLabel: UILabel!
    var viewModel: DetailPostViewModel?
    var refreshControl: UIRefreshControl?
    
    let disposeBag = DisposeBag()
    let dataSource = RxTableViewSectionedReloadDataSource<MultipleSectionModel>()
    
    var selectedPost = BuzzlerPost()
    fileprivate let tapGesture = UITapGestureRecognizer()
    var selectedPostId: Int?
    var selectedPostCreatedAt: String?
    
    var originTitle: String?
    var originContents: String?
    
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
                    self.showAlert(message: "Server Error!")
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
                    imgCell.lbl_content.text = item.contents
                    imgCell.lbl_time.text = convertDateFormatter(dateStr: item.createdAt)
                    imgCell.lbl_likeCount.text = String(item.likeCount) + " Likes"
                    imgCell.lbl_commentCount.text = String(item.commentCount) + " Comments"
                    imgCell.lbl_author.text = item.author.username
                    imgCell.lbl_remainImgCnt.text = "+" + String(item.imageUrls.count-1)
                    imgCell.lbl_remainTime.text = getRemainTimeString(createdAt: item.createdAt)
                    
                    if item.imageUrls.count == 1 {
                        imgCell.vw_remainLabelContainer.isHidden = true
                    } else {
                        imgCell.vw_remainLabelContainer.isHidden = false
                    }
                    
                    // check rewarded
                    if checkIsRewarded(createdAt: item.createdAt) {
                        imgCell.btn_like.isEnabled = false
                    } else {
                        imgCell.btn_like.isEnabled = true
                    }
                    
                    // set origin info
                    self.originTitle = item.title
                    self.originContents = item.contents
                    
                    // set image
                    let encodedURL = item.imageUrls.sorted()[0].addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    imgCell.img_items.kf.indicatorType = .activity
                    imgCell.img_items.kf.setImage(with: URL(string: encodedURL!), placeholder: nil)
                    
                    // add post action for edit
                    imgCell.btn_postAction.rx.tap.asDriver()
                        .drive(onNext: { [weak self] in
                            // save post data to local
                            self?.selectedPost = item
                            self?.addDimmedView()
                            // present popover
                            let controller = PopoverController(items:(self?.makePorverActions())!,
                                                               fromView: imgCell.btn_postAction,
                                                               direction: .down,
                                                               style: .withImage,
                                                               dismissHandler: {
                                                                self?.removeDimmedView()
                                                                // remove dimmed view from navigation bar
                                                                if let navigationBar = self?.navigationController?.navigationBar {
                                                                    navigationBar.removeSubviews()
                                                                }
                            })
                            self?.popover(controller)
                            
                            // add dimmed view to navigation bar
                            if let navigationBar = self?.navigationController?.navigationBar {
                                let dimmedFrame = CGRect(x: 0, y: 0, width: navigationBar.frame.width, height: navigationBar.frame.height)
                                let dimmedNavView = UIView(frame: dimmedFrame)
                                dimmedNavView.backgroundColor = Config.UI.blackTransparencyColor
                                navigationBar.addSubview(dimmedNavView)
                            }
                        })
                        .disposed(by: imgCell.bag)
                    
                    // like action
                    imgCell.btn_like.rx.tap.asDriver()
                        .drive(onNext: { _ in
                            let environment = Environment()
                            guard let categoryId = environment.categoryId, let postId = self.selectedPostId else { return }
                            
                            // set disabled like button
                            imgCell.btn_like.isEnabled = false

                            BuzzlerProvider.request(Buzzler.likePost(categoryId: categoryId, postId: postId)) { result in
                                // set enabled
                                imgCell.btn_like.isEnabled = true

                                switch result {
                                case let .success(moyaResponse):
                                    let statusCode = moyaResponse.statusCode // Int - 200, 401, 500, etc
                                    if statusCode == 201 {
                                        self.likeAnimation()
                                        imgCell.btn_like.setImage(UIImage(named: "icon_like"), for: .normal)
                                        imgCell.lbl_likeCount.text = String(item.likeCount+1) + " Likes"
                                    } else {
                                        self.showAlert(message: "Already Liked before")
                                    }
                                    
                                case .failure(_):
                                    self.showAlert(message: "Server Error!")
                                }
                            }
                        })
                        .disposed(by: imgCell.bag)
                    
                    
                    // add image viewer
                    imgCell.vw_imgContainer.addGestureRecognizer(self.tapGesture)
                    // create URL Array
                    var skImages = [SKPhoto]()
                    let photos = item.imageUrls
                        .map { img -> SKPhoto in
                            guard let encodedURL = img.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return SKPhoto.photoWithImageURL("") }
                            let photo = SKPhoto.photoWithImageURL(encodedURL)
                            photo.shouldCachePhotoURLImage = true
                            return photo
                    }
                    skImages = photos

                    self.tapGesture.rx.event
                        .bind(onNext: { recognizer in
                            // create PhotoBrowser Instance, and present.
                            SKPhotoBrowserOptions.displayAction = false
                            let browser = SKPhotoBrowser(photos: skImages)
                            browser.initializePageIndex(0)
                            self.present(browser, animated: true, completion: {})
                        })
                        .disposed(by: imgCell.bag)
                    
                    defaultCell = imgCell
                } else {
                    let cell = tableView.dequeueReusableCell(for: indexPath, cellType: HomeTableViewCell.self)
                    cell.lbl_title.text = item.title
                    cell.lbl_content.text = item.contents
                    cell.lbl_time.text = convertDateFormatter(dateStr: item.createdAt)
                    cell.lbl_likeCount.text = String(item.likeCount) + " Likes"
                    cell.lbl_commentCount.text = String(item.commentCount) + " Comments"
                    cell.lbl_author.text = item.author.username
                    cell.lbl_remainTime.text = getRemainTimeString(createdAt: item.createdAt)
                    
                    // check rewarded
                    if checkIsRewarded(createdAt: item.createdAt) {
                        cell.btn_like.isEnabled = false
                    } else {
                        cell.btn_like.isEnabled = true
                    }
                    
                    // set origin info
                    self.originTitle = item.title
                    self.originContents = item.contents
                    
                    // add post action for edit
                    cell.btn_postAction.rx.tap.asDriver()
                        .drive(onNext: { [weak self] in
                            self?.selectedPost = item
                            let controller = PopoverController(items:(self?.makePorverActions())!,
                                                               fromView: cell.btn_postAction,
                                                               direction: .down,
                                                               style: .withImage,
                                                               dismissHandler: {
                                                                self?.removeDimmedView()
                                                                // remove dimmed view from navigation bar
                                                                if let navigationBar = self?.navigationController?.navigationBar {
                                                                    navigationBar.removeSubviews()
                                                                }
                            })
                            self?.addDimmedView()
                            self?.popover(controller)
                            // add dimmed view to navigation bar
                            if let navigationBar = self?.navigationController?.navigationBar {
                                let dimmedFrame = CGRect(x: 0, y: 0, width: navigationBar.frame.width, height: navigationBar.frame.height)
                                let dimmedNavView = UIView(frame: dimmedFrame)
                                dimmedNavView.backgroundColor = Config.UI.blackTransparencyColor
                                navigationBar.addSubview(dimmedNavView)
                            }
                        })
                        .disposed(by: cell.bag)
                    
                    // like post action
                    cell.btn_like.rx.tap.asDriver()
                        .drive(onNext: { _ in
                            let environment = Environment()
                            guard let categoryId = environment.categoryId, let postId = self.selectedPostId else { return }
                            
                            // set disabled like button
                            cell.btn_like.isEnabled = false

                            BuzzlerProvider.request(Buzzler.likePost(categoryId: categoryId, postId: postId)) { result in
                                // set enabled
                                cell.btn_like.isEnabled = true

                                switch result {
                                case let .success(moyaResponse):
                                    let statusCode = moyaResponse.statusCode
                                    if statusCode == 201 {
                                        self.likeAnimation()
                                        cell.btn_like.setImage(UIImage(named: "icon_like"), for: .normal)
                                        cell.lbl_likeCount.text = String(item.likeCount+1) + " Likes"
                                    } else {
                                        self.showAlert(message: "Already Liked before")
                                    }
                                    
                                case .failure(_):
                                    self.showAlert(message: "Server Error!")
                                }
                            }
                        })
                        .disposed(by: cell.bag)
                    
                    defaultCell = cell
                }
                
                return defaultCell
            case let .CommentItem(item):
                let cell = tableView.dequeueReusableCell(for: indexPath, cellType: CommentTableViewCell.self)
                cell.lbl_comment.text = item.contents
                cell.lbl_comment.numberOfLines = 0
                cell.lbl_author.text = item.author.username
                cell.lbl_createdAt.text = getDateFromString(date: item.createdAt).timeAgoSinceNow

                // check rewarded with selected Post CreatedAt
                if let postCreatedAt = self.selectedPostCreatedAt {
                    if checkIsRewarded(createdAt: postCreatedAt){
                        cell.btn_like.isEnabled = false
                    } else {
                        cell.btn_like.isEnabled = true
                    }
                }
                
                // define action to write comment
                cell.btn_writeRecomment.rx.tap.asDriver()
                    .drive(onNext: { _ in
                        // open input view
                        self.txt_vw_comment.becomeFirstResponder()
                        // set parent comment Info
                        self.lbl_parentCommentId.text = item.id.toString
                        self.vw_parentComment.isHidden = false
                        self.lbl_parentAuthor.text = item.author.username
                    }).disposed(by: cell.bag)
                
                // like post action
                cell.btn_like.rx.tap.asDriver()
                    .drive(onNext: { _ in
                        let environment = Environment()
                        guard let categoryId = environment.categoryId else { return }
                        
                        // set disabled like button
                        cell.btn_like.isEnabled = false
                        
                        BuzzlerProvider.request(Buzzler.likePost(categoryId: categoryId, postId: item.id)) { result in
                            // set enabled
                            cell.btn_like.isEnabled = true
                            
                            switch result {
                            case let .success(moyaResponse):
                                let statusCode = moyaResponse.statusCode
                                if statusCode == 201 {
                                    self.likeAnimation()
                                } else {
                                    self.showAlert(message: "Already Liked before")
                                }
                                
                            case .failure(_):
                                self.showAlert(message: "Server Error!")
                            }
                        }
                    })
                    .disposed(by: cell.bag)
                
                return cell
            case let .ReCommentItem(item):
                let cell = tableView.dequeueReusableCell(for: indexPath, cellType: ReCommentTableViewCell.self)
                cell.lbl_recomment.text = item.contents
                cell.lbl_recomment.numberOfLines = 0
                cell.lbl_author.text = item.author.username
                cell.lbl_createdAt.text = getDateFromString(date: item.createdAt).timeAgoSinceNow
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
        self.img_heartPopup.alpha = 0.0
        self.resetNavBar()
        self.vw_dimmed.isHidden = true
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

extension PostViewController {
    
    func makePorverActions() -> [PopoverItem] {
        let editAction = PopoverItem(title: "수정", image: UIImage(named: "btn_edit_post")) {
            debugPrint($0.title)
            print(self.selectedPost.title)
            
            let writePostVC = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "WritePostViewController") as! WritePostViewController
            
            writePostVC.isUpdate = true
            writePostVC.originContents = self.originContents
            writePostVC.originTitle = self.originTitle
            
//            let deleteVC = CantDeletePostPopUpViewController(nibName: "CantDeletePostPopUpViewController", bundle: nil)
//            deleteVC.modalPresentationStyle = .overCurrentContext
//            deleteVC.modalTransitionStyle = .crossDissolve
//            self.present(deleteVC, animated: true, completion: nil)
            
            self.present(writePostVC, animated: true, completion: nil)
        }
        
        let deleteAction = PopoverItem(title: "삭제", image: UIImage(named: "btn_delete_post")) {
            debugPrint($0.title)
            print(self.selectedPost.title)
            
            let deleteVC = DeletePostPopUpViewController(nibName: "DeletePostPopUpViewController", bundle: nil)
            deleteVC.modalPresentationStyle = .overCurrentContext
            deleteVC.modalTransitionStyle = .crossDissolve
            deleteVC.postId = self.selectedPostId
            self.present(deleteVC, animated: true, completion: nil)
        }
        
        return [editAction, deleteAction]
    }
    
    func likeAnimation() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: {() -> Void in
            self.img_heartPopup.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.img_heartPopup.alpha = 1.0
        }, completion: {(_ finished: Bool) -> Void in
            UIView.animate(withDuration: 0.1, delay: 0, options: .allowUserInteraction, animations: {() -> Void in
                self.img_heartPopup.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: {(_ finished: Bool) -> Void in
                UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: {() -> Void in
                    self.img_heartPopup.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                    self.img_heartPopup.alpha = 0.0
                }, completion: {(_ finished: Bool) -> Void in
                    self.img_heartPopup.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                })
            })
        })
    }
    
    func addDimmedView() {
        self.vw_dimmed.isHidden = false
    }
    
    func removeDimmedView() {
        self.vw_dimmed.isHidden = true
    }
}
