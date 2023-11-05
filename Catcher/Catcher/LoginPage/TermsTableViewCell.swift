//
//  TermsTableViewCell.swift
//  Catcher
//
//  Created by 김지은 on 2023/11/05.
//

import UIKit

class TermsTableViewCell: UITableViewCell {

    /// 체크 버튼
    @IBOutlet weak var btnSelect: UIButton!
    /// title label
    @IBOutlet weak var lbTitle: UILabel!
    /// 약관 상세 버튼
    @IBOutlet weak var btnDetail: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
