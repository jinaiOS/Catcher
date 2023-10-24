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
    let profilesettingView = ProfilesettingView()
    override func loadView() {
        super.loadView()
        view = profilesettingView
    }
    override func viewDidLoad() {
        view.backgroundColor = .systemBackground
    }
}
struct ProfilesettingViewControllerprview: PreviewProvider {
    static var previews: some View {
        ProfilesettingViewController().toPreview().edgesIgnoringSafeArea(.all)
    }
}
