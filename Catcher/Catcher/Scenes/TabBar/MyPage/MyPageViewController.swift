//
//  MyPageViewController.swift
//  Catcher
//
//  Created by 정기현 on 2023/10/17.
//

import SnapKit
import UIKit

enum MenuItems: String, CaseIterable {
    case setProfile = "기본 프로필 설정"
    case inquiry = "1:1 문의"
    case report = "사용자 신고"
    case terms = "개인 정보 및 처리 방침"
    case opensource = "오픈소스 라이선스"
    case version = "앱 버전 v1.0"
    case withdraw = "회원 탈퇴"
}

class MyPageViewController: BaseViewController {
    private lazy var nickName: UILabel = {
        let lb = UILabel()
        lb.text = DataManager.sharedInstance.userInfo?.nickName ?? ""
        lb.font = .systemFont(ofSize: 20, weight: .light)
        lb.textAlignment = .center
        view.addSubview(lb)
        return lb
    }()

    private lazy var profilePhoto: UIImageView = {
        let im = UIImageView()
        ImageCacheManager.shared.loadImage(uid: DataManager.sharedInstance.userInfo?.uid ?? "") { [weak self] image in
            guard let self = self else { return }
            DispatchQueue.main.async {
                im.image = image
            }
        }
//        im.image = UIImage(named: "sample1")
        im.contentMode = .scaleToFill
        im.layer.cornerRadius = CGFloat(photoSize / 2) // 반지름을 이미지 크기의 절반으로 설정하여 원 모양으로 클리핑
        im.clipsToBounds = true // 이미지를 원 모양으로 클리핑
        view.addSubview(im)
        return im
    }()

    private lazy var myMainView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .white
        vw.layer.cornerRadius = 16
        vw.addSubview(myMainStack)
        vw.borderColor = ThemeColor.primary
        vw.borderWidth = 1
        view.addSubview(vw)
        return vw
    }()

    private lazy var myMainStack: UIStackView = {
        let st = UIStackView(arrangedSubviews: [myTemperatureStack, myPointStack, mySaveStack])
        st.axis = .horizontal
        st.alignment = .fill
        st.distribution = .fill
        st.spacing = spacingStackHorizontal

        return st
    }()

    private lazy var myTemperatureStack: UIStackView = {
        let st = UIStackView(arrangedSubviews: [myTemperatureNumber, myTemperatureLabel])
        st.axis = .vertical
        st.alignment = .fill
        st.distribution = .equalSpacing
        st.spacing = spacingStackVertical

        return st
    }()

    private lazy var myTemperatureNumber: UILabel = {
        let lb = UILabel()
        lb.text = "30°"
        lb.font = .systemFont(ofSize: 20, weight: .bold)
        lb.textAlignment = .center
        return lb
    }()

    private lazy var myTemperatureLabel: UILabel = {
        let lb = UILabel()
        lb.text = "내 온도"
        lb.font = .systemFont(ofSize: labelFontSize, weight: .light)
        lb.textAlignment = .center
        return lb
    }()

    private lazy var myPointStack: UIStackView = {
        let st = UIStackView(arrangedSubviews: [myPointNumber, myPointLabel])
        st.axis = .vertical
        st.alignment = .fill
        st.distribution = .equalSpacing
        st.spacing = spacingStackVertical

        return st
    }()

    private lazy var myPointNumber: UILabel = {
        let lb = UILabel()
        lb.text = "3000P"
        lb.font = .systemFont(ofSize: 20, weight: .bold)
        lb.textAlignment = .center
        return lb
    }()

    private lazy var myPointLabel: UILabel = {
        let lb = UILabel()
        lb.text = "마일리지"
        lb.font = .systemFont(ofSize: labelFontSize, weight: .light)
        lb.textAlignment = .center
        return lb
    }()

    private lazy var mySaveStack: UIStackView = {
        let st = UIStackView(arrangedSubviews: [mySaveNumber, mySaveLabel])
        st.axis = .vertical
        st.alignment = .fill
        st.distribution = .equalSpacing
        st.spacing = spacingStackVertical

        return st
    }()

    private lazy var mySaveNumber: UILabel = {
        let lb = UILabel()
        lb.text = "3"
        lb.font = .systemFont(ofSize: 20, weight: .bold)
        lb.textAlignment = .center
        return lb
    }()

    private lazy var mySaveLabel: UILabel = {
        let lb = UILabel()
        lb.text = "나의 찜"
        lb.font = .systemFont(ofSize: labelFontSize, weight: .light)
        lb.textAlignment = .center
        return lb
    }()

    let spacingStackVertical: CGFloat = 10
    let spacingStackHorizontal: CGFloat = 70
    let labelFontSize: CGFloat = 13
    let photoSize = 44
    var menuItems = MenuItems.setProfile
    var tableViewHeight: CGFloat = 0

    private lazy var myTableView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .white
        vw.layer.cornerRadius = 16
        vw.addSubview(menuLabel)
        vw.addSubview(myTable)
        vw.borderColor = ThemeColor.primary
        vw.borderWidth = 1
        view.addSubview(vw)
        return vw
    }()

    private lazy var menuLabel: UILabel = {
        let lb = UILabel()
        lb.text = "메뉴"
        lb.font = .systemFont(ofSize: 20, weight: .bold)
        lb.textAlignment = .left
        return lb
    }()

    private lazy var myTable: UITableView = {
        let tb = UITableView()
        tb.register(MenuTableViewCell.self, forCellReuseIdentifier: MenuTableViewCell.identifier)
        // 경계선 지우기
        tb.separatorStyle = .none
        //  스크롤 x
        tb.isScrollEnabled = false
        return tb
    }()

    private lazy var logOutButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("로그아웃", for: .normal)
        btn.layer.cornerRadius = 15
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = ThemeColor.primary
        view.addSubview(btn)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
        configure()
        logOutButton.addTarget(self, action: #selector(pressLogOutButton), for: .touchUpInside)
    }
}

extension MyPageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuItems.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let menuTableViewCell = tableView.dequeueReusableCell(withIdentifier: MenuTableViewCell.identifier, for: indexPath) as? MenuTableViewCell else {
            return UITableViewCell()
        }
        // 셀 선택시 색상 변경 x
        menuTableViewCell.selectionStyle = .none
        let menu = MenuItems.allCases[indexPath.row]
        menuTableViewCell.menuLabel.text = MenuItems.allCases[indexPath.row].rawValue
        return menuTableViewCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let vc = InfoViewController()
            self.navigationPushController(viewController: vc, animated: true)
        case 1:
            let vc = AskViewController()
            self.navigationPushController(viewController: vc, animated: true)
        case 2:
            let vc = ReportViewController()
            self.navigationPushController(viewController: vc, animated: true)
        case 3:
            break
        case 4:
            break
        case 5:
            break
        default:
            break
        }
    }
}

extension MyPageViewController {
    @objc func pressLogOutButton() {
        if let errorMessage = FirebaseManager().logOut {
            // 로그아웃 실패
            CommonUtil.print(output:"로그아웃 실패: \(errorMessage)")
        } else {
            // 로그아웃 성공
            CommonUtil.print(output:"로그아웃 성공")
            AppDelegate.applicationDelegate().changeInitViewController(type: .Login)
        }
    }
}

extension MyPageViewController {
    func configure() {
        // 메뉴 아이템의 갯수에 따라 view의 높이를 변경
        tableViewHeight = CGFloat(MenuItems.allCases.count) * 44 + 70
        myTable.dataSource = self
        myTable.delegate = self
        nickName.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(30)
            make.leading.equalTo(view.snp.leading).inset(27)
            make.height.equalTo(24)
        }
        profilePhoto.snp.makeConstraints { make in
            make.centerY.equalTo(nickName.snp.centerY)
            make.trailing.equalTo(view.snp.trailing).inset(40)
            make.height.width.equalTo(photoSize)
        }

        myMainView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self.view).inset(14)
            make.top.equalTo(nickName.snp.bottom).inset(-50)
            make.height.equalTo(100)
        }
        myMainStack.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(self.myMainView)
            make.height.equalTo(50
            )
        }
        menuLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.myTable)
            make.top.equalTo(self.myTableView).inset(20)
            make.height.equalTo(30)
        }
        myTable.snp.makeConstraints { make in
            make.bottom.equalTo(self.myTableView).inset(20)
            make.top.equalTo(self.menuLabel).inset(30)
            make.leading.equalTo(myTableView.snp_leadingMargin).inset(20)
            make.trailing.equalTo(self.myTableView).inset(20)
        }
        myTableView.snp.makeConstraints { make in
            make.top.equalTo(myMainView.snp.bottom).inset(-20)
            make.leading.trailing.equalTo(self.view).inset(14)
            make.height.equalTo(tableViewHeight)
        }
        logOutButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.bottom).inset(100)
            make.leading.trailing.equalTo(self.view).inset(14)
            make.height.equalTo(53)
        }
    }
}
