//
//  CommonHeaderView.swift
//  Catcher
//
//  Created by 김지은 on 2023/10/29.
//

import UIKit

class CommonHeaderView: UIView {
    
    /** @brief Xib로 그려진 containerView */
    @IBOutlet weak var vContainer: UIView!
    /** @brief Header Title Label*/
    @IBOutlet weak var lblTitle: UILabel!
    /** 뒤로가기 버튼*/
    @IBOutlet weak var btnBack: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        Bundle.main.loadNibNamed("CommonHeaderView", owner: self, options: nil)
        vContainer.layer.frame = self.bounds
        self.addSubview(vContainer)
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
