//
//  PushDemoApp.swift
//  PushDemo
//
//  Created by 김지훈 on 2024/02/16.
//

import SwiftUI
import Firebase
import FirebaseMessaging
import UserNotifications
import UIKit

@main
struct PushDemoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Firebase 초기화
        FirebaseApp.configure()
        
        // 푸시 알림을 위한 사용자 권한 요청
        requestNotificationAuthorization(application: application)
        
        // Messaging delegate 설정
        Messaging.messaging().delegate = self
        
        return true
    }
    
    func requestNotificationAuthorization(application: UIApplication) {
        // UserNotifications 프레임워크 사용
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in }
        application.registerForRemoteNotifications()
    }
    
    // APNs 토큰이 성공적으로 등록되었을 때 호출
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // APNs 토큰을 FCM에 설정
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // FCM 토큰 업데이트 수신
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // 필요한 경우 서버로 토큰 전송
    }
}
