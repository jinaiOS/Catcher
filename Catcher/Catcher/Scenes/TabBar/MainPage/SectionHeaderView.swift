//
//  SectionHeaderView.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import UIKit
import SnapKit

final class SectionHeaderView: UICollectionReusableView {
    static let identifier = "SectionHeader"
    
    private lazy var sectionNameLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.bold(size: 20)
        label.textColor = .label
        label.sizeToFit()
        return label
    }()
    
    func configure(sectionTitle: String?) {
        sectionNameLabel.text = sectionTitle
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
            $0.leading.top.bottom.equalToSuperview().offset(10)
        }
    }
}
