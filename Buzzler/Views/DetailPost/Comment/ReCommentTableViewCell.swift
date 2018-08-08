//
//  ReCommentTableViewCell.swift
//  Buzzler
//
//  Created by 진형탁 on 02/06/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import UIKit
import RxSwift
import Reusable

final class ReCommentTableViewCell: UITableViewCell, NibReusable  {

    @IBOutlet weak var vw_shadow: UIView!
    @IBOutlet weak var vw_reCommentContainer: UIView!
    @IBOutlet weak var lbl_recomment: UILabel!
    @IBOutlet weak var lbl_author: UILabel!
    @IBOutlet weak var lbl_createdAt: UILabel!
    @IBOutlet weak var btn_like: UIButton!
    
    var bag = DisposeBag()
    static let height: CGFloat = UITableViewAutomaticDimension
    
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
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        vw_reCommentContainer.setCornerRadius(radius: 25)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
