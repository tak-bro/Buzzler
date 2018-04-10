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

final class HomeViewController: UIViewController {

    let tableView = UITableView().then {
        $0.register(cellType: HomeTableViewCell.self)
    }

    let refreshControl = PullToRefresh()

    let homeVM = HomeViewModel()

    let dataSource = RxTableViewSectionedReloadDataSource<HomeSection>()

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configBinding()
        configNotification()
    }
}

extension HomeViewController {

    // MARK: - Private Method

    fileprivate func configUI() {
        
        // set tableView UI
        title = "Buzzler"
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
        SideMenuManager.menuShadowOpacity = 0
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
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: HomeTableViewCell.self)
            cell.gankTitle?.text = item.desc
            cell.gankAuthor.text = item.who
            cell.gankTime.text = item.publishedAt.toString(format: "YYYY/MM/DD")
            
            // set shadow
            let layer = cell.layer
            layer.shadowOffset = CGSize(width: 1, height: 1)
            layer.shadowRadius = 5
            layer.shadowColor = UIColor.lightGray.cgColor
            layer.shadowOpacity = 0.5
            layer.frame = cell.frame
        
            return cell
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

extension HomeViewController {

    // MARK: - Private Methpd

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension HomeViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return HomeTableViewCell.height
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let webActivity = BrowserWebViewController(url: homeVM.itemURLs.value[indexPath.row])
        navigationController?.pushViewController(webActivity, animated: true)
    }
}
