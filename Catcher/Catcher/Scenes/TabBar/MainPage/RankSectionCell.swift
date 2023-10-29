//
//  RankSectionCell.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import UIKit
import SnapKit

final class RankSectionCell: UICollectionViewCell {
    static let identifier = "RankSectionCell"
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = AppConstraint.mainCellCornerRadius
        view.clipsToBounds = true
        view.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        return view
    }()
    
    private lazy var rankLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.bold(size: 60)
        label.textColor = ThemeColor.sectionLabel
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RankSectionCell {
    func configure(data: UserInfo, index: Int) {
        rankLabel.text = "\(index + 1)"
        ImageCacheManager.shared.loadImage(uid: data.uid) { [weak self] image in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.imageView.backgroundColor = .clear
                self.imageView.image = image
            }
        }
    }
}

private extension RankSectionCell {
    func setUI() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 6
        layer.shadowOpacity = 0.5
        layer.masksToBounds = false
    }
    
    func setLayout() {
        [imageView, rankLabel].forEach {
            self.addSubview($0)
        }
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        rankLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(-10)
            $0.bottom.equalToSuperview().offset(22)
        }
    }
    
    func getTextSize(text: String, font: UIFont) -> (CGFloat, CGFloat) {
        let label = UILabel()
        label.font = font
        label.text = text
        label.sizeToFit()
        return (label.frame.width, label.frame.height)
    }
}
