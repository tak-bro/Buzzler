// swiftlint:disable function_body_length

import UIKit
import EZSwiftExtensions
import Then
import SnapKit
import Reusable
import RxSwift
import RxCocoa
import NoticeBar
import SideMenu
import RxDataSources
import SwiftyAttributes
import SVProgressHUD

final class HomeViewController: UIViewController {
   
    let disposeBag = DisposeBag()
    var viewModel = HomeViewModel()
    let dataSource = RxTableViewSectionedReloadDataSource<BuzzlerSection>()

    let header = StretchHeader()
    let tableView = UITableView().then {
        $0.register(cellType: HomeTableViewCell.self)
        $0.register(cellType: HomeImageTableViewCell.self)
    }
    
    var refreshControl : UIRefreshControl?
    var category: Int = 1

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set SideMenu UI
        SideMenuManager.menuWidth = view.frame.width * CGFloat(0.64)
        
        configureTableView()
        configBinding()
        setupHeaderView()
    }
}

extension HomeViewController: UITableViewDelegate {
    
    // MARK: - Private Method
    
    fileprivate func configureTableView() {
        
        // set tableView UI
        title = " "
        tableView.backgroundColor = Config.UI.themeColor
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        tableView.separatorStyle = .none
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        self.refreshControl = UIRefreshControl()
        if let refreshControl = self.refreshControl {
            refreshControl.backgroundColor = .clear
            refreshControl.tintColor = .lightGray
            if #available(iOS 10.0, *) {
                tableView.refreshControl = refreshControl
            } else {
                tableView.addSubview(refreshControl)
            }
        }
    }
    
    fileprivate func configBinding() {
        
        self.viewModel = HomeViewModel()
        self.viewModel.category(category: self.category)
        self.viewModel.inputs.refresh()

        dataSource.configureCell = { dataSource, tableView, indexPath, item in
            let defaultCell: UITableViewCell
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
                print("item.createat", item.createdAt)
                cell.lbl_title.text = item.title
                cell.lbl_content.text = item.content
                cell.lbl_time.text = item.createdAt.toString()
                cell.lbl_likeCount.text = String(item.likeCount)
                cell.lbl_author.text = "익명"
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
            .drive(self.tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        self.tableView.rx.itemSelected
            .map { (at: $0, animated: true) }
            .subscribe(onNext: tableView.deselectRow)
            .disposed(by: disposeBag)
        
        self.tableView.rx.itemSelected
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
            self.navigationController?.pushViewController(detailPostVC, animated: true)
        }).disposed(by: disposeBag)
    }
}

extension HomeViewController {
    
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
        
        // add first header label
        var firstHeaderLabel = HeaderLabel()
        firstHeaderLabel = HeaderLabel(frame: CGRect(x: header.frame.size.width / 2, y: header.frame.size.height / 2, width: 200, height: 30))
        firstHeaderLabel.text = "Seoul Univ."
        
        // add second header label
        var secondHeaderLabel = HeaderLabel()
        secondHeaderLabel = HeaderLabel(frame: CGRect(x: header.frame.size.width / 2, y: header.frame.size.height / 2, width: 200, height: 30))
        
        let peopleCnt = "1K".withAttributes([
            .textColor(Config.UI.fontColor),
            .font(.AvenirNext(type: .Book, size: 12))
            ])
        let staticPeople = "  peoples     ".withAttributes([
            .textColor(Config.UI.lightFontColor),
            .font(.AvenirNext(type: .Book, size: 12))
            ])
        let postCnt = "100K".withAttributes([
            .textColor(Config.UI.fontColor),
            .font(.AvenirNext(type: .Book, size: 12))
            ])
        let staticPost = "  posts".withAttributes([
            .textColor(Config.UI.lightFontColor),
            .font(.AvenirNext(type: .Book, size: 12))
            ])
        let finalString = peopleCnt + staticPeople + postCnt + staticPost
        secondHeaderLabel.attributedText = finalString
        
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
        
        tableView.tableHeaderView = header
    }
    
    // MARK: - ScrollView Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        header.updateScrollViewOffset(scrollView)
        
        // NavigationHeader alpha update
        let offset: CGFloat = scrollView.contentOffset.y
        if (offset > 50) {
            self.navigationController?.navigationBar.barTintColor = UIColor.white
            addShadowToNav()
            title = "Seoul Univ."
        } else {
            self.navigationController?.navigationBar.barTintColor = Config.UI.themeColor
            deleteShadow()
            title = " "
        }
    }
    
    func addShadowToNav() {
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 1.0
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.5
        self.navigationController?.navigationBar.layer.masksToBounds = false
    }
    
    func deleteShadow() {
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.clear.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 0.0
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.0
    }
}
