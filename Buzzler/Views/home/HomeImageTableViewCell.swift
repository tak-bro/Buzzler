//
//  HomeImageTableViewCell.swift
//  Buzzler
//
//  Created by 진형탁 on 2018. 4. 22..
//  Copyright © 2018년 Maru. All rights reserved.
//

import UIKit
import Reusable
import RxSwift

final class HomeImageTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet weak var vw_imgContainer: UIView!
    @IBOutlet weak var img_items: UIImageView!
    @IBOutlet weak var btn_like: UIButton!
    @IBOutlet weak var btn_postAction: UIButton!
    @IBOutlet weak var lbl_content: UILabel!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_time: UILabel!
    @IBOutlet weak var lbl_likeCount: UILabel!
    @IBOutlet weak var lbl_commentCount: UILabel!
    @IBOutlet weak var lbl_remainTime: UILabel!
    @IBOutlet weak var lbl_author: UILabel!
    @IBOutlet weak var lbl_remainImgCnt: UILabel!
    @IBOutlet weak var vw_remainLabelContainer: UIView!
    @IBOutlet weak var vw_container: UIView!
    
    static let height: CGFloat = UITableViewAutomaticDimension

    var bag = DisposeBag()
    let subject = PublishSubject<Void>()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = DisposeBag()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        vw_container.dropShadow(width: 1, height: 1)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
