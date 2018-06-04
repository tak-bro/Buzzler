//
//  ReCommentTableViewCell.swift
//  Buzzler
//
//  Created by 진형탁 on 02/06/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import UIKit
import Reusable

final class ReCommentTableViewCell: UITableViewCell, NibReusable  {

    @IBOutlet weak var vw_reCommentContainer: UIView!
    @IBOutlet weak var lbl_recomment: UILabel!
    
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
        self.lbl_recomment.preferredMaxLayoutWidth = bounds.width - 90
        vw_reCommentContainer.setCornerRadius(radius: 25)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
