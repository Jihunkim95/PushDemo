//
//  ContentView.swift
//  PushDemo
//
//  Created by 김지훈 on 2024/02/16.
//
import SwiftUI

struct ContentView: View {
    // 사용자 ID와 메시지 내용을 저장할 상태 변수
    @State private var userId: String = "사용자ID"
    @State private var message: String = "알림 메시지"
    
    var body: some View {
        VStack {
            TextField("사용자 ID", text: $userId)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("메시지", text: $message)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("보내기") {
                sendNotification(userId: userId, message: message)
            }
            .padding()
        }
    }
    
    func sendNotification(userId: String, message: String) {
        guard let url = URL(string: "http://192.168.0.16:3000/send-notification") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["userId": userId, "message": message]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending notification: \(error.localizedDescription)")
                return
            }
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("Notification sent successfully")
            } else {
                print("Failed to send notification")
            }
        }.resume()
    }
}
