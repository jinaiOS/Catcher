//
//  MenuTableViewCell.swift
//  Catcher
//
//  Created by 정기현 on 2023/10/17.
//

import UIKit

class MenuTableViewCell: UITableViewCell {
    static let identifier = "MenuTableViewCell"
    lazy var menuLabel: UILabel = {
        let lb = UILabel()
        lb.text = "연락처차단"
        lb.font = .systemFont(ofSize: 16, weight: .light)
        contentView.addSubview(lb)
        return lb

    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure() {
        menuLabel.snp.makeConstraints { make in
            make.leading.centerY.equalTo(self.contentView)
        }
    }
}
