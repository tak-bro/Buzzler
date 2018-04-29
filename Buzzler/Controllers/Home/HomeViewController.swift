// swiftlint:disable function_body_length

import UIKit
import SwiftWebVC
import EZSwiftExtensions
import Then
import SnapKit
import Reusable
import RxSwift
import RxCocoa
import Kingfisher
import NoticeBar
import SideMenu
import PullToRefresh
import RxDataSources
import SwiftyAttributes

final class HomeViewController: UIViewController {

    let tableView = UITableView().then {
        $0.register(cellType: HomeTableViewCell.self)
        $0.register(cellType: HomeImageTableViewCell.self)
    }

    let refreshControl = PullToRefresh()
    let homeVM = HomeViewModel()
    let dataSource = RxTableViewSectionedReloadDataSource<BuzzlerSection>()
    
    let header = StretchHeader()
    let router = HomeRouter()

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupHeaderView()
        configUI()
        configBinding()
        configNotification()
    }
}

extension HomeViewController {

    // MARK: - Private Method

    fileprivate func configUI() {
        
        // set tableView UI
        title = " "
        tableView.backgroundColor = Config.UI.themeColor
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        tableView.separatorStyle = .none
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.backgroundColor = Config.UI.themeColor
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        // set SideMenu UI
        SideMenuManager.menuWidth = view.frame.width * CGFloat(0.64)
    }
    
    fileprivate func configBinding() {
        // Input
        let inputStuff  = HomeViewModel.HomeInput()
        // Output
        let outputStuff = homeVM.transform(input: inputStuff)

        // DataBinding
        tableView.refreshControl?.rx.controlEvent(.allEvents)
            .flatMap({ inputStuff.category.asObservable() })
            .bind(to: outputStuff.refreshCommand)
            .addDisposableTo(rx.disposeBag)
        

        NotificationCenter.default.rx.notification(Notification.Name.category)
            .map({ (notification) -> Int in
                let indexPath = (notification.object as? IndexPath) ?? IndexPath(item: 0, section: 0)
                return indexPath.row
            })
            .bind(to: inputStuff.category)
            .addDisposableTo(rx.disposeBag)

        NotificationCenter.default.rx.notification(Notification.Name.category)
            .map({ (notification) -> Int in
                let indexPath = (notification.object as? IndexPath) ?? IndexPath(item: 0, section: 0)
                return indexPath.row
            })
            .observeOn(MainScheduler.asyncInstance)
            .do(onNext: { (_) in
                SideMenuManager.menuLeftNavigationController?.dismiss(animated: true, completion: {
                    DispatchQueue.main.async(execute: {
                        self.tableView.refreshControl?.beginRefreshing()
                    })
                })
            }, onError: nil, onCompleted: nil, onSubscribe: nil, onDispose: nil)
            .bind(to: outputStuff.refreshCommand)
            .addDisposableTo(rx.disposeBag)

        // Configure
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
                cell.lbl_title.text = item.title
                cell.lbl_content.text = item.content
                cell.lbl_time.text = item.createdAt.toString(format: "YYYY/MM/DD")
                cell.lbl_likeCount.text = String(item.likeCount)
                cell.lbl_author.text = "익명"
                
                defaultCell = cell
            }
            return defaultCell
        }

        outputStuff.section
            .drive(tableView.rx.items(dataSource: dataSource))
            .addDisposableTo(rx.disposeBag)

        tableView.rx.setDelegate(self)
            .addDisposableTo(rx.disposeBag)

        outputStuff.refreshTrigger
            .observeOn(MainScheduler.instance)
            .subscribe { [unowned self] (event) in
                self.tableView.refreshControl?.endRefreshing()
                switch event {
                case .error(_):
                    NoticeBar(title: "Network Disconnect!", defaultType: .error).show(duration: 2.0, completed: nil)
                    break
                case .next(_):
                    self.tableView.reloadData()
                    break
                default:
                    break
                }
            }
            .addDisposableTo(rx.disposeBag)
    }

    fileprivate func configNotification() {
        NotificationCenter.default.post(name: Notification.Name.category, object: IndexPath(row: 0, section: 0))
    }
}

extension HomeViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return HomeTableViewCell.height
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let postVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
        navigationController?.pushViewController(postVC, animated: true)
        
        // let webActivity = BrowserWebViewController(url: homeVM.itemURLs.value[indexPath.row])
        // navigationController?.pushViewController(webActivity, animated: true)
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
