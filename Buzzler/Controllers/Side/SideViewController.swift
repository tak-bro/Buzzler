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

enum SideModel {
    case category(id: Int, title: String)
    case myPage(navTitle: String)
    case settings(navTitle: String)
}
typealias SideSectionModel = SectionModel<String, SideModel>

class SideViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var tbl_category: UITableView!
    @IBOutlet weak var vw_header: UIView!
    
    private let disposeBag = DisposeBag()
    let dataSource = RxTableViewSectionedReloadDataSource<SideSectionModel>()
    let router = SideMenuRouter()
    
    let categories$ = Observable.just([
        SideSectionModel(model: "", items: sideCategories),
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
            case let .category(id, title):
                cell.id = id
                cell.lbl_category.text = title
                cell.vw_sideBox.isHidden = false
            case .myPage(_):
                cell.id = -1
                cell.lbl_category.text = "MyPage"
                cell.vw_sideBox.isHidden = true
                cell.lbl_category.textColor = Config.UI.buttonActiveColor
            case .settings(_):
                cell.id = -2
                cell.lbl_category.text = "Settings"
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
                case .category(id: let id, title: _):
                    // save current categoryId
                    var environment = Environment()
                    environment.categoryId = id
                    
                    self.router.category = id
                    self.router.perform(.home, from: self)
                case .myPage(navTitle: _):
                    self.router.perform(.myPage, from: self)
                case .settings(navTitle: _):
                    self.router.perform(.settings, from: self)
                }
            })
            .disposed(by: disposeBag)
        
        
        categories$
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
    
    fileprivate func resetEnv() {
        var environment = Environment()
        environment.major = ""
        environment.univ = ""
        environment.nickName = ""
        environment.password = ""
        environment.receiver = ""
    }
    
}

// MARK: - Actions
extension SideViewController {
    
    @IBAction func pressDismiss(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pressLogout(_ sender: UIButton) {
        dismiss(animated: false, completion: {
            self.resetEnv()
            GlobalUIManager.loadLoginVC()
        })
    }
}
