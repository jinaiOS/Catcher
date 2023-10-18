//
//  CommonHeaderView.swift
//  Catcher
//
//  Created by 김지은 on 2023/10/13.
//

import UIKit

class CommonHeaderView: UIView {

    /** @brief Xib로 그려진 containerView */
    @IBOutlet weak var containerView: UIView!
    /** @brief Header Title Label*/
    @IBOutlet weak var titleLabel: UILabel!
    /** @brief  뒤로가기 버튼*/
    @IBOutlet weak var backButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        Bundle.main.loadNibNamed("CommonHeaderView", owner: self, options: nil)
        containerView.layer.frame = self.bounds
        self.addSubview(containerView)
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
