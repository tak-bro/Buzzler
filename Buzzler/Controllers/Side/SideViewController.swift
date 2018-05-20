//
//  SideViewController.swift
//  Buzzler
//
//  Created by Tak on 2018/04/08.
//  Copyright © 2018年 Tak. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SVProgressHUD
import SideMenu

enum CategoryModel {
    case info(id: String, title: String)
    case myPage(id: String, navTitle: String)
    case settings(id: String, navTitle: String)
}
typealias SideSectionModel = SectionModel<String, CategoryModel>


class SideViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tbl_category: UITableView!
    @IBOutlet weak var vw_header: UIView!
    
    private let disposeBag = DisposeBag()
    let dataSource = RxTableViewSectionedReloadDataSource<SideSectionModel>()

    // Temp Category List
    let categorySections = Observable.just([
        SideSectionModel(model: "", items: [
            CategoryModel.info(id: "3", title: "Seoul Univ."),
            CategoryModel.info(id: "2", title: "Economics"),
            CategoryModel.info(id: "1", title: "Anonymous"),
            CategoryModel.myPage(id: "MyPage", navTitle: "MyPageNavigationController"),
            CategoryModel.settings(id: "Settings", navTitle: "SettingsNavigationController"),
            ]),
        ])

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configUI()
    }
    
    // MARK: - Private Method
    
    fileprivate func configureTableView() {
        self.tbl_category.register(cellType: SideTableViewCell.self)
        self.tbl_category.isScrollEnabled = false
        self.tbl_category.rx.setDelegate(self).disposed(by: disposeBag)
        
        // Configure
        dataSource.configureCell = { dataSource, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: SideTableViewCell.self)
            switch item {
            case let .info(id, title):
                cell.id = id
                cell.lbl_category.text = title
                cell.vw_sideBox.isHidden = false
            case let .myPage(id, _):
                cell.id = id
                cell.lbl_category.text = id
                cell.vw_sideBox.isHidden = true
                cell.lbl_category.textColor = Config.UI.buttonActiveColor
            case let .settings(id, _):
                cell.id = id
                cell.lbl_category.text = id
                cell.vw_sideBox.isHidden = true
                cell.lbl_category.textColor = Config.UI.lightFontColor
            }
            return cell
        }
        
        self.tbl_category.rx
            .itemSelected
            .map { indexPath in
                return self.dataSource[indexPath]
            }
            .subscribe(onNext: { item in
                switch item {
                case .myPage(id: _, navTitle: let title),
                     .settings(id: _, navTitle: let title):
                    SideMenuManager.menuLeftNavigationController?.dismiss(animated: true, completion: {
                        GlobalUIManager.loadCustomVC(withTitle: title)
                    })
                default:
                    print(item)
                }
            })
            .disposed(by: disposeBag)

        
        categorySections
            .bind(to: self.tbl_category.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    fileprivate func configUI() {
        vw_header.backgroundColor = Config.UI.themeColor
        
        // set tableView UI
        tbl_category.backgroundColor = UIColor.clear
        tbl_category.rowHeight = UITableViewAutomaticDimension
        tbl_category.estimatedRowHeight = 200
        tbl_category.separatorStyle = .none
    }
}

// MARK: - Actions
extension SideViewController {

    @IBAction func pressDismiss(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pressLogout(_ sender: UIButton) {
        dismiss(animated: false, completion: {
            GlobalUIManager.loadLoginVC()
        })
    }
}
