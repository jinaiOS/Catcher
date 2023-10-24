//
//  ProfilesetingViewController.swift
//  Catcher
//
//  Created by t2023-m0070 on 10/23/23.
//

import UIKit
import SnapKit
import SwiftUI

final class ProfilesettingViewController: UIViewController{
    let profilesetingView = ProfilesetingView()
    override func loadView() {
        super.loadView()
        view = profilesetingView
    }
    override func viewDidLoad() {
        view.backgroundColor = .systemBackground
    }
}
struct ProfilesetingViewControllerprview: PreviewProvider {
    static var previews: some View {
        ProfilesettingViewController().toPreview().edgesIgnoringSafeArea(.all)
    }
}
