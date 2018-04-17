//
//  HomeTableViewCell.swift
//  Buzzler
//
//  Created by Tak on 2018/04/08.
//  Copyright © 2018年 Tak. All rights reserved.
//

import UIKit
import Reusable

final class HomeTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet weak var gankTitle: UILabel!
    @IBOutlet weak var gankAuthor: UILabel!
    @IBOutlet weak var gankTime: UILabel!

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
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
