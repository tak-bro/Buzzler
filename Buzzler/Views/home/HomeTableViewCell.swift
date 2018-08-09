//
//  HomeTableViewCell.swift
//  Buzzler
//
//  Created by Tak on 2018/04/08.
//  Copyright © 2018年 Tak. All rights reserved.
//

import UIKit
import Reusable
import RxSwift

final class HomeTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet weak var btn_like: UIButton!
    @IBOutlet weak var btn_postAction: UIButton!
    @IBOutlet weak var lbl_content: UILabel!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_time: UILabel!
    @IBOutlet weak var lbl_likeCount: UILabel!
    @IBOutlet weak var lbl_commentCount: UILabel!
    @IBOutlet weak var lbl_remainTime: UILabel!
    @IBOutlet weak var lbl_author: UILabel!
    @IBOutlet weak var vw_container: UIView!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var vw_bottomContainer: UIView!
    
    var bag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = DisposeBag()
    }
    
    static let height: CGFloat = UITableViewAutomaticDimension

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
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
