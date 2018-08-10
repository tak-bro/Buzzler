//
//  MyPageViewController.swift
//  Buzzler
//
//  Created by 진형탁 on 20/05/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import UIKit
import SideMenu
import SVProgressHUD
import RxSwift
import RxCocoa
import RxDataSources
import SwiftyAttributes

class MyPageViewController: UIViewController {

    @IBOutlet weak var tbl_post: UITableView!
    
    let disposeBag = DisposeBag()
    var viewModel = MyPageViewModel()
    let dataSource = RxTableViewSectionedReloadDataSource<BuzzlerSection>()
    
    var refreshControl : UIRefreshControl?
    var categories: [UserCategory] = userCategories.filter { $0.id != 1 } // delete Secret Lounge
    var category: Int = 1
    
    var isAddedShadow = false
    let header = StretchHeader()
    var segmentedControl: UISegmentedControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SideMenuManager.menuWidth = view.frame.width * CGFloat(0.64)
        deleteShadow(from: self)
        title = " "
        
        setupHeaderView()
        configureTableView()
        configBinding()
    }
    
    @IBAction func segmentedControlDidChange(_ sender: UISegmentedControl) {
        guard let segmentControl = self.segmentedControl else { return }
        segmentControl.changeUnderlinePosition()
        
        // request new category
        let index = segmentControl.selectedSegmentIndex
        self.category = categories[index].id
        self.viewModel.category(category: self.category)
        self.viewModel.loadPageTrigger.onNext(())
    }
}

extension MyPageViewController: UITableViewDelegate {
    
    // MARK: - Private Method
    
    fileprivate func configureTableView() {
        // set tableView
        tbl_post.register(cellType: HomeTableViewCell.self)
        tbl_post.register(cellType: HomeImageTableViewCell.self)
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
    }
    
    fileprivate func configBinding() {
        
        self.viewModel = MyPageViewModel()
        self.viewModel.category(category: self.category)
        self.viewModel.inputs.refresh()
        
        dataSource.configureCell = { dataSource, tableView, indexPath, item in
            let defaultCell: UITableViewCell
            if item.imageUrls.count > 0 {
                let imgCell = tableView.dequeueReusableCell(for: indexPath, cellType: HomeImageTableViewCell.self)
                
                imgCell.lbl_title.text = item.title
                imgCell.lbl_content.text = item.contents
                imgCell.lbl_time.text = convertDateFormatter(dateStr: item.createdAt)
                imgCell.lbl_likeCount.text = String(item.likeCount)
                imgCell.lbl_commentCount.text = String(item.commentCount)
                imgCell.lbl_author.text = item.author.username
                imgCell.lbl_remainImgCnt.text = "+" + String(item.imageUrls.count-1)
                imgCell.lbl_remainTime.text = getRemainTimeString(createdAt: item.createdAt)
                if item.imageUrls.count == 1 {
                    imgCell.vw_remainLabelContainer.isHidden = true
                } else {
                    imgCell.vw_remainLabelContainer.isHidden = false
                }
                
                // set image
                let encodedURL = item.imageUrls.sorted()[0].addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                imgCell.img_items.kf.indicatorType = .activity
                imgCell.img_items.kf.setImage(with: URL(string: encodedURL!), placeholder: nil)
                
                // hide action button
                imgCell.btn_postAction.isHidden = true
                
                defaultCell = imgCell
            } else {
                let cell = tableView.dequeueReusableCell(for: indexPath, cellType: HomeTableViewCell.self)
                
                cell.lbl_title.text = item.title
                cell.lbl_content.text = item.contents
                cell.lbl_time.text = convertDateFormatter(dateStr: item.createdAt)
                cell.lbl_likeCount.text = String(item.likeCount)
                cell.lbl_commentCount.text = String(item.commentCount)
                cell.lbl_author.text = item.author.username
                cell.lbl_remainTime.text = getRemainTimeString(createdAt: item.createdAt)
                cell.btn_postAction.isHidden = true
                
                defaultCell = cell
            }
            return defaultCell
        }
        
        self.refreshControl?.rx.controlEvent(.valueChanged)
            .bind(to:self.viewModel.inputs.loadPageTrigger)
            .disposed(by: disposeBag)
        
        /* TODO
         self.tableView.rx.reachedBottom
         .bind(to:self.viewModel.inputs.loadNextPageTrigger)
         .disposed(by: disposeBag)
         */
        
        self.viewModel.outputs.elements.asDriver()
            .map({ (posts) -> [BuzzlerSection] in
                return [BuzzlerSection(items: posts)]
            })
            .drive(self.tbl_post.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        self.tbl_post.rx.itemSelected
            .map { (at: $0, animated: true) }
            .subscribe(onNext: tbl_post.deselectRow)
            .disposed(by: disposeBag)
        
        self.tbl_post.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                self?.viewModel.inputs.tapped(indexRow: indexPath.row)
            }).disposed(by: disposeBag)
        
        self.viewModel.isLoading
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
        
        self.viewModel.outputs.selectedViewModel.drive(onNext: { detailPostViewModel in
            // push to PostViewController
            let detailPostVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
            detailPostVC.viewModel = detailPostViewModel
            detailPostVC.selectedPostId = detailPostViewModel.selectedPostId
            detailPostVC.selectedPostCreatedAt = detailPostViewModel.selectedPostCreatedAt
            self.navigationController?.pushViewController(detailPostVC, animated: true)
        }).disposed(by: disposeBag)
    }
}

extension MyPageViewController {

    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UIView()
        vw.backgroundColor = .clear
        
        self.segmentedControl = UISegmentedControl(frame: CGRect(x: 0, y: 0, width: self.tbl_post.frame.width, height: 40))
        guard let segmentedControl = self.segmentedControl else { return vw }
        
        if let firstCategory = self.categories.first?.id {
            self.category = firstCategory
        }
        // set segment control info frm global value
        self.categories.enumerated().map { (arg) -> Void in
            let (index, category) = arg
            segmentedControl.insertSegment(withTitle: category.name, at: index, animated: true)
        }
        segmentedControl.addUnderlineForSelectedSegment()
        segmentedControl.addTarget(self, action: #selector(MyPageViewController.segmentedControlDidChange(_:)), for: .valueChanged)
        
        vw.addSubview(segmentedControl)
        return vw
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
}


extension MyPageViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setupHeaderView() {
        let options = StretchHeaderOptions()
        options.position = .fullScreenTop
        header.stretchHeaderSize(headerSize: CGSize(width: view.frame.size.width, height: 90),
                                 imageSize: CGSize(width: view.frame.size.width, height: 90),
                                 controller: self,
                                 options: options)
        
        //        self.lbl_userName.text = globalAccountInfo.username
        //        self.lbl_buzAmount.text = String(globalAccountInfo.buzAmount)
        //        self.lbl_univInfo.text = globalAccountInfo.email
        
        // add first header label
        var firstHeaderLabel = HeaderLabel()
        firstHeaderLabel = HeaderLabel(frame: CGRect(x: header.frame.size.width / 2, y: header.frame.size.height / 2, width: 200, height: 30))
        firstHeaderLabel.text = globalAccountInfo.username
        
        // add second header label
        var secondHeaderLabel = HeaderLabel()
        secondHeaderLabel = HeaderLabel(frame: CGRect(x: header.frame.size.width / 2, y: header.frame.size.height / 2, width: 200, height: 30))
        secondHeaderLabel.text = String(globalAccountInfo.buzAmount)
//
//        let peopleCnt = "1K".withAttributes([
//            .textColor(Config.UI.fontColor),
//            .font(.AvenirNext(type: .Book, size: 12))
//            ])
//        let staticPeople = "  peoples     ".withAttributes([
//            .textColor(Config.UI.lightFontColor),
//            .font(.AvenirNext(type: .Book, size: 12))
//            ])
//        let postCnt = "100K".withAttributes([
//            .textColor(Config.UI.fontColor),
//            .font(.AvenirNext(type: .Book, size: 12))
//            ])
//        let staticPost = "  posts".withAttributes([
//            .textColor(Config.UI.lightFontColor),
//            .font(.AvenirNext(type: .Book, size: 12))
//            ])
//        let finalString = peopleCnt + staticPeople + postCnt + staticPost
//        secondHeaderLabel.attributedText = finalString
        
        header.addSubview(firstHeaderLabel)
        header.addSubview(secondHeaderLabel)
        
        header.backgroundColor = Config.UI.themeColor
        firstHeaderLabel.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(header)
            make.centerY.equalTo(header).multipliedBy(0.6)
        }
        secondHeaderLabel.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(header)
            make.centerY.equalTo(header).multipliedBy(1.4)
        }
        
        self.tbl_post.tableHeaderView = header
    }
    
    // MARK: - ScrollView Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        header.updateScrollViewOffset(scrollView)
        
        // NavigationHeader alpha update
        let offset: CGFloat = scrollView.contentOffset.y
        if (offset > 50) {
            addShadowToNav(from: self)
            self.isAddedShadow = true
            title = "MyPage"
        } else {
            deleteShadow(from: self)
            self.isAddedShadow = false
            title = " "
        }
    }
}
