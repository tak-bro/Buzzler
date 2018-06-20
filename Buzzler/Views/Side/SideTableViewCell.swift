//
//  SideTableViewCell.swift
//  Buzzler
//
//  Created by 진형탁 on 2018. 4. 29..
//  Copyright © 2018년 Maru. All rights reserved.
//

import UIKit
import Reusable

class SideTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet weak var vw_sideBox: UIView!
    @IBOutlet weak var lbl_category: UILabel!
    
    var id: Int!
    static let height: CGFloat = UITableViewAutomaticDimension
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // vw_commentContainer.setCornerRadius(radius: 25)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
