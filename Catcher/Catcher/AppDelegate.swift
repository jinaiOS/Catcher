//
//  AppDelegate.swift
//  Catcher
//
//  Created by 김지은 on 2023/10/12.
//

import Firebase
import FirebaseMessaging
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    /**
     @brief  navigationBarController 객체
     */
    var navigationController: UINavigationController?

    /**
     @brief  tabBarController 객체
     */
    var tabBarController: BaseTabBarController?

    /**
     @enum StartType

     @brief  화면시작 지점 구분 enum
     */
    enum StartType: String {
        case Main
        case Login
    }

    let keyWindow = UIApplication.shared.connectedScenes
        .filter { $0.activationState == .foregroundActive }
        .compactMap { $0 as? UIWindowScene }
        .first?.windows
        .filter { $0.isKeyWindow }.first

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        setFirebasePush()
        clearPushNotificationCenter()
        let introVC = IntroViewController(nibName: "IntroViewController", bundle: nil)
        navigationController = UINavigationController(rootViewController: introVC)
        // 네비게이션바 히든
        navigationController?.isNavigationBarHidden = true
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        return true
    }
    
    //MARK: - APNS
    func setFirebasePush() {
        UNUserNotificationCenter.current().delegate = self
        
        //set push receive type
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        //push requestAuthorization
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {(granted, error) in
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        })
    }
    
    /**
     @brief navigationController의 쌓여있는 스택을 리턴
     */
    static func navigationViewControllers() -> [UIViewController] {
        return AppDelegate.applicationDelegate().navigationController!.viewControllers
    }

    /**
     @brief Appdelegate의 객체를 리턴
     */
    static var realDelegate: AppDelegate?
    static func applicationDelegate() -> AppDelegate {
        if Thread.isMainThread {
            return UIApplication.shared.delegate as! AppDelegate
        }
        let dg = DispatchGroup()
        dg.enter()
        DispatchQueue.main.async {
            realDelegate = UIApplication.shared.delegate as? AppDelegate
            dg.leave()
        }
        dg.wait()
        return realDelegate!
    }

    /**
     @brief 최상위ViewController의 객체를 리턴
     */
    static func applicationTopViewController() -> UIViewController? {
        return UIApplication.topViewController()
    }

    /**
     @brief storyBoard를 변경한다.
     */
    func changeInitViewController(type: StartType) {
        DataManager.sharedInstance.modalViewControllerList = nil
        tabBarController = nil
        if type == .Login {
            navigationController = UINavigationController(rootViewController: LoginViewController())
        } else {
            let storyBoard = UIStoryboard(name: type.rawValue, bundle: nil)
            self.navigationController = nil
            tabBarController = nil
            let navigationController: UINavigationController?
            navigationController = storyBoard.instantiateInitialViewController() as? UINavigationController
            if navigationController?.topViewController is UITabBarController {
                tabBarController = navigationController!.topViewController as? BaseTabBarController
            }
            self.navigationController = navigationController
        }

        // 네비게이션바 히든
        navigationController?.isNavigationBarHidden = true
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
            AppDelegate.applicationDelegate().window?.rootViewController?.view.alpha = 0
        }) { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            DispatchQueue.main.async {
                strongSelf.window?.rootViewController = strongSelf.navigationController
                strongSelf.window?.rootViewController?.view.alpha = 0
                UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
                    AppDelegate.applicationDelegate().window?.rootViewController?.view.alpha = 1
                }, completion: { _ in
                })
            }
        }
    }
    
    /**
     @brief push notification의 badgeNumber를 초기화한다.
     */
    func clearPushNotificationCenter() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {
    /*
     @brief 최초 앱 시작 시 및 토큰이 업데이트/무효화될 때마다 신규 또는 기존 토큰을 알려주는 FCM delegate
     */
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        //        CommonUtil.showOneButtonAlertWithTitle(title: "", message: fcmToken, okButton: "ok", okHandler: nil)

        guard fcmToken != nil else {
            return
        }

        CommonUtil.print(output: "DeviceToken : \(fcmToken!)")
        // NSLog("DeviceToken : %@", fcmToken)

        // 기존 저장한 token값과 다르면
        if UserDefaultsManager().getValue(forKey: Userdefault_Key.PUSH_KEY) != fcmToken {
            UserDefaultsManager().setValue(value: fcmToken, key: Userdefault_Key.PUSH_KEY)
        }
    }

    /**
     @brief APNS를 통해 들어오는 pushData가 아닌 FCM을 통해 들어오는 push Message
     */
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingDelegate) {
        CommonUtil.print(output: "remoteMessage : \(remoteMessage)")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        clearPushNotificationCenter()
        completionHandler([.sound])
        
        if let payloadData = notification.request.content.userInfo as? Dictionary<String, Any>
        {
            CommonUtil.print(output: "payloadData: \(payloadData)")
            let otherUserUid = payloadData["otherUserUid"] as? String ?? ""
            let viewController = ChattingDetailViewController(otherUid: otherUserUid)
            viewController.title = notification.request.content.title
            viewController.headerTitle = notification.request.content.title
            AppDelegate.applicationDelegate().navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    // 백그라운드에서 action을 눌렀을때
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
        clearPushNotificationCenter()

        guard let payloadData = response.notification.request.content.userInfo as? [String: Any] else {
            CommonUtil.print(output: "Invalid payload data")
            return
        }

        CommonUtil.print(output: "payloadData: \(payloadData)")

        // Check if the app is active
        let isActive = !(AppDelegate.applicationDelegate().navigationController?.viewControllers.contains { $0 is MainPageViewController } ?? true)

        if isActive {
            // Handle the payload data based on your requirements
            let otherUserUid = payloadData["otherUserUid"] as? String ?? ""
            let viewController = ChattingDetailViewController(otherUid: otherUserUid)
            viewController.title = response.notification.request.content.title
            viewController.headerTitle = response.notification.request.content.title
            AppDelegate.applicationDelegate().navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = AppDelegate.realDelegate?.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
