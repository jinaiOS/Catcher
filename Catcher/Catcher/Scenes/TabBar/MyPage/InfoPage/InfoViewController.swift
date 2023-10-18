//
//  InfoViewController.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import UIKit
import SwiftUI

final class InfoViewController: UIViewController {
    private let infoView = InfoView()
    
    init(title: String) {
        super.init(nibName: nil, bundle: nil)
        configure(title: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        view = infoView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

private extension InfoViewController {
    func configure(title: String) {
        let titleLabel = UILabel()
        titleLabel.attributedText = NSAttributedString.makeNavigationTitle(title: title)
        navigationItem.titleView = titleLabel
    }
}

struct InfoViewControllerPreView: PreviewProvider {
    static var previews: some View {
        InfoViewController(title: "기본 프로필").toPreview().edgesIgnoringSafeArea(.all)
    }
}
