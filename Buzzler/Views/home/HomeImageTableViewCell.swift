//
//  HomeImageTableViewCell.swift
//  Buzzler
//
//  Created by 진형탁 on 2018. 4. 22..
//  Copyright © 2018년 Maru. All rights reserved.
//

import UIKit
import Reusable

final class HomeImageTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet weak var lbl_content: UILabel!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_time: UILabel!
    @IBOutlet weak var lbl_likeCount: UILabel!
    @IBOutlet weak var lbl_commentCount: UILabel!
    @IBOutlet weak var lbl_remainTime: UILabel!
    @IBOutlet weak var lbl_author: UILabel!
    
    static let height: CGFloat = UITableViewAutomaticDimension
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
