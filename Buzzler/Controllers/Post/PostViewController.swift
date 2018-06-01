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
import Kingfisher
import NoticeBar
import RxDataSources
import Differentiator

class PostViewController: UIViewController {


    @IBOutlet weak var vw_writeComment: UIView!
    @IBOutlet weak var commentBottom: NSLayoutConstraint!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    @IBOutlet weak var txt_vw_comment: UITextView!
    @IBOutlet weak var tbl_post: UITableView!
    
    var viewModel: DetailPostViewModel?
    
    let homeVM = HomeViewModel()
    let originDataSource = RxTableViewSectionedReloadDataSource<BuzzlerSection>()
    let disposeBag = DisposeBag()
    
    let tmpDataSource = RxTableViewSectionedReloadDataSource<MultipleSectionModel>()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        // configBinding()
        setTempData()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension PostViewController {
    
    // MARK: - Private Method
    
    fileprivate func configUI() {
        // set tableView UI
        title = "Post"
        tbl_post.register(cellType: HomeTableViewCell.self)
        tbl_post.register(cellType: HomeImageTableViewCell.self)
        tbl_post.register(cellType: CommentTableViewCell.self)
        tbl_post.allowsSelection = false
        tbl_post.backgroundColor = Config.UI.themeColor
        tbl_post.rowHeight = UITableViewAutomaticDimension
        tbl_post.estimatedRowHeight = 200
        tbl_post.separatorStyle = .none
        
        // add footer view
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 73))
        footerView.backgroundColor = Config.UI.themeColor
        tbl_post.tableFooterView = footerView
        
        vw_writeComment.dropShadow(width: -1, height: 1)
    }

    /*
    fileprivate func configBinding() {
         // Input
        let inputStuff  = HomeViewModel.HomeInput()
        // Output
        let outputStuff = homeVM.transform(input: inputStuff)
         
        // Configure
        originDataSource.configureCell = { dataSource, tableView, indexPath, item in
            let defaultCell: UITableViewCell
            
            if item.imageUrls.count > 0 {
                let imgCell = tableView.dequeueReusableCell(for: indexPath, cellType: HomeImageTableViewCell.self)
                imgCell.lbl_title.text = "General2"
                imgCell.lbl_title.numberOfLines = 0
                imgCell.lbl_content.text = "General2"
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
                let cell = tableView.dequeueReusableCell(for: indexPath, cellType: CommentTableViewCell.self)
                cell.lbl_comment.text = item.title
                cell.lbl_comment.numberOfLines = 0
                defaultCell = cell
            }
            return defaultCell
        }
        
        outputStuff.section
            .drive(tbl_post.rx.items(dataSource: originDataSource))
            .addDisposableTo(rx.disposeBag)
        
       tbl_post.rx.setDelegate(self)
            .addDisposableTo(rx.disposeBag)
    }
 */
}

extension PostViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return HomeTableViewCell.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension PostViewController {
    // temp
    
    func setTempData() {
        let sections: [MultipleSectionModel] = [
            .ImageProvidableSection(title: "Section 1",
                                    items: [.ImageSectionItem(image: UIImage(named: "img_tmp")!, title: "General")]),
            .ToggleableSection(title: "Section 2",
                               items: [.ToggleableSectionItem(title: "On", enabled: true)]),
//            .StepperableSection(title: "Section 3",
//                                items: [.StepperSectionItem(title: "1")]),
            .ToggleableSection(title: "Section 2",
                               items: [.ToggleableSectionItem(title: "asdasdasd", enabled: true)]),
            .ToggleableSection(title: "Section 2",
                               items: [.ToggleableSectionItem(title: "asdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasd", enabled: true)]),
            .ToggleableSection(title: "Section 2",
                               items: [.ToggleableSectionItem(title: "asdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasd", enabled: true)]),
            .ToggleableSection(title: "Section 2",
                               items: [.ToggleableSectionItem(title: "asdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasd", enabled: true)]),
            .ToggleableSection(title: "Section 2",
                               items: [.ToggleableSectionItem(title: "asdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasd", enabled: true)]),
        ]
        
        tmpDataSource.configureCell  = { dataSource, tableView, indexPath, item in

            switch dataSource[indexPath] {
            case let .ImageSectionItem(image, title):
                let imgCell = tableView.dequeueReusableCell(for: indexPath, cellType: HomeImageTableViewCell.self)
                imgCell.lbl_title.text = title
                imgCell.lbl_author.text = title
     
                return imgCell
            case let .StepperSectionItem(title):
                let imgCell = tableView.dequeueReusableCell(for: indexPath, cellType: HomeImageTableViewCell.self)
                imgCell.lbl_title.text = title
                
                return imgCell
            case let .ToggleableSectionItem(title, enabled):
                let cell = tableView.dequeueReusableCell(for: indexPath, cellType: CommentTableViewCell.self)
                cell.lbl_comment.text = title
                return cell
            }
        }
        
        
        Observable.just(sections)
            .bind(to: tbl_post.rx.items(dataSource: tmpDataSource))
            .disposed(by: disposeBag)
    }
    
}


enum MultipleSectionModel {
    case ImageProvidableSection(title: String, items: [SectionItem])
    case ToggleableSection(title: String, items: [SectionItem])
    case StepperableSection(title: String, items: [SectionItem])
}

enum SectionItem {
    case ImageSectionItem(image: UIImage, title: String)
    case ToggleableSectionItem(title: String, enabled: Bool)
    case StepperSectionItem(title: String)
}

extension MultipleSectionModel: SectionModelType {
    typealias Item = SectionItem
    
    var items: [SectionItem] {
        switch  self {
        case .ImageProvidableSection(title: _, items: let items):
            return items.map {$0}
        case .StepperableSection(title: _, items: let items):
            return items.map {$0}
        case .ToggleableSection(title: _, items: let items):
            return items.map {$0}
        }
    }
    
    init(original: MultipleSectionModel, items: [Item]) {
        switch original {
        case let .ImageProvidableSection(title: title, items: _):
            self = .ImageProvidableSection(title: title, items: items)
        case let .StepperableSection(title, _):
            self = .StepperableSection(title: title, items: items)
        case let .ToggleableSection(title, _):
            self = .ToggleableSection(title: title, items: items)
        }
    }
}

extension MultipleSectionModel {
    var title: String {
        switch self {
        case .ImageProvidableSection(title: let title, items: _):
            return title
        case .StepperableSection(title: let title, items: _):
            return title
        case .ToggleableSection(title: let title, items: _):
            return title
        }
    }
}

