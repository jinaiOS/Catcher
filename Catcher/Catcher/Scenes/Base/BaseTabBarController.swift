//
//  BaseTabBarController.swift
//  Catcher
//
//  Created by 김지은 on 2023/10/13.
//

import UIKit

class BaseTabBarController: UITabBarController {

    enum TabBarMenu: Int {
        case Main = 0 // 메인
        case Chat // 채팅
        case My // 내 정보
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setTabControllers()
        self.delegate = self
        // Do any additional setup after loading the view.
    }
    
    /**
     @brief TabBarController의 item 이미지 및 컬러 설정
     */
    func setTabControllers() {
        let mainVC = MainPageViewController()
        let chatVC = ChatViewController()
        let myVC = MyPageViewController()
        
        // init tabbar controller
        let controllers = [mainVC, chatVC, myVC]
        self.viewControllers = controllers
        
        self.tabBar.backgroundColor = .white
        self.tabBar.borderWidth = 1
        self.tabBar.borderColor = #colorLiteral(red: 0.9176470588, green: 0.9176470588, blue: 0.9176470588, alpha: 1)
        
        // main
        self.tabBar.items![0].imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        self.tabBar.items![0].image = UIImage(systemName: "heart")?.withRenderingMode(.alwaysOriginal).withTintColor(.black)
        self.tabBar.items![0].selectedImage = UIImage(systemName: "heart.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.black)
        self.tabBar.items![0].title = "Main"
        
        
        // Chat
        self.tabBar.items![1].imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        self.tabBar.items![1].image = UIImage(systemName: "bubble.left")?.withRenderingMode(.alwaysOriginal)
        self.tabBar.items![1].selectedImage = UIImage(systemName: "bubble.left.fill")?.withRenderingMode(.alwaysOriginal)
        self.tabBar.items![1].title = "Chat"
        
        // my
        self.tabBar.items![2].imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        self.tabBar.items![2].image = UIImage(systemName: "person.2")?.withRenderingMode(.alwaysOriginal)
        self.tabBar.items![2].selectedImage = UIImage(systemName: "person.2.fill")?.withRenderingMode(.alwaysOriginal)
        self.tabBar.items![2].title = "My"
        
        // iOS13이상에서 탭바의 타이틀 컬러가 적용안되는 이슈 해결 modify by subway 20191024
        if #available(iOS 13, *) {
            let appearance = UITabBarAppearance()

            appearance.backgroundColor = .white
            appearance.shadowImage = UIImage()
            appearance.shadowColor = .white

            appearance.stackedLayoutAppearance.normal.iconColor = .black
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.5333333333, green: 0.5333333333, blue: 0.5333333333, alpha: 1),
//              NSAttributedString.Key.font: UIFont(name: "AppleSDGothicNeo-Medium", size: 12)!
            ]

            appearance.stackedLayoutAppearance.selected.iconColor = .black
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.5333333333, green: 0.5333333333, blue: 0.5333333333, alpha: 1),
//              NSAttributedString.Key.font: UIFont(name: "AppleSDGothicNeo-Medium", size: 12)!
            ]

            self.tabBar.standardAppearance = appearance

        } else {
            // init tabbar item textColor
            UITabBarItem.appearance().setTitleTextAttributes([
                NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.5333333333, green: 0.5333333333, blue: 0.5333333333, alpha: 1),
                NSAttributedString.Key.font: UIFont(name: "AppleSDGothicNeo-Medium", size: 12)!,
            ], for: .normal)
                 
            UITabBarItem.appearance().setTitleTextAttributes([
                NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.231372549, green: 0.3568627451, blue: 0.8509803922, alpha: 1),
                NSAttributedString.Key.font: UIFont(name: "AppleSDGothicNeo-Medium", size: 12)!,
            ], for: .selected)
        }
    }
    
    /**
     @brief TabBarController에서 입력받은 index로 이동
     
     @param TabBarController에서 이동하고자 하는 index
     */
    func moveToTabBarIndex(index: TabBarMenu) {
        AppDelegate.applicationDelegate().tabBarController!.selectedIndex = index.rawValue
    }
    
    /**
     @brief TabBarController에 현재 선택되어진 index를 리턴
     */
    func selectedTabBarIndex() -> TabBarMenu {
        return TabBarMenu(rawValue: AppDelegate.applicationDelegate().tabBarController!.selectedIndex) ?? TabBarMenu.Main
    }
    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
}

extension BaseTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        if tabBarIndex == 0 {
            // do your stuff
        }
        print("tabBarIndex : \(tabBarIndex)")
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let currentIndex = tabBarController.selectedIndex
        print("currentIndex : \(currentIndex)")
        guard let fromView = selectedViewController?.view, let toView = viewController.view else {
            return false // Make sure you want this as false
        }

        if fromView != toView {
            UIView.transition(from: fromView, to: toView, duration: 0.3, options: [.transitionCrossDissolve], completion: nil)
        }

        return true
    }

}
