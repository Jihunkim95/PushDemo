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
        guard let fcmToken = fcmToken else { return }
        print("Firebase registration token: \(fcmToken)")
        sendTokenToServer(token: fcmToken)
    }
    
    //Test용 포그라운드에서도 알림 볼 수 있는 로직
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // 앱이 포그라운드에 있을 때 알림 메시지와 함께 배너를 표시하도록 설정
        completionHandler([.banner, .sound, .badge])
    }
    func sendTokenToServer(token: String) {
        guard let url = URL(string: "http://192.168.0.16:3000/register-token") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["token": token]
        guard let finalBody = try? JSONSerialization.data(withJSONObject: body) else { return }
        
        request.httpBody = finalBody
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending token to server: \(error.localizedDescription)")
                return
            }
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("Successfully sent token to server")
            } else {
                print("Failed to send token with response: \(String(describing: response))")
            }
        }.resume()
    }
}
