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
    
    private lazy var profileView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = AppConstraint.defaultCornerRadius
        view.clipsToBounds = true
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    private lazy var userLabel: UILabel = {
        LabelFactory.makeLabel(
            text: nil,
            font: ThemeFont.bold(size: 16),
            textAlignment: .left)
    }()
    
    private lazy var attractionLabel: UILabel = {
        LabelFactory.makeLabel(
            text: nil,
            font: ThemeFont.regular(size: 13),
            textColor: .darkGray,
            textAlignment: .left)
    }()
    
    private lazy var infoVStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        
        [userLabel, attractionLabel].forEach {
            view.addArrangedSubview($0)
        }
        return view
    }()
    
    private lazy var introductionLabel: UILabel = {
        LabelFactory.makeLabel(
            text: nil,
            font: ThemeFont.regular(size: 13),
            textColor: .darkGray,
            textAlignment: .left)
    }()
    
    private lazy var vStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .fill
        view.distribution = .fillProportionally
        view.spacing = 6
        
        [infoVStack, introductionLabel].forEach {
            view.addArrangedSubview($0)
        }
        return view
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
        ImageCacheManager.shared.loadImage(uid: data.uid) { [weak self] image in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.profileView.backgroundColor = .clear
                self.profileView.image = image
            }
        }
        userLabel.text = "\(index + 1)위  \(data.nickName)"
        attractionLabel.text = "받은 찜 \(data.heart)개"
        introductionLabel.text = "유저의 소개 한 마디"
    }
}

private extension RankSectionCell {
    func setUI() {
        contentView.layer.cornerRadius = AppConstraint.defaultCornerRadius
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.layer.borderWidth = 1
    }
    
    func setLayout() {
        [profileView, vStack].forEach {
            contentView.addSubview($0)
        }
        
        profileView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(profileView.snp.width)
        }
        
        vStack.snp.makeConstraints {
            $0.top.equalTo(profileView.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.bottom.equalToSuperview().inset(5)
        }
    }
}
