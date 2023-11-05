//
//  SectionHeaderView.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import SnapKit
import UIKit

final class SectionHeaderView: UICollectionReusableView {
    static let identifier = "SectionHeaderView"
    
    private lazy var sectionNameLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.bold(size: 20)
        label.textColor = .label
        label.sizeToFit()
        return label
    }()
    
    func configure(sectionTitle: String?, isTitle: Bool = false) {
        sectionNameLabel.text = sectionTitle
        if isTitle {
            sectionNameLabel.font = UIFont(name: "Futura-bold", size: 35)
            sectionNameLabel.textColor = ThemeColor.primary
        } else {
            sectionNameLabel.font = ThemeFont.bold(size: 20)
            sectionNameLabel.textColor = .label
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension SectionHeaderView {
    func setLayout() {
        addSubview(sectionNameLabel)
        
        sectionNameLabel.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview().offset(15)
        }
    }
}
